#' Stints: stretches with the same ten players on court
#'
#' @param pbp Play-by-play in the ggbasket layout with line-ups (see
#'   [add_lineups()]).
#' @return A tibble per stint: `game_id`, `hometeam`, `awayteam`,
#'   `home_lineup`, `away_lineup` (players sorted and joined by `" | "`),
#'   `sec`, `home_pts`, `away_pts`, `home_poss`, `away_poss`.
#' @export
stints <- function(pbp) {
  d <- as.data.frame(pbp)
  hl <- apply(d[, paste0("h", 1:5)], 1, function(x) paste(sort(x[!is.na(x)]), collapse = " | "))
  al <- apply(d[, paste0("a", 1:5)], 1, function(x) paste(sort(x[!is.na(x)]), collapse = " | "))
  key <- paste(d$game_id, hl, al)
  id <- cumsum(c(TRUE, key[-1] != key[-length(key)]))
  pts <- ifelse(is.na(d$points) | d$result != "made", 0, d$points)
  ends <- poss_ends(d)
  tibble::tibble(stint = id, game_id = d$game_id, league = d$league, season = d$season,
                 hometeam = d$hometeam, awayteam = d$awayteam, home_lineup = hl, away_lineup = al,
                 sec = d$playlength, home_pts = ifelse(d$team == d$hometeam, pts, 0),
                 away_pts = ifelse(d$team == d$awayteam, pts, 0),
                 home_poss = ifelse(d$team == d$hometeam, ends, 0),
                 away_poss = ifelse(d$team == d$awayteam, ends, 0)) |>
    dplyr::group_by(.data$stint, .data$game_id, .data$league, .data$season, .data$hometeam, .data$awayteam,
                    .data$home_lineup, .data$away_lineup) |>
    dplyr::summarise(dplyr::across(c("sec", "home_pts", "away_pts", "home_poss", "away_poss"), sum),
                     .groups = "drop")
}

# possessions used per event: FGA + 0.44 FTA - ORB + TOV, the box-score estimate
poss_ends <- function(d) {
  fga <- d$event_type %in% c("shot", "miss")
  fta <- d$event_type == "free throw"
  orb <- d$event_type == "rebound" & d$rebound %in% "offensive"
  tov <- d$event_type == "turnover"
  fga + 0.44 * fta - orb + tov
}

#' On/off: how a team plays with and without each player
#'
#' Points scored and allowed per 100 possessions while a player is on the
#' floor and while he or she sits, from the stints of every game supplied.
#' `on_off` = net rating on minus net rating off: the raw version of what
#' adjusted plus-minus models refine. It mixes the player's impact with who
#' they share the floor with, so read it alongside minutes.
#'
#' @inheritParams stints
#' @param team Teams to keep (default: all).
#' @param min_minutes Players with fewer minutes are dropped.
#' @return A tibble per player and team: `min`, `on_ortg`, `on_drtg`,
#'   `on_net`, `off_net`, `on_off`, `pm` (raw plus-minus), `poss_on`,
#'   `poss_off`.
#' @export
on_off <- function(pbp, team = NULL, min_minutes = 100) {
  st <- stints(pbp)
  long <- dplyr::bind_rows(
    tibble::tibble(team = st$hometeam, lineup = st$home_lineup, sec = st$sec, pf = st$home_pts, pa = st$away_pts,
                   pof = st$home_poss, poa = st$away_poss),
    tibble::tibble(team = st$awayteam, lineup = st$away_lineup, sec = st$sec, pf = st$away_pts, pa = st$home_pts,
                   pof = st$away_poss, poa = st$home_poss))
  if (!is.null(team)) long <- long[long$team %in% team, ]
  tot <- long |> dplyr::group_by(.data$team) |>
    dplyr::summarise(t_sec = sum(.data$sec), t_pf = sum(.data$pf), t_pa = sum(.data$pa),
                     t_pof = sum(.data$pof), t_poa = sum(.data$poa), .groups = "drop")
  pl <- long |>
    dplyr::mutate(player = strsplit(.data$lineup, " | ", fixed = TRUE)) |>
    tidyr::unnest("player") |>
    dplyr::filter(.data$player != "") |>
    dplyr::group_by(.data$team, .data$player) |>
    dplyr::summarise(sec = sum(.data$sec), pf = sum(.data$pf), pa = sum(.data$pa), pof = sum(.data$pof),
                     poa = sum(.data$poa), .groups = "drop") |>
    dplyr::left_join(tot, by = "team")
  pl |>
    dplyr::mutate(min = .data$sec / 60,
                  on_ortg = 100 * .data$pf / .data$pof, on_drtg = 100 * .data$pa / .data$poa,
                  on_net = .data$on_ortg - .data$on_drtg,
                  off_ortg = 100 * (.data$t_pf - .data$pf) / (.data$t_pof - .data$pof),
                  off_drtg = 100 * (.data$t_pa - .data$pa) / (.data$t_poa - .data$poa),
                  off_net = .data$off_ortg - .data$off_drtg,
                  on_off = .data$on_net - .data$off_net, pm = .data$pf - .data$pa,
                  poss_on = (.data$pof + .data$poa) / 2,
                  poss_off = (.data$t_pof - .data$pof + .data$t_poa - .data$poa) / 2) |>
    dplyr::filter(.data$min >= min_minutes) |>
    dplyr::select("team", "player", "min", "on_ortg", "on_drtg", "on_net", "off_ortg", "off_drtg", "off_net",
                  "on_off", "pm", "poss_on", "poss_off") |>
    dplyr::arrange(dplyr::desc(.data$on_off))
}

#' Line-ups: which units work
#'
#' @inheritParams on_off
#' @param min_minutes Line-ups with fewer minutes together are dropped.
#' @return A tibble per team and five-player unit: `min`, `pts_for`,
#'   `pts_against`, `ortg`, `drtg`, `net`, `poss`.
#' @export
lineups <- function(pbp, team = NULL, min_minutes = 20) {
  st <- stints(pbp)
  long <- dplyr::bind_rows(
    tibble::tibble(team = st$hometeam, lineup = st$home_lineup, sec = st$sec, pf = st$home_pts, pa = st$away_pts,
                   pof = st$home_poss, poa = st$away_poss),
    tibble::tibble(team = st$awayteam, lineup = st$away_lineup, sec = st$sec, pf = st$away_pts, pa = st$home_pts,
                   pof = st$away_poss, poa = st$home_poss))
  if (!is.null(team)) long <- long[long$team %in% team, ]
  long |>
    dplyr::group_by(.data$team, .data$lineup) |>
    dplyr::summarise(min = sum(.data$sec) / 60, pts_for = sum(.data$pf), pts_against = sum(.data$pa),
                     pof = sum(.data$pof), poa = sum(.data$poa), .groups = "drop") |>
    dplyr::filter(.data$min >= min_minutes, lengths(strsplit(.data$lineup, " | ", fixed = TRUE)) == 5) |>
    dplyr::mutate(ortg = 100 * .data$pts_for / .data$pof, drtg = 100 * .data$pts_against / .data$poa,
                  net = .data$ortg - .data$drtg, poss = (.data$pof + .data$poa) / 2) |>
    dplyr::select(-"pof", -"poa") |>
    dplyr::arrange(dplyr::desc(.data$min))
}

#' Plot on/off
#'
#' One row per player: the team's net rating with the player off the floor
#' (open circle) and on it (filled), joined by a line coloured by which is
#' better. Ordered by the difference.
#'
#' @param oo Output of [on_off()], one team (or use `n`).
#' @param n Show at most `n` players with the most minutes.
#' @param title,subtitle,caption Labels.
#' @export
plot_on_off <- function(oo, n = 12, title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(oo)
  d <- d[order(-d$min), ][seq_len(min(n, nrow(d))), ]
  d$lab <- sprintf("%s  (%s min)", d$player, trimws(format(round(d$min), big.mark = ",")))
  d$lab <- factor(d$lab, levels = d$lab[order(d$on_off)])
  d$dir <- ifelse(d$on_off >= 0, "up", "down")
  cols <- c(up = ggbasket_colours$above, down = ggbasket_colours$below)
  ggplot2::ggplot(d, ggplot2::aes(y = .data$lab)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_segment(ggplot2::aes(x = .data$off_net, xend = .data$on_net, colour = .data$dir), linewidth = 1.6,
                          alpha = 0.5) +
    ggplot2::geom_point(ggplot2::aes(x = .data$off_net), shape = 21, size = 2.8, fill = ggbasket_colours$paper,
                        colour = "grey40", stroke = 0.8) +
    ggplot2::geom_point(ggplot2::aes(x = .data$on_net, colour = .data$dir), size = 3) +
    ggplot2::geom_text(ggplot2::aes(x = pmax(.data$on_net, .data$off_net), label = sprintf("%+.1f", .data$on_off),
                                    colour = .data$dir), hjust = -0.4, size = 3, fontface = "bold") +
    ggplot2::scale_colour_manual(values = cols, guide = "none") +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", x), expand = ggplot2::expansion(c(0.05, 0.12))) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Team net rating (points per 100 possessions)", y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "Open circle = player off the floor, filled = on it; number = difference")
}
