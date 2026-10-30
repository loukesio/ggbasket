#' Quadrant scatter: two stats, an average cross and stories in the corners
#'
#' One function for the book's `scatterplot()` and `bubbleplot()`: points
#' (optionally sized and coloured by two more variables), dashed lines at the
#' average of each axis, corner captions, and labels for highlighted and most
#' extreme cases (repelled, so they never overlap).
#'
#' @param data A data frame.
#' @param x,y Column names.
#' @param label Column with names.
#' @param size,colour Optional columns mapped to point size and colour.
#' @param highlight Names to colour and label.
#' @param n_label Also label the `n_label` points farthest from the centre.
#' @param corners Optional four captions: top-left, top-right, bottom-left,
#'   bottom-right.
#' @param centre `"mean"` or `"median"` reference lines.
#' @param xlab,ylab,title,subtitle,caption Labels.
#' @param size_lab,colour_lab Legend titles.
#' @export
#' @examples
#' p <- subset(player_seasons, league == "NBA" & minutes >= 1500)
#' p$ast36 <- 36 * p$ast / p$minutes
#' p$tov36 <- 36 * p$tov / p$minutes
#' plot_quadrant(p, "ast36", "tov36", label = "player", size = "minutes",
#'               corners = c("Turnover-prone", "High-usage creators",
#'                           "Low usage", "Careful creators"),
#'               xlab = "Assists per 36", ylab = "Turnovers per 36")
plot_quadrant <- function(data, x, y, label = NULL, size = NULL, colour = NULL, highlight = NULL,
                          n_label = 10, corners = NULL, centre = c("mean", "median"),
                          xlab = x, ylab = y, size_lab = size, colour_lab = colour,
                          title = NULL, subtitle = NULL, caption = NULL) {
  centre <- match.arg(centre)
  f <- if (centre == "mean") mean else stats::median
  data <- as.data.frame(data)
  data <- data[is.finite(data[[x]]) & is.finite(data[[y]]), ]
  cx <- f(data[[x]]); cy <- f(data[[y]])
  data$.lab <- if (!is.null(label)) as.character(data[[label]]) else as.character(seq_len(nrow(data)))
  d2 <- ((data[[x]] - cx) / stats::sd(data[[x]]))^2 + ((data[[y]] - cy) / stats::sd(data[[y]]))^2
  data$.show <- data$.lab %in% c(highlight, data$.lab[order(-d2)][seq_len(min(n_label, nrow(data)))])
  data$.hl <- data$.lab %in% highlight
  pt_aes <- ggplot2::aes(.data[[x]], .data[[y]])
  pt_args <- list(alpha = 0.55)
  if (!is.null(size)) pt_aes$size <- rlang::quo(.data[[size]]) else pt_args$size <- 2.2
  if (!is.null(colour)) pt_aes$colour <- rlang::quo(.data[[colour]]) else
    pt_args$colour <- ifelse(data$.hl, ggbasket_colours$highlight, "grey55")
  p <- ggplot2::ggplot(data, ggplot2::aes(.data[[x]], .data[[y]])) +
    ggplot2::geom_vline(xintercept = cx, colour = "grey60", linetype = "22") +
    ggplot2::geom_hline(yintercept = cy, colour = "grey60", linetype = "22")
  if (!is.null(corners)) {
    cdf <- data.frame(x = c(-Inf, Inf, -Inf, Inf), y = c(Inf, Inf, -Inf, -Inf),
                      hjust = c(-0.05, 1.05, -0.05, 1.05), vjust = c(1.5, 1.5, -0.7, -0.7),
                      label = corners)
    p <- p + ggplot2::geom_text(data = cdf, ggplot2::aes(.data$x, .data$y, label = .data$label,
                                                         hjust = .data$hjust, vjust = .data$vjust),
                                inherit.aes = FALSE, colour = "grey55", fontface = "italic", size = 3.3)
  }
  p <- p + do.call(ggplot2::geom_point, c(list(mapping = pt_aes), pt_args))
  if (any(data$.hl)) {
    p <- p + ggplot2::geom_point(data = data[data$.hl, ], shape = 21, fill = NA, colour = "black",
                                 stroke = 0.8, size = if (is.null(size)) 2.6 else 4)
  }
  p <- p + ggrepel::geom_text_repel(data = data[data$.show, ], ggplot2::aes(label = .data$.lab),
                                    size = 3.1, colour = ifelse(data$.hl[data$.show], "black", "grey30"),
                                    fontface = ifelse(data$.hl[data$.show], "bold", "plain"),
                                    min.segment.length = 0.2, box.padding = 0.35, seed = 6,
                                    max.overlaps = 30) +
    theme_ggbasket() +
    ggplot2::labs(x = xlab, y = ylab, title = title, subtitle = subtitle, caption = caption)
  if (!is.null(size)) p <- p + ggplot2::scale_size_area(max_size = 5, name = size_lab)
  if (!is.null(colour) && is.numeric(data[[colour]])) {
    p <- p + ggplot2::scale_colour_viridis_c(option = "C", end = 0.9, name = colour_lab)
  } else if (!is.null(colour) && colour == "league") {
    p <- p + scale_colour_league(name = NULL, guide = if (length(unique(data$league)) > 1) "legend" else "none")
  } else if (!is.null(colour)) {
    p <- p + ggplot2::scale_colour_manual(values = categorical_palette(data[[colour]]), name = colour_lab)
  }
  p
}

#' Percentile fingerprint of players or teams
#'
#' Each variable becomes its percentile within a reference group (league,
#' position, ...), so all axes share one meaningful 0-100 scale; this fixes the
#' book's radial plots, whose common min-max axis squashed low-range
#' variables like steals. `style = "bars"` (default) draws a lollipop per
#' variable with the 50th percentile marked; `style = "radar"` keeps the
#' radial look for those who like it, but on percentiles and with straight
#' edges.
#'
#' @param data Data containing the subjects and the reference group.
#' @param id Column identifying subjects.
#' @param vars Columns to profile. Name the vector to relabel
#'   (`c("Assists" = "ast36")`).
#' @param subjects Values of `id` to show.
#' @param group Optional column defining the reference group (percentiles are
#'   computed within it).
#' @param reverse Variables where lower is better (e.g. turnovers); their
#'   percentiles are flipped so outward always means "better".
#' @param style `"bars"` or `"radar"`.
#' @param ncol Facet columns.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' p <- subset(player_seasons, league == "NBA" & minutes >= 1000)
#' p <- transform(p, pts36 = 36 * pts / minutes, ast36 = 36 * ast / minutes,
#'                reb36 = 36 * (orb + drb) / minutes, stl36 = 36 * stl / minutes,
#'                blk36 = 36 * blk / minutes, tov36 = 36 * tov / minutes,
#'                three_rate = p3a / (p2a + p3a))
#' plot_profile(p, "player", c(Points = "pts36", Assists = "ast36", Rebounds = "reb36",
#'                             Steals = "stl36", Blocks = "blk36", `Ball security` = "tov36",
#'                             `3PA share` = "three_rate"),
#'              subjects = c("Nikola Jokic", "Stephen Curry", "Victor Wembanyama"),
#'              reverse = "tov36")
plot_profile <- function(data, id, vars, subjects, group = NULL, reverse = NULL,
                         style = c("bars", "radar"), ncol = NULL,
                         title = NULL, subtitle = NULL, caption = NULL) {
  style <- match.arg(style)
  labs_v <- if (is.null(names(vars))) vars else ifelse(names(vars) == "", vars, names(vars))
  vars <- unname(vars)
  data <- as.data.frame(data)
  grp <- if (is.null(group)) NULL else data[[group]]
  long <- dplyr::bind_rows(lapply(seq_along(vars), function(j) {
    pr <- percentile_rank(data[[vars[j]]], grp)
    if (vars[j] %in% reverse) pr <- 100 - pr
    tibble::tibble(subject = as.character(data[[id]]), var = labs_v[j], value = data[[vars[j]]],
                   pct = pr)
  }))
  long <- long[long$subject %in% subjects, ]
  missing <- setdiff(subjects, long$subject)
  if (length(missing)) rlang::warn(paste("Not found:", paste(missing, collapse = ", ")))
  long$subject <- factor(long$subject, levels = intersect(subjects, long$subject))
  long$var <- factor(long$var, levels = rev(labs_v))
  fmt <- function(v) ifelse(abs(v) >= 10, sprintf("%.0f", v), ifelse(abs(v) >= 1, sprintf("%.1f", v),
                                                                      sprintf("%.2f", v)))
  if (style == "bars") {
    p <- ggplot2::ggplot(long, ggplot2::aes(.data$pct, .data$var)) +
      ggplot2::annotate("rect", xmin = 25, xmax = 75, ymin = -Inf, ymax = Inf, fill = "grey95") +
      ggplot2::geom_vline(xintercept = 50, colour = "grey60", linewidth = 0.4) +
      ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$pct, yend = .data$var, colour = .data$pct),
                            linewidth = 1.6, lineend = "round") +
      ggplot2::geom_point(ggplot2::aes(fill = .data$pct), shape = 21, size = 3.4, colour = "white", stroke = 0.8) +
      ggplot2::geom_text(ggplot2::aes(label = fmt(.data$value)), hjust = -0.6, size = 2.8, colour = "grey30") +
      ggplot2::scale_x_continuous(limits = c(0, 112), breaks = c(0, 25, 50, 75, 100),
                                  expand = ggplot2::expansion(0)) +
      scale_colour_vs_average(midpoint = 50, limits = c(0, 100), guide = "none") +
      scale_fill_vs_average(midpoint = 50, limits = c(0, 100), guide = "none") +
      ggplot2::facet_wrap(~subject, ncol = ncol) +
      theme_ggbasket(grid = "x") +
      ggplot2::labs(x = "Percentile", y = NULL, title = title, caption = caption,
                    subtitle = subtitle %||% "Bar = percentile within the reference group (shaded: middle half); number = actual value")
    return(p)
  }
  # radar on percentiles with straight edges
  k <- length(labs_v)
  long$angle <- 2 * pi * (match(as.character(long$var), labs_v) - 1) / k
  long$px <- long$pct * sin(long$angle)
  long$py <- long$pct * cos(long$angle)
  poly <- long[order(long$subject, long$angle), ]
  poly <- dplyr::bind_rows(poly, dplyr::group_by(poly, .data$subject) |> dplyr::slice(1) |> dplyr::ungroup())
  rings <- dplyr::bind_rows(lapply(c(25, 50, 75, 100), function(r) {
    a <- 2 * pi * (0:k) / k
    data.frame(r = r, x = r * sin(a), y = r * cos(a))
  }))
  spokes <- data.frame(a = 2 * pi * (seq_len(k) - 1) / k, lab = labs_v)
  ggplot2::ggplot() +
    ggplot2::geom_path(data = rings[rings$r != 50, ], ggplot2::aes(.data$x, .data$y, group = .data$r),
                       colour = "grey88") +
    ggplot2::geom_path(data = rings[rings$r == 50, ], ggplot2::aes(.data$x, .data$y, group = .data$r),
                       colour = "grey55", linetype = "22") +
    ggplot2::geom_segment(data = spokes, ggplot2::aes(x = 0, y = 0, xend = 100 * sin(.data$a),
                                                      yend = 100 * cos(.data$a)), colour = "grey88") +
    ggplot2::geom_text(data = spokes, ggplot2::aes(x = 122 * sin(.data$a), y = 116 * cos(.data$a),
                                                   label = .data$lab), size = 3, colour = "grey30") +
    ggplot2::geom_polygon(data = poly, ggplot2::aes(.data$px, .data$py, group = .data$subject),
                          fill = scales::alpha(ggbasket_colours$highlight, 0.18),
                          colour = ggbasket_colours$highlight, linewidth = 0.8) +
    ggplot2::geom_point(data = long, ggplot2::aes(.data$px, .data$py), colour = ggbasket_colours$highlight,
                        size = 1.6) +
    ggplot2::coord_equal(xlim = c(-140, 140), ylim = c(-125, 125)) +
    ggplot2::facet_wrap(~subject, ncol = ncol) +
    theme_court() +
    ggplot2::labs(title = title, caption = caption,
                  subtitle = subtitle %||% "Distance from centre = percentile within the reference group (dashed ring = median)")
}

#' Spread within a team: who carries each skill?
#'
#' Replacement for the book's variability diagram. One row per variable,
#' players as dots (size = volume, e.g. attempts), the team's weighted average
#' as a line, and the coefficient of variation written at the end. Players
#' named in `label_top` are labelled at their dots.
#'
#' With `shrink = TRUE` and `made`/`attempts` pairs, percentages are shrunk
#' (see [shrink_rate()]) so a 0/2 shooter no longer defines the range.
#'
#' @param data Player rows for one team.
#' @param made,attempts Character vectors of paired columns (e.g.
#'   `c("p2m", "p3m", "ftm")` and `c("p2a", "p3a", "fta")`).
#' @param labels Row labels.
#' @param player Column with names.
#' @param shrink Shrink percentages.
#' @param label_top Number of highest-volume players to name per row.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' # player_seasons has no makes; use the book's data
#' if (requireNamespace("BasketballAnalyzeR", quietly = TRUE)) {
#'   data(Pbox, package = "BasketballAnalyzeR")
#'   okc <- as_ggbasket_players(subset(Pbox, Team == "Oklahoma City Thunder" & MIN >= 500))
#'   plot_spread(okc, c("p2m", "p3m", "ftm"), c("p2a", "p3a", "fta"),
#'               labels = c("2-point FG%", "3-point FG%", "Free throws"))
#' }
plot_spread <- function(data, made, attempts, labels = made, player = "player", shrink = TRUE,
                        label_top = 3, title = NULL, subtitle = NULL, caption = NULL) {
  long <- dplyr::bind_rows(lapply(seq_along(made), function(j) {
    m <- data[[made[j]]]; a <- data[[attempts[j]]]
    s <- if (shrink) shrink_rate(m, a)$shrunk else m / a
    tibble::tibble(player = as.character(data[[player]]), var = labels[j], made = m, att = a,
                   raw = m / a, pct = s)
  }))
  long <- long[long$att > 0, ]
  stats_df <- long |>
    dplyr::group_by(.data$var) |>
    dplyr::summarise(team = sum(.data$made) / sum(.data$att),
                     wsd = sqrt(sum(.data$att * (.data$pct - sum(.data$made) / sum(.data$att))^2) / sum(.data$att)),
                     cv = .data$wsd / .data$team, lo = min(.data$pct), hi = max(.data$pct), .groups = "drop")
  axis_lab <- stats::setNames(sprintf("%s\nCV %.2f", stats_df$var, stats_df$cv), stats_df$var)
  long$var <- factor(axis_lab[long$var], levels = rev(axis_lab[labels]))
  stats_df$var <- factor(axis_lab[stats_df$var], levels = rev(axis_lab[labels]))
  tops <- long |>
    dplyr::group_by(.data$var) |>
    dplyr::slice_max(.data$att, n = label_top, with_ties = FALSE) |>
    dplyr::ungroup()
  ggplot2::ggplot(long, ggplot2::aes(.data$pct, .data$var)) +
    ggplot2::geom_segment(data = stats_df, ggplot2::aes(x = .data$lo, xend = .data$hi, yend = .data$var),
                          colour = "grey85", linewidth = 6, lineend = "round") +
    ggplot2::geom_point(ggplot2::aes(size = .data$att), shape = 21, fill = scales::alpha("#1F5FA8", 0.45),
                        colour = "white", stroke = 0.6) +
    ggplot2::geom_point(data = stats_df, ggplot2::aes(x = .data$team), shape = "|", size = 9,
                        colour = ggbasket_colours$highlight) +
    ggrepel::geom_text_repel(data = tops, ggplot2::aes(label = .data$player), size = 2.8,
                             nudge_y = 0.32, direction = "x", segment.colour = "grey60",
                             segment.size = 0.25, colour = "grey25", seed = 7) +
    ggplot2::scale_x_continuous(labels = scales::label_percent(accuracy = 1)) +
    ggplot2::scale_size_area(max_size = 9, name = "Attempts") +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = if (shrink) "Shooting % (shrunk towards the team average for small samples)" else "Shooting %",
                  y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "Dots = players (size = attempts); red tick = team average; CV = weighted coefficient of variation")
}

#' Ranked composition bars with a companion stat
#'
#' The book's bar-line plot draws bars and a line on two different y axes,
#' which invites false comparisons between them. This version draws the
#' ranked (stacked) bars on the left and the companion variable as a dot
#' column on the right, sharing the rows, each on its own honest axis.
#'
#' @param data A data frame, one row per subject.
#' @param id Column with names.
#' @param bars Columns to stack (named to relabel).
#' @param line Companion column shown as dots.
#' @param order_by Column to sort by (default: total of the bars).
#' @param line_label Title of the companion panel.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' hou <- subset(player_seasons, league == "NBA" & team == "HOU" & minutes >= 500)
#' plot_ranked(hou, "player", c(`2PA` = "p2a", `3PA` = "p3a", FTA = "fta"), line = "minutes",
#'             line_label = "Minutes")
plot_ranked <- function(data, id, bars, line = NULL, order_by = NULL, line_label = line,
                        title = NULL, subtitle = NULL, caption = NULL) {
  labs_b <- if (is.null(names(bars))) bars else ifelse(names(bars) == "", bars, names(bars))
  data <- as.data.frame(data)
  ord <- if (is.null(order_by)) rowSums(data[, unname(bars), drop = FALSE]) else data[[order_by]]
  lev <- as.character(data[[id]])[order(ord)]
  long <- dplyr::bind_rows(lapply(seq_along(bars), function(j) {
    tibble::tibble(id = as.character(data[[id]]), var = labs_b[j], value = data[[bars[j]]],
                   panel = "bars")
  }))
  long$id <- factor(long$id, levels = lev)
  long$var <- factor(long$var, levels = rev(labs_b))
  cols <- stats::setNames(rep_len(c("#1F5FA8", "#E07B00", "#2A9D8F", "#6A4C93", "#D1495B", "#8D6E63"),
                                  length(labs_b)), labs_b)
  p1 <- ggplot2::ggplot(long, ggplot2::aes(.data$value, .data$id, fill = .data$var)) +
    ggplot2::geom_col(width = 0.72) +
    ggplot2::scale_fill_manual(values = cols, breaks = labs_b, name = NULL) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(c(0, 0.04))) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = NULL, y = NULL)
  if (is.null(line) || !requireNamespace("patchwork", quietly = TRUE)) {
    return(p1 + ggplot2::labs(title = title, subtitle = subtitle, caption = caption))
  }
  dl <- tibble::tibble(id = factor(as.character(data[[id]]), levels = lev), value = data[[line]])
  p2 <- ggplot2::ggplot(dl, ggplot2::aes(.data$value, .data$id)) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60") +
    ggplot2::geom_segment(ggplot2::aes(x = 0, xend = .data$value, yend = .data$id), colour = "grey80") +
    ggplot2::geom_point(colour = "grey25", size = 2.4) +
    theme_ggbasket(grid = "x") +
    ggplot2::theme(axis.text.y = ggplot2::element_blank()) +
    ggplot2::labs(x = NULL, y = NULL, subtitle = line_label)
  patchwork::wrap_plots(p1, p2, widths = c(3, 1)) +
    patchwork::plot_annotation(title = title, subtitle = subtitle, caption = caption,
                               theme = theme_ggbasket())
}
