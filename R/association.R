#' Strength of association between any two variables
#'
#' The book (Section 3.1) measures dependence with a different index for each
#' pair of variable types: Cramer's V for two categorical variables, the
#' correlation ratio eta-squared for a categorical and a numerical one, and
#' Pearson's correlation for two numerical ones. `association()` does all
#' three for every pair in `vars` and puts them on one 0-1 scale (|r| for
#' two numerical variables), with a test p-value, so they can be read in one
#' table or one heatmap ([plot_association()]).
#'
#' Logical columns and character columns are treated as categorical. With
#' large data almost everything is "significant"; read the strength, not the
#' p-value.
#'
#' @param data A data frame.
#' @param vars Columns to use; a named vector sets display names.
#' @return A tibble with `var1`, `var2`, `measure` (`"V"`, `"eta2"` or
#'   `"|r|"`), `value` and `p_value`.
#' @export
#' @examples
#' set.seed(1)
#' sh <- shots_2024[sample(nrow(shots_2024), 5000), ]
#' sh$dist <- sqrt(sh$x^2 + sh$y^2)
#' association(sh, c("league", "value", "made", "dist"))
association <- function(data, vars) {
  data <- as.data.frame(data)
  labels <- if (is.null(names(vars))) vars else ifelse(names(vars) == "", vars, names(vars))
  vars <- unname(vars)
  is_cat <- vapply(vars, function(v) {
    x <- data[[v]]
    is.character(x) || is.factor(x) || is.logical(x) || (is.numeric(x) && length(unique(x)) <= 5)
  }, logical(1))
  pairs <- utils::combn(seq_along(vars), 2)
  out <- lapply(seq_len(ncol(pairs)), function(k) {
    i <- pairs[1, k]; j <- pairs[2, k]
    x <- data[[vars[i]]]; y <- data[[vars[j]]]
    ok <- !is.na(x) & !is.na(y)
    x <- x[ok]; y <- y[ok]
    if (is_cat[i] && is_cat[j]) {
      tab <- table(x, y)
      ct <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))
      v <- sqrt(unname(ct$statistic) / (sum(tab) * (min(dim(tab)) - 1)))
      res <- c(value = v, p = ct$p.value); m <- "V"
    } else if (!is_cat[i] && !is_cat[j]) {
      ct <- stats::cor.test(x, y)
      res <- c(value = abs(unname(ct$estimate)), p = ct$p.value); m <- "|r|"
    } else {
      g <- if (is_cat[i]) x else y
      num <- if (is_cat[i]) y else x
      fit <- stats::lm(num ~ factor(g))
      a <- stats::anova(fit)
      res <- c(value = a[1, "Sum Sq"] / sum(a[, "Sum Sq"]), p = a[1, "Pr(>F)"]); m <- "eta2"
    }
    tibble::tibble(var1 = labels[i], var2 = labels[j], measure = m,
                   value = unname(res["value"]), p_value = unname(res["p"]))
  })
  out <- dplyr::bind_rows(out)
  attr(out, "vars") <- labels
  out
}

#' Heatmap of associations
#'
#' Lower-triangle heatmap of [association()]: one sequential colour scale
#' from 0 (independent) to 1 (perfectly dependent); each cell names the index
#' used, so a Cramer's V is never mistaken for a correlation.
#'
#' @param assoc Output of [association()].
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' set.seed(1)
#' sh <- shots_2024[sample(nrow(shots_2024), 5000), ]
#' sh$dist <- sqrt(sh$x^2 + sh$y^2)
#' plot_association(association(sh, c(League = "league", Value = "value",
#'                                    Made = "made", Distance = "dist")))
plot_association <- function(assoc, title = NULL, subtitle = NULL, caption = NULL) {
  lev <- attr(assoc, "vars") %||% unique(c(assoc$var1, assoc$var2))
  assoc$var1 <- factor(assoc$var1, levels = lev)
  assoc$var2 <- factor(assoc$var2, levels = rev(lev))
  # base pdf()/postscript() cannot draw the Greek letter
  eta <- if (identical(ggbasket_fonts()$body, "sans") && names(grDevices::dev.cur()) %in% c("pdf", "postscript")) "eta\u00b2" else "\u03b7\u00b2"
  sym <- c(V = "V", eta2 = eta, `|r|` = "|r|")
  assoc$lab <- sprintf("%s\n%s", sub("^0", "", sprintf("%.2f", assoc$value)), sym[assoc$measure])
  ggplot2::ggplot(assoc, ggplot2::aes(.data$var1, .data$var2)) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$value), colour = ggbasket_colours$paper, linewidth = 1.2) +
    ggplot2::geom_text(ggplot2::aes(label = .data$lab, colour = .data$value > 0.45), size = 3,
                       lineheight = 0.9) +
    ggplot2::scale_fill_gradient(low = "#F1ECE4", high = "#6A1B4D", limits = c(0, 1),
                                 name = "Strength of association (0 = none, 1 = perfect)",
                                 guide = ggplot2::guide_colourbar(barwidth = grid::unit(12, "lines"),
                                                                  barheight = grid::unit(0.5, "lines"),
                                                                  title.position = "top")) +
    ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey20"), guide = "none") +
    ggplot2::scale_x_discrete(drop = TRUE) +
    ggplot2::coord_equal() +
    theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1)) +
    ggplot2::labs(x = NULL, y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "V = Cramer's V (two categories), eta-squared = share of variance explained by a category, |r| = absolute correlation")
}

#' Joint distribution of two statistics
#'
#' The book's Section 3.5.3 draws two-dimensional kernel densities to see
#' where players concentrate. Here the density is drawn as soft filled
#' contours behind the players, with the marginal distributions on the
#' edges, a few highlighted players labelled, and optional groups coloured.
#'
#' @param data A data frame, one row per player (or team).
#' @param x,y Column names.
#' @param label Column with names.
#' @param highlight Names to label and emphasise.
#' @param x_labels,y_labels Axis label functions, e.g. `scales::label_percent()`.
#' @param xlab,ylab,title,subtitle,caption Labels.
#' @return A patchwork object (needs the patchwork package).
#' @export
plot_joint <- function(data, x, y, label = NULL, highlight = NULL, xlab = x, ylab = y,
                       x_labels = ggplot2::waiver(), y_labels = ggplot2::waiver(),
                       title = NULL, subtitle = NULL, caption = NULL) {
  if (!requireNamespace("patchwork", quietly = TRUE)) stop("plot_joint() needs the patchwork package")
  data <- as.data.frame(data)
  data <- data[is.finite(data[[x]]) & is.finite(data[[y]]), ]
  data$.hl <- if (!is.null(label)) data[[label]] %in% highlight else FALSE
  acc <- ggbasket_colours$highlight
  main <- ggplot2::ggplot(data, ggplot2::aes(.data[[x]], .data[[y]])) +
    ggplot2::stat_density_2d_filled(ggplot2::aes(alpha = ggplot2::after_stat(level)), bins = 7,
                                    fill = "#6A1B4D", contour_var = "ndensity", show.legend = FALSE) +
    ggplot2::scale_alpha_discrete(range = c(0, 0.45)) +
    ggplot2::geom_point(data = data[!data$.hl, ], colour = "grey35", size = 1.1, alpha = 0.55) +
    ggplot2::geom_point(data = data[data$.hl, ], fill = acc, colour = ggbasket_colours$paper,
                        shape = 21, size = 3, stroke = 0.8)
  if (!is.null(label) && any(data$.hl)) {
    main <- main + ggrepel::geom_text_repel(family = gb_family(), data = data[data$.hl, ],
                                            ggplot2::aes(label = .data[[label]]), size = 3.2,
                                            fontface = "bold", colour = acc, seed = 2,
                                            min.segment.length = 0, box.padding = 0.5)
  }
  xr <- range(data[[x]]); yr <- range(data[[y]])
  xr <- xr + c(-1, 1) * 0.05 * diff(xr); yr <- yr + c(-1, 1) * 0.05 * diff(yr)
  main <- main + ggplot2::scale_x_continuous(labels = x_labels) +
    ggplot2::scale_y_continuous(labels = y_labels) +
    ggplot2::coord_cartesian(xlim = xr, ylim = yr, expand = FALSE) +
    theme_ggbasket() + ggplot2::labs(x = xlab, y = ylab)
  dens_theme <- theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text = ggplot2::element_blank(), axis.title = ggplot2::element_blank(),
                   axis.title.x = ggplot2::element_blank(), axis.title.y = ggplot2::element_blank(),
                   plot.margin = ggplot2::margin(0, 0, 0, 0))
  top <- ggplot2::ggplot(data, ggplot2::aes(.data[[x]])) +
    ggplot2::geom_density(fill = "#6A1B4D", alpha = 0.25, colour = NA) +
    ggplot2::coord_cartesian(xlim = xr, expand = FALSE) + dens_theme
  right <- ggplot2::ggplot(data, ggplot2::aes(y = .data[[y]])) +
    ggplot2::geom_density(fill = "#6A1B4D", alpha = 0.25, colour = NA) +
    ggplot2::coord_cartesian(ylim = yr, expand = FALSE) + dens_theme
  empty <- ggplot2::ggplot() + dens_theme
  patchwork::wrap_plots(top, empty, main, right, ncol = 2,
                        widths = c(5, 1), heights = c(1, 5)) +
    patchwork::plot_annotation(title = title, subtitle = subtitle, caption = caption,
                               theme = theme_ggbasket())
}
