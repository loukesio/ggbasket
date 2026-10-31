#' Correlation heatmap
#'
#' Lower triangle only, variables ordered by hierarchical clustering so related
#' stats sit together, coefficients printed in each cell, and correlations
#' that are not significant (after Holm correction across all pairs) faded
#' rather than crossed out.
#'
#' @param data A data frame.
#' @param vars Columns (named to relabel).
#' @param method `"pearson"` or `"spearman"`.
#' @param alpha Significance level.
#' @param order `"cluster"` or `"asis"`.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' p <- subset(player_seasons, minutes >= 1000)
#' p <- transform(p, PTS = pts / minutes, AST = ast / minutes, TOV = tov / minutes,
#'                REB = (orb + drb) / minutes, BLK = blk / minutes, STL = stl / minutes,
#'                `3PA` = p3a / minutes, check.names = FALSE)
#' plot_corr_matrix(p, c("PTS", "AST", "TOV", "REB", "BLK", "STL", "3PA"))
plot_corr_matrix <- function(data, vars, method = c("pearson", "spearman"), alpha = 0.05,
                             order = c("cluster", "asis"), title = NULL, subtitle = NULL,
                             caption = NULL) {
  method <- match.arg(method); order <- match.arg(order)
  labs_v <- if (is.null(names(vars))) vars else ifelse(names(vars) == "", vars, names(vars))
  X <- as.data.frame(data)[, unname(vars), drop = FALSE]
  names(X) <- labs_v
  X <- X[stats::complete.cases(X), ]
  R <- stats::cor(X, method = method)
  if (order == "cluster") {
    o <- stats::hclust(stats::as.dist(1 - abs(R)), method = "average")$order
    R <- R[o, o]
  }
  n <- nrow(X)
  tstat <- R * sqrt((n - 2) / pmax(1 - R^2, 1e-12))
  pv <- 2 * stats::pt(-abs(tstat), df = n - 2)
  long <- expand.grid(a = rownames(R), b = colnames(R), stringsAsFactors = FALSE)
  long$r <- as.vector(R)
  long$p <- as.vector(pv)
  long$ia <- match(long$a, rownames(R)); long$ib <- match(long$b, colnames(R))
  long <- long[long$ia > long$ib, ]
  long$p_adj <- stats::p.adjust(long$p, "holm")
  long$sig <- long$p_adj < alpha
  long$a <- factor(long$a, levels = rev(rownames(R)))
  long$b <- factor(long$b, levels = colnames(R))
  ggplot2::ggplot(long, ggplot2::aes(.data$b, .data$a)) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$r, alpha = .data$sig), colour = ggbasket_colours$paper, linewidth = 1) +
    ggplot2::geom_text(ggplot2::aes(label = sub("^(-?)0\\.", "\\1.", sprintf("%.2f", .data$r)),
                                    colour = abs(.data$r) > 0.6), size = 3.3) +
    scale_fill_vs_average(limits = c(-1, 1), name = sprintf("%s correlation", tools::toTitleCase(method)),
                          guide = ggplot2::guide_colourbar(barwidth = grid::unit(10, "lines"),
                                                           barheight = grid::unit(0.5, "lines"),
                                                           title.position = "top")) +
    ggplot2::scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.25), guide = "none") +
    ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey20"), guide = "none") +
    ggplot2::coord_equal() +
    theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1)) +
    ggplot2::labs(x = NULL, y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% sprintf("n = %d. Faded cells: not significant at %.0f%% after Holm correction", n, 100 * alpha))
}

#' Fit a line and name the over- and under-performers
#'
#' Scatter with a fitted relationship (`"lm"`, `"loess"` or a GAM) and its
#' confidence band. Points are coloured by their residual, and the cases
#' farthest above and below the fit are labelled, which is usually the story
#' ("for his assist load, he barely turns it over").
#'
#' @param data A data frame.
#' @param x,y Columns.
#' @param label Column with names.
#' @param method `"lm"`, `"loess"` or `"gam"`.
#' @param n_label Number of cases to label on each side of the fit.
#' @param highlight Extra names to label.
#' @param above_is_good Is being above the line good (affects colours)?
#' @param xlab,ylab,title,subtitle,caption Labels.
#' @return A ggplot; the fitted model is in `attr(p, "fit")`.
#' @export
plot_fit <- function(data, x, y, label, method = c("lm", "loess", "gam"), n_label = 4,
                     highlight = NULL, above_is_good = TRUE, xlab = x, ylab = y,
                     title = NULL, subtitle = NULL, caption = NULL) {
  method <- match.arg(method)
  data <- as.data.frame(data)
  data <- data[is.finite(data[[x]]) & is.finite(data[[y]]), ]
  f <- stats::as.formula(paste0("`", y, "` ~ ", if (method == "gam") paste0("s(`", x, "`)") else paste0("`", x, "`")))
  fit <- switch(method,
                lm = stats::lm(f, data),
                loess = stats::loess(f, data),
                gam = mgcv::gam(f, data = data))
  grid <- data.frame(seq(min(data[[x]]), max(data[[x]]), length.out = 200))
  names(grid) <- x
  pr <- stats::predict(fit, grid, se = TRUE)
  grid$fit <- as.numeric(pr$fit); grid$se <- as.numeric(pr$se.fit)
  data$.res <- data[[y]] - as.numeric(stats::predict(fit, data))
  data$.lab <- as.character(data[[label]])
  ord <- order(data$.res)
  show <- unique(c(data$.lab[utils::head(ord, n_label)], data$.lab[utils::tail(ord, n_label)], highlight))
  data$.show <- data$.lab %in% show
  r2 <- 1 - sum(data$.res^2) / sum((data[[y]] - mean(data[[y]]))^2)
  lim <- stats::quantile(abs(data$.res), 0.98)
  p <- ggplot2::ggplot(data, ggplot2::aes(.data[[x]], .data[[y]])) +
    ggplot2::geom_ribbon(data = grid, ggplot2::aes(x = .data[[x]], ymin = .data$fit - 1.96 * .data$se,
                                                   ymax = .data$fit + 1.96 * .data$se),
                         inherit.aes = FALSE, fill = "grey88") +
    ggplot2::geom_line(data = grid, ggplot2::aes(.data[[x]], .data$fit), inherit.aes = FALSE,
                       colour = "grey30", linewidth = 0.8) +
    ggplot2::geom_point(ggplot2::aes(colour = .data$.res), size = 2.2, alpha = 0.85) +
    ggrepel::geom_text_repel(family = gb_family(), data = data[data$.show, ], ggplot2::aes(label = .data$.lab),
                             size = 3.1, min.segment.length = 0, box.padding = 0.4, seed = 8) +
    scale_colour_vs_average(limits = c(-lim, lim), reverse = !above_is_good, guide = "none") +
    theme_ggbasket() +
    ggplot2::labs(x = xlab, y = ylab, title = title, caption = caption,
                  subtitle = subtitle %||% sprintf("%s fit, R\u00b2 = %.0f%%. Colour = distance from the fit (red = better than expected, blue = worse)",
                                                   c(lm = "Linear", loess = "LOESS", gam = "GAM")[method], 100 * r2))
  attr(p, "fit") <- fit
  p
}

#' Similarity map (MDS or PCA) with variable arrows
#'
#' Places subjects so that similar statistical profiles sit close together.
#' Instead of the book's four separate "level plots" for interpreting the map,
#' each variable is drawn as an arrow pointing in the direction in which it
#' increases (its correlation with the two map axes), so the whole map can be
#' read at once.
#'
#' @param data A data frame.
#' @param vars Columns (named to relabel); standardised internally.
#' @param label Column with names.
#' @param method `"mds"` (Kruskal non-metric, needs MASS) or `"pca"`.
#' @param colour Optional column to colour by (e.g. a cluster or position).
#' @param highlight Names to emphasise.
#' @param n_label Also label the most outlying `n_label` subjects.
#' @param title,subtitle,caption Labels.
#' @export
plot_similarity_map <- function(data, vars, label, method = c("pca", "mds"), colour = NULL,
                                highlight = NULL, n_label = 12, title = NULL, subtitle = NULL,
                                caption = NULL) {
  method <- match.arg(method)
  labs_v <- if (is.null(names(vars))) vars else ifelse(names(vars) == "", vars, names(vars))
  data <- as.data.frame(data)
  X <- scale(data[, unname(vars), drop = FALSE])
  ok <- stats::complete.cases(X)
  X <- X[ok, , drop = FALSE]; data <- data[ok, ]
  if (method == "pca") {
    pc <- stats::prcomp(X)
    coords <- pc$x[, 1:2]
    ve <- pc$sdev^2 / sum(pc$sdev^2)
    fit_note <- sprintf("PCA: the two axes keep %.0f%% of the variation", 100 * sum(ve[1:2]))
  } else {
    if (!requireNamespace("MASS", quietly = TRUE)) rlang::abort("method = 'mds' needs the MASS package.")
    d <- stats::dist(X)
    d[d == 0] <- 1e-6
    m <- MASS::isoMDS(d, k = 2, trace = FALSE)
    coords <- m$points
    fit_note <- sprintf("Non-metric MDS, stress %.1f%% (below 20%% is acceptable)", m$stress)
  }
  data$m1 <- coords[, 1]; data$m2 <- coords[, 2]
  arrows <- data.frame(var = labs_v, a1 = stats::cor(X, data$m1)[, 1], a2 = stats::cor(X, data$m2)[, 1])
  sc <- 0.9 * max(abs(c(data$m1, data$m2)))
  arrows$x <- arrows$a1 * sc; arrows$y <- arrows$a2 * sc
  data$.lab <- as.character(data[[label]])
  far <- data$.lab[order(-(data$m1^2 + data$m2^2))][seq_len(min(n_label, nrow(data)))]
  data$.show <- data$.lab %in% c(far, highlight)
  data$.hl <- data$.lab %in% highlight
  pt_aes <- ggplot2::aes(.data$m1, .data$m2)
  if (!is.null(colour)) pt_aes$colour <- rlang::quo(.data[[colour]])
  p <- ggplot2::ggplot(data, ggplot2::aes(.data$m1, .data$m2)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey90") +
    ggplot2::geom_vline(xintercept = 0, colour = "grey90") +
    ggplot2::geom_segment(data = arrows, ggplot2::aes(x = 0, y = 0, xend = .data$x, yend = .data$y),
                          inherit.aes = FALSE, colour = "grey55",
                          arrow = grid::arrow(length = grid::unit(0.18, "cm"), type = "closed")) +
    ggrepel::geom_label_repel(family = gb_family(), data = arrows, ggplot2::aes(x = .data$x, y = .data$y, label = .data$var),
                              inherit.aes = FALSE, size = 3, colour = "grey25", label.size = 0,
                              fill = scales::alpha(ggbasket_colours$paper, 0.85), fontface = "bold", seed = 10,
                              min.segment.length = Inf, point.padding = 0.2)
  p <- p + if (is.null(colour)) ggplot2::geom_point(pt_aes, colour = ifelse(data$.hl, ggbasket_colours$highlight, "grey50"),
                                                    alpha = 0.7, size = 2) else
    ggplot2::geom_point(pt_aes, alpha = 0.75, size = 2)
  if (!is.null(colour) && !is.numeric(data[[colour]])) {
    p <- p + ggplot2::scale_colour_manual(values = categorical_palette(data[[colour]]), name = NULL)
  }
  p + ggrepel::geom_text_repel(family = gb_family(), data = data[data$.show, ], ggplot2::aes(label = .data$.lab), size = 3,
                               fontface = ifelse(data$.hl[data$.show], "bold", "plain"),
                               max.overlaps = 40, seed = 9) +
    ggplot2::coord_equal() +
    theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text = ggplot2::element_blank()) +
    ggplot2::labs(x = NULL, y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% paste0(fit_note, ". Arrows point to where each stat increases"))
}
