#' ggbasket theme and colours
#'
#' `theme_ggbasket()` is a quiet, annotation-friendly theme: no minor grid,
#' left-aligned bold titles, grey subtitles and captions, legend on top.
#' `theme_court()` is the same look without axes, for shot charts.
#'
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @param grid Which major grid lines to keep: `"xy"`, `"x"`, `"y"` or `"none"`.
#' @return A [ggplot2::theme()].
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() + theme_ggbasket()
theme_ggbasket <- function(base_size = 11, base_family = "", grid = "xy") {
  grid <- match.arg(grid, c("xy", "x", "y", "none"))
  t <- ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.25),
                                         margin = ggplot2::margin(b = 4)),
      plot.subtitle = ggplot2::element_text(colour = "grey35", margin = ggplot2::margin(b = 8),
                                            lineheight = 1.1),
      plot.caption = ggplot2::element_text(colour = "grey50", hjust = 0, size = ggplot2::rel(0.8)),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "grey91", linewidth = 0.35),
      axis.title = ggplot2::element_text(colour = "grey30"),
      axis.text = ggplot2::element_text(colour = "grey40"),
      strip.text = ggplot2::element_text(face = "bold", hjust = 0, size = ggplot2::rel(1)),
      legend.position = "top",
      legend.justification = "left",
      legend.title = ggplot2::element_text(colour = "grey30", size = ggplot2::rel(0.9)),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(12, 14, 10, 12)
    )
  if (!grepl("x", grid)) t <- t + ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  if (!grepl("y", grid)) t <- t + ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
  t
}

#' @rdname theme_ggbasket
#' @export
theme_court <- function(base_size = 11, base_family = "") {
  theme_ggbasket(base_size, base_family, grid = "none") +
    ggplot2::theme(axis.text = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   legend.position = "bottom",
                   legend.justification = "center")
}

#' Colours used across ggbasket
#'
#' A named list: `league` (NBA / EuroLeague), `highlight` (one accent for the
#' subject of a figure), `context` (grey for everyone else), `above`/`below`
#' (the two ends of the diverging scale), and `court` (line and floor colours).
#' The diverging ends are taken from ColorBrewer RdBu, which is safe for
#' red-green colour blindness (unlike the red-green ramps used in the book).
#' @export
ggbasket_colours <- list(
  league = c(NBA = "#1F5FA8", EuroLeague = "#E07B00", FIBA = "#E07B00"),
  highlight = "#D1495B",
  context = "grey72",
  above = "#B2182B",
  mid = "#F7F7F7",
  below = "#2166AC",
  court_line = "grey35",
  court_floor = "#FBF7F0"
)

#' Diverging and sequential scales
#'
#' `scale_*_vs_average()` centres a blue-white-red scale on `midpoint`
#' (typically 0 for "difference from league average"). Red always means
#' "better than average" for the quantity shown, so flip `reverse` for
#' quantities where lower is better (turnovers, defensive rating).
#'
#' @param ... Passed to [ggplot2::scale_fill_gradient2()] or
#'   [ggplot2::scale_fill_viridis_c()].
#' @param midpoint Centre of the diverging scale.
#' @param reverse Swap the two ends.
#' @param limits,oob Scale limits; values outside are squished, so a single
#'   extreme cell does not wash out the rest.
#' @export
scale_fill_vs_average <- function(..., midpoint = 0, reverse = FALSE, limits = NULL,
                                  oob = scales::squish) {
  ends <- c(ggbasket_colours$below, ggbasket_colours$above)
  if (reverse) ends <- rev(ends)
  ggplot2::scale_fill_gradient2(..., low = ends[1], mid = ggbasket_colours$mid, high = ends[2],
                                midpoint = midpoint, limits = limits, oob = oob)
}

#' @rdname scale_fill_vs_average
#' @export
scale_colour_vs_average <- function(..., midpoint = 0, reverse = FALSE, limits = NULL,
                                    oob = scales::squish) {
  ends <- c(ggbasket_colours$below, ggbasket_colours$above)
  if (reverse) ends <- rev(ends)
  ggplot2::scale_colour_gradient2(..., low = ends[1], mid = "grey80", high = ends[2],
                                  midpoint = midpoint, limits = limits, oob = oob)
}

#' @rdname scale_fill_vs_average
#' @export
scale_colour_league <- function(...) {
  ggplot2::scale_colour_manual(..., values = ggbasket_colours$league)
}

#' @rdname scale_fill_vs_average
#' @export
scale_fill_league <- function(...) {
  ggplot2::scale_fill_manual(..., values = ggbasket_colours$league)
}

# Muted, colour-blind-friendlier categorical palette (Okabe-Ito order, no yellow).
categorical_palette <- function(x) {
  lev <- if (is.factor(x)) levels(x) else sort(unique(as.character(x)))
  cols <- c("#0072B2", "#E69F00", "#009E73", "#CC79A7", "#D55E00", "#56B4E9", "#7F7F7F", "#000000")
  stats::setNames(rep_len(cols, length(lev)), lev)
}
