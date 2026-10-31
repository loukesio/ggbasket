#' ggbasket theme and colours
#'
#' `theme_ggbasket()` is an editorial theme in the style of Cedric Scherer's
#' graphics: warm paper background, bold left-aligned title, a subtitle that
#' wraps by itself and renders markdown (so words can be coloured to replace
#' a legend, see [colour_text()]), a monospaced caption, and
#' generous margins. Titles and subtitles wrap to the plot width by themselves. `theme_court()` is the same look without axes, for shot
#' charts.
#'
#' Fonts: Fira Sans (titles), Fira Sans Condensed (text) and Roboto Mono
#' (numbers), all free on Google Fonts. Missing fonts fall back to Roboto,
#' Helvetica or the system sans. On the base `pdf()` / `postscript()` devices,
#' which cannot use system fonts, the theme falls back to `"sans"`; use
#' `ggsave(device = cairo_pdf)` or a PNG for the full look. Set
#' `options(ggbasket.family = "sans")` to switch the custom fonts off.
#'
#' @param base_size Base font size.
#' @param base_family Body font family. Default: picked by [ggbasket_fonts()].
#' @param grid Which major grid lines to keep: `"xy"`, `"x"`, `"y"` or `"none"`.
#' @return A [ggplot2::theme()].
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) + geom_point() +
#'   labs(title = "Heavier cars burn more fuel",
#'        subtitle = paste("Cars with", colour_text("more cylinders", "#D1495B"), "sit lower")) +
#'   theme_ggbasket()
theme_ggbasket <- function(base_size = 11.5, base_family = NULL, grid = "xy") {
  grid <- match.arg(grid, c("xy", "x", "y", "none"))
  f <- ggbasket_fonts()
  body <- base_family %||% f$body
  title_family <- if (is.null(base_family)) f$title else base_family
  mono <- if (is.null(base_family)) f$mono else base_family
  ink <- ggbasket_colours$ink
  t <- ggplot2::theme_minimal(base_size = base_size, base_family = body) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = ggbasket_colours$paper, colour = NA),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "#E6E2DA", linewidth = 0.35),
      plot.title = ggtext::element_textbox_simple(family = title_family, face = "bold", colour = ink,
                                                  size = ggplot2::rel(1.65), lineheight = 1.1,
                                                  margin = ggplot2::margin(b = 8)),
      plot.subtitle = ggtext::element_textbox_simple(colour = "#4A4A4A", lineheight = 1.3,
                                                     margin = ggplot2::margin(t = 2, b = 16)),
      plot.caption = ggtext::element_markdown(family = mono, colour = "#8A8A8A", hjust = 0,
                                              size = ggplot2::rel(0.66), lineheight = 1.35,
                                              margin = ggplot2::margin(t = 16)),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.title = ggplot2::element_text(colour = "#3A3A3A", size = ggplot2::rel(0.95)),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 8)),
      axis.text = ggplot2::element_text(colour = "#5A5A5A", size = ggplot2::rel(0.82)),
      strip.text = ggplot2::element_text(family = title_family, face = "bold", hjust = 0,
                                         size = ggplot2::rel(1.08), colour = ink,
                                         margin = ggplot2::margin(b = 6)),
      legend.position = "top",
      legend.justification = "left",
      legend.title = ggplot2::element_text(colour = "#3A3A3A", size = ggplot2::rel(0.9)),
      legend.text = ggplot2::element_text(colour = "#4A4A4A", size = ggplot2::rel(0.85)),
      legend.background = ggplot2::element_rect(fill = NA, colour = NA),
      legend.key = ggplot2::element_rect(fill = NA, colour = NA),
      plot.margin = ggplot2::margin(22, 26, 14, 24),
      geom = ggplot2::element_geom(family = body, ink = ink, paper = ggbasket_colours$paper)
    )
  if (!grepl("x", grid)) t <- t + ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  if (!grepl("y", grid)) t <- t + ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
  t
}

#' @rdname theme_ggbasket
#' @export
theme_court <- function(base_size = 11.5, base_family = NULL) {
  theme_ggbasket(base_size, base_family, grid = "none") +
    ggplot2::theme(axis.text = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   axis.title.x = ggplot2::element_blank(),
                   axis.title.y = ggplot2::element_blank(),
                   legend.position = "bottom",
                   legend.justification = "center")
}

#' Fonts used by the ggbasket theme
#'
#' Returns the first installed family from each preference list: `body`
#' (Fira Sans Condensed, Roboto Condensed, Arial Narrow), `title` (Fira Sans,
#' Roboto, Helvetica Neue) and `mono` (Roboto Mono, Fira Mono, Menlo). Falls
#' back to `"sans"`/`"mono"` when none is installed, when the current device
#' is base `pdf()`/`postscript()`, or when `options(ggbasket.family)` is set.
#' @return A list with `body`, `title` and `mono`.
#' @export
#' @examples
#' ggbasket_fonts()
ggbasket_fonts <- function() {
  opt <- getOption("ggbasket.family")
  if (!is.null(opt)) return(list(body = opt, title = opt, mono = opt))
  basic <- list(body = "sans", title = "sans", mono = "mono")
  if (names(grDevices::dev.cur()) %in% c("pdf", "postscript", "xfig", "pictex")) return(basic)
  avail <- tryCatch(unique(systemfonts::system_fonts()$family), error = function(e) character())
  pick <- function(x, fallback) {
    x <- x[x %in% avail]
    if (length(x)) x[1] else fallback
  }
  list(body = pick(c("Fira Sans Condensed", "Roboto Condensed", "Arial Narrow"), "sans"),
       title = pick(c("Fira Sans", "Roboto", "Helvetica Neue"), "sans"),
       mono = pick(c("Roboto Mono", "Fira Mono", "Menlo"), "mono"))
}

# family for ggrepel layers, which do not follow theme(geom = element_geom())
gb_family <- function() ggbasket_fonts()$body

#' Colour words in titles and subtitles
#'
#' `colour_text()` wraps text in a coloured (and by default bold) HTML span,
#' for titles and subtitles drawn by [theme_ggbasket()]: naming the groups in
#' their own colour makes a legend unnecessary. `ggbasket_caption()` builds
#' the standard "Data · Graphic" caption.
#'
#' @param text Text to colour.
#' @param colour A colour; a name from `ggbasket_colours$league` also works.
#' @param bold Make it bold.
#' @export
#' @examples
#' colour_text("NBA", "NBA")
#' ggbasket_caption("2024/25 regular season, NBA Stats and EuroLeague API")
colour_text <- function(text, colour, bold = TRUE) {
  if (colour %in% names(ggbasket_colours$league)) colour <- ggbasket_colours$league[[colour]]
  if (bold) text <- paste0("**", text, "**")
  sprintf("<span style='color:%s'>%s</span>", colour, text)
}

#' @rdname colour_text
#' @param data Data source.
#' @param graphic Author credit.
#' @param note Optional extra line(s).
#' @export
ggbasket_caption <- function(data, graphic = "Loukas Theodosiou \u00b7 ggbasket", note = NULL) {
  out <- paste0("**Data** ", data, " &nbsp;\u00b7&nbsp; **Graphic** ", graphic)
  if (!is.null(note)) out <- paste(c(out, note), collapse = "<br>")
  out
}

#' Colours used across ggbasket
#'
#' A named list: `league` (NBA / EuroLeague), `highlight` (one accent for the
#' subject of a figure), `context` (grey for everyone else), `above`/`below`
#' (the two ends of the diverging scale), `ink`/`paper` (text and background) and
#' `court_line`/`court_floor`.
#' The diverging ends are taken from ColorBrewer RdBu, which is safe for
#' red-green colour blindness (unlike the red-green ramps used in the book).
#' @export
ggbasket_colours <- list(
  league = c(NBA = "#1F5FA8", EuroLeague = "#E07B00", FIBA = "#E07B00"),
  highlight = "#D1495B",
  ink = "#1F1F1F",
  paper = "#FAF8F4",
  context = "grey72",
  above = "#B2182B",
  mid = "#F7F7F7",
  below = "#2166AC",
  court_line = "grey35",
  court_floor = "#F3EDE2"
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
