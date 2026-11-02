#' Expected make probability of every shot
#'
#' A league-wide model of how likely a shot from a given spot is to go in.
#' With `mgcv` installed this is a logistic GAM with a smooth of distance and
#' angle per league and shot value; otherwise a binned average (0.5 m
#' distance bands by zone). Extra context columns (shot clock, score margin)
#' can be added as `extra` smooth terms, which is the regression version of
#' a classification-tree "high-pressure" model (see [pressure_effects()]).
#'
#' @param shots Shots with `x`, `y`, `made` (and optionally `value`,
#'   `league`).
#' @param extra Optional character vector of extra numeric columns to adjust
#'   for (each enters as a smooth).
#' @param method `"gam"` or `"bins"`.
#' @return `shots` with a column `xfg`.
#' @export
expected_fg <- function(shots, extra = NULL, method = c("gam", "bins")) {
  method <- match.arg(method)
  shots <- prep_shots(shots)
  shots$dist <- sqrt(shots$x^2 + shots$y^2)
  shots$angle <- atan2(abs(shots$x), shots$y)
  shots$grp <- interaction(shots$league, shots$value, drop = TRUE)
  if (method == "gam" && !requireNamespace("mgcv", quietly = TRUE)) method <- "bins"
  if (method == "gam") {
    shots$xfg <- NA_real_
    for (g in levels(shots$grp)) {
      i <- which(shots$grp == g)
      d <- shots[i, ]
      f <- "made ~ s(dist, k = 10) + s(angle, k = 5) + ti(dist, angle, k = 4)"
      if (length(extra)) f <- paste(f, paste0("+ s(", extra, ", k = 6)", collapse = " "))
      fit <- mgcv::bam(stats::as.formula(f), family = stats::binomial(), data = d, discrete = TRUE)
      shots$xfg[i] <- as.numeric(stats::predict(fit, d, type = "response"))
    }
  } else {
    shots$band <- floor(shots$dist / 0.5)
    shots$zone <- shot_zone(shots$x, shots$y, shots$league, shots$value)
    shots <- shots |>
      dplyr::group_by(.data$league, .data$value, .data$zone, .data$band) |>
      dplyr::mutate(xfg = mean(.data$made)) |>
      dplyr::ungroup()
    shots$band <- NULL
  }
  shots$grp <- NULL
  shots
}

#' Shot-making over expected
#'
#' The idea of grading every shot by
#' `made - P(make)`, so a difficult make is worth more than an easy one,
#' (Zuccolotto et al., 2018), turned into a per-player table:
#'
#' * `xfg`: average expected FG% of the player's shots (shot difficulty; lower
#'   = harder diet);
#' * `fg_oe`: FG% over expected, shrunk towards 0 by
#'   `prior_n` pseudo-attempts so that low-volume players do not top the list;
#' * `pts_added`: points added over an average shooter taking the same shots.
#'
#' @param shots Shots with an `xfg` column (see [expected_fg()]), or raw shots
#'   (then `expected_fg()` is called on them).
#' @param by Grouping columns, default `"player"`.
#' @param prior_n Shrinkage strength in attempts.
#' @export
shot_making <- function(shots, by = "player", prior_n = 100) {
  if (!"xfg" %in% names(shots)) shots <- expected_fg(shots)
  shots <- prep_shots(shots)
  shots |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(by, "league")))) |>
    dplyr::summarise(attempts = dplyr::n(), fg = mean(.data$made), xfg = mean(.data$xfg),
                     three_share = mean(.data$value == 3),
                     raw_oe = mean(.data$made - .data$xfg),
                     pts_added = sum((.data$made - .data$xfg) * .data$value),
                     .groups = "drop") |>
    dplyr::mutate(fg_oe = .data$raw_oe * .data$attempts / (.data$attempts + prior_n))
}

#' Shot difficulty vs shot making
#'
#' Each player is a point: x = how hard their shots are (expected FG%,
#' reversed so harder is to the right), y = how much better or worse than
#' expected they finish them. Point size = attempts. The four corners have a
#' story (tough-shot makers, efficient finishers, ...), which is written on the
#' plot.
#'
#' @param sm Output of [shot_making()].
#' @param label Column with names.
#' @param highlight Names to colour and always label.
#' @param n_label Also label the `n_label` most extreme players.
#' @param min_attempts Drop players with fewer attempts.
#' @param title,subtitle,caption Labels.
#' @export
plot_shot_making <- function(sm, label = "player", highlight = NULL, n_label = 8,
                             min_attempts = 200, title = NULL, subtitle = NULL, caption = NULL) {
  sm <- sm[sm$attempts >= min_attempts, ]
  sm$.lab <- as.character(sm[[label]])
  sm$.score <- abs(scale(sm$fg_oe)[, 1]) + abs(scale(sm$xfg)[, 1])
  top <- sm$.lab[order(-sm$.score)][seq_len(min(n_label, nrow(sm)))]
  sm$.show <- sm$.lab %in% c(top, highlight)
  sm$.hl <- sm$.lab %in% highlight
  mx <- stats::median(sm$xfg)
  corners <- data.frame(
    # x is reversed on the plot, so +Inf is drawn on the left
    x = c(Inf, -Inf, Inf, -Inf), y = c(Inf, Inf, -Inf, -Inf),
    hjust = c(-0.05, 1.05, -0.05, 1.05), vjust = c(1.5, 1.5, -0.6, -0.6),
    label = c("Easy shots, made them", "Hard shots, made them anyway",
              "Easy shots, missed them", "Hard shots, and it showed")
  )
  ggplot2::ggplot(sm, ggplot2::aes(.data$xfg, .data$fg_oe)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey50", linewidth = 0.4) +
    ggplot2::geom_vline(xintercept = mx, colour = "grey50", linewidth = 0.4, linetype = "22") +
    ggplot2::geom_text(data = corners, ggplot2::aes(.data$x, .data$y, label = .data$label,
                                                    hjust = .data$hjust, vjust = .data$vjust),
                       inherit.aes = FALSE, colour = "grey55", fontface = "italic", size = 3.2) +
    ggplot2::geom_point(ggplot2::aes(size = .data$attempts, colour = .data$league), alpha = 0.45) +
    ggplot2::geom_point(data = sm[sm$.hl, ], ggplot2::aes(size = .data$attempts),
                        shape = 21, fill = NA, colour = "black", stroke = 0.9, show.legend = FALSE) +
    ggrepel::geom_text_repel(family = gb_family(), data = sm[sm$.show, ], ggplot2::aes(label = .data$.lab),
                             size = 3.2, min.segment.length = 0, box.padding = 0.4,
                             fontface = ifelse(sm$.hl[sm$.show], "bold", "plain"), seed = 1) +
    ggplot2::scale_x_reverse(labels = scales::label_percent(accuracy = 1)) +
    ggplot2::scale_y_continuous(labels = function(v) sprintf("%+.1f", 100 * v)) +
    ggplot2::scale_size_area(max_size = 7, name = "Attempts") +
    scale_colour_league(name = NULL, guide = if (length(unique(sm$league)) > 1) "legend" else "none") +
    theme_ggbasket() +
    ggplot2::labs(x = "Expected FG% of their shots  (harder \u2192)",
                  y = "FG% over expected (percentage points, shrunk)",
                  title = title, caption = caption,
                  subtitle = subtitle %||% "Each shot graded against a league model of make probability by location")
}
