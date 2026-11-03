#' The score, event by event
#'
#' @param pbp Play-by-play in the ggbasket layout (see [pbp]), one or more
#'   games.
#' @return A tibble with one row per scoring event (plus each game's start
#'   and end): `game_id`, `hometeam`, `awayteam`, `period`, `totalTime`,
#'   `team`, `points`, `home_score`, `away_score` and `margin` (home minus
#'   away).
#' @export
game_flow <- function(pbp) {
  d <- as.data.frame(pbp)
  sc <- d$result == "made" & !is.na(d$points) & d$points > 0
  ends <- !duplicated(d$game_id) | !duplicated(d$game_id, fromLast = TRUE)
  f <- d[sc | ends, c("league", "game_id", "hometeam", "awayteam", "period", "totalTime", "team", "points",
                      "home_score", "away_score", "player")]
  f$points[!sc[sc | ends]] <- 0
  first <- !duplicated(f$game_id)
  f$home_score[first & f$points == 0] <- 0; f$away_score[first & f$points == 0] <- 0
  f$margin <- f$home_score - f$away_score
  tibble::as_tibble(f)
}

#' Scoring runs
#'
#' Stretches in which one team scores at least `min_points` while the other
#' scores at most `allow` points.
#'
#' @inheritParams game_flow
#' @param min_points Smallest run reported.
#' @param allow Points the other team may score during a run (0 = unanswered).
#' @return A tibble: `game_id`, `team`, `points`, `against`, `start`,
#'   `end` (seconds of game time), `margin_before`, `margin_after` (home
#'   minus away), `label` (e.g. `"14-0 OKC"`).
#' @export
scoring_runs <- function(pbp, min_points = 8, allow = 0) {
  f <- game_flow(pbp)
  f <- f[f$points > 0, ]
  out <- lapply(split(f, f$game_id), function(g) {
    res <- list()
    n <- nrow(g); i <- 1
    while (i <= n) {
      tm <- g$team[i]; j <- i; own <- 0; opp <- 0; best <- NULL
      while (j <= n) {
        if (g$team[j] == tm) own <- own + g$points[j] else opp <- opp + g$points[j]
        if (opp > allow) break
        if (g$team[j] == tm && own >= min_points) best <- list(j = j, own = own, opp = opp)
        j <- j + 1
      }
      if (!is.null(best)) {
        k <- best$j
        mb <- if (i > 1) g$margin[i - 1] else 0
        res[[length(res) + 1]] <- tibble::tibble(
          game_id = g$game_id[1], team = tm, points = best$own, against = best$opp,
          start = if (i > 1) g$totalTime[i - 1] else 0, end = g$totalTime[k],
          margin_before = mb, margin_after = g$margin[k],
          label = sprintf("%d-%d %s", best$own, best$opp, tm))
        i <- k + 1
      } else i <- i + 1
    }
    dplyr::bind_rows(res)
  })
  out <- dplyr::bind_rows(out)
  if (!nrow(out)) {
    out <- tibble::tibble(game_id = character(), team = character(), points = numeric(), against = numeric(),
                          start = numeric(), end = numeric(), margin_before = numeric(),
                          margin_after = numeric(), label = character())
  }
  out
}

#' Win probability through a game
#'
#' A Brownian-motion model of the score (Stern, 1994): the home margin
#' drifts by `mu` points per game with standard deviation `sigma`, so with a
#' lead `m` and a share `r` of regulation left, P(home wins) =
#' \eqn{\Phi((m + \mu r) / (\sigma \sqrt{r}))}. It needs only two numbers per
#' league, both estimated from final margins by [fit_win_probability()];
#' defaults are the 2024/25 regular seasons. An expected margin per game (a
#' betting line, or the difference in net ratings plus home court) can
#' replace `mu`.
#'
#' @inheritParams game_flow
#' @param params Output of [fit_win_probability()]: `league`, `mu`, `sigma`.
#' @param expected Optional named vector of expected home margins, by
#'   `game_id`.
#' @return The play-by-play with `margin`, `time_left` (share of regulation),
#'   `wp` (home win probability after the event) and `wp_change`.
#' @export
win_probability <- function(pbp, params = NULL, expected = NULL) {
  d <- as.data.frame(pbp)
  params <- params %||% wp_default
  m <- match(d$league, params$league)
  if (anyNA(m)) m[is.na(m)] <- 1
  mu <- params$mu[m]; sigma <- params$sigma[m]
  if (!is.null(expected)) {
    e <- expected[as.character(d$game_id)]
    mu[!is.na(e)] <- e[!is.na(e)]
  }
  reg <- reg_seconds(d)
  d$margin <- d$home_score - d$away_score
  d$time_left <- pmax(0, (reg - d$totalTime)) / reg
  ot <- d$period > 4
  if (any(ot)) {
    otlen <- 300
    end_ot <- reg + (d$period - 4) * otlen
    d$time_left[ot] <- pmax(0, end_ot[ot] - d$totalTime[ot]) / reg[ot]
  }
  p <- stern_wp(d$margin, d$time_left, mu, sigma, reg)
  # the last row of a game is final
  last <- !duplicated(d$game_id, fromLast = TRUE)
  p[last] <- ifelse(d$margin[last] > 0, 1, ifelse(d$margin[last] < 0, 0, 0.5))
  d$wp <- p
  d$wp_change <- stats::ave(d$wp, d$game_id, FUN = function(w) c(w[1] - stats::pnorm(0), diff(w)))
  first <- !duplicated(d$game_id)
  d$wp_change[first] <- 0
  tibble::as_tibble(d)
}

#' @rdname win_probability
#' @details `fit_win_probability()` takes `mu` as the mean home margin at the
#'   end of regulation and chooses `sigma` by maximum likelihood on every
#'   in-game state (score, time left, final result), which calibrates the
#'   model to how often leads are actually lost. A floor of 15 seconds on
#'   the time left stands in for the possession that is still to come, so a
#'   three-point deficit with a second left is unlikely but not impossible.
#' @export
fit_win_probability <- function(pbp) {
  d <- as.data.frame(pbp)
  reg <- reg_seconds(d)
  d$margin <- d$home_score - d$away_score
  d$time_left <- pmax(0, reg - d$totalTime) / reg
  fin <- d[!duplicated(d$game_id, fromLast = TRUE), c("game_id", "margin")]
  d$home_won <- fin$margin[match(d$game_id, fin$game_id)] > 0
  d <- d[d$totalTime < reg & !is.na(d$home_won) & fin$margin[match(d$game_id, fin$game_id)] != 0, ]
  end_reg <- d[!duplicated(d$game_id, fromLast = TRUE), ]
  lapply(split(d, d$league), function(x) {
    e <- end_reg[end_reg$league == x$league[1], ]
    mu <- mean(e$margin)
    rg <- reg_seconds(x[1, ])
    nll <- function(s) {
      p <- pmin(pmax(stern_wp(x$margin, x$time_left, mu, s, rg), 1e-6), 1 - 1e-6)
      -sum(ifelse(x$home_won, log(p), log(1 - p)))
    }
    s <- stats::optimize(nll, c(5, 40))$minimum
    p <- stern_wp(x$margin, x$time_left, mu, s, rg)
    tibble::tibble(league = x$league[1], mu = mu, sigma = s, sigma_final = stats::sd(e$margin),
                   brier = mean((p - x$home_won)^2), games = nrow(e))
  }) |> dplyr::bind_rows()
}

stern_wp <- function(margin, r, mu, sigma, reg) {
  r <- r + 15 / reg
  stats::pnorm((margin + mu * r) / (sigma * sqrt(r)))
}

reg_seconds <- function(d) {
  ifelse(toupper(d$league) == "NBA" | is.na(d$league), 48 * 60, 40 * 60)
}

#' One line per game: what kind of game was it?
#'
#' @inheritParams game_flow
#' @param params Win-probability parameters, see [win_probability()].
#' @return A tibble per game: teams and final score, `lead_changes`, `ties`,
#'   `home_max_lead`, `away_max_lead`, `best_run` (label), `excitement`
#'   (total win-probability movement: how much the game swung),
#'   `comeback` (the winner's lowest win probability), `overtime`.
#' @export
game_summary <- function(pbp, params = NULL) {
  wp <- win_probability(pbp, params)
  f <- game_flow(pbp)
  runs <- scoring_runs(pbp, min_points = 1)
  best <- runs |> dplyr::group_by(.data$game_id) |> dplyr::slice_max(.data$points, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()
  sg <- f |>
    dplyr::group_by(.data$game_id) |>
    dplyr::summarise(league = .data$league[1], hometeam = .data$hometeam[1], awayteam = .data$awayteam[1],
                     home_pts = dplyr::last(.data$home_score), away_pts = dplyr::last(.data$away_score),
                     lead_changes = sum(abs(diff(sign(.data$margin[.data$margin != 0]))) == 2),
                     ties = sum(.data$margin[-1] == 0 & .data$points[-1] > 0),
                     home_max_lead = max(0, .data$margin), away_max_lead = max(0, -.data$margin),
                     overtime = max(.data$period) > 4, .groups = "drop")
  ex <- wp |>
    dplyr::group_by(.data$game_id) |>
    dplyr::summarise(excitement = sum(abs(.data$wp_change)),
                     home_won = dplyr::last(.data$margin) > 0,
                     comeback = ifelse(.data$home_won[1], min(.data$wp), min(1 - .data$wp)), .groups = "drop")
  sg |>
    dplyr::left_join(ex, by = "game_id") |>
    dplyr::left_join(dplyr::select(best, "game_id", best_run = "label"), by = "game_id") |>
    dplyr::mutate(winner = ifelse(.data$home_won, .data$hometeam, .data$awayteam),
                  score = sprintf("%s %d-%d %s", .data$hometeam, .data$home_pts, .data$away_pts, .data$awayteam)) |>
    dplyr::select(-"home_won")
}

#' Keep only clutch time
#'
#' Events in the last `minutes` of the fourth quarter or overtime with the
#' score within `margin` points (the NBA's definition: last 5 minutes, within
#' 5). Feed the result to [box_score()] or [on_off()].
#'
#' @inheritParams game_flow
#' @param minutes,margin Window and score difference.
#' @export
clutch_time <- function(pbp, minutes = 5, margin = 5) {
  d <- as.data.frame(pbp)
  per_len <- ifelse(d$period <= 4, ifelse(toupper(d$league) == "NBA", 720, 600), 300)
  left <- per_len - d$periodTime
  before <- stats::ave(d$home_score - d$away_score, d$game_id, FUN = function(m) c(0, utils::head(m, -1)))
  keep <- d$period >= 4 & left <= 60 * minutes & abs(before) <= margin
  tibble::as_tibble(d[keep, ])
}

#' What decided the game?
#'
#' Splits each game's margin into Dean Oliver's four factors. Across all the
#' games supplied, the margin is regressed on the four differences between
#' the teams (eFG%, turnover rate, offensive-rebound rate, free-throw rate);
#' a game's contribution of a factor is its coefficient times that game's
#' difference, in points. What the factors leave over (mostly the number of
#' possessions and how they ended) is `other`.
#'
#' @param teams Team-game box scores from `box_score(pbp, by = "team")`,
#'   many games (a season), both teams of each game.
#' @param coefs Coefficients to use instead of fitting them (named
#'   `d_efg`, `d_tov`, `d_orb`, `d_ftr`).
#' @param min_games With fewer games than this (and no `coefs`), the
#'   coefficients fitted on every 2024/25 game of the league are used, so a
#'   single game can be explained on its own.
#' @return The four factors per team and game plus `margin`, the four
#'   contributions (`c_shooting`, `c_turnovers`, `c_rebounding`,
#'   `c_free_throws`), `c_other`; the model (if fitted) is attached as
#'   attribute `fit`.
#' @export
game_factors <- function(teams, coefs = NULL, min_games = 30) {
  ff <- four_factors(teams)
  ff$margin <- ff$pts - ff$o_pts
  ff$d_efg <- 100 * (ff$efg - ff$o_efg)
  ff$d_tov <- 100 * (ff$tov_pct - ff$o_tov_pct)
  ff$d_orb <- 100 * (ff$orb_pct - (1 - ff$drb_pct))
  ff$d_ftr <- 100 * (ff$ft_rate - ff$o_ft_rate)
  fit <- NULL
  if (is.null(coefs) && length(unique(ff$game_id)) >= min_games) {
    fit <- stats::lm(margin ~ 0 + d_efg + d_tov + d_orb + d_ftr, data = ff)
    b <- stats::coef(fit)
  } else {
    lg <- if ("league" %in% names(ff)) as.character(ff$league[1]) else "NBA"
    b <- coefs %||% factor_coefs[[if (identical(toupper(lg), "NBA")) "NBA" else "EuroLeague"]]
  }
  ff$c_shooting <- b[["d_efg"]] * ff$d_efg
  ff$c_turnovers <- b[["d_tov"]] * ff$d_tov
  ff$c_rebounding <- b[["d_orb"]] * ff$d_orb
  ff$c_free_throws <- b[["d_ftr"]] * ff$d_ftr
  ff$c_other <- ff$margin - ff$c_shooting - ff$c_turnovers - ff$c_rebounding - ff$c_free_throws
  attr(ff, "fit") <- fit
  ff
}

#' Plot what decided one game
#'
#' Bars from zero for the points each factor gave the chosen team, with the
#' teams' own numbers written next to each bar.
#'
#' @param gf Output of [game_factors()].
#' @param game `game_id`.
#' @param team Team whose view to take (default: the winner).
#' @param title,subtitle,caption Labels.
#' @export
plot_game_factors <- function(gf, game, team = NULL, title = NULL, subtitle = NULL, caption = NULL) {
  g <- as.data.frame(gf[gf$game_id == game, ])
  if (is.null(team)) team <- g$team[which.max(g$margin)]
  r <- g[g$team == team, ][1, ]
  opp <- r$oppTeam
  pc <- function(x) sprintf("%.0f%%", 100 * x)
  d <- tibble::tibble(
    factor = c("Shooting (eFG%)", "Turnovers", "Offensive rebounds", "Free throws", "Everything else"),
    value = c(r$c_shooting, r$c_turnovers, r$c_rebounding, r$c_free_throws, r$c_other),
    note = c(sprintf("%s %s vs %s", team, pc(r$efg), pc(r$o_efg)),
             sprintf("%s lost %s of possessions, %s %s", team, pc(r$tov_pct), opp, pc(r$o_tov_pct)),
             sprintf("%s grabbed %s of its misses, %s %s", team, pc(r$orb_pct), opp, pc(1 - r$drb_pct)),
             sprintf("%d vs %d free throws made", as.integer(r$ftm), as.integer(r$o_ftm)),
             "possessions, and how each one ended"))
  d$factor <- factor(d$factor, levels = rev(d$factor))
  d$side <- ifelse(d$value >= 0, "up", "down")
  lim <- max(abs(d$value)) * 1.9
  ggplot2::ggplot(d, ggplot2::aes(.data$value, .data$factor)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey55") +
    ggplot2::geom_col(ggplot2::aes(fill = .data$side), width = 0.6) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.1f", .data$value),
                                    hjust = ifelse(.data$value >= 0, -0.25, 1.25)),
                       size = 3.6, fontface = "bold", colour = ggbasket_colours$ink) +
    ggplot2::geom_text(ggplot2::aes(x = ifelse(.data$value >= 0, -lim * 0.03, lim * 0.03), label = .data$note,
                                    hjust = ifelse(.data$value >= 0, 1, 0)),
                       size = 3, colour = "grey35") +
    ggplot2::scale_fill_manual(values = c(up = ggbasket_colours$above, down = ggbasket_colours$below), guide = "none") +
    ggplot2::scale_x_continuous(limits = c(-lim, lim), labels = function(x) sprintf("%+.0f", x)) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = sprintf("Points of %s's margin explained", team), y = NULL, caption = caption,
                  title = title %||% sprintf("%s %d-%d %s", team, as.integer(r$pts), as.integer(r$o_pts), opp),
                  subtitle = subtitle %||% "Each factor's share of the margin, from a regression of margin on the four-factor differences over the season")
}

#' The story of a game
#'
#' The home team's lead over time, filled in each team's colour, with
#' quarters marked, scoring runs bracketed and labelled, and the final score.
#'
#' @inheritParams game_flow
#' @param game `game_id` (default: the first game).
#' @param min_run Smallest scoring run labelled (unanswered points).
#' @param colours Two colours, home first.
#' @param title,subtitle,caption Labels.
#' @export
plot_game_flow <- function(pbp, game = NULL, min_run = 8, colours = c("#1F5FA8", "#E07B00"),
                           title = NULL, subtitle = NULL, caption = NULL) {
  game <- game %||% as.character(pbp$game_id[1])
  g <- pbp[pbp$game_id == game, ]
  f <- game_flow(g)
  home <- f$hometeam[1]; away <- f$awayteam[1]
  runs <- scoring_runs(g, min_points = min_run)
  st <- data.frame(t = c(rbind(f$totalTime, c(f$totalTime[-1], max(f$totalTime)))) / 60,
                   m = rep(f$margin, each = 2))
  periods <- sort(unique(g$period))
  reg <- reg_seconds(as.data.frame(g[1, ]))[1] / 60
  q_end <- c(reg / 4 * (1:4), reg + 5 * seq_len(max(0, max(periods) - 4)))
  q_lab <- tibble::tibble(t = c(0, q_end[-length(q_end)]) + diff(c(0, q_end)) / 2,
                          lab = c(paste0("Q", 1:4), paste0("OT", seq_len(max(0, max(periods) - 4))))[seq_along(q_end)])
  ymax <- max(abs(f$margin), 6) * 1.25
  runs$mid <- (runs$start + runs$end) / 2 / 60
  runs$yy <- ifelse(runs$team == home, pmax(runs$margin_after, 0) + ymax * 0.12,
                    pmin(runs$margin_after, 0) - ymax * 0.12)
  last <- f[nrow(f), ]
  p <- ggplot2::ggplot(st, ggplot2::aes(.data$t, .data$m)) +
    ggplot2::geom_vline(xintercept = q_end[-length(q_end)], colour = "grey80", linewidth = 0.4) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = 0, ymax = pmax(.data$m, 0)), fill = colours[1], alpha = 0.8) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = pmin(.data$m, 0), ymax = 0), fill = colours[2], alpha = 0.8) +
    ggplot2::geom_hline(yintercept = 0, colour = ggbasket_colours$ink, linewidth = 0.4) +
    ggplot2::geom_text(data = q_lab, ggplot2::aes(x = .data$t, y = -ymax, label = .data$lab), inherit.aes = FALSE,
                       colour = "grey55", size = 3, vjust = 0) +
    ggplot2::annotate("text", x = 0.3, y = ymax * 0.92, label = paste(home, "ahead"), hjust = 0,
                      colour = colours[1], fontface = "bold", size = 3.4) +
    ggplot2::annotate("text", x = 0.3, y = -ymax * 0.8, label = paste(away, "ahead"), hjust = 0,
                      colour = colours[2], fontface = "bold", size = 3.4)
  if (nrow(runs)) {
    p <- p +
      ggplot2::geom_segment(data = runs, ggplot2::aes(x = .data$start / 60, xend = .data$end / 60,
                                                      y = .data$yy, yend = .data$yy), inherit.aes = FALSE,
                            colour = "grey30", linewidth = 0.4) +
      ggplot2::geom_text(data = runs, ggplot2::aes(x = .data$mid, y = .data$yy, label = .data$label,
                                                   vjust = ifelse(.data$team == home, -0.5, 1.5)),
                         inherit.aes = FALSE, size = 2.9, colour = "grey20")
  }
  p +
    ggplot2::scale_x_continuous(breaks = c(0, q_end), labels = function(x) paste0(round(x), "'"),
                                expand = ggplot2::expansion(c(0, 0.01))) +
    ggplot2::scale_y_continuous(limits = c(-ymax, ymax), labels = function(y) ifelse(y == 0, "tied", paste0("+", abs(y)))) +
    theme_ggbasket(grid = "y") +
    ggplot2::labs(x = "Game minute", y = "Lead", caption = caption,
                  title = title %||% sprintf("%s %d-%d %s", home, last$home_score, last$away_score, away),
                  subtitle = subtitle %||% sprintf("Lead of %s (up) or %s (down) through the game; brackets = runs of %d+ unanswered points",
                                                   colour_text(home, colours[1]), colour_text(away, colours[2]), min_run))
}

#' Win probability chart
#'
#' Home win probability through the game, from [win_probability()], with the
#' plays that moved it most numbered and listed under the title.
#'
#' @param wp Output of [win_probability()].
#' @param game `game_id` (default: the first game).
#' @param n_key Number of biggest swings to label.
#' @param colours Two colours, home first.
#' @param title,subtitle,caption Labels.
#' @export
plot_win_probability <- function(wp, game = NULL, n_key = 4, colours = c("#1F5FA8", "#E07B00"),
                                 title = NULL, subtitle = NULL, caption = NULL) {
  game <- game %||% as.character(wp$game_id[1])
  g <- as.data.frame(wp[wp$game_id == game, ])
  home <- g$hometeam[1]; away <- g$awayteam[1]
  g$t <- g$totalTime / 60
  key <- g[order(-abs(g$wp_change)), ][seq_len(min(n_key, nrow(g))), ]
  key <- key[order(key$totalTime), ]
  key$n <- seq_len(nrow(key))
  what <- dplyr::case_when(
    key$event_type == "shot" & key$ShotType == "3P" ~ "hits a three",
    key$event_type == "shot" ~ "scores two",
    key$event_type == "free throw" & key$result == "made" ~ "makes a free throw",
    key$event_type == "free throw" ~ "misses a free throw",
    key$event_type == "miss" ~ "misses",
    key$event_type == "turnover" ~ "turns it over",
    .default = key$event_type)
  key_text <- paste(sprintf("**%d** %s %s, %d-%d (%s %+.0f%%)", key$n, key$player, what, key$home_score,
                            key$away_score, ifelse(key$wp_change > 0, home, away), 100 * abs(key$wp_change)),
                    collapse = " \u00b7 ")
  # step-shaped ribbons, so the fill follows the line
  st <- data.frame(t = c(rbind(g$t, c(g$t[-1], g$t[nrow(g)]))), wp = rep(g$wp, each = 2))
  periods <- sort(unique(g$period))
  reg <- reg_seconds(g[1, ])[1] / 60
  q_end <- c(reg / 4 * (1:4), reg + 5 * seq_len(max(0, max(periods) - 4)))
  ggplot2::ggplot(g, ggplot2::aes(.data$t, .data$wp)) +
    ggplot2::geom_vline(xintercept = q_end[-length(q_end)], colour = "grey85", linewidth = 0.4) +
    ggplot2::geom_ribbon(data = st, ggplot2::aes(ymin = 0.5, ymax = pmax(.data$wp, 0.5)), fill = colours[1],
                         alpha = 0.35) +
    ggplot2::geom_ribbon(data = st, ggplot2::aes(ymin = pmin(.data$wp, 0.5), ymax = 0.5), fill = colours[2],
                         alpha = 0.35) +
    ggplot2::geom_hline(yintercept = 0.5, colour = "grey50", linewidth = 0.4) +
    ggplot2::geom_step(colour = ggbasket_colours$ink, linewidth = 0.5) +
    ggplot2::geom_point(data = key, shape = 21, fill = ggbasket_colours$paper, colour = ggbasket_colours$ink,
                        size = 5.2, stroke = 0.7) +
    ggplot2::geom_text(data = key, ggplot2::aes(label = .data$n), size = 3, fontface = "bold",
                       colour = ggbasket_colours$ink) +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.25, 0.5, 0.75, 1),
                                labels = c(paste("100%", away), "75%", "50/50", "75%", paste("100%", home))) +
    ggplot2::scale_x_continuous(breaks = c(0, q_end), labels = function(x) paste0(round(x), "'"),
                                expand = ggplot2::expansion(c(0, 0.01))) +
    theme_ggbasket(grid = "y") +
    ggplot2::labs(x = "Game minute", y = NULL, caption = caption,
                  title = title %||% sprintf("%s vs %s: win probability", home, away),
                  subtitle = paste0(subtitle %||% sprintf("Chance that %s (up) or %s (down) wins, after every play.",
                                                          colour_text(home, colours[1]), colour_text(away, colours[2])),
                                    "<br>Biggest swings: ", key_text))
}

# Stern-model parameters fitted with fit_win_probability() on the 2024/25 regular seasons (data-raw/make_pbp.R)
wp_default <- tibble::tibble(league = c("NBA", "EuroLeague"), mu = c(1.62, 3.31), sigma = c(18.8, 15.9))
