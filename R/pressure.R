#' Game situations that put a shooter under pressure
#'
#' Following Zuccolotto et al. (2018), every field-goal
#' attempt in a play-by-play is tagged with five situations that may make a
#' shot harder, with their cut-offs:
#'
#' * `shot_clock`: seconds left on the shot clock, in four bands
#'   (`"early"` > 17, `"early-middle"` 10-17, `"middle-end"` 2-10,
#'   `"time-end"` <= 2). Play-by-play feeds have no shot clock,
#'   so it is *estimated* as 24 minus the seconds since the opponent's last
#'   action (shot, rebound, turnover), with a reset to `orb_reset` seconds
#'   after an offensive rebound.
#' * `period_end`: the last 100 seconds of a period.
#' * `score_diff`: shooting team's margin before the shot, in five
#'   bands.
#' * `team_misses`: share of the team's field goals missed so far in the game,
#'   split at its 25th and 75th percentiles.
#' * `prev_miss`: whether the shooter missed their previous shot in the game.
#'
#' @param pbp Play-by-play in the ggbasket layout (see [pbp]), all teams
#'   of each game.
#' @param league League label for [expected_fg()].
#' @param orb_reset Shot clock after an offensive rebound: 14 (NBA from
#'   2018/19, FIBA from 2014) or 24 (NBA before 2018/19).
#' @return The field-goal attempts as from [as_ggbasket_shots()], plus
#'   `shot_clock_left`, `score_margin`, `team_miss_rate` and the five
#'   situation factors.
#' @export
pressure_situations <- function(pbp, league = "NBA", orb_reset = 14) {
  d <- as.data.frame(pbp)
  d$.row <- seq_len(nrow(d))
  d <- d[order(d$game_id, d$period, d$periodTime, d$.row), ]
  d$team <- as.character(d$team)
  active <- !d$event_type %in% c("sub", "timeout", "foul", "jump ball", "unknown", "ejection",
                                 "violation", "start of period", "end of period") &
    !is.na(d$team) & d$team != ""
  # shot clock used: time since the team gained the ball (the opponent's last
  # action), or since its own offensive rebound, which resets the clock to orb_reset
  d$clock_used <- NA_real_
  key <- paste(d$game_id, d$period)
  for (k in unique(key)) {
    i <- which(key == k)
    last_team <- ""; last_time <- 0; last_missed <- FALSE
    start <- 0; offset <- 0; owner <- ""
    for (r in i) {
      tm <- d$team[r]
      now <- d$periodTime[r]
      if (active[r]) {
        if (tm != owner) {
          owner <- tm; start <- if (last_team == "") 0 else last_time; offset <- 0
        } else if (d$event_type[r] == "rebound" && last_team == tm && last_missed) {
          start <- now; offset <- 24 - orb_reset
        }
        last_team <- tm; last_time <- now
        last_missed <- d$event_type[r] == "miss"
      }
      if (!is.na(tm) && tm != "") d$clock_used[r] <- if (tm == owner) now - start + offset else 0
    }
  }
  d$shot_clock_left <- pmin(24, pmax(0, 24 - d$clock_used))
  fg <- d$result %in% c("made", "missed") & d$ShotType %in% c("2P", "3P") & !is.na(d$original_x)
  pts_now <- ifelse(d$result == "made", ifelse(d$ShotType == "3P", 3, 2), 0)
  is_home <- d$team == as.character(d$hometeam)
  # scores in the data already include the current basket
  home_before <- d$home_score - ifelse(is_home, pts_now, 0) * fg
  away_before <- d$away_score - ifelse(!is_home, pts_now, 0) * fg
  d$score_margin <- ifelse(is_home, home_before - away_before, away_before - home_before)
  d <- d[fg, ]
  # team miss rate and the shooter's previous result, before each shot
  d <- d |>
    dplyr::group_by(.data$game_id, .data$team) |>
    dplyr::mutate(team_miss_rate = dplyr::lag(cumsum(.data$result == "missed") / dplyr::row_number())) |>
    dplyr::group_by(.data$game_id, .data$player) |>
    dplyr::mutate(prev = dplyr::lag(.data$result)) |>
    dplyr::ungroup()
  shots <- as_ggbasket_shots(d, league = league)
  q <- stats::quantile(d$team_miss_rate, c(0.25, 0.75), na.rm = TRUE)
  shots$shot_clock_left <- d$shot_clock_left
  shots$score_margin <- d$score_margin
  shots$team_miss_rate <- d$team_miss_rate
  shots$shot_clock <- cut(d$shot_clock_left, c(-Inf, 2, 10, 17, Inf),
                          labels = c("time-end", "middle-end", "early-middle", "early"))
  shots$shot_clock <- stats::relevel(shots$shot_clock, "early")
  shots$period_end <- factor(ifelse(d$periodTime > max(d$periodTime, na.rm = TRUE) - 100,
                                    "last 100 s", "normal"), levels = c("normal", "last 100 s"))
  shots$score_diff <- cut(d$score_margin, c(-Inf, -15, -5, 1, 6, Inf),
                          labels = c("down 15+", "down 5-15", "close (-5 to +1)", "up 1-6", "up 6+"))
  shots$score_diff <- stats::relevel(shots$score_diff, "up 1-6")
  shots$team_misses <- cut(d$team_miss_rate, c(-Inf, q, Inf),
                           labels = c("team shooting well", "team average", "team shooting badly"))
  shots$team_misses <- stats::relevel(shots$team_misses, "team average")
  shots$prev_miss <- factor(ifelse(is.na(d$prev), "first shot",
                                   ifelse(d$prev == "missed", "missed last shot", "made last shot")),
                            levels = c("made last shot", "missed last shot", "first shot"))
  shots
}

#' How much each pressure situation changes the chance of scoring
#'
#' One logistic regression (instead of a classification tree) that
#' holds shot location fixed: the location-based expected FG% from
#' [expected_fg()] enters as an offset, so each coefficient is the effect of
#' the situation *on top of* where the shot was taken, adjusted for the other
#' situations. Effects are reported as average changes in make probability
#' (percentage points) against each situation's reference level, with 90%
#' intervals.
#'
#' @param shots Output of [pressure_situations()], with `xfg` from
#'   [expected_fg()] (computed if absent).
#' @param situations Situation columns to include.
#' @param level Interval width.
#' @return A tibble: `situation`, `level`, `reference`, `effect`, `lower`,
#'   `upper`, `n`.
#' @export
pressure_effects <- function(shots, situations = c("shot_clock", "period_end", "score_diff",
                                                   "team_misses", "prev_miss"),
                             level = 0.9) {
  if (!"xfg" %in% names(shots)) shots <- expected_fg(shots)
  shots <- as.data.frame(shots)
  shots$off <- stats::qlogis(pmin(pmax(shots$xfg, 0.01), 0.99))
  f <- stats::as.formula(paste("made ~ offset(off) +", paste(situations, collapse = " + ")))
  fit <- stats::glm(f, family = stats::binomial(), data = shots)
  co <- summary(fit)$coefficients
  slope <- mean(shots$xfg * (1 - shots$xfg))  # dp/dlogit at the average shot
  z <- stats::qnorm(1 - (1 - level) / 2)
  out <- lapply(situations, function(s) {
    lev <- levels(shots[[s]])
    rows <- paste0(s, lev[-1])
    tibble::tibble(situation = s, level = lev[-1], reference = lev[1],
                   effect = slope * co[rows, "Estimate"],
                   lower = slope * (co[rows, "Estimate"] - z * co[rows, "Std. Error"]),
                   upper = slope * (co[rows, "Estimate"] + z * co[rows, "Std. Error"]),
                   n = as.integer(table(shots[[s]])[lev[-1]]))
  })
  dplyr::bind_rows(out)
}

#' Plot pressure effects
#'
#' One row per situation level: dot = change in make probability against the
#' reference level, bar = interval. Red = easier than expected, blue =
#' harder, grey = interval crosses zero.
#'
#' @param eff Output of [pressure_effects()].
#' @param labels Optional named vector of display names for the situations.
#' @param title,subtitle,caption Labels.
#' @export
plot_pressure <- function(eff, labels = NULL, title = NULL, subtitle = NULL, caption = NULL) {
  labels <- labels %||% c(shot_clock = "Shot clock (est.)", period_end = "End of period",
                          score_diff = "Score", team_misses = "Team's shooting so far",
                          prev_miss = "Shooter's last shot")
  eff$facet <- sprintf("%s  \u00b7  vs %s", ifelse(eff$situation %in% names(labels),
                                                     labels[eff$situation], eff$situation), eff$reference)
  eff$facet <- factor(eff$facet, levels = unique(eff$facet))
  eff$sig <- ifelse(eff$lower > 0, "up", ifelse(eff$upper < 0, "down", "none"))
  eff$level <- factor(eff$level, levels = rev(unique(eff$level)))
  ggplot2::ggplot(eff, ggplot2::aes(.data$effect, .data$level, colour = .data$sig)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey55", linewidth = 0.4) +
    ggplot2::geom_linerange(ggplot2::aes(xmin = .data$lower, xmax = .data$upper), linewidth = 2.4,
                            alpha = 0.35) +
    ggplot2::geom_point(size = 3) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.1f", 100 * .data$effect)), vjust = -1.1,
                       size = 3, show.legend = FALSE) +
    ggplot2::scale_colour_manual(values = c(up = ggbasket_colours$above, down = ggbasket_colours$below,
                                            none = "grey55"), guide = "none") +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f pts", 100 * x)) +
    ggplot2::facet_grid(facet ~ ., scales = "free_y", space = "free_y", switch = "y") +
    theme_ggbasket(grid = "x") +
    ggplot2::theme(strip.placement = "outside", strip.text.y.left = ggplot2::element_text(angle = 0),
                   strip.text = ggplot2::element_text(hjust = 0, vjust = 1, size = ggplot2::rel(0.9))) +
    ggplot2::labs(x = "Change in make probability, on top of shot location (percentage points)", y = NULL,
                  title = title, caption = caption,
                  subtitle = subtitle %||% "Logistic regression with location-based expected FG% as offset; bars = 90% intervals")
}
