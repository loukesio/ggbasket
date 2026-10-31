#' Offensive vs defensive rating, with net-rating contours
#'
#' One point per team: points scored per 100 possessions (x) against points
#' allowed (y, reversed so good defence is up). Diagonal lines are constant
#' net rating, so "how good is this team overall" is read off the diagonals and
#' "how do they get there" off the axes. Replaces the book's two side-by-side
#' bar charts of ORtg and DRtg, where that trade-off is invisible.
#'
#' @param ff Output of [four_factors()] (needs `ortg`, `drtg`).
#' @param label Column used for labels.
#' @param highlight Labels to emphasise.
#' @param colour Optional column to colour by (e.g. `"league"` or a cluster).
#' @param size Optional column for point size (e.g. wins).
#' @param net_breaks Net-rating contours to draw.
#' @param facet Optional column to facet by (e.g. `"league"`), each with its
#'   own scales.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' ff <- four_factors(team_seasons)
#' plot_ratings(subset(ff, league == "NBA"), highlight = c("OKC", "CLE", "BOS"))
plot_ratings <- function(ff, label = "team", highlight = NULL, colour = NULL, size = NULL,
                         net_breaks = seq(-15, 15, by = 5), facet = NULL,
                         title = NULL, subtitle = NULL, caption = NULL) {
  ff$.lab <- as.character(ff[[label]])
  ff$.hl <- ff$.lab %in% highlight
  centre <- ff |>
    dplyr::group_by(dplyr::across(dplyr::all_of(facet))) |>
    dplyr::summarise(mo = mean(.data$ortg), md = mean(.data$drtg), .groups = "drop")
  rng <- range(c(ff$ortg, ff$drtg))
  span <- seq(rng[1] - 10, rng[2] + 10, length.out = 2)
  iso <- expand.grid(net = net_breaks, end = 1:2)
  iso$ortg <- span[iso$end]
  iso$drtg <- iso$ortg - iso$net
  iso_lab <- iso[iso$end == 2, ]
  p <- ggplot2::ggplot(ff, ggplot2::aes(.data$ortg, .data$drtg)) +
    ggplot2::geom_line(data = iso, mapping = ggplot2::aes(.data$ortg, .data$drtg, group = .data$net),
                       colour = "grey85", linewidth = 0.35, inherit.aes = FALSE) +
    ggplot2::geom_vline(data = centre, ggplot2::aes(xintercept = .data$mo), colour = "grey70",
                        linetype = "22") +
    ggplot2::geom_hline(data = centre, ggplot2::aes(yintercept = .data$md), colour = "grey70",
                        linetype = "22")
  pt_aes <- ggplot2::aes()
  pt_args <- list(alpha = 0.9)
  if (!is.null(colour)) pt_aes$colour <- rlang::quo(.data[[colour]]) else
    pt_args$colour <- ifelse(ff$.hl, ggbasket_colours$highlight, "grey35")
  if (!is.null(size)) pt_aes$size <- rlang::quo(.data[[size]]) else pt_args$size <- 2.6
  p <- p + do.call(ggplot2::geom_point, c(list(mapping = pt_aes), pt_args))
  p <- p +
    ggrepel::geom_text_repel(family = gb_family(), ggplot2::aes(label = .data$.lab),
                             size = ifelse(ff$.hl, 3.6, 2.9),
                             fontface = ifelse(ff$.hl, "bold", "plain"),
                             colour = ifelse(ff$.hl, "black", "grey35"),
                             box.padding = 0.25, min.segment.length = 0.3, seed = 2) +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_cartesian(xlim = range(ff$ortg) + c(-1, 1), ylim = rev(range(ff$drtg) + c(-1, 1))) +
    theme_ggbasket() +
    ggplot2::labs(x = "Offensive rating (points scored per 100 possessions) \u2192 better",
                  y = "Defensive rating (points allowed per 100) \u2192 better",
                  title = title, caption = caption,
                  subtitle = subtitle %||% "Grey diagonals: constant net rating (5-point steps). Top right = good at both ends")
  if (!is.null(colour) && colour == "league") p <- p + scale_colour_league(name = NULL)
  if (!is.null(size)) p <- p + ggplot2::scale_size_area(max_size = 6)
  if (!is.null(facet)) p <- p + ggplot2::facet_wrap(facet, scales = "free")
  p
}

#' Four factors: where each team sits in the league
#'
#' For each of the eight factors (four on offence, four on defence), every
#' team in the league is a grey dot; the teams in `teams` are coloured and
#' labelled. Axes are oriented so that right is always better, and the facet
#' strips carry Dean Oliver's weights, so it is clear that a big advantage in
#' free-throw rate matters less than a small one in shooting. The book's
#' version plots only differences from the average of the selected teams,
#' which hides how they compare with everyone else.
#'
#' @param ff Output of [four_factors()] for the whole league.
#' @param teams Teams to highlight (values of `label`).
#' @param label Team column.
#' @param scale `"raw"` (natural units) or `"z"` (standard deviations from the
#'   league mean, all panels on one scale).
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' ff <- four_factors(subset(team_seasons, league == "EuroLeague"))
#' plot_four_factors(ff, teams = c("PAN", "FEN", "MCO", "OLY"))
plot_four_factors <- function(ff, teams, label = "team", scale = c("z", "raw"),
                              title = NULL, subtitle = NULL, caption = NULL) {
  scale <- match.arg(scale)
  info <- four_factor_info()
  long <- dplyr::bind_rows(lapply(seq_len(nrow(info)), function(i) {
    v <- ff[[info$column[i]]]
    tibble::tibble(team = as.character(ff[[label]]), factor = info$factor[i], side = info$side[i],
                   raw = v, z = (v - mean(v)) / stats::sd(v) * ifelse(info$higher_is_better[i], 1, -1),
                   weight = info$weight[i], hib = info$higher_is_better[i])
  }))
  long$panel <- factor(sprintf("%s  \u00b7  weight %d%%", long$factor, round(100 * long$weight)),
                       levels = unique(sprintf("%s  \u00b7  weight %d%%", info$factor, round(100 * info$weight))))
  long$side <- factor(long$side, levels = c("Defence", "Offence"))
  long$.hl <- long$team %in% teams
  long$xv <- if (scale == "z") long$z else long$raw
  pal <- stats::setNames(rep_len(c(ggbasket_colours$highlight, "#1F5FA8", "#E07B00", "#2A9D8F",
                                   "#6A4C93", "#8D6E63"), length(teams)), teams)
  set.seed(3)
  long$jit <- stats::runif(nrow(long), -0.18, 0.18)
  p <- ggplot2::ggplot(long, ggplot2::aes(.data$xv, as.numeric(.data$side) + .data$jit)) +
    ggplot2::geom_point(data = long[!long$.hl, ], colour = "grey78", size = 1.6) +
    ggplot2::geom_point(data = long[long$.hl, ], ggplot2::aes(colour = .data$team), size = 3.2) +
    ggrepel::geom_text_repel(family = gb_family(), data = long[long$.hl, ], ggplot2::aes(label = .data$team, colour = .data$team),
                             size = 3, direction = "x", nudge_y = 0.32, segment.colour = NA,
                             fontface = "bold", seed = 4) +
    ggplot2::facet_wrap(~panel, ncol = 1, scales = if (scale == "raw") "free_x" else "fixed") +
    ggplot2::scale_y_continuous(breaks = 1:2, labels = c("Defence", "Offence"),
                                expand = ggplot2::expansion(add = 0.45)) +
    ggplot2::scale_colour_manual(values = pal, guide = "none") +
    theme_ggbasket(grid = "x") +
    ggplot2::theme(panel.spacing.y = grid::unit(0.9, "lines")) +
    ggplot2::labs(y = NULL,
                  x = if (scale == "z") "Standard deviations from the league average  (right = better for the team)" else NULL,
                  title = title, caption = caption,
                  subtitle = subtitle %||% "Grey: every team in the league. Defence = what opponents managed against them")
  if (scale == "z") p <- p + ggplot2::geom_vline(xintercept = 0, colour = "grey55", linewidth = 0.4)
  p
}

#' Lorenz curves: how concentrated is scoring?
#'
#' Several teams on one panel (instead of one panel per team), each curve
#' labelled directly with its Gini coefficient, plus the line of equality.
#' The area between the diagonal and a curve is the inequality.
#'
#' @param data Player-level data.
#' @param value Column to analyse (e.g. `"pts"`).
#' @param group Column identifying teams.
#' @param n Top-`n` players per team (same `n` for every team).
#' @param highlight Groups to colour; others grey. Default: the most equal
#'   team and the two most top-heavy.
#' @param value_label How to name `value` on the axis (e.g. "points").
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' nba <- subset(player_seasons, league == "NBA")
#' plot_lorenz(nba, "pts", "team", highlight = c("OKC", "MIL", "BKN"))
plot_lorenz <- function(data, value, group, n = 8, highlight = NULL, value_label = NULL,
                        title = NULL, subtitle = NULL, caption = NULL) {
  sp <- split(data[[value]], data[[group]])
  cur <- dplyr::bind_rows(lapply(names(sp), function(g) {
    l <- lorenz(sp[[g]], n = n)
    l$group <- g
    l$gini <- attr(l, "gini")
    l
  }))
  if (is.null(highlight)) {
    g <- vapply(sp, gini, numeric(1), n = n)
    highlight <- if (length(g) <= 4) names(g) else names(sort(g))[c(1, length(g) - 1, length(g))]
  }
  cur$.hl <- cur$group %in% highlight
  pal <- stats::setNames(rep_len(c(ggbasket_colours$highlight, "#1F5FA8", "#E07B00", "#2A9D8F",
                                   "#6A4C93"), length(highlight)), highlight)
  # a coloured key in the empty lower-right triangle, ordered by Gini
  labs <- cur[cur$.hl, ] |>
    dplyr::distinct(.data$group, .data$gini) |>
    dplyr::arrange(dplyr::desc(.data$gini)) |>
    dplyr::mutate(x = 0.97, y = 0.04 + 0.065 * (dplyr::n() - dplyr::row_number()),
                  label = sprintf("%s  Gini %.0f%%", .data$group, 100 * .data$gini))
  others <- cur[!cur$.hl, ] |> dplyr::distinct(.data$group, .data$gini)
  if (nrow(others)) {
    rng <- sprintf("Grey: other teams (Gini %.0f-%.0f%%)", 100 * min(others$gini), 100 * max(others$gini))
    labs <- dplyr::bind_rows(labs, tibble::tibble(group = "", gini = NA, x = 0.97,
                                                  y = max(labs$y, 0) + 0.065, label = rng))
  }
  ggplot2::ggplot(cur, ggplot2::aes(.data$people, .data$value, group = .data$group)) +
    ggplot2::annotate("segment", x = 0, y = 0, xend = 1, yend = 1, colour = "grey50") +
    ggplot2::annotate("text", x = 0.55, y = 0.59, label = "perfect equality", angle = 45,
                      colour = "grey50", size = 3, vjust = -0.4) +
    ggplot2::geom_line(data = cur[!cur$.hl, ], colour = "grey85", linewidth = 0.5) +
    ggplot2::geom_line(data = cur[cur$.hl, ], ggplot2::aes(colour = .data$group), linewidth = 1.1) +
    ggplot2::geom_point(data = cur[cur$.hl, ], ggplot2::aes(colour = .data$group), size = 1.6) +
    ggplot2::geom_text(data = labs[labs$group != "", ], ggplot2::aes(.data$x, .data$y, label = .data$label,
                                                                     colour = .data$group),
                       inherit.aes = FALSE, hjust = 1, size = 3.6, fontface = "bold") +
    ggplot2::geom_text(data = labs[labs$group == "", ], ggplot2::aes(.data$x, .data$y, label = .data$label),
                       inherit.aes = FALSE, hjust = 1, size = 3.2, colour = "grey55") +
    ggplot2::scale_colour_manual(values = pal, guide = "none") +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::scale_x_continuous(labels = scales::label_percent(), expand = ggplot2::expansion(0.01)) +
    ggplot2::scale_y_continuous(labels = scales::label_percent(), expand = ggplot2::expansion(0.01)) +
    ggplot2::coord_equal() +
    theme_ggbasket() +
    ggplot2::labs(x = sprintf("Share of the top-%d players (from lowest to highest scorer)", n),
                  y = sprintf("Share of the team's %s", value_label %||% value), title = title, caption = caption,
                  subtitle = subtitle %||% "The further a curve sags below the diagonal, the more the team relies on a few players")
}
