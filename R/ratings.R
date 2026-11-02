#' Opponent-adjusted team ratings
#'
#' The Simple Rating System: every game's margin is modelled as home
#' advantage + rating of the team - rating of the opponent, fitted by least
#' squares over all games with ratings summing to zero within a league. A
#' rating is the margin a team would have against an average opponent on a
#' neutral court, so a team with a soft schedule is marked down.
#'
#' @param teams Team-game box scores from `box_score(pbp, by = "team")`,
#'   with `game_id`, `team`, `oppTeam`, `pts`, `o_pts`, `home`, `league`.
#' @return A tibble per team: `games`, `mov` (average margin), `rating`,
#'   `sos` (average opponent rating), `w`, `l`; the home advantage of each
#'   league is attached as attribute `home_adv`.
#' @export
#' @examples
#' r <- team_ratings(box_score(pbp_games, by = "team"))
team_ratings <- function(teams) {
  d <- as.data.frame(teams)
  d <- d[d$home, ]
  out <- lapply(split(d, d$league), function(x) {
    tm <- sort(unique(c(x$team, x$oppTeam)))
    X <- matrix(0, nrow(x), length(tm), dimnames = list(NULL, tm))
    X[cbind(seq_len(nrow(x)), match(x$team, tm))] <- 1
    X[cbind(seq_len(nrow(x)), match(x$oppTeam, tm))] <- -1
    y <- x$pts - x$o_pts
    # sum-to-zero: drop the last team and recover it as minus the sum of the others
    Z <- X[, -length(tm), drop = FALSE] - X[, length(tm)]
    fit <- stats::lm(y ~ Z)
    b <- stats::coef(fit)[-1]
    b[is.na(b)] <- 0
    r <- c(b, -sum(b))
    names(r) <- tm
    long <- rbind(data.frame(team = x$team, opp = x$oppTeam, m = y),
                  data.frame(team = x$oppTeam, opp = x$team, m = -y))
    res <- long |>
      dplyr::group_by(.data$team) |>
      dplyr::summarise(games = dplyr::n(), mov = mean(.data$m), sos = mean(r[.data$opp]),
                       w = sum(.data$m > 0), l = sum(.data$m < 0), .groups = "drop")
    res$rating <- r[res$team]
    res$league <- x$league[1]
    attr(res, "home_adv") <- unname(stats::coef(fit)[1])
    res
  })
  ha <- vapply(out, function(o) attr(o, "home_adv"), numeric(1))
  res <- dplyr::bind_rows(out) |> dplyr::arrange(.data$league, dplyr::desc(.data$rating))
  attr(res, "home_adv") <- ha
  res
}

#' Plot raw against schedule-adjusted margin
#'
#' One row per team: open circle = average margin, filled = rating against
#' an average opponent. A long line means the schedule flattered (line to
#' the left) or hurt (to the right) the raw margin.
#'
#' @param tr Output of [team_ratings()].
#' @param title,subtitle,caption Labels.
#' @export
plot_team_ratings <- function(tr, title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(tr)
  d$lab <- sprintf("%s  %d-%d", d$team, as.integer(d$w), as.integer(d$l))
  d$key <- paste(d$league, d$lab)
  d$key <- factor(d$key, levels = d$key[order(d$league, d$rating)])
  d$dir <- ifelse(d$rating >= d$mov, "up", "down")
  ha <- attr(tr, "home_adv")
  ggplot2::ggplot(d, ggplot2::aes(y = .data$key)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_segment(ggplot2::aes(x = .data$mov, xend = .data$rating, colour = .data$dir), linewidth = 1.3,
                          alpha = 0.6) +
    ggplot2::geom_point(ggplot2::aes(x = .data$mov), shape = 21, size = 2.4, fill = ggbasket_colours$paper,
                        colour = "grey40") +
    ggplot2::geom_point(ggplot2::aes(x = .data$rating, fill = .data$league), shape = 21, size = 2.8,
                        colour = ggbasket_colours$paper) +
    ggplot2::scale_y_discrete(labels = function(k) sub("^\\S+ ", "", k)) +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", x)) +
    ggplot2::scale_colour_manual(values = c(up = ggbasket_colours$above, down = ggbasket_colours$below), guide = "none") +
    scale_fill_league(guide = "none") +
    ggplot2::facet_wrap(~league, scales = "free_y") +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Points per game against an average opponent", y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% paste0(
                    "Open circle = raw average margin; filled = rating after adjusting for the schedule and home court ",
                    "(home advantage: ", paste(sprintf("%s %+.1f", names(ha), ha), collapse = ", "), " points)"))
}

#' Regularised adjusted plus-minus (RAPM)
#'
#' Each stint (see [stints()]) is one observation: the home margin per 100
#' possessions, explained by +1 for every home player on court, -1 for every
#' away player, and a home-court intercept, weighted by possessions. Ridge
#' regression (penalty `lambda`) shrinks players with little or collinear
#' playing time towards zero, which is what makes plus-minus usable. A value
#' is points per 100 possessions added to the team's margin, against an
#' average player.
#'
#' @param pbp Play-by-play with line-ups, one league.
#' @param lambda Ridge penalty (in possessions). Larger = more shrinkage.
#' @param min_poss Players with fewer possessions on court are pooled into
#'   one "replacement" column.
#' @return A tibble per player: `team` (most minutes), `poss`, `rapm`;
#'   the home-court intercept as attribute `home_adv`.
#' @export
rapm <- function(pbp, lambda = 2000, min_poss = 200) {
  st <- stints(pbp)
  st$poss <- (st$home_poss + st$away_poss) / 2
  st <- st[st$poss > 0, ]
  y <- 100 * (st$home_pts - st$away_pts) / st$poss
  hp <- strsplit(st$home_lineup, " | ", fixed = TRUE)
  ap <- strsplit(st$away_lineup, " | ", fixed = TRUE)
  long <- rbind(data.frame(i = rep(seq_along(hp), lengths(hp)), player = unlist(hp), s = 1,
                           team = rep(st$hometeam, lengths(hp)), poss = rep(st$poss, lengths(hp))),
                data.frame(i = rep(seq_along(ap), lengths(ap)), player = unlist(ap), s = -1,
                           team = rep(st$awayteam, lengths(ap)), poss = rep(st$poss, lengths(ap))))
  pp <- tapply(long$poss, long$player, sum)
  long$col <- ifelse(pp[long$player] >= min_poss, long$player, "(replacement)")
  cols <- sort(unique(long$col))
  X <- matrix(0, length(y), length(cols))
  idx <- cbind(long$i, match(long$col, cols))
  for (k in seq_len(nrow(idx))) X[idx[k, 1], idx[k, 2]] <- X[idx[k, 1], idx[k, 2]] + long$s[k]
  w <- st$poss
  X1 <- cbind(1, X)
  pen <- diag(c(0, rep(lambda, length(cols))))
  b <- solve(crossprod(X1, X1 * w) + pen, crossprod(X1, w * y))
  main_team <- long |>
    dplyr::group_by(.data$player, .data$team) |>
    dplyr::summarise(p = sum(.data$poss), .groups = "drop_last") |>
    dplyr::slice_max(.data$p, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()
  out <- tibble::tibble(player = cols, rapm = b[-1, 1])
  out <- out[out$player != "(replacement)", ]
  out$poss <- as.numeric(pp[out$player])
  out$team <- main_team$team[match(out$player, main_team$player)]
  out <- out[order(-out$rapm), c("player", "team", "poss", "rapm")]
  attr(out, "home_adv") <- b[1, 1]
  out
}

#' Plot RAPM: the top and bottom players
#'
#' @param rp Output of [rapm()].
#' @param n Players shown at each end.
#' @param highlight Players to colour.
#' @param title,subtitle,caption Labels.
#' @export
plot_rapm <- function(rp, n = 12, highlight = NULL, title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(rp)
  d <- d[order(-d$rapm), ]
  d <- rbind(utils::head(d, n), utils::tail(d, n))
  d$end <- rep(c("Top", "Bottom"), each = n)
  d$lab <- sprintf("%s (%s)", d$player, d$team)
  d$lab <- factor(d$lab, levels = d$lab[order(d$rapm)])
  d$col <- ifelse(d$player %in% highlight, "hl", ifelse(d$rapm >= 0, "up", "down"))
  ggplot2::ggplot(d, ggplot2::aes(.data$rapm, .data$lab)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$rapm, colour = .data$col), linewidth = 0.9) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$col, size = .data$poss)) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.1f", .data$rapm), hjust = ifelse(.data$rapm >= 0, -0.6, 1.6)),
                       size = 2.8, colour = "grey30") +
    ggplot2::scale_colour_manual(values = c(up = ggbasket_colours$above, down = ggbasket_colours$below,
                                            hl = ggbasket_colours$ink), guide = "none") +
    ggplot2::scale_size_area(max_size = 3.5, guide = "none") +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", x), expand = ggplot2::expansion(0.15)) +
    ggplot2::facet_wrap(~ factor(end, levels = c("Top", "Bottom")), scales = "free_y", ncol = 2) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Points per 100 possessions added to the team's margin", y = NULL, title = title,
                  caption = caption,
                  subtitle = subtitle %||% "Ridge-regularised adjusted plus-minus from every line-up stint; dot size = possessions played")
}

#' Win probability added
#'
#' Credits every change in win probability (from [win_probability()]) to the
#' players involved, from their team's point of view: the player who made
#' the play (shooter, free-throw shooter, player who lost the ball) gets the
#' change, and the five opponents on the floor share the opposite change
#' equally (a fifth each), so defence counts and the two teams' totals
#' cancel. For a steal, the stealer takes half of the defence's share. +0.30
#' means the player's plays added 30 percentage points to their team's
#' chance of winning.
#'
#' @param wp Output of [win_probability()], with line-ups.
#' @return A tibble per game and player: `team`, `wpa`, `offence`,
#'   `defence`, `plays`.
#' @export
win_probability_added <- function(wp) {
  d <- as.data.frame(wp)
  act <- d$event_type %in% c("shot", "miss", "free throw", "turnover") & d$player != "" & d$team != "" &
    d$wp_change != 0
  d <- d[act, ]
  sgn <- ifelse(d$team == d$hometeam, 1, -1)
  dw <- sgn * d$wp_change
  off <- tibble::tibble(game_id = d$game_id, team = d$team, player = d$player, offence = dw, defence = 0)
  def_cols <- function(i) if (d$team[i] == d$hometeam[i]) paste0("a", 1:5) else paste0("h", 1:5)
  defn <- dplyr::bind_rows(lapply(seq_len(nrow(d)), function(i) {
    pl <- unlist(d[i, def_cols(i)])
    pl <- pl[!is.na(pl) & pl != ""]
    if (!length(pl)) return(NULL)
    share <- rep(-dw[i] / length(pl), length(pl))
    if (d$event_type[i] == "turnover" && d$steal[i] %in% pl) {
      share <- share * 0.5
      share[pl == d$steal[i]] <- share[pl == d$steal[i]] + (-dw[i]) * 0.5
    }
    tibble::tibble(game_id = d$game_id[i], team = d$oppTeam[i], player = pl, offence = 0, defence = share)
  }))
  dplyr::bind_rows(off, defn) |>
    dplyr::group_by(.data$game_id, .data$team, .data$player) |>
    dplyr::summarise(plays = sum(.data$offence != 0), offence = sum(.data$offence), defence = sum(.data$defence),
                     .groups = "drop") |>
    dplyr::mutate(wpa = .data$offence + .data$defence) |>
    dplyr::arrange(dplyr::desc(.data$wpa))
}

#' Plot win probability added in one game
#'
#' @param wpa Output of [win_probability_added()].
#' @param game `game_id`.
#' @param colours Named vector of team colours (default: blue and orange).
#' @param title,subtitle,caption Labels.
#' @export
plot_wpa <- function(wpa, game = NULL, colours = NULL, title = NULL, subtitle = NULL, caption = NULL) {
  game <- game %||% wpa$game_id[1]
  d <- as.data.frame(wpa[wpa$game_id == game, ])
  d <- d[abs(d$wpa) >= 0.02, ]
  tm <- unique(d$team)
  colours <- colours %||% stats::setNames(c("#1F5FA8", "#E07B00")[seq_along(tm)], tm)
  d$lab <- factor(d$player, levels = d$player[order(d$wpa)])
  ggplot2::ggplot(d, ggplot2::aes(.data$wpa, .data$lab, fill = .data$team)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_col(width = 0.65) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.0f", 100 * .data$wpa), hjust = ifelse(.data$wpa >= 0, -0.3, 1.3)),
                       size = 2.9, colour = "grey25") +
    ggplot2::scale_fill_manual(values = colours, guide = "none") +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", 100 * x), expand = ggplot2::expansion(0.12)) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Win probability added (percentage points)", y = NULL,
                  title = title, caption = caption,
                  subtitle = subtitle %||% paste("Each player's plays, plus a fifth of every opponent play while on the floor; players with 2+ points either way:",
                                                 paste(vapply(tm, function(t) colour_text(t, colours[[t]]), ""), collapse = " and ")))
}

#' Plot line-ups
#'
#' The best and worst five-player units by net rating, with minutes played.
#'
#' @param lu Output of [lineups()].
#' @param n Units at each end.
#' @param title,subtitle,caption Labels.
#' @export
plot_lineups <- function(lu, n = 6, title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(lu)
  d <- d[order(-d$net), ]
  d <- unique(rbind(utils::head(d, n), utils::tail(d, n)))
  short <- vapply(strsplit(d$lineup, " | ", fixed = TRUE),
                  function(p) paste(sub("^(\\S)\\S*\\s+", "\\1. ", p), collapse = " \\u00b7 "), "")
  names(short) <- d$lineup
  d$lab <- factor(d$lineup, levels = d$lineup[order(d$net)])
  d$dir <- ifelse(d$net >= 0, "up", "down")
  ggplot2::ggplot(d, ggplot2::aes(.data$net, .data$lab)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$net, colour = .data$dir), linewidth = 0.9) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$dir, size = .data$min)) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.0f  (%.0f min)", .data$net, .data$min),
                                    hjust = ifelse(.data$net >= 0, -0.25, 1.25)), size = 2.8, colour = "grey30") +
    ggplot2::scale_colour_manual(values = c(up = ggbasket_colours$above, down = ggbasket_colours$below), guide = "none") +
    ggplot2::scale_size_area(max_size = 4, guide = "none") +
    ggplot2::scale_y_discrete(labels = function(k) short[k]) +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", x), expand = ggplot2::expansion(0.35)) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Net rating (points per 100 possessions)", y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "Five-player units by net rating; dot size = minutes together")
}

#' Transition and shot quality, per team
#'
#' From the field-goal attempts of [pressure_situations()] (with `xfg` from
#' [expected_fg()]): how often each team shoots early in the clock
#' (`early_share`, at least `early` seconds left, mostly transition), points
#' per early and per half-court shot, and the quality of the shots it takes
#' and allows: expected points per shot from location alone (`xpps`,
#' `o_xpps`) and how far actual points beat it (`making`, `o_making`).
#'
#' @param shots Output of [pressure_situations()], with `xfg`.
#' @param early Seconds left on the shot clock that count as early.
#' @export
team_shot_profile <- function(shots, early = 17) {
  if (!"xfg" %in% names(shots)) shots <- expected_fg(shots)
  d <- as.data.frame(shots)
  d$xpts <- d$xfg * d$value
  d$early <- d$shot_clock_left >= early
  off <- d |>
    dplyr::group_by(.data$league, .data$team) |>
    dplyr::summarise(fga = dplyr::n(), early_share = mean(.data$early),
                     pps_early = mean(.data$pts[.data$early]), pps_half = mean(.data$pts[!.data$early]),
                     xpps = mean(.data$xpts), pps = mean(.data$pts), .groups = "drop")
  def <- d |>
    dplyr::group_by(team = .data$opp) |>
    dplyr::summarise(o_early_share = mean(.data$early), o_xpps = mean(.data$xpts), o_pps = mean(.data$pts),
                     .groups = "drop")
  off |>
    dplyr::left_join(def, by = "team") |>
    dplyr::mutate(making = .data$pps - .data$xpps, o_making = .data$o_pps - .data$o_xpps)
}
