#' Scoring probability and expected points along one variable
#'
#' Nadaraya-Watson Gaussian kernel smoothing, with two additions that make
#' the curve readable:
#' a bootstrap confidence band, so a wiggle can be told apart from noise, and
#' the density of attempts, so the curve can be drawn thick where shots
#' actually happen and thin where it rests on a handful of attempts.
#'
#' @param shots A data frame with `made` and the variable `x`; for expected
#'   points also `value` (or `pts`).
#' @param x Name of the variable (e.g. `"dist"`, `"playlength"`,
#'   `"periodTime"`). `"dist"` is computed from `x`, `y` if absent.
#' @param by Optional grouping column (e.g. `"player"`).
#' @param outcome `"prob"` (scoring probability) or `"points"` (expected
#'   points per shot).
#' @param bw Kernel bandwidth in units of `x`. Default: Silverman's rule on the
#'   pooled data.
#' @param n_boot Bootstrap resamples for the band (0 to skip).
#' @param level Width of the band.
#' @param grid Points at which to evaluate; default 100 points over the
#'   central 99% of `x`.
#' @param min_density Grid points where a group's attempt density falls below
#'   this fraction of its peak are dropped, so curves are not extrapolated
#'   into places a player never shoots from.
#' @param split_value Smooth 2-point and 3-point attempts separately. A
#'   kernel smoother run across the 3-point line blurs the jump in value into
#'   a fake ramp; splitting keeps the discontinuity (use with distance).
#' @return A tibble with `x`, `estimate`, `lower`, `upper`, `density` and the
#'   grouping column.
#' @export
#' @examples
#' sc <- shot_curve(subset(shots_2024, league == "NBA"), "dist", outcome = "points", n_boot = 0)
#' head(sc)
shot_curve <- function(shots, x, by = NULL, outcome = c("prob", "points"), bw = NULL,
                       n_boot = 200, level = 0.9, grid = NULL, min_density = 0.02,
                       split_value = FALSE) {
  outcome <- match.arg(outcome)
  shots <- as.data.frame(shots)
  if (identical(x, "dist") && !"dist" %in% names(shots)) shots$dist <- sqrt(shots$x^2 + shots$y^2)
  shots$made <- as.numeric(as.logical(shots$made))
  y <- if (outcome == "prob") shots$made else {
    if ("pts" %in% names(shots)) shots$pts else shots$value * shots$made
  }
  shots$.y <- y
  xx <- shots[[x]]
  keep <- is.finite(xx) & is.finite(shots$.y)
  shots <- shots[keep, ]
  xx <- xx[keep]
  bw <- bw %||% (0.9 * min(stats::sd(xx), stats::IQR(xx) / 1.34) * length(xx)^(-1 / 5) * 2)
  grid <- grid %||% seq(stats::quantile(xx, 0.005), stats::quantile(xx, 0.995), length.out = 100)
  shots$.grp <- if (is.null(by)) "all" else as.character(shots[[by]])
  shots$.val <- if (split_value) shots$value else 0
  groups <- split(shots, list(shots$.grp, shots$.val), drop = TRUE, sep = "\r")
  out <- lapply(names(groups), function(gname) {
    d <- groups[[gname]]
    g <- d$.grp[1]
    est <- nw_smooth(d[[x]], d$.y, grid, bw)
    dens <- vapply(grid, function(g0) mean(stats::dnorm(g0, d[[x]], bw)), numeric(1))
    lower <- upper <- rep(NA_real_, length(grid))
    if (n_boot > 0) {
      boots <- replicate(n_boot, {
        i <- sample.int(nrow(d), replace = TRUE)
        nw_smooth(d[[x]][i], d$.y[i], grid, bw)
      })
      lower <- apply(boots, 1, stats::quantile, (1 - level) / 2, na.rm = TRUE)
      upper <- apply(boots, 1, stats::quantile, 1 - (1 - level) / 2, na.rm = TRUE)
    }
    res <- tibble::tibble(x = grid, estimate = est, lower = lower, upper = upper,
                          density = dens, attempts = nrow(d), group = g, value = d$.val[1])
    res
  })
  out <- dplyr::bind_rows(out)
  # density relative to the group's peak (across 2s and 3s), weighted by volume
  out <- out |>
    dplyr::group_by(.data$group) |>
    dplyr::mutate(density = .data$density * .data$attempts / max(.data$density * .data$attempts)) |>
    dplyr::ungroup()
  out <- out[out$density >= min_density, ]
  if (!split_value) out$value <- NULL
  if (!is.null(by)) names(out)[names(out) == "group"] <- by else out$group <- NULL
  attr(out, "x") <- x
  attr(out, "outcome") <- outcome
  attr(out, "bw") <- bw
  out
}

nw_smooth <- function(x, y, grid, bw) {
  vapply(grid, function(g0) {
    w <- stats::dnorm(g0, x, bw)
    sum(w * y) / sum(w)
  }, numeric(1))
}

#' Plot shooting curves
#'
#' Line = estimate, ribbon = bootstrap band, line width = how many shots are
#' taken there (attempt density), so the eye is drawn to where the volume is.
#' Group labels are placed at the right end of each line instead of in a
#' legend. An optional dashed reference line marks e.g. the team average.
#'
#' @param curve Output of [shot_curve()].
#' @param highlight Groups to colour; others are drawn in grey for context.
#' @param ref Optional horizontal reference value.
#' @param ref_label Label for the reference line.
#' @param vlines Optional named numeric vector of vertical markers, e.g.
#'   `c("3-pt line" = 7.24)`.
#' @param xlab,ylab,title,subtitle,caption Labels.
#' @export
#' @examples
#' sh <- subset(shots_2024, player %in% c("Stephen Curry", "Nikola Jokic"))
#' sc <- shot_curve(sh, "dist", by = "player", outcome = "points", n_boot = 50)
#' plot_shot_curve(sc, vlines = c("NBA 3-pt line" = 7.24),
#'                 xlab = "Shot distance (m)")
plot_shot_curve <- function(curve, highlight = NULL, ref = NULL, ref_label = NULL, vlines = NULL,
                            xlab = NULL, ylab = NULL, title = NULL, subtitle = NULL,
                            caption = NULL) {
  by <- setdiff(names(curve), c("x", "estimate", "lower", "upper", "density", "attempts", "value"))
  outcome <- attr(curve, "outcome") %||% "prob"
  if (length(by) == 0) {
    curve$group <- "All shots"
    by <- "group"
  }
  by <- by[1]
  curve$.g <- as.character(curve[[by]])
  curve$.seg <- if ("value" %in% names(curve)) paste(curve$.g, curve$value) else curve$.g
  groups <- unique(curve$.g)
  highlight <- highlight %||% groups
  pal <- stats::setNames(rep(ggbasket_colours$context, length(groups)), groups)
  hl_cols <- c(ggbasket_colours$highlight, ggbasket_colours$categorical[-2])
  pal[highlight] <- rep_len(hl_cols, length(highlight))
  # leagues keep their own colours
  lg <- intersect(highlight, names(ggbasket_colours$league))
  pal[lg] <- ggbasket_colours$league[lg]
  curve$.hl <- curve$.g %in% highlight
  ends <- curve |>
    dplyr::group_by(.data$.g) |>
    dplyr::slice_max(.data$x, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()
  ylab <- ylab %||% if (outcome == "prob") "Scoring probability" else "Expected points per shot"
  yfmt <- if (outcome == "prob") scales::label_percent(accuracy = 1) else scales::label_number(accuracy = 0.1)
  p <- ggplot2::ggplot(curve, ggplot2::aes(.data$x, .data$estimate, group = .data$.seg))
  if (!is.null(vlines)) {
    p <- p + ggplot2::geom_vline(xintercept = vlines, colour = "grey60", linewidth = 0.4, linetype = "22") +
      ggplot2::annotate("text", x = vlines, y = Inf, label = names(vlines),
                        vjust = 1.4 + 1.5 * (seq_along(vlines) - 1), hjust = -0.05,
                        size = 3, colour = "grey40")
  }
  if (!is.null(ref)) {
    p <- p + ggplot2::geom_hline(yintercept = ref, colour = "grey45", linetype = "dashed", linewidth = 0.4)
    if (!is.null(ref_label)) {
      p <- p + ggplot2::annotate("text", x = min(curve$x), y = ref, label = ref_label, vjust = -0.5,
                                 hjust = 0, size = 3, colour = "grey40")
    }
  }
  if (any(!is.na(curve$lower))) {
    p <- p + ggplot2::geom_ribbon(data = curve[curve$.hl, ],
                                  ggplot2::aes(ymin = .data$lower, ymax = .data$upper, fill = .data$.g,
                                               group = .data$.seg),
                                  alpha = max(0.05, 0.3 / length(highlight)), colour = NA)
  }
  p <- p +
    ggplot2::geom_line(data = curve[!curve$.hl, ], ggplot2::aes(linewidth = .data$density),
                       colour = ggbasket_colours$context, lineend = "round") +
    ggplot2::geom_line(data = curve[curve$.hl, ], ggplot2::aes(colour = .data$.g, linewidth = .data$density),
                       lineend = "round") +
    ggrepel::geom_text_repel(family = gb_family(), data = ends[ends$.g %in% highlight, ],
                             ggplot2::aes(label = .data$.g, colour = .data$.g),
                             hjust = 0, nudge_x = diff(range(curve$x)) * 0.02, direction = "y",
                             segment.colour = NA, size = 3.5, fontface = "bold") +
    ggplot2::scale_colour_manual(values = pal, guide = "none") +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::scale_linewidth(range = c(0.3, 2.4), name = "Line width = share of attempts",
                             breaks = NULL) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.02, 0.18))) +
    ggplot2::scale_y_continuous(labels = yfmt) +
    theme_ggbasket() +
    ggplot2::theme(legend.position = "none") +
    ggplot2::labs(x = xlab %||% attr(curve, "x"), y = ylab, title = title, caption = caption,
                  subtitle = subtitle %||% "Line width shows where the shots are taken; ribbon = 90% bootstrap band")
  p
}
