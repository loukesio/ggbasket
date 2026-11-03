#' Interactive game flow
#'
#' [plot_game_flow()] as an interactive chart for the web. Hover over any
#' moment of the game to see the score, the clock and the ten players on the
#' floor; hover over a run's bracket to read why it happened
#' ([explain_runs()]). The figure is drawn by [plot_game_flow()] and keeps its
#' look; only the interaction is added. Needs the ggiraph package.
#'
#' @inheritParams plot_game_flow
#' @param names Optional named vector of display names for team codes.
#' @param width Width in inches of the underlying figure.
#' @param height Height in inches.
#' @param ... Passed to [plot_game_flow()] (`title`, `subtitle`, `caption`).
#' @return A ggiraph `girafe` htmlwidget.
#' @export
#' @examples
#' \dontrun{
#' plot_game_flow_interactive(pbp_games, "401766128", min_run = 7)
#' }
plot_game_flow_interactive <- function(pbp, game = NULL, min_run = 8, colours = c("#1F5FA8", "#E07B00"),
                                       names = NULL, width = 10, height = 5.5, ...) {
  rlang::check_installed("ggiraph", "for interactive charts")
  game <- game %||% as.character(pbp$game_id[1])
  g <- as.data.frame(pbp[pbp$game_id == game, ])
  p <- plot_game_flow(g, game, min_run = min_run, colours = colours, ...)
  home <- g$hometeam[1]; away <- g$awayteam[1]
  nm <- function(x) if (!is.null(names) && x %in% names(names)) names[[x]] else x
  f <- game_flow(g)
  ymax <- max(abs(f$margin), 6) * 1.25

  # one stretch per change of score or of the players on the floor
  lu <- intersect(c(paste0("h", 1:5), paste0("a", 1:5)), names(g))
  key <- do.call(paste, c(list(g$home_score, g$away_score), lapply(lu, function(v) g[[v]])))
  brk <- which(c(TRUE, key[-1] != key[-length(key)]))
  st <- g[brk, ]
  st$t0 <- st$totalTime / 60
  st$t1 <- c(st$totalTime[-1], max(g$totalTime)) / 60
  st <- st[st$t1 > st$t0, ]
  five <- function(r, side) {
    v <- unlist(r[paste0(side, 1:5)][intersect(paste0(side, 1:5), names(r))])
    paste(v[!is.na(v)], collapse = ", ")
  }
  esc <- function(x) gsub("'", "&#39;", x, fixed = TRUE)
  st$tip <- vapply(seq_len(nrow(st)), function(i) {
    r <- st[i, ]
    floor <- if (length(lu)) sprintf("<br><span style='color:%s'><b>%s</b></span>: %s<br><span style='color:%s'><b>%s</b></span>: %s",
                                     colours[1], nm(home), five(r, "h"), colours[2], nm(away), five(r, "a")) else ""
    esc(sprintf("<b>%s</b> &middot; %s %d-%d %s%s", game_clock(st, i), nm(home), as.integer(r$home_score),
                as.integer(r$away_score), nm(away), floor))
  }, character(1))
  st$id <- paste0("s", seq_len(nrow(st)))

  # the run layers of plot_game_flow() are swapped for interactive copies
  is_run <- vapply(p$layers, function(l) is.data.frame(l$data) && "yy" %in% names(l$data), logical(1))
  p$layers <- p$layers[!is_run]
  p <- p + ggiraph::geom_rect_interactive(
    data = st, ggplot2::aes(xmin = .data$t0, xmax = .data$t1, ymin = -ymax, ymax = ymax,
                            tooltip = .data$tip, data_id = .data$id),
    inherit.aes = FALSE, fill = "white", alpha = 0, colour = NA)

  runs <- explain_runs(g, min_points = min_run, names = names)
  if (nrow(runs)) {
    runs$mid <- (runs$start + runs$end) / 2 / 60
    runs$yy <- ifelse(runs$team == home, pmax(runs$margin_after, 0) + ymax * 0.12,
                      pmin(runs$margin_after, 0) - ymax * 0.12)
    runs$tip <- esc(gsub("\\*\\*(.+?)\\*\\*", "<b>\\1</b>", runs$story))
    runs$id <- paste0("r", seq_len(nrow(runs)))
    band <- ymax * 0.09
    runs$y0 <- ifelse(runs$team == home, runs$yy - band * 0.3, runs$yy - band)
    runs$y1 <- ifelse(runs$team == home, runs$yy + band, runs$yy + band * 0.3)
    runs$y0 <- pmax(runs$y0, -ymax); runs$y1 <- pmin(runs$y1, ymax)
    p <- p +
      ggiraph::geom_rect_interactive(data = runs, ggplot2::aes(xmin = .data$start / 60, xmax = .data$end / 60,
                                                               ymin = .data$y0, ymax = .data$y1,
                                                               tooltip = .data$tip, data_id = .data$id),
                                     inherit.aes = FALSE, fill = "white", alpha = 0, colour = NA) +
      ggiraph::geom_segment_interactive(data = runs, ggplot2::aes(x = .data$start / 60, xend = .data$end / 60,
                                                                  y = .data$yy, yend = .data$yy,
                                                                  tooltip = .data$tip, data_id = .data$id),
                                        inherit.aes = FALSE, colour = "grey30", linewidth = 0.4) +
      ggiraph::geom_text_interactive(data = runs, ggplot2::aes(x = .data$mid, y = .data$yy, label = .data$label,
                                                               vjust = ifelse(.data$team == home, -0.5, 1.5),
                                                               tooltip = .data$tip, data_id = .data$id),
                                     inherit.aes = FALSE, size = 2.9, colour = "grey20")
  }
  fo <- ggbasket_fonts()
  w <- ggiraph::girafe(
    ggobj = p, width_svg = width, height_svg = height,
    fonts = list(sans = fo$body, serif = fo$title, mono = fo$mono, symbol = fo$body),
    options = list(
      ggiraph::opts_hover(css = ggiraph::girafe_css(css = "", area = "fill:#1F1F1F;fill-opacity:0.07;",
                                                     line = "stroke:#00798c;stroke-width:2.5px;", text = "fill:#00798c;")),
      ggiraph::opts_hover_inv(css = ""),
      ggiraph::opts_tooltip(css = paste("background:#FFFFFF;color:#1F1F1F;border:1px solid #DDDDDD;border-radius:4px;",
                                        "padding:8px 10px;font-family:'Fira Sans',Helvetica,Arial,sans-serif;",
                                        "font-size:12px;line-height:1.4;max-width:340px;box-shadow:0 2px 6px rgba(0,0,0,.12);"),
                            use_fill = FALSE, opacity = 1),
      ggiraph::opts_toolbar(saveaspng = FALSE),
      ggiraph::opts_sizing(rescale = TRUE)))
  # ggiraph would embed its Liberation fonts (8 MB); ship small Latin subsets of the figure's fonts instead
  w$dependencies <- c(Filter(function(x) !grepl("^liberation", x$name), w$dependencies), list(web_fonts_dependency()))
  w
}

web_fonts_env <- new.env(parent = emptyenv())

# @font-face rules with the Latin woff2 subsets of the ggbasket fonts, embedded; downloaded once per session.
# Offline, only the fallback stack is used.
web_fonts_dependency <- function() {
  if (is.null(web_fonts_env$css)) {
    ua <- c(`User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120 Safari/537.36")
    css <- tryCatch({
      tmp <- tempfile(fileext = ".css")
      utils::download.file(paste0("https://fonts.googleapis.com/css2?family=Fira+Sans:wght@400;700",
                                  "&family=Fira+Sans+Condensed:wght@400;700&family=Roboto+Mono:wght@400;700"),
                           tmp, quiet = TRUE, headers = ua)
      txt <- paste(readLines(tmp, warn = FALSE), collapse = "\n")
      blocks <- regmatches(txt, gregexpr("/\\* latin(-ext)? \\*/\\s*@font-face \\{[^}]*\\}", txt))[[1]]
      vapply(blocks, function(b) {
        u <- regmatches(b, regexpr("https://[^)]+\\.woff2", b))
        f <- tempfile(fileext = ".woff2")
        utils::download.file(u, f, quiet = TRUE, mode = "wb")
        b64 <- jsonlite::base64_enc(readBin(f, "raw", file.size(f)))
        sub(u, paste0("data:font/woff2;base64,", gsub("\\s", "", b64)), b, fixed = TRUE)
      }, character(1), USE.NAMES = FALSE)
    }, error = function(e) character())
    web_fonts_env$css <- paste(css, collapse = "\n")
  }
  htmltools::htmlDependency(
    "ggbasket-fonts", "1.0", src = c(href = ""), all_files = FALSE,
    head = paste0("<style>", web_fonts_env$css, "\n.girafe_container_std svg text { font-synthesis: none; }</style>"))
}
