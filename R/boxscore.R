#' Box scores from play-by-play
#'
#' Counts every event of a play-by-play in the ggbasket layout (see [pbp])
#' into player or team box scores, one row per game. Player rows also carry
#' minutes and plus-minus from the line-ups on court. Team rebounds (no
#' player credited) are left out, as in official box scores. Team rows carry the
#' opponent's totals with an `o_` prefix, so they go straight into
#' [four_factors()].
#'
#' @param pbp Play-by-play in the ggbasket layout.
#' @param by `"player"` or `"team"`.
#' @param total If `TRUE`, sum over games (one row per player or team, with
#'   `games`).
#' @return A tibble with `league`, `season`, `game_id` (unless `total`),
#'   `team`, (`player`), `pts p2m p2a p3m p3a ftm fta orb drb ast stl blk tov
#'   pf`, and for players `min` and `pm`; for teams `o_*`, `min` (5 x game
#'   minutes), `w` and `l`.
#' @export
#' @examples
#' bx <- box_score(pbp_games)
#' head(bx[order(-bx$pts), c("team", "player", "min", "pts", "ast", "pm")])
#' four_factors(box_score(pbp_games, by = "team"))[, c("game_id", "team", "ortg", "drtg", "efg")]
box_score <- function(pbp, by = c("player", "team"), total = FALSE) {
  by <- match.arg(by)
  d <- as.data.frame(pbp)
  if (!"season" %in% names(d)) d$season <- NA_integer_
  if (!"league" %in% names(d)) d$league <- NA_character_
  d$team <- as.character(d$team); d$oppTeam <- as.character(d$oppTeam)
  for (v in c("player", "assist", "steal", "block")) {
    d[[v]] <- as.character(d[[v]]); d[[v]][is.na(d[[v]])] <- ""
  }
  if (!"rebound" %in% names(d)) d$rebound <- ifelse(grepl("off", tolower(d$type)), "offensive", "defensive")
  shot <- d$event_type %in% c("shot", "miss", "free throw") & d$team != ""
  made <- d$result == "made"
  st <- d$ShotType
  tech <- grepl("echnical", d$description %||% "")
  credit <- function(rows, who, team, var) {
    tibble::tibble(league = d$league[rows], season = d$season[rows], game_id = d$game_id[rows],
                   team = team[rows], player = who[rows], var = var)
  }
  long <- dplyr::bind_rows(
    credit(which(shot & st == "2P" & made), d$player, d$team, "p2m"),
    credit(which(shot & st == "2P"), d$player, d$team, "p2a"),
    credit(which(shot & st == "3P" & made), d$player, d$team, "p3m"),
    credit(which(shot & st == "3P"), d$player, d$team, "p3a"),
    credit(which(shot & st == "FT" & made), d$player, d$team, "ftm"),
    credit(which(shot & st == "FT"), d$player, d$team, "fta"),
    credit(which(d$event_type == "rebound" & d$rebound == "offensive" & d$team != "" & d$player != ""), d$player, d$team, "orb"),
    credit(which(d$event_type == "rebound" & d$rebound == "defensive" & d$team != "" & d$player != ""), d$player, d$team, "drb"),
    credit(which(d$assist != ""), d$assist, d$team, "ast"),
    credit(which(d$event_type == "turnover" & d$steal != ""), d$steal, d$oppTeam, "stl"),
    credit(which(d$event_type == "miss" & d$block != ""), d$block, d$oppTeam, "blk"),
    credit(which(d$event_type == "turnover" & d$team != ""), d$player, d$team, "tov"),
    credit(which(d$event_type == "foul" & d$team != "" & !tech), d$player, d$team, "pf")
  )
  vars <- c("p2m", "p2a", "p3m", "p3a", "ftm", "fta", "orb", "drb", "ast", "stl", "blk", "tov", "pf")
  keys <- c("league", "season", "game_id", "team")
  if (by == "player") {
    keys <- c(keys, "player")
    long <- long[long$player != "", ]
  }
  out <- long |>
    dplyr::count(dplyr::across(dplyr::all_of(c(keys, "var")))) |>
    tidyr::pivot_wider(names_from = "var", values_from = "n", values_fill = 0)
  for (v in setdiff(vars, names(out))) out[[v]] <- 0L
  out$pts <- 2 * out$p2m + 3 * out$p3m + out$ftm
  if (by == "player") {
    on <- on_court_long(d)
    oc <- on |>
      dplyr::group_by(.data$league, .data$season, .data$game_id, .data$team, .data$player) |>
      dplyr::summarise(min = sum(.data$sec) / 60, pm = sum(.data$pts_for - .data$pts_against), .groups = "drop")
    out <- dplyr::full_join(out, oc, by = keys)
    out[vars] <- lapply(out[vars], function(v) dplyr::coalesce(v, 0L))
    out$pts <- dplyr::coalesce(out$pts, 0)
    out <- out[, c(keys, "min", "pts", vars, "pm")]
  } else {
    gm <- d |> dplyr::group_by(.data$game_id) |>
      dplyr::summarise(min = 5 * max(.data$totalTime) / 60, home = .data$hometeam[1], .groups = "drop")
    out <- out[, c(keys, "pts", vars)]
    opp <- out[, c("game_id", "team", "pts", vars)]
    names(opp)[-(1:2)] <- paste0("o_", names(opp)[-(1:2)])
    tm <- unique(d[d$team != "", c("game_id", "team", "oppTeam")])
    opp <- dplyr::rename(opp, oppTeam = "team")
    out <- out |>
      dplyr::left_join(tm, by = c("game_id", "team")) |>
      dplyr::left_join(opp, by = c("game_id", "oppTeam")) |>
      dplyr::left_join(gm, by = "game_id") |>
      dplyr::mutate(home = .data$team == .data$home, w = as.integer(.data$pts > .data$o_pts),
                    l = as.integer(.data$pts < .data$o_pts))
  }
  if (total) {
    g <- setdiff(keys, "game_id")
    num <- setdiff(names(out)[vapply(out, is.numeric, logical(1))], c("season", g))
    out <- out |>
      dplyr::group_by(dplyr::across(dplyr::all_of(g))) |>
      dplyr::summarise(games = dplyr::n_distinct(.data$game_id), dplyr::across(dplyr::all_of(num), sum),
                       .groups = "drop")
  }
  tibble::as_tibble(out)
}

# one row per event x player on court: seconds played before the event and points for / against at it
on_court_long <- function(d) {
  if (!all(c(paste0("a", 1:5), paste0("h", 1:5)) %in% names(d))) {
    rlang::abort("Line-ups (a1-a5, h1-h5) are needed; see add_lineups().")
  }
  pts <- ifelse(is.na(d$points) | d$result != "made", 0, d$points)
  home_pts <- ifelse(d$team == d$hometeam, pts, 0)
  away_pts <- ifelse(d$team == d$awayteam, pts, 0)
  side <- function(cols, team, pf, pa) {
    dplyr::bind_rows(lapply(cols, function(cl) {
      tibble::tibble(league = d$league, season = d$season, game_id = d$game_id, team = team,
                     player = as.character(d[[cl]]), sec = d$playlength, pts_for = pf, pts_against = pa,
                     row = seq_len(nrow(d)))
    }))
  }
  on <- dplyr::bind_rows(side(paste0("h", 1:5), d$hometeam, home_pts, away_pts),
                         side(paste0("a", 1:5), d$awayteam, away_pts, home_pts))
  on[!is.na(on$player) & on$player != "", ]
}

#' Game Score: one number per player per game
#'
#' John Hollinger's Game Score, a box-score summary on the points scale
#' (about 10 is an average game, 40 an outstanding one):
#' PTS + 0.4 FGM - 0.7 FGA - 0.4 (FTA - FTM) + 0.7 ORB + 0.3 DRB + STL +
#' 0.7 AST + 0.7 BLK - 0.4 PF - TOV.
#'
#' @param box Player box scores from [box_score()].
#' @return `box` with `game_score`.
#' @export
game_score <- function(box) {
  b <- box
  fgm <- b$p2m + b$p3m; fga <- b$p2a + b$p3a
  b$game_score <- b$pts + 0.4 * fgm - 0.7 * fga - 0.4 * (b$fta - b$ftm) + 0.7 * b$orb + 0.3 * b$drb +
    b$stl + 0.7 * b$ast + 0.7 * b$blk - 0.4 * b$pf - b$tov
  b
}

#' How dependable is a player, game to game?
#'
#' One dot per game for each player (Game Score by default), with the middle
#' half of games shaded and the median marked. A tight strip is a player you
#' can count on; a wide one swings between quiet nights and big games.
#' Players are ordered by median.
#'
#' @param box Player-game rows, e.g. `game_score(box_score(pbp))`.
#' @param players Players to show.
#' @param stat Column to plot.
#' @param stat_label Axis label.
#' @param min_minutes Games with fewer minutes are dropped.
#' @param title,subtitle,caption Labels.
#' @export
plot_consistency <- function(box, players, stat = "game_score", stat_label = "Game Score", min_minutes = 10,
                             title = NULL, subtitle = NULL, caption = NULL) {
  if (!stat %in% names(box) && stat == "game_score") box <- game_score(box)
  d <- as.data.frame(box)
  d <- d[d$player %in% players & d$min >= min_minutes, ]
  d$value <- d[[stat]]
  s <- d |>
    dplyr::group_by(.data$player) |>
    dplyr::summarise(med = stats::median(.data$value), q1 = stats::quantile(.data$value, 0.25),
                     q3 = stats::quantile(.data$value, 0.75), p10 = stats::quantile(.data$value, 0.1),
                     p90 = stats::quantile(.data$value, 0.9), n = dplyr::n(), .groups = "drop")
  lev <- s$player[order(s$med)]
  d$player <- factor(d$player, levels = lev); s$player <- factor(s$player, levels = lev)
  set.seed(1)
  d$jit <- as.numeric(d$player) + stats::runif(nrow(d), -0.22, 0.22)
  s$y <- as.numeric(s$player)
  ggplot2::ggplot() +
    ggplot2::geom_rect(data = s, ggplot2::aes(xmin = .data$q1, xmax = .data$q3, ymin = .data$y - 0.32,
                                              ymax = .data$y + 0.32), fill = "grey85") +
    ggplot2::geom_point(data = d, ggplot2::aes(.data$value, .data$jit), shape = 21, size = 1.9,
                        fill = ggbasket_colours$league[["NBA"]], colour = ggbasket_colours$paper,
                        stroke = 0.3, alpha = 0.75) +
    ggplot2::geom_segment(data = s, ggplot2::aes(x = .data$med, xend = .data$med, y = .data$y - 0.38,
                                                 yend = .data$y + 0.38), colour = ggbasket_colours$ink,
                          linewidth = 1) +
    ggplot2::geom_text(data = s, ggplot2::aes(x = max(d$value) + 0.04 * diff(range(d$value)), y = .data$y,
                                              label = sprintf("median %.0f\nworst 10%%: below %.0f\nbest 10%%: above %.0f",
                                                              .data$med, .data$p10, .data$p90)),
                       hjust = 0, size = 2.6, colour = "grey35", lineheight = 0.95) +
    ggplot2::scale_y_continuous(breaks = seq_along(lev), labels = lev, expand = ggplot2::expansion(add = c(0.5, 0.5))) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.03, 0.22))) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = stat_label, y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "One dot per game; grey box = middle half of games; black tick = median")
}
