#' Possession-based player rates
#'
#' The rate statistics the book does not use but every modern analysis does,
#' with Basketball-Reference definitions. They put players from teams (and
#' leagues) with different pace and game length on the same footing:
#'
#' * `ts_pct`: true shooting, points per shooting possession,
#'   PTS / (2 (FGA + 0.44 FTA)).
#' * `usg_pct`: share of team possessions a player uses while on the floor.
#' * `tov_pct`: turnovers per 100 plays (FGA + 0.44 FTA + TOV).
#' * `orb_pct`, `drb_pct`: share of available rebounds grabbed on the floor.
#' * `stl_pct`: steals per opponent possession on the floor.
#' * `blk_pct`: share of opponent 2-point attempts blocked on the floor.
#' * `ast_pct`: share of teammates' baskets assisted on the floor (only when
#'   player makes `p2m`, `p3m` are available).
#' * `efg_pct`: effective FG% (also needs makes).
#'
#' All are returned as proportions (0.25, not 25).
#'
#' @param players Player season totals (`minutes`, `pts`, `p2a`, `p3a`,
#'   `fta`, `tov`, `orb`, `drb`, `ast`, `stl`, `blk`; optionally `p2m`,
#'   `p3m`) with `team` and, if present, `league` and `season`.
#' @param teams Team totals with opponent columns (`o_` prefix), as in
#'   `team_seasons`; `min` = total player minutes.
#' @param ft_coef Free-throw weight in possessions (0.44).
#' @return `players` with the rate columns added.
#' @export
#' @examples
#' pr <- player_rates(player_seasons, team_seasons)
#' head(pr[order(-pr$usg_pct), c("player", "usg_pct", "ts_pct")])
player_rates <- function(players, teams, ft_coef = 0.44) {
  by <- intersect(c("league", "season", "team"), intersect(names(players), names(teams)))
  t <- as.data.frame(teams)
  t$t_fga <- t$p2a + t$p3a
  t$t_fgm <- t$p2m + t$p3m
  t$o_poss <- t$o_p2a + t$o_p3a + ft_coef * t$o_fta - t$o_orb + t$o_tov
  t <- t[, c(by, "min", "t_fga", "t_fgm", "fta", "tov", "orb", "drb", "o_orb", "o_drb", "o_p2a", "o_poss")]
  names(t)[-seq_along(by)] <- paste0(".t_", names(t)[-seq_along(by)])
  d <- dplyr::left_join(as.data.frame(players), t, by = by)
  fga <- d$p2a + d$p3a
  share <- d$minutes / (d$.t_min / 5)  # share of team minutes on the floor
  d$ts_pct <- d$pts / (2 * (fga + ft_coef * d$fta))
  d$usg_pct <- (fga + ft_coef * d$fta + d$tov) / (share * (d$.t_t_fga + ft_coef * d$.t_fta + d$.t_tov))
  d$tov_pct <- d$tov / (fga + ft_coef * d$fta + d$tov)
  d$orb_pct <- d$orb / (share * (d$.t_orb + d$.t_o_drb))
  d$drb_pct <- d$drb / (share * (d$.t_drb + d$.t_o_orb))
  d$stl_pct <- d$stl / (share * d$.t_o_poss)
  d$blk_pct <- d$blk / (share * d$.t_o_p2a)
  if (all(c("p2m", "p3m") %in% names(d))) {
    fgm <- d$p2m + d$p3m
    d$efg_pct <- (fgm + 0.5 * d$p3m) / fga
    d$ast_pct <- d$ast / (share * d$.t_t_fgm - fgm)
  }
  d[grepl("^\\.t_", names(d))] <- NULL
  tibble::as_tibble(d)
}

#' Expected wins and luck
#'
#' Pythagorean expectation: a team's win share follows from points scored
#' and allowed as PTS^k / (PTS^k + OPP^k). The exponent `k` is fitted per
#' league by least squares on log(W/L) = k log(PTS/OPP) (about 14 in the
#' NBA). `luck` = actual minus expected wins. Because a team has little
#' control over how well opponents shoot 3s, `o_p3_vs_league` (opponents'
#' 3P% minus the league's) is added as a second luck marker.
#'
#' @param teams Team season totals with `w`, `l`, `pts`, `o_pts` and
#'   optionally `o_p3m`, `o_p3a`.
#' @param exponent Fixed exponent instead of fitting one.
#' @return `teams` with `exponent`, `exp_win_pct`, `exp_w`, `luck` and,
#'   if possible, `o_p3_vs_league`.
#' @export
#' @examples
#' ew <- expected_wins(team_seasons)
#' head(ew[order(-ew$luck), c("league", "team", "w", "exp_w", "luck")])
expected_wins <- function(teams, exponent = NULL) {
  d <- as.data.frame(teams)
  if (!"league" %in% names(d)) d$league <- "all"
  d$exponent <- NA_real_
  for (lg in unique(d$league)) {
    i <- d$league == lg
    k <- exponent %||% unname(stats::coef(stats::lm(log(w / l) ~ 0 + log(pts / o_pts),
                                                    data = d[i & d$w > 0 & d$l > 0, ]))[1])
    d$exponent[i] <- k
  }
  d$exp_win_pct <- d$pts^d$exponent / (d$pts^d$exponent + d$o_pts^d$exponent)
  d$exp_w <- d$exp_win_pct * (d$w + d$l)
  d$luck <- d$w - d$exp_w
  if (all(c("o_p3m", "o_p3a") %in% names(d))) {
    d <- d |>
      dplyr::group_by(.data$league) |>
      dplyr::mutate(o_p3_vs_league = .data$o_p3m / .data$o_p3a - sum(.data$o_p3m) / sum(.data$o_p3a)) |>
      dplyr::ungroup()
  }
  tibble::as_tibble(d)
}

#' Who won more (or fewer) games than their points say?
#'
#' Dumbbell chart from [expected_wins()]: open circle = wins expected from
#' points scored and allowed, filled circle = actual wins; red = luckier than
#' the margin says, blue = unluckier. Teams sorted by luck; the
#' `n` luckiest and unluckiest per league are shown.
#'
#' @param ew Output of [expected_wins()].
#' @param n Teams shown at each end per league (all teams if `NULL`).
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' plot_luck(expected_wins(team_seasons), n = 5)
plot_luck <- function(ew, n = NULL, title = NULL, subtitle = NULL, caption = NULL) {
  ew <- as.data.frame(ew)
  if (!is.null(n)) {
    ew <- ew |>
      dplyr::group_by(.data$league) |>
      dplyr::arrange(.data$luck, .by_group = TRUE) |>
      dplyr::filter(dplyr::row_number() <= n | dplyr::row_number() > dplyr::n() - n) |>
      dplyr::ungroup() |>
      as.data.frame()
  }
  ew$key <- paste(ew$league, ew$team)
  ew$key <- factor(ew$key, levels = ew$key[order(ew$luck)])
  ew$side <- ifelse(ew$luck > 0, "lucky", "unlucky")
  pal <- c(lucky = ggbasket_colours$above, unlucky = ggbasket_colours$below)
  ggplot2::ggplot(ew, ggplot2::aes(y = .data$key)) +
    ggplot2::geom_segment(ggplot2::aes(x = .data$exp_w, xend = .data$w, yend = .data$key, colour = .data$side),
                          linewidth = 1.6, alpha = 0.45, lineend = "round") +
    ggplot2::geom_point(ggplot2::aes(x = .data$exp_w), shape = 21, size = 2.6, fill = ggbasket_colours$paper,
                        colour = "grey40", stroke = 0.8) +
    ggplot2::geom_point(ggplot2::aes(x = .data$w, colour = .data$side), size = 3) +
    ggplot2::geom_text(ggplot2::aes(x = pmax(.data$w, .data$exp_w), label = sprintf("%+.1f", .data$luck),
                                    colour = .data$side), hjust = -0.4, size = 3, fontface = "bold") +
    ggplot2::scale_colour_manual(values = pal, guide = "none") +
    ggplot2::scale_y_discrete(labels = function(x) sub("^\\S+ ", "", x)) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.05, 0.12))) +
    ggplot2::facet_wrap(~league, scales = "free") +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Wins", y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "Open circle = wins expected from points scored and allowed (Pythagorean); filled = actual wins")
}
