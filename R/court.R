# Court geometry. Units are metres, origin at the centre of the hoop, y pointing
# towards half court, x positive to the shooter's right as seen from the baseline
# camera (the convention of NBA Stats and the EuroLeague API after rescaling).

court_specs <- list(
  NBA = list(
    half_length = 14.325, width = 15.24, hoop_baseline = 1.600,
    arc_r = 7.24, corner_x = 6.71, lane_w = 4.88, ft_line = 5.79,
    restricted_r = 1.22, board_baseline = 1.22, board_w = 1.83, circle_r = 1.83,
    hash = c(2.13, 3.05, 3.96, 4.88)
  ),
  FIBA = list(
    half_length = 14.000, width = 15.00, hoop_baseline = 1.575,
    arc_r = 6.75, corner_x = 6.60, lane_w = 4.90, ft_line = 5.80,
    restricted_r = 1.25, board_baseline = 1.20, board_w = 1.80, circle_r = 1.80,
    hash = c(1.75, 2.85, 3.70, 4.55)
  )
)
for (.lg in names(court_specs)) {
  court_specs[[.lg]]$corner_y <- with(court_specs[[.lg]], sqrt(arc_r^2 - corner_x^2))
}
rm(.lg)

# "EuroLeague", "euroleague", "FIBA" -> "FIBA"; "NBA" -> "NBA"
court_rules <- function(league) {
  league <- as.character(league)
  out <- ifelse(toupper(league) == "NBA", "NBA", "FIBA")
  bad <- !toupper(league) %in% c("NBA", "FIBA", "EUROLEAGUE", "EUROCUP", "EL")
  if (any(bad)) rlang::abort(paste0("Unknown league: ", paste(unique(league[bad]), collapse = ", "),
                                    ". Use 'NBA', 'FIBA' or 'EuroLeague'."))
  out
}

#' Court specification
#'
#' Dimensions (in metres) of the NBA or FIBA half court used by every court
#' drawing and zone function. `"EuroLeague"` is accepted as an alias of
#' `"FIBA"`.
#'
#' @param league `"NBA"`, `"FIBA"` or `"EuroLeague"`.
#' @return A named list of dimensions.
#' @export
#' @examples
#' court_spec("NBA")$arc_r     # 7.24 m
#' court_spec("EuroLeague")$arc_r  # 6.75 m
court_spec <- function(league = "NBA") {
  court_specs[[court_rules(league[1])]]
}

arc_pts <- function(r, from, to, n = 120, x0 = 0, y0 = 0) {
  t <- seq(from, to, length.out = n)
  data.frame(x = x0 + r * cos(t), y = y0 + r * sin(t))
}

#' Court lines as a data frame
#'
#' @inheritParams court_spec
#' @return A data frame with columns `piece`, `x`, `y` (one path per piece).
#' @export
court_lines <- function(league = "NBA") {
  k <- court_spec(league)
  base <- -k$hoop_baseline
  top <- k$half_length - k$hoop_baseline
  w2 <- k$width / 2
  a0 <- asin(k$corner_y / k$arc_r)
  ft_y <- k$ft_line - k$hoop_baseline
  pieces <- list(
    outline = data.frame(x = c(-w2, -w2, w2, w2), y = c(top, base, base, top)),
    halfway = data.frame(x = c(-w2, w2), y = c(top, top)),
    three = rbind(data.frame(x = -k$corner_x, y = base),
                  arc_pts(k$arc_r, pi - a0, a0),
                  data.frame(x = k$corner_x, y = base)),
    lane = data.frame(x = c(-k$lane_w / 2, -k$lane_w / 2, k$lane_w / 2, k$lane_w / 2),
                      y = c(base, ft_y, ft_y, base)),
    ft_circle = arc_pts(k$circle_r, 0, pi, y0 = ft_y),
    ft_circle_back = arc_pts(k$circle_r, pi, 2 * pi, y0 = ft_y, n = 60),
    restricted = arc_pts(k$restricted_r, 0, pi),
    hoop = arc_pts(0.225, 0, 2 * pi, n = 40),
    board = data.frame(x = c(-k$board_w / 2, k$board_w / 2),
                       y = rep(k$board_baseline - k$hoop_baseline, 2)),
    centre = arc_pts(k$circle_r, pi, 2 * pi, y0 = top)
  )
  # lane-space marks along both sides of the key
  for (i in seq_along(k$hash)) {
    for (sgn in c(-1, 1)) {
      pieces[[sprintf("hash_%d_%d", i, sgn)]] <-
        data.frame(x = sgn * (k$lane_w / 2 + c(0, 0.2)), y = rep(k$hash[i] - k$hoop_baseline, 2))
    }
  }
  out <- dplyr::bind_rows(pieces, .id = "piece")
  out$dashed <- out$piece == "ft_circle_back"
  tibble::as_tibble(out)
}

#' Draw a half court
#'
#' Adds the floor, the painted key, the court lines and the rim to a plot,
#' plus a fixed-ratio coordinate system cropped to the half court. Put it
#' first so data layers are drawn on top, then add [annotate_court_lines()]
#' after the data layers to keep the lines visible.
#'
#' Three looks, set per call or for the session with
#' `options(ggbasket.court = "...")`:
#' * `"painted"` (default): light cool-grey floor, blue-grey key, dark lines, orange rim;
#' * `"arena"`: darker floor with white lines, like a broadcast graphic;
#' * `"minimal"`: lines only, on a near-white floor.
#'
#' @inheritParams court_spec
#' @param style `"painted"`, `"arena"` or `"minimal"`.
#' @param colour,linewidth Line colour and width (default: from `style`).
#' @param floor Floor colour (default: from `style`), or `NA` for none.
#' @param ylim Visible depth of the court in metres from the hoop. The default
#'   stops just past the top of the arc, where almost all shots are; use
#'   `c(-1.75, 12.6)` for the whole half court.
#' @param coord Add [ggplot2::coord_fixed()] with court limits.
#' @return A list of ggplot2 layers.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot() + geom_court("NBA") + theme_court()
#' ggplot() + geom_court("EuroLeague", style = "arena", ylim = c(-1.75, 12.6)) + theme_court()
geom_court <- function(league = "NBA", style = getOption("ggbasket.court", "painted"), colour = NULL,
                       linewidth = NULL, floor = NULL, ylim = c(-1.75, 9.25), coord = TRUE) {
  st <- court_style(style)
  k <- court_spec(league)
  w2 <- k$width / 2
  floor <- floor %||% st$floor
  out <- list()
  if (!is.na(floor)) {
    out <- c(out, ggplot2::annotate("rect", xmin = -w2, xmax = w2, ymin = -k$hoop_baseline,
                                    ymax = k$half_length - k$hoop_baseline, fill = floor, colour = NA))
  }
  if (!is.na(st$key)) {
    out <- c(out, ggplot2::annotate("rect", xmin = -k$lane_w / 2, xmax = k$lane_w / 2, ymin = -k$hoop_baseline,
                                    ymax = k$ft_line - k$hoop_baseline, fill = st$key, colour = NA))
  }
  out <- c(out, annotate_court_lines(league, colour, linewidth, style = style))
  if (coord) {
    out <- c(out, ggplot2::coord_fixed(xlim = c(-w2, w2) + c(-0.15, 0.15), ylim = ylim,
                                       expand = FALSE, clip = "on"))
  }
  out
}

#' @rdname geom_court
#' @param alpha Line opacity (lower it when lines are drawn over data).
#' @export
annotate_court_lines <- function(league = "NBA", colour = NULL, linewidth = NULL,
                                 style = getOption("ggbasket.court", "painted"), alpha = 1) {
  st <- court_style(style)
  colour <- scales::alpha(colour %||% st$line, alpha)
  linewidth <- linewidth %||% st$linewidth
  d <- court_lines(league)
  hoop <- d$piece == "hoop"
  board <- d$piece == "board"
  list(
    ggplot2::geom_path(data = d[!d$dashed & !hoop & !board, ], ggplot2::aes(.data$x, .data$y, group = .data$piece),
                       colour = colour, linewidth = linewidth, inherit.aes = FALSE, lineend = "square"),
    ggplot2::geom_path(data = d[d$dashed, ], ggplot2::aes(.data$x, .data$y, group = .data$piece),
                       colour = colour, linewidth = linewidth * 0.8, linetype = "22",
                       inherit.aes = FALSE),
    ggplot2::geom_path(data = d[board, ], ggplot2::aes(.data$x, .data$y, group = .data$piece),
                       colour = colour, linewidth = linewidth * 2.6, inherit.aes = FALSE),
    ggplot2::geom_path(data = d[hoop, ], ggplot2::aes(.data$x, .data$y, group = .data$piece),
                       colour = scales::alpha(st$rim, alpha), linewidth = linewidth * 1.8, inherit.aes = FALSE)
  )
}

court_style <- function(style = "painted") {
  style <- match.arg(style, c("painted", "arena", "minimal"))
  switch(style,
         painted = list(floor = "#F1F3F5", key = "#DCE4EC", line = "#3A3F45", linewidth = 0.5, rim = "#E8743B"),
         arena = list(floor = "#DDE2E7", key = "#C5CED8", line = "#FFFFFF", linewidth = 0.7, rim = "#E8743B"),
         minimal = list(floor = "#F7F7F7", key = NA, line = "grey35", linewidth = 0.4, rim = "grey35"))
}

#' Classify shots into court zones
#'
#' Five distance zones (`detail = FALSE`) or thirteen zones that also split by
#' side of the floor (`detail = TRUE`): rim, paint, mid-range left / centre /
#' right (short and long), corner 3 left / right, above-the-break 3 left /
#' centre / right. Uses each league's own 3-point geometry. When `value` is
#' missing, 2 vs 3 is inferred from the coordinates.
#'
#' The rim radius is 1.75 m by default rather than the 1.22-1.25 m restricted
#' area because EuroLeague operators record layups about 1.1 m from the hoop.
#'
#' @param x,y Shot coordinates in metres (see [geom_court()]).
#' @param league League rules, recycled.
#' @param value Shot value (2 or 3), optional.
#' @param detail Return the 13 side-split zones.
#' @param rim_r,short_r Radii (m) of the rim area and of short mid-range.
#' @return A factor.
#' @export
#' @examples
#' shot_zone(c(0, 3, 6.8, 0), c(0.5, 3, 0.5, 7.5), "NBA", detail = TRUE)
shot_zone <- function(x, y, league = "NBA", value = NULL, detail = FALSE,
                      rim_r = 1.75, short_r = 4.25) {
  rules <- court_rules(rep_len(league, length(x)))
  arc_r <- ifelse(rules == "NBA", court_specs$NBA$arc_r, court_specs$FIBA$arc_r)
  cx <- ifelse(rules == "NBA", court_specs$NBA$corner_x, court_specs$FIBA$corner_x)
  cy <- ifelse(rules == "NBA", court_specs$NBA$corner_y, court_specs$FIBA$corner_y)
  d <- sqrt(x^2 + y^2)
  if (is.null(value)) {
    value <- ifelse((y <= cy & abs(x) >= cx) | (y > cy & d >= arc_r), 3, 2)
  }
  ang <- atan2(y, x) * 180 / pi  # 90 = straight on
  side <- dplyr::case_when(ang > 120 | ang < -90 ~ "left", ang < 60 ~ "right", TRUE ~ "centre")
  if (!detail) {
    z <- dplyr::case_when(
      value == 3 & y <= cy ~ "Corner 3",
      value == 3 ~ "Above-break 3",
      d < rim_r ~ "Rim",
      d < short_r ~ "Short mid-range",
      TRUE ~ "Long mid-range"
    )
    return(factor(z, levels = shot_zone_levels(FALSE)))
  }
  # "left"/"right" follow the image: negative x is drawn on the left.
  z <-dplyr::case_when(
    value == 3 & y <= cy ~ paste("Corner 3", ifelse(x < 0, "left", "right")),
    value == 3 ~ paste("Above-break 3", side),
    d < rim_r ~ "Rim",
    d < short_r & abs(x) < 2.45 ~ "Paint",
    d < short_r ~ paste("Short mid", ifelse(x < 0, "left", "right")),
    TRUE ~ paste("Long mid", side)
  )
  factor(z, levels = shot_zone_levels(TRUE))
}

#' @rdname shot_zone
#' @export
shot_zone_levels <- function(detail = FALSE) {
  if (!detail) return(c("Rim", "Short mid-range", "Long mid-range", "Corner 3", "Above-break 3"))
  c("Rim", "Paint", "Short mid left", "Short mid right",
    "Long mid left", "Long mid centre", "Long mid right",
    "Corner 3 left", "Corner 3 right",
    "Above-break 3 left", "Above-break 3 centre", "Above-break 3 right")
}

#' A fine grid of the half court labelled by zone
#'
#' Used to paint zone charts: each cell of a `res`-metre grid is classified
#' with [shot_zone()], so zone shapes follow the real court lines exactly
#' without hand-made polygons.
#'
#' @inheritParams shot_zone
#' @param res Grid resolution in metres.
#' @param ymax Depth of the grid from the hoop.
#' @export
court_zone_grid <- function(league = "NBA", detail = TRUE, res = 0.05, ymax = 9.25,
                            rim_r = 1.75, short_r = 4.25) {
  k <- court_spec(league)
  g <- expand.grid(x = seq(-k$width / 2 + res / 2, k$width / 2, by = res),
                   y = seq(-k$hoop_baseline + res / 2, ymax, by = res))
  g$zone <- shot_zone(g$x, g$y, league, detail = detail, rim_r = rim_r, short_r = short_r)
  tibble::as_tibble(g)
}
