#' Who assists whom
#'
#' Builds passer-to-scorer counts from play-by-play data with one row per
#' event and columns `player` (scorer), `assist` (passer, empty when
#' unassisted), `result` (`"made"`/`"missed"`) and `points`: the ggbasket
#' play-by-play layout (see [pbp]).
#'
#' @param pbp Play-by-play rows of one team.
#' @return A list: `edges` (from, to, assists, points) and `nodes` (player,
#'   assists, assisted_fgm, fgm, pct_assisted, points_created, plus the
#'   network-centrality measures: `partners` = teammates assisted,
#'   `ast_share` = share of the team's assists, `ast_gini` / `recv_gini` =
#'   how concentrated a player's assists made / received are across
#'   teammates, from 0 = spread evenly to 1 = all to / from one player).
#' @export
assist_network <- function(pbp) {
  pbp <- as.data.frame(pbp)
  ft <- if ("type" %in% names(pbp)) grepl("free throw", pbp$type, ignore.case = TRUE) else FALSE
  made <- pbp[!is.na(pbp$result) & pbp$result == "made" & !is.na(pbp$player) & pbp$player != "" & !ft, ]
  if ("ShotType" %in% names(made)) made <- made[made$ShotType %in% c("2P", "3P"), ]
  made$assist <- as.character(made$assist)
  ast <- made[!is.na(made$assist) & made$assist != "", ]
  edges <- ast |>
    dplyr::count(from = .data$assist, to = .data$player, name = "assists") |>
    dplyr::left_join(ast |> dplyr::group_by(from = .data$assist, to = .data$player) |>
                       dplyr::summarise(points = sum(.data$points), .groups = "drop"),
                     by = c("from", "to"))
  fgm <- made |> dplyr::count(player = .data$player, name = "fgm")
  nodes <- fgm |>
    dplyr::full_join(edges |> dplyr::group_by(player = .data$from) |>
                       dplyr::summarise(assists = sum(.data$assists), points_created = sum(.data$points)),
                     by = "player") |>
    dplyr::full_join(edges |> dplyr::group_by(player = .data$to) |>
                       dplyr::summarise(assisted_fgm = sum(.data$assists)), by = "player") |>
    dplyr::mutate(dplyr::across(c("fgm", "assists", "points_created", "assisted_fgm"), ~ dplyr::coalesce(.x, 0)),
                  pct_assisted = ifelse(.data$fgm > 0, .data$assisted_fgm / .data$fgm, NA_real_))
  players <- nodes$player
  conc <- function(p, from_col, to_col) {
    e <- edges[edges[[from_col]] == p, ]
    x <- e$assists[match(setdiff(players, p), e[[to_col]])]
    x[is.na(x)] <- 0
    if (sum(x) == 0) NA_real_ else gini(x)
  }
  nodes$partners <- vapply(nodes$player, function(p) sum(edges$from == p), integer(1))
  nodes$ast_share <- nodes$assists / sum(nodes$assists)
  nodes$ast_gini <- vapply(nodes$player, conc, numeric(1), from_col = "from", to_col = "to")
  nodes$recv_gini <- vapply(nodes$player, conc, numeric(1), from_col = "to", to_col = "from")
  list(edges = tibble::as_tibble(edges), nodes = tibble::as_tibble(nodes))
}

#' Hubs and two-man games
#'
#' An assist network can be summarised by how *concentrated* each player's
#' passes are (a Gini index over teammates). Here that becomes a map: x = share of the team's assists the player makes (how much of a hub),
#' y = how evenly those assists are spread over teammates (1 - Gini), point
#' size = assisted baskets received, colour = share of own baskets that were
#' assisted. Top right: a hub who feeds everyone; top left: a connector with
#' few assists; bottom: assists that go mostly to one partner.
#'
#' @inheritParams plot_assist_network
#' @param min_assists Players with fewer assists made are dropped.
#' @export
plot_assist_roles <- function(net, min_assists = 30, title = NULL, subtitle = NULL, caption = NULL) {
  n <- net$nodes[net$nodes$assists >= min_assists & !is.na(net$nodes$ast_gini), ]
  n$spread <- 1 - n$ast_gini
  ggplot2::ggplot(n, ggplot2::aes(.data$ast_share, .data$spread)) +
    ggplot2::geom_hline(yintercept = stats::median(n$spread), colour = "grey60", linetype = "22",
                        linewidth = 0.4) +
    ggplot2::geom_point(ggplot2::aes(size = .data$assisted_fgm, fill = .data$pct_assisted), shape = 21,
                        colour = ggbasket_colours$paper, stroke = 1) +
    ggrepel::geom_text_repel(family = gb_family(), ggplot2::aes(label = sprintf("%s  %d ast \u00b7 %d partners", .data$player,
                                                                as.integer(.data$assists), .data$partners)),
                             size = 3, colour = "grey20", seed = 4, box.padding = 0.6,
                             min.segment.length = 0.2, point.padding = 0.4) +
    ggplot2::annotate("text", x = Inf, y = Inf, label = "Hub: feeds everyone", hjust = 1.05, vjust = 1.5,
                      size = 3, colour = "grey45", fontface = "italic") +
    ggplot2::annotate("text", x = Inf, y = -Inf, label = "Two-man game", hjust = 1.05, vjust = -1,
                      size = 3, colour = "grey45", fontface = "italic") +
    ggplot2::scale_x_continuous(labels = scales::label_percent(accuracy = 1),
                                expand = ggplot2::expansion(mult = c(0.08, 0.12))) +
    ggplot2::scale_y_continuous(labels = scales::label_number(accuracy = 0.01),
                                expand = ggplot2::expansion(mult = 0.15)) +
    ggplot2::scale_size_area(max_size = 12, name = "Assisted baskets received",
                             guide = ggplot2::guide_legend(override.aes = list(fill = "grey65"))) +
    scale_fill_vs_average(midpoint = 0.65, limits = c(0.3, 1), labels = scales::label_percent(),
                          name = "Own baskets assisted",
                          guide = ggplot2::guide_colourbar(barwidth = grid::unit(8, "lines"),
                                                           barheight = grid::unit(0.5, "lines"),
                                                           title.position = "top")) +
    theme_ggbasket() +
    ggplot2::labs(x = "Share of the team's assists \u2192 more of a hub",
                  y = "How evenly assists are spread over teammates (1 \u2212 Gini)",
                  title = title, caption = caption,
                  subtitle = subtitle %||% "Share of the team's assists against how evenly they are spread over team-mates (1 - Gini)")
}

#' Assist network on a circle
#'
#' Players sit on a circle ordered by assists made; curved arrows go from
#' passer to scorer, with width and darkness proportional to the number of
#' assists. Node size = assists made, node colour = share of the player's own
#' baskets that were assisted (blue = creates his own shot, red = finisher).
#' Edges below `min_assists` are dropped to keep the core visible.
#'
#' @param net Output of [assist_network()].
#' @param min_assists Minimum assists for an edge to be drawn.
#' @param top_n Keep the `top_n` players by assists + assisted baskets.
#' @param title,subtitle,caption Labels.
#' @export
plot_assist_network <- function(net, min_assists = 10, top_n = 10, title = NULL, subtitle = NULL,
                                caption = NULL) {
  nodes <- net$nodes
  nodes$involve <- nodes$assists + nodes$assisted_fgm
  nodes <- nodes[order(-nodes$involve), ][seq_len(min(top_n, nrow(nodes))), ]
  nodes <- nodes[order(-nodes$assists), ]
  k <- nrow(nodes)
  nodes$theta <- pi / 2 - 2 * pi * (seq_len(k) - 1) / k
  nodes$x <- cos(nodes$theta); nodes$y <- sin(nodes$theta)
  e <- net$edges[net$edges$from %in% nodes$player & net$edges$to %in% nodes$player &
                   net$edges$assists >= min_assists, ]
  e <- dplyr::left_join(e, nodes[, c("player", "x", "y")], by = c(from = "player"))
  e <- dplyr::left_join(e, nodes[, c("player", "x", "y")], by = c(to = "player"), suffix = c("", "end"))
  # shorten edges so arrows stop at the node rim
  sh <- 0.11
  dx <- e$xend - e$x; dy <- e$yend - e$y; L <- sqrt(dx^2 + dy^2)
  e$x0 <- e$x + sh * dx / L; e$y0 <- e$y + sh * dy / L
  e$x1 <- e$xend - sh * dx / L; e$y1 <- e$yend - sh * dy / L
  e <- e[order(e$assists), ]
  nodes$lx <- 1.24 * nodes$x
  nodes$ly <- 1.18 * nodes$y + ifelse(nodes$y > 0.6, 0.12, ifelse(nodes$y < -0.6, -0.02, 0))
  nodes$hj <- ifelse(nodes$x > 0.2, 0, ifelse(nodes$x < -0.2, 1, 0.5))
  top_edge <- e[which.max(e$assists), ]
  ggplot2::ggplot() +
    ggplot2::geom_curve(data = e, ggplot2::aes(x = .data$x0, y = .data$y0, xend = .data$x1, yend = .data$y1,
                                               linewidth = .data$assists, colour = .data$assists),
                        curvature = 0.25, arrow = grid::arrow(length = grid::unit(0.16, "cm"), type = "closed"),
                        lineend = "round") +
    ggplot2::geom_point(data = nodes, ggplot2::aes(.data$x, .data$y, size = .data$assists,
                                                   fill = .data$pct_assisted),
                        shape = 21, colour = ggbasket_colours$paper, stroke = 1.2) +
    ggplot2::geom_text(data = nodes, ggplot2::aes(.data$lx, .data$ly, label = .data$player, hjust = .data$hj),
                       size = 3.3, fontface = "bold", colour = "grey20") +
    ggplot2::geom_text(data = nodes, ggplot2::aes(.data$lx, .data$ly - 0.09, hjust = .data$hj,
                                                  label = sprintf("%d ast \u00b7 %.0f%% of FGM assisted",
                                                                  as.integer(.data$assists), 100 * .data$pct_assisted)),
                       size = 2.6, colour = "grey45") +
    ggplot2::scale_linewidth(range = c(0.25, 3), guide = "none") +
    ggplot2::scale_colour_gradient(low = "grey85", high = "grey15", guide = "none") +
    ggplot2::scale_size_area(max_size = 14, guide = "none") +
    scale_fill_vs_average(midpoint = 0.65, limits = c(0.3, 1), labels = scales::label_percent(),
                          name = "Share of own baskets assisted (blue = self-creator)",
                          guide = ggplot2::guide_colourbar(barwidth = grid::unit(12, "lines"),
                                                           barheight = grid::unit(0.5, "lines"),
                                                           title.position = "top")) +
    ggplot2::coord_equal(xlim = c(-1.75, 1.75), ylim = c(-1.35, 1.35), clip = "off") +
    theme_court() +
    ggplot2::labs(title = title, caption = caption,
                  subtitle = subtitle %||% sprintf("Arrows: passer \u2192 scorer, width = assists (only pairs with %d+). Strongest link: %s \u2192 %s (%d)",
                                                   min_assists, top_edge$from, top_edge$to, as.integer(top_edge$assists)))
}

#' Assist matrix heatmap
#'
#' Passers in rows, scorers in columns, both ordered by volume; each cell is
#' the number of assists. Row and column totals are printed in the margins.
#' Often easier to read exactly than a network.
#'
#' @inheritParams plot_assist_network
#' @export
plot_assist_matrix <- function(net, top_n = 10, title = NULL, subtitle = NULL, caption = NULL) {
  nodes <- net$nodes
  nodes$involve <- nodes$assists + nodes$assisted_fgm
  keep <- nodes$player[order(-nodes$involve)][seq_len(min(top_n, nrow(nodes)))]
  e <- net$edges[net$edges$from %in% keep & net$edges$to %in% keep, ]
  e <- tidyr::complete(e, from = keep, to = keep, fill = list(assists = 0, points = 0))
  self <- e[e$from == e$to, ]
  e <- e[e$from != e$to, ]
  rows <- names(sort(tapply(e$assists, e$from, sum)))
  cols <- names(sort(tapply(e$assists, e$to, sum), decreasing = TRUE))
  e$from <- factor(e$from, levels = rows); e$to <- factor(e$to, levels = cols)
  self$from <- factor(self$from, levels = rows); self$to <- factor(self$to, levels = cols)
  ggplot2::ggplot(e, ggplot2::aes(.data$to, .data$from)) +
    ggplot2::geom_tile(data = self, fill = "grey92", colour = ggbasket_colours$paper, linewidth = 0.8) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$assists), colour = ggbasket_colours$paper, linewidth = 0.8) +
    ggplot2::geom_text(ggplot2::aes(label = ifelse(.data$assists > 0, .data$assists, ""),
                                    colour = .data$assists > stats::quantile(.data$assists, 0.85)), size = 3) +
    ggplot2::scale_fill_gradient(low = "#F3F3F5", high = "#6A1B4D", name = "Assists") +
    ggplot2::coord_equal() +
    ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey25"), guide = "none") +
    theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1),
                   legend.position = "right") +
    ggplot2::labs(x = "Scorer \u2192", y = "Passer", title = title, subtitle = subtitle, caption = caption)
}
