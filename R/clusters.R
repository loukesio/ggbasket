#' How many clusters? Explained variance by k
#'
#' For each k, the share of total variance explained by the clustering
#' (between deviance / total deviance, the book's BD/TD) and its gain over
#' k - 1. Variables are standardised. k-means uses `nstart` random starts
#' (the book's `kclustering()` uses 10 runs); `"ward"` uses Ward hierarchical
#' clustering. Also returns the average silhouette width (when the `cluster`
#' package is available), a second opinion the book does not report.
#'
#' @param data A data frame.
#' @param vars Columns to cluster on.
#' @param k Values of k to try.
#' @param method `"kmeans"` or `"ward"`.
#' @param nstart Random starts for k-means.
#' @param seed Random seed.
#' @export
cluster_quality <- function(data, vars, k = 2:12, method = c("kmeans", "ward"), nstart = 25,
                            seed = 1) {
  method <- match.arg(method)
  X <- scale(as.data.frame(data)[, vars, drop = FALSE])
  set.seed(seed)
  hc <- if (method == "ward") stats::hclust(stats::dist(X), "ward.D2") else NULL
  res <- lapply(k, function(kk) {
    cl <- if (method == "kmeans") stats::kmeans(X, kk, nstart = nstart, iter.max = 100)$cluster else
      stats::cutree(hc, kk)
    sil <- if (requireNamespace("cluster", quietly = TRUE)) {
      mean(cluster::silhouette(cl, stats::dist(X))[, 3])
    } else NA_real_
    tibble::tibble(k = kk, explained = explained_variance(X, cl), silhouette = sil)
  })
  out <- dplyr::bind_rows(res)
  out$gain <- c(NA, diff(out$explained) / utils::head(out$explained, -1))
  out
}

explained_variance <- function(X, cl) {
  td <- sum(scale(X, scale = FALSE)^2)
  wd <- sum(vapply(split(as.data.frame(X), cl), function(d) sum(scale(as.matrix(d), scale = FALSE)^2), numeric(1)))
  1 - wd / td
}

#' @rdname cluster_quality
#' @param cq Output of `cluster_quality()`.
#' @param choose Optional chosen k, highlighted.
#' @export
plot_cluster_quality <- function(cq, choose = NULL) {
  cq$.ch <- cq$k %in% choose
  ggplot2::ggplot(cq, ggplot2::aes(.data$k, .data$explained)) +
    ggplot2::geom_col(ggplot2::aes(y = .data$gain, fill = .data$.ch), width = 0.55, alpha = 0.9, na.rm = TRUE) +
    ggplot2::geom_line(colour = "grey25") +
    ggplot2::geom_point(ggplot2::aes(colour = .data$.ch), size = 3) +
    ggplot2::geom_text(ggplot2::aes(label = scales::percent(.data$explained, accuracy = 1)), vjust = -1,
                       size = 3, colour = "grey25") +
    ggplot2::geom_text(ggplot2::aes(y = .data$gain, label = ifelse(is.na(.data$gain), "",
                                                                    sprintf("+%.0f%%", 100 * .data$gain))),
                       vjust = -0.5, size = 2.7, colour = "grey45") +
    ggplot2::scale_fill_manual(values = c(`TRUE` = ggbasket_colours$highlight, `FALSE` = "grey82"), guide = "none") +
    ggplot2::scale_colour_manual(values = c(`TRUE` = ggbasket_colours$highlight, `FALSE` = "grey25"), guide = "none") +
    ggplot2::scale_x_continuous(breaks = cq$k) +
    ggplot2::scale_y_continuous(labels = scales::label_percent(), limits = c(0, 1.05)) +
    theme_ggbasket(grid = "y") +
    ggplot2::labs(x = "Number of clusters", y = NULL, title = "How many groups?",
                  subtitle = "Line: share of variance explained by the clustering. Bars: relative gain from adding one more cluster")
}

#' Cluster profiles as a heatmap
#'
#' Rows are clusters (labelled with size, heterogeneity index CHI and, if
#' given, a few example members), columns are variables, cells are the
#' cluster mean in standard deviations from the overall mean. One heatmap
#' replaces the book's grid of radial plots and reads in both directions:
#' across a row (what defines this group) and down a column (who is high on
#' this stat).
#'
#' @param data A data frame.
#' @param vars Columns used (named to relabel).
#' @param cluster Cluster assignment (vector or column name).
#' @param label Optional column of member names; up to `n_examples` members
#'   closest to the cluster centre are listed.
#' @param n_examples Number of example members per cluster.
#' @param title,subtitle,caption Labels.
#' @export
#' @examples
#' p <- subset(player_seasons, league == "NBA" & minutes >= 1500)
#' v <- c(PTS = "pts", AST = "ast", REB = "drb", ORB = "orb", BLK = "blk", STL = "stl",
#'        `3PA` = "p3a", FTA = "fta", TOV = "tov")
#' X <- p[, v] / p$minutes * 36
#' p[, v] <- X
#' km <- stats::kmeans(scale(X), 6, nstart = 25)
#' plot_cluster_profiles(p, v, km$cluster, label = "player")
plot_cluster_profiles <- function(data, vars, cluster, label = NULL, n_examples = 3,
                                  title = NULL, subtitle = NULL, caption = NULL) {
  labs_v <- if (is.null(names(vars))) vars else ifelse(names(vars) == "", vars, names(vars))
  data <- as.data.frame(data)
  cl <- if (is.character(cluster) && length(cluster) == 1) data[[cluster]] else cluster
  Z <- scale(data[, unname(vars), drop = FALSE])
  colnames(Z) <- labs_v
  prof <- stats::aggregate(as.data.frame(Z), list(cluster = cl), mean)
  chi <- tapply(seq_len(nrow(Z)), cl, function(i) mean(apply(Z[i, , drop = FALSE], 2, stats::var)))
  nn <- table(cl)
  ex <- if (!is.null(label)) tapply(seq_len(nrow(Z)), cl, function(i) {
    ctr <- colMeans(Z[i, , drop = FALSE])
    d <- rowSums(sweep(Z[i, , drop = FALSE], 2, ctr)^2)
    paste(as.character(data[[label]][i][order(d)][seq_len(min(n_examples, length(i)))]), collapse = ", ")
  }) else NULL
  rowlab <- sprintf("Cluster %s  (n = %d, CHI %.2f)%s", names(nn), as.integer(nn),
                    chi[names(nn)], if (is.null(ex)) "" else paste0("\n", ex[names(nn)]))
  long <- tidyr::pivot_longer(prof, -"cluster", names_to = "var", values_to = "z")
  long$row <- factor(rowlab[match(as.character(long$cluster), names(nn))], levels = rev(rowlab))
  # order columns by clustering the variables
  o <- stats::hclust(stats::dist(t(as.matrix(prof[, -1]))))$order
  long$var <- factor(long$var, levels = labs_v[o])
  ggplot2::ggplot(long, ggplot2::aes(.data$var, .data$row)) +
    ggplot2::geom_tile(ggplot2::aes(fill = .data$z), colour = ggbasket_colours$paper, linewidth = 1.2) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.1f", .data$z), colour = abs(.data$z) > 1.2), size = 3) +
    scale_fill_vs_average(limits = c(-2, 2), name = "SD from average",
                          guide = ggplot2::guide_colourbar(barwidth = grid::unit(10, "lines"),
                                                           barheight = grid::unit(0.5, "lines"))) +
    ggplot2::scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey20"), guide = "none") +
    ggplot2::scale_x_discrete(position = "top") +
    theme_ggbasket(grid = "none") +
    ggplot2::theme(axis.text.y = ggplot2::element_text(hjust = 0, lineheight = 0.95, colour = "grey20"),
                   axis.text.x = ggplot2::element_text(face = "bold", colour = "grey20")) +
    ggplot2::labs(x = NULL, y = NULL, title = title, caption = caption,
                  subtitle = subtitle %||% "Cluster means in standard deviations; CHI = within-cluster heterogeneity (lower = tighter); names = most typical members")
}
