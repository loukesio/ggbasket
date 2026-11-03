#' Offence against defence: how each team wins
#'
#' One dot per team. Both axes are measured against the league average, so
#' the centre of the chart is an average team and up and right are both
#' good: x = points scored per 100 possessions above average (offence),
#' y = points allowed per 100 possessions below average (defence). The four
#' corners are labelled in words, dot colour is net rating (offence +
#' defence), and the dashed diagonal separates teams that outscore their
#' opponents from those that do not. Both axes use the same scale, so five
#' points of offence look as big as five points of defence.
#'
#' @param ff Output of [four_factors()] (needs `ortg`, `drtg`, `pts`, `poss`).
#' @param label Column used for labels.
#' @param highlight Labels to emphasise (bold, with a dark outline).
#' @param colour Optional column to colour by instead of net rating (e.g.
#'   `"league"`).
#' @param size Optional column for point size (e.g. wins).
#' @param net_breaks Extra net-rating diagonals to draw (the zero line is
#'   always drawn).
#' @param facet Optional column to facet by (e.g. `"league"`); each panel is
#'   centred on its own league average.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' ff <- four_factors(team_seasons)
#' plot_ratings(subset(ff, league == "NBA"), highlight = c("OKC", "CLE", "BOS"))
plot_ratings <- function(ff, label = "team", highlight = NULL, colour = NULL, size = NULL,
                         net_breaks = NULL, facet = NULL,
                         title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(ff)
  grp <- if (is.null(facet)) rep("all", nrow(d)) else d[[facet]]
  avg <- tapply(100 * d$pts, grp, sum) / tapply(d$poss, grp, sum)
  d$off <- d$ortg - avg[grp]
  d$def <- avg[grp] - d$drtg
  d$net <- d$off + d$def
  d$.lab <- as.character(d[[label]])
  d$.hl <- d$.lab %in% highlight
  lim <- max(abs(c(d$off, d$def))) * 1.12
  corners <- data.frame(x = c(lim, -lim, lim, -lim), y = c(lim, lim, -lim, -lim),
                        hjust = c(1, 0, 1, 0), vjust = c(1, 1, 0, 0),
                        label = c("Good at both ends", "Defence carries them", "Offence carries them",
                                  "Struggles at both ends"))
  if (!is.null(facet)) corners <- merge(corners, data.frame(.f = unique(d[[facet]])), by = NULL) |>
    stats::setNames(c(names(corners), facet))
  diag <- data.frame(net = unique(c(0, net_breaks)))
  p <- ggplot2::ggplot(d, ggplot2::aes(.data$off, .data$def)) +
    ggplot2::annotate("rect", xmin = 0, xmax = Inf, ymin = 0, ymax = Inf, fill = "#F3F6F8") +
    ggplot2::geom_hline(yintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.4) +
    ggplot2::geom_abline(data = diag, ggplot2::aes(slope = -1, intercept = .data$net), colour = "grey55",
                         linetype = "22", linewidth = 0.4) +
    ggplot2::geom_text(data = corners, ggplot2::aes(x = .data$x, y = .data$y, label = .data$label,
                                                    hjust = .data$hjust, vjust = .data$vjust),
                       colour = "grey45", size = 3.2, fontface = "italic", inherit.aes = FALSE) +
    ggplot2::annotate("text", x = lim * 0.55, y = -lim * 0.55, angle = -45, vjust = -0.6, size = 2.8,
                      colour = "grey40", label = "above this line: outscore opponents") +
    ggplot2::annotate("text", x = lim * 0.55, y = -lim * 0.55, angle = -45, vjust = 1.6, size = 2.8,
                      colour = "grey40", label = "below: outscored")
  pt_aes <- ggplot2::aes(fill = .data$net)
  if (!is.null(colour)) pt_aes$fill <- rlang::quo(.data[[colour]])
  if (!is.null(size)) pt_aes$size <- rlang::quo(.data[[size]])
  p <- p + ggplot2::geom_point(pt_aes, shape = 21, size = if (is.null(size)) 3.4 else NULL,
                               colour = ifelse(d$.hl, ggbasket_colours$ink, ggbasket_colours$paper),
                               stroke = ifelse(d$.hl, 1.1, 0.5)) +
    ggrepel::geom_text_repel(family = gb_family(), ggplot2::aes(label = .data$.lab),
                             size = ifelse(d$.hl, 3.6, 2.8), fontface = ifelse(d$.hl, "bold", "plain"),
                             colour = ifelse(d$.hl, ggbasket_colours$ink, "grey35"),
                             box.padding = 0.3, min.segment.length = 0.3, seed = 2)
  if (is.null(colour)) {
    p <- p + ggplot2::scale_fill_gradientn(colours = ggbasket_colours$diverging, limits = c(-1, 1) * max(abs(d$net)),
                                           name = "Net rating", labels = function(x) sprintf("%+.0f", x),
                                           guide = ggplot2::guide_colourbar(barwidth = grid::unit(10, "lines"),
                                                                            barheight = grid::unit(0.5, "lines")))
  } else if (colour == "league") p <- p + scale_fill_league(name = NULL)
  if (!is.null(size)) p <- p + ggplot2::scale_size_area(max_size = 6)
  p <- p +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", x)) +
    ggplot2::scale_y_continuous(labels = function(x) sprintf("%+.0f", x)) +
    ggplot2::coord_equal(xlim = c(-lim, lim), ylim = c(-lim, lim)) +
    theme_ggbasket() +
    ggplot2::labs(x = "Offence: points scored per 100 possessions, above league average \u2192",
                  y = "Defence: points allowed per 100, below league average \u2192",
                  title = title, caption = caption,
                  subtitle = subtitle %||% "The centre is an average team; up and right are both better. Colour = net rating (offence + defence)")
  if (!is.null(facet)) p <- p + ggplot2::facet_wrap(facet)
  p
}

#' Four factors: where each team sits in the league
#'
#' For each of the eight factors (four on offence, four on defence), every
#' team in the league is a grey dot; the teams in `teams` are coloured and
#' labelled. Axes are oriented so that right is always better, and the facet
#' strips carry Dean Oliver's weights, so it is clear that a big advantage in
#' free-throw rate matters less than a small one in shooting. Values are
#' against the whole league, not only the selected teams.
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
  pal <- stats::setNames(rep_len(c(ggbasket_colours$highlight, ggbasket_colours$categorical[-2]), length(teams)), teams)
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
  pal <- stats::setNames(rep_len(c(ggbasket_colours$highlight, ggbasket_colours$categorical[-2]), length(highlight)), highlight)
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

#' Where each team's net rating comes from
#'
#' Net rating split into its two halves against the league average: offence
#' (points scored per 100 possessions above average) and defence (points
#' allowed below average). One row per team, sorted by net rating, so the
#' ranking and the way each team gets there read together.
#'
#' @param ff Output of [four_factors()], one league (or use `league`).
#' @param league League to show (default: the first in `ff`).
#' @param highlight Teams to mark with a light band.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' plot_net_rating(four_factors(team_seasons), "EuroLeague")
plot_net_rating <- function(ff, league = NULL, highlight = NULL, title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(ff)
  league <- league %||% d$league[1]
  d <- d[d$league == league, ]
  avg <- 100 * sum(d$pts) / sum(d$poss)
  d$off <- d$ortg - avg
  d$def <- avg - d$drtg
  d$net <- d$off + d$def
  d$team <- factor(d$team, levels = d$team[order(d$net)])
  long <- rbind(data.frame(team = d$team, part = "Offence", value = d$off),
                data.frame(team = d$team, part = "Defence", value = d$def))
  # stack positives right and negatives left of zero
  long <- long[order(long$team, long$part), ]
  long <- do.call(rbind, lapply(split(long, long$team), function(x) {
    pos <- x$value >= 0
    x$xmin <- x$xmax <- 0
    x$xmax[pos] <- cumsum(x$value[pos]); x$xmin[pos] <- x$xmax[pos] - x$value[pos]
    x$xmin[!pos] <- cumsum(x$value[!pos]); x$xmax[!pos] <- x$xmin[!pos] - x$value[!pos]
    x
  }))
  long$y <- as.numeric(long$team)
  cols <- c(Offence = ggbasket_colours$offence, Defence = ggbasket_colours$defence)
  d$y <- as.numeric(d$team)
  d$face <- ifelse(d$team %in% highlight, "bold", "plain")
  band <- d[d$team %in% highlight, ]
  ggplot2::ggplot() +
    ggplot2::geom_rect(data = band, ggplot2::aes(ymin = .data$y - 0.5, ymax = .data$y + 0.5), xmin = -Inf, xmax = Inf,
                       fill = "grey93") +
    ggplot2::geom_vline(xintercept = 0, colour = "grey55", linewidth = 0.4) +
    ggplot2::geom_rect(data = long, ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax, ymin = .data$y - 0.36,
                                                 ymax = .data$y + 0.36, fill = .data$part)) +
    ggplot2::geom_point(data = d, ggplot2::aes(.data$net, .data$y), shape = 21, size = 2.6,
                        fill = ggbasket_colours$ink, colour = ggbasket_colours$paper, stroke = 0.6) +
    ggplot2::geom_text(data = d, ggplot2::aes(x = pmax(.data$net, 0, .data$off, .data$def) + 0.5, y = .data$y,
                                              label = sprintf("%+.1f", .data$net), fontface = .data$face),
                       hjust = 0, size = 3, colour = ggbasket_colours$ink) +
    ggplot2::scale_fill_manual(values = cols, guide = "none") +
    ggplot2::scale_y_continuous(breaks = d$y, labels = as.character(d$team), expand = ggplot2::expansion(add = 0.6)) +
    ggplot2::scale_x_continuous(labels = function(x) sprintf("%+.0f", x), expand = ggplot2::expansion(c(0.04, 0.1))) +
    theme_ggbasket(grid = "x") +
    ggplot2::labs(x = "Points per 100 possessions against the league average", y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% paste0(
                    "Net rating (black dot and number) = ", colour_text("offence", cols[["Offence"]]),
                    " (points scored above average) + ", colour_text("defence", cols[["Defence"]]),
                    " (points allowed below average), per 100 possessions"))
}

#' Four factors as a ranking table
#'
#' One row per chosen team, one column per factor on offence and defence.
#' Each cell shows the team's value and its rank in the league, coloured
#' from best (red) to worst (blue), so strengths and weaknesses read at a
#' glance. Columns carry Dean Oliver's weights.
#'
#' @param ff Output of [four_factors()].
#' @param teams Teams to show (ranks are within their league).
#' @param title,subtitle,caption Labels.
#' @export
plot_factor_ranks <- function(ff, teams, title = NULL, subtitle = NULL, caption = NULL) {
  d <- as.data.frame(ff)
  spec <- tibble::tribble(
    ~col, ~side, ~factor, ~high_good,
    "efg", "Offence", "Shooting\neFG%\n40%", TRUE,
    "tov_pct", "Offence", "Turnovers\nTOV%\n25%", FALSE,
    "orb_pct", "Offence", "Off. reb.\nORB%\n20%", TRUE,
    "ft_rate", "Offence", "Free thr.\nFT/FGA\n15%", TRUE,
    "o_efg", "Defence", "Shooting\nopp. eFG%\n40%", FALSE,
    "o_tov_pct", "Defence", "Turnovers\nforced\n25%", TRUE,
    "drb_pct", "Defence", "Def. reb.\nDRB%\n20%", TRUE,
    "o_ft_rate", "Defence", "Free thr.\nopp. FT/FGA\n15%", FALSE)
  lg <- unique(d$league[d$team %in% teams])
  long <- dplyr::bind_rows(lapply(seq_len(nrow(spec)), function(i) {
    s <- spec[i, ]
    x <- d[d$league %in% lg, ]
    v <- x[[s$col]]
    r <- rank(if (s$high_good) -v else v, ties.method = "min")
    tibble::tibble(team = x$team, league = x$league, n = nrow(x), side = s$side, factor = s$factor,
                   value = v, rank = r)
  }))
  long <- long[long$team %in% teams, ]
  long$score <- 1 - (long$rank - 1) / (long$n - 1)
  ord <- function(r) paste0(r, ifelse(r %% 100 %in% 11:13, "th", c("th", "st", "nd", "rd", rep("th", 6))[r %% 10 + 1]))
  long$label <- sprintf("%s\n%s", ifelse(long$factor %in% spec$factor[spec$col %in% c("ft_rate", "o_ft_rate")],
                                         sprintf("%.2f", long$value), sprintf("%.1f%%", 100 * long$value)),
                        ord(long$rank))
  long$x <- match(long$factor, spec$factor) + ifelse(long$side == "Defence", 0.4, 0)
  long$team <- factor(long$team, levels = rev(teams))
  long$y <- as.numeric(long$team)
  heads <- tibble::tibble(x = c(2.5, 6.9), y = length(teams) + 1.4, label = c("Offence", "Defence"))
  cols <- tibble::tibble(x = unique(long$x), label = spec$factor)
  ggplot2::ggplot(long, ggplot2::aes(.data$x, .data$y)) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$score), colour = ggbasket_colours$paper, linewidth = 1.2,
                       width = 1, height = 1) +
    ggplot2::geom_text(ggplot2::aes(label = .data$label, colour = abs(.data$score - 0.5) > 0.35),
                       size = 3.1, lineheight = 0.9) +
    ggplot2::geom_text(data = cols, ggplot2::aes(x = .data$x, y = length(teams) + 0.62, label = .data$label),
                       size = 2.7, lineheight = 0.9, vjust = 0, colour = "grey30") +
    ggplot2::geom_text(data = heads, ggplot2::aes(label = .data$label), fontface = "bold", size = 4.2,
                       colour = ggbasket_colours$ink, vjust = 0) +
    ggplot2::scale_fill_gradientn(colours = ggbasket_colours$diverging, limits = c(0, 1), guide = "none") +
    ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey15"), guide = "none") +
    ggplot2::scale_y_continuous(breaks = seq_along(teams), labels = rev(teams)) +
    ggplot2::coord_equal(ylim = c(0.5, length(teams) + 1.75), clip = "off") +
    theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.1))) +
    ggplot2::labs(x = NULL, y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% paste0("Value and rank among the league's ", long$n[1],
                                                  " teams; red = near the top, blue = near the bottom. Percentages under each factor = Dean Oliver's weights"))
}
