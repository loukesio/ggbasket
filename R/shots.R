# Shot data convention: one row per field-goal attempt with columns
#   x, y   metres, origin at the hoop centre, y towards half court
#   made   logical (or 0/1)
#   value  2 or 3 (optional; inferred from x, y when absent)
#   league "NBA" / "EuroLeague" / "FIBA" (optional; default NBA)
# plus anything to group by (player, team, season, ...).

prep_shots <- function(shots, league = NULL) {
  if (!all(c("x", "y", "made") %in% names(shots))) {
    rlang::abort("Shots need columns `x`, `y` (metres from the hoop) and `made`.")
  }
  if (!"league" %in% names(shots)) shots$league <- league %||% "NBA"
  shots$made <- as.logical(shots$made)
  if (!"value" %in% names(shots)) {
    shots$value <- ifelse(as.character(shot_zone(shots$x, shots$y, shots$league)) %in%
                            c("Corner 3", "Above-break 3"), 3, 2)
  }
  shots$pts <- shots$value * shots$made
  shots
}

`%||%` <- function(a, b) if (is.null(a)) b else a

#' Summarise shots by zone (with shrinkage)
#'
#' Attempts, makes, FG%, points per shot and share of attempts per zone, plus
#' the league average in the same zone and the player's FG% shrunk towards it
#' (see [shrink_rate()]).
#'
#' @param shots Shot data (see Details in [plot_shot_hex()]).
#' @param by Grouping columns (character), e.g. `"player"`.
#' @param baseline Shots used for the league reference; defaults to `shots`.
#'   Pass the whole league so a single player is compared with everyone.
#' @param detail Use the 12 side-split zones.
#' @param prior_n Strength of the pull towards the league zone average, in
#'   attempts: a zone with `prior_n` attempts is moved halfway.
#' @export
#' @examples
#' zs <- summarise_zones(subset(shots_2024, player == "Stephen Curry"),
#'                       baseline = shots_2024, by = "player")
#' zs[, c("zone", "attempts", "fg", "fg_league", "fg_shrunk")]
summarise_zones <- function(shots, by = NULL, baseline = shots, detail = FALSE, prior_n = 30) {
  shots <- prep_shots(shots)
  baseline <- prep_shots(baseline)
  shots$zone <- shot_zone(shots$x, shots$y, shots$league, shots$value, detail)
  baseline$zone <- shot_zone(baseline$x, baseline$y, baseline$league, baseline$value, detail)
  ref <- baseline |>
    dplyr::group_by(.data$league, .data$zone) |>
    dplyr::summarise(fg_league = mean(.data$made), pps_league = mean(.data$pts),
                     share_league = dplyr::n(), .groups = "drop_last") |>
    dplyr::mutate(share_league = .data$share_league / sum(.data$share_league)) |>
    dplyr::ungroup()
  out <- shots |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(by, "league"))), .data$zone) |>
    dplyr::summarise(attempts = dplyr::n(), makes = sum(.data$made), pts = sum(.data$pts),
                     .groups = "drop_last") |>
    dplyr::mutate(share = .data$attempts / sum(.data$attempts)) |>
    dplyr::ungroup() |>
    dplyr::mutate(fg = .data$makes / .data$attempts, pps = .data$pts / .data$attempts) |>
    tidyr::complete(tidyr::nesting(!!!rlang::syms(c(by, "league"))), .data$zone,
                    fill = list(attempts = 0L, makes = 0L, pts = 0, share = 0)) |>
    dplyr::left_join(ref, by = c("league", "zone"))
  # shrink each zone's FG% towards the league average of that zone with a
  # prior worth `prior_n` attempts
  out$fg_shrunk <- (out$makes + prior_n * out$fg_league) / (out$attempts + prior_n)
  out$fg_vs_league <- out$fg_shrunk - out$fg_league
  out
}

# Pointy-top hexagonal binning in plain R (no hexbin dependency).
hex_assign <- function(x, y, size) {
  # axial coordinates for pointy-top hexagons with circumradius `size`
  q <- (sqrt(3) / 3 * x - 1 / 3 * y) / size
  r <- (2 / 3 * y) / size
  # cube rounding
  cx <- q; cz <- r; cy <- -cx - cz
  rx <- round(cx); ry <- round(cy); rz <- round(cz)
  dx <- abs(rx - cx); dy <- abs(ry - cy); dz <- abs(rz - cz)
  fix_x <- dx > dy & dx > dz
  fix_z <- !fix_x & !(dy > dz)
  rx[fix_x] <- -ry[fix_x] - rz[fix_x]
  rz[fix_z] <- -rx[fix_z] - ry[fix_z]
  list(q = rx, r = rz, cx = size * sqrt(3) * (rx + rz / 2), cy = size * 3 / 2 * rz)
}

hex_polygon <- function(cx, cy, size, scale = 1) {
  ang <- pi / 6 + (0:5) * pi / 3
  n <- length(cx)
  s <- rep(scale, each = 6)
  data.frame(id = rep(seq_len(n), each = 6),
             x = rep(cx, each = 6) + s * size * cos(rep(ang, n)),
             y = rep(cy, each = 6) + s * size * sin(rep(ang, n)))
}

#' Hexagonal shot bins
#'
#' Bins shots into hexagons and returns, per hexagon, attempts, share of the
#' group's attempts, FG%, points per shot, and the league FG% from the same
#' spot (`fg_league`, from `baseline`). `fg_vs_league` uses FG% shrunk towards
#' the league value from the same hexagon, so a 2/2 hexagon is not shown as
#' "+50%".
#'
#' @inheritParams summarise_zones
#' @param binwidth Distance between hexagon centres, in metres.
#' @param min_attempts Drop hexagons with fewer attempts.
#' @param prior_n Pull towards the league FG% of the same hexagon, in attempts.
#' @export
bin_shots_hex <- function(shots, by = NULL, baseline = shots, binwidth = 0.75, min_attempts = 1,
                          prior_n = 20) {
  shots <- prep_shots(shots)
  baseline <- prep_shots(baseline)
  size <- binwidth / sqrt(3)
  h <- hex_assign(shots$x, shots$y, size)
  shots$hq <- h$q; shots$hr <- h$r; shots$cx <- h$cx; shots$cy <- h$cy
  hb <- hex_assign(baseline$x, baseline$y, size)
  baseline$hq <- hb$q; baseline$hr <- hb$r
  baseline$zone <- shot_zone(baseline$x, baseline$y, baseline$league, baseline$value)
  ref_hex <- baseline |>
    dplyr::group_by(.data$league, .data$hq, .data$hr) |>
    dplyr::summarise(n_league = dplyr::n(), fg_league = mean(.data$made),
                     pps_league = mean(.data$pts), .groups = "drop")
  out <- shots |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(by, "league"))),
                    .data$hq, .data$hr, .data$cx, .data$cy) |>
    dplyr::summarise(attempts = dplyr::n(), makes = sum(.data$made), pts = sum(.data$pts),
                     value = stats::median(.data$value), .groups = "drop_last") |>
    dplyr::ungroup() |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(by, "league")))) |>
    dplyr::mutate(share = .data$attempts / sum(.data$attempts)) |>
    dplyr::ungroup() |>
    dplyr::left_join(ref_hex, by = c("league", "hq", "hr")) |>
    dplyr::mutate(fg = .data$makes / .data$attempts, pps = .data$pts / .data$attempts)
  # shrink towards the league FG% of the same hexagon (prior worth `prior_n` attempts)
  m <- ifelse(is.na(out$fg_league), mean(shots$made), out$fg_league)
  out$fg_shrunk <- (out$makes + prior_n * m) / (out$attempts + prior_n)
  out$fg_vs_league <- out$fg_shrunk - out$fg_league
  out$pps_vs_league <- out$fg_shrunk * out$value - out$pps_league
  out <- out[out$attempts >= min_attempts, ]
  attr(out, "hex_size") <- size
  out
}

#' Hexagon shot chart: where they shoot from, and how well
#'
#' Kirk Goldsberry-style chart. Hexagon **size** is how often the player
#' shoots from that spot, hexagon **colour** is FG% compared with the league
#' from the same spot (shrunk, so tiny samples stay near white). Faceting by
#' `facet` gives small multiples on a common scale.
#'
#' Shot data needs `x`, `y` in metres from the hoop centre (y towards half
#' court), `made`, and optionally `value` and `league`. See
#' [as_ggbasket_shots()] to convert BasketballAnalyzeR play-by-play.
#'
#' @inheritParams bin_shots_hex
#' @param facet Column to facet by (also used for binning).
#' @param league Court to draw; defaults to the league in the data.
#' @param fill `"fg"` (FG% vs league) or `"pps"` (points per shot vs league).
#' @param limit Colour scale limit (+-).
#' @param max_size Largest hexagon as a fraction of the full hexagon.
#' @param min_attempts Hide hexagons with fewer attempts (they carry no
#'   information about efficiency and clutter the court).
#' @param title,subtitle,caption Labels. A default subtitle explains the
#'   encoding.
#' @export
#' @examples
#' curry <- subset(shots_2024, player == "Stephen Curry")
#' plot_shot_hex(curry, baseline = subset(shots_2024, league == "NBA"),
#'               title = "Stephen Curry, 2024/25")
plot_shot_hex <- function(shots, baseline = shots, facet = NULL, league = NULL,
                          binwidth = 0.75, min_attempts = 3, fill = c("fg", "pps"), limit = NULL,
                          max_size = 1, title = NULL, subtitle = NULL, caption = NULL) {
  fill <- match.arg(fill)
  shots <- prep_shots(shots)
  league <- league %||% as.character(shots$league[1])
  hb <- bin_shots_hex(shots, by = facet, baseline = baseline, binwidth = binwidth)
  size <- attr(hb, "hex_size")
  # size encodes share relative to the busiest hexagon of each facet, square-root
  # scaled so area (not radius) is proportional to frequency
  hb <- hb |>
    dplyr::group_by(dplyr::across(dplyr::all_of(facet))) |>
    dplyr::mutate(scale = max_size * pmin(1, pmax(sqrt(.data$share / stats::quantile(.data$share, 0.95)), 0.3))) |>
    dplyr::filter(.data$attempts >= min_attempts) |>
    dplyr::ungroup()
  val <- if (fill == "fg") hb$fg_vs_league else hb$pps_vs_league
  limit <- limit %||% if (fill == "fg") 0.12 else 0.3
  poly <- hex_polygon(hb$cx, hb$cy, size, hb$scale)
  poly <- cbind(poly, hb[poly$id, setdiff(names(hb), c("x", "y"))])
  poly$val <- val[poly$id]
  poly$group <- paste(poly$id)
  lab <- if (fill == "fg") "FG% vs league from the same spot" else "Points per shot vs league"
  p <- ggplot2::ggplot(poly, ggplot2::aes(.data$x, .data$y)) +
    geom_court(league, coord = FALSE, floor = ggbasket_colours$court_floor) +
    ggplot2::geom_polygon(ggplot2::aes(group = .data$group, fill = .data$val),
                          colour = "white", linewidth = 0.15) +
    annotate_court_lines(league, colour = scales::alpha(ggbasket_colours$court_line, 0.6)) +
    scale_fill_vs_average(
      name = lab, limits = c(-limit, limit),
      labels = if (fill == "fg") function(v) sprintf("%+.0f pts", 100 * v) else scales::label_number(accuracy = 0.1, style_positive = "plus"),
      guide = ggplot2::guide_colourbar(barwidth = grid::unit(14, "lines"), barheight = grid::unit(0.5, "lines"),
                                       title.position = "top", title.hjust = 0.5)
    ) +
    ggplot2::coord_fixed(xlim = c(-7.75, 7.75), ylim = c(-1.75, 9.25), expand = FALSE) +
    theme_court() +
    ggplot2::labs(title = title,
                  subtitle = subtitle %||% "Hexagon size = how often they shoot from there; colour = how well, compared with the league from the same spot",
                  caption = caption)
  if (!is.null(facet)) p <- p + ggplot2::facet_wrap(facet)
  p
}

#' Zone shot chart with annotated makes and attempts
#'
#' The court painted by zone. Fill is FG% versus the league in that zone
#' (shrunk), and each zone is labelled with makes/attempts, FG% and its share
#' of the player's shots. This is the book's "sectors" chart with real court
#' zones instead of pie slices and a diverging rather than rainbow scale.
#'
#' @inheritParams summarise_zones
#' @inheritParams plot_shot_hex
#' @param detail Use 12 side-split zones (default) or 5 distance zones.
#' @export
#' @examples
#' plot_shot_zones(subset(shots_2024, player == "Nikola Jokic"),
#'                 baseline = subset(shots_2024, league == "NBA"),
#'                 title = "Nikola Jokic")
plot_shot_zones <- function(shots, baseline = shots, league = NULL, detail = TRUE,
                            limit = 0.1, title = NULL, subtitle = NULL, caption = NULL) {
  shots <- prep_shots(shots)
  league <- league %||% as.character(shots$league[1])
  zs <- summarise_zones(shots, baseline = baseline, detail = detail)
  zs <- zs[court_rules(zs$league) == court_rules(league), ]
  grid <- court_zone_grid(league, detail = detail, res = 0.025)
  grid <- dplyr::left_join(grid, zs, by = "zone")
  # label position: median of each zone's cells, nudged for the rim
  labs <- grid |>
    dplyr::group_by(.data$zone) |>
    dplyr::summarise(x = stats::median(.data$x), y = stats::median(.data$y), .groups = "drop") |>
    dplyr::left_join(zs, by = "zone") |>
    dplyr::filter(.data$y < 9) |>
    dplyr::mutate(label = ifelse(.data$attempts > 0,
                                 sprintf("%d/%d\n%.0f%%  \u00b7  %.0f%% of shots", .data$makes,
                                         .data$attempts, 100 * .data$fg, 100 * .data$share),
                                 "0 shots"))
  labs$y[labs$zone == "Rim"] <- -0.75
  labs$x <- pmin(pmax(labs$x, -6.1), 6.1)
  labs$y[grepl("Corner", labs$zone)] <- -1.05
  ggplot2::ggplot(grid, ggplot2::aes(.data$x, .data$y)) +
    ggplot2::geom_raster(ggplot2::aes(fill = .data$fg_vs_league), interpolate = FALSE) +
    annotate_court_lines(league) +
    ggplot2::geom_label(data = labs, ggplot2::aes(label = .data$label), size = 2.7,
                        lineheight = 0.95, linewidth = 0, fill = scales::alpha("white", 0.75),
                        label.padding = grid::unit(0.12, "lines"), colour = "grey15") +
    scale_fill_vs_average(name = "FG% vs league in the zone", limits = c(-limit, limit),
                          labels = function(v) sprintf("%+.0f pts", 100 * v),
                          na.value = "grey95",
                          guide = ggplot2::guide_colourbar(barwidth = grid::unit(14, "lines"),
                                                           barheight = grid::unit(0.5, "lines"),
                                                           title.position = "top", title.hjust = 0.5)) +
    ggplot2::coord_fixed(xlim = c(-7.75, 7.75), ylim = c(-1.75, 9.25), expand = FALSE) +
    theme_court() +
    ggplot2::labs(title = title, caption = caption,
                  subtitle = subtitle %||% "Makes/attempts, FG% and share of shots per zone.\nColour = FG% compared with the league in the zone (shrunk for small samples)")
}

#' Shot density on the court
#'
#' Where a player (or group) shoots from, as filled density contours, with
#' optional made/missed points on top. With `compare`, shows the difference
#' between the group's shot density and the reference density (red = shoots
#' there more than the reference), which answers "how is this shot diet
#' different?" rather than "where is the rim?".
#'
#' @inheritParams plot_shot_hex
#' @param compare Optional reference shots for a density difference map.
#' @param points Overlay individual shots.
#' @param bw Kernel bandwidth in metres.
#' @export
plot_shot_density <- function(shots, compare = NULL, facet = NULL, league = NULL, points = FALSE,
                              bw = 0.6, title = NULL, subtitle = NULL, caption = NULL) {
  shots <- prep_shots(shots)
  league <- league %||% as.character(shots$league[1])
  gx <- seq(-7.6, 7.6, length.out = 120)
  gy <- seq(-1.6, 9.2, length.out = 90)
  dens <- function(d) {
    d <- d[d$y < 10, ]
    k <- kde2d_simple(d$x, d$y, bw, gx, gy)
    k$z <- k$z / sum(k$z)
    k
  }
  groups <- if (is.null(facet)) list(all = shots) else split(shots, shots[[facet]])
  ref <- if (!is.null(compare)) dens(prep_shots(compare)) else NULL
  grid_df <- dplyr::bind_rows(lapply(names(groups), function(g) {
    k <- dens(groups[[g]])
    z <- if (is.null(ref)) k$z else k$z - ref$z
    out <- expand.grid(x = gx, y = gy)
    out$z <- as.vector(z)
    out$panel <- g
    out
  }))
  if (!is.null(facet)) grid_df[[facet]] <- grid_df$panel
  p <- ggplot2::ggplot(grid_df, ggplot2::aes(.data$x, .data$y)) +
    geom_court(league, coord = FALSE)
  if (is.null(ref)) {
    grid_df$z <- grid_df$z / max(grid_df$z)
    p <- p + ggplot2::geom_raster(data = grid_df[grid_df$z > 0.04, ],
                                  ggplot2::aes(fill = .data$z, alpha = .data$z), interpolate = TRUE) +
      ggplot2::scale_fill_gradientn(colours = c("#FDE6C4", "#F4A259", "#D1495B", "#6A1B4D"),
                                    name = "Shot density", labels = NULL) +
      ggplot2::scale_alpha(range = c(0.25, 0.95), guide = "none")
  } else {
    lim <- stats::quantile(abs(grid_df$z), 0.995)
    p <- p + ggplot2::geom_raster(ggplot2::aes(fill = .data$z), interpolate = TRUE) +
      scale_fill_vs_average(name = "Shoots here more (red) / less (blue) than the reference",
                            limits = c(-lim, lim), labels = NULL,
                            guide = ggplot2::guide_colourbar(barwidth = grid::unit(14, "lines"),
                                                             barheight = grid::unit(0.5, "lines"),
                                                             title.position = "top", title.hjust = 0.5))
  }
  if (points) {
    p <- p + ggplot2::geom_point(data = shots, ggplot2::aes(shape = .data$made), size = 0.8,
                                 alpha = 0.5, colour = "grey15") +
      ggplot2::scale_shape_manual(values = c(`TRUE` = 16, `FALSE` = 4), name = NULL,
                                  labels = c(`TRUE` = "made", `FALSE` = "missed"))
  }
  p <- p + annotate_court_lines(league) +
    ggplot2::coord_fixed(xlim = c(-7.75, 7.75), ylim = c(-1.75, 9.25), expand = FALSE) +
    theme_court() +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption)
  if (!is.null(facet)) p <- p + ggplot2::facet_wrap(facet)
  p
}

# Gaussian 2-D kernel density on a grid (bandwidth in data units).
kde2d_simple <- function(x, y, bw, gx, gy) {
  kx <- outer(gx, x, function(a, b) stats::dnorm(a, b, bw))
  ky <- outer(gy, y, function(a, b) stats::dnorm(a, b, bw))
  list(x = gx, y = gy, z = kx %*% t(ky) / length(x))
}
