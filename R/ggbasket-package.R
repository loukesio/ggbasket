#' ggbasket: story-driven ggplot2 graphics for basketball data
#'
#' Metrics and redesigned graphics for the analyses in Zuccolotto & Manisera,
#' *Basketball Data Science* (CRC, 2020), for NBA and FIBA/EuroLeague data.
#'
#' Conventions: column names are lower case (`pts`, `p3a`, `orb`, `tov`,
#' ...), opponent stats carry an `o_` prefix, shot coordinates are metres
#' from the hoop centre with y pointing towards half court.
#'
#' Main entry points:
#' * Teams: [four_factors()], [plot_ratings()], [plot_four_factors()], [plot_lorenz()]
#' * Players: [plot_profile()], [plot_quadrant()], [plot_spread()], [plot_ranked()]
#' * Shots: [plot_shot_hex()], [plot_shot_zones()], [plot_shot_density()],
#'   [shot_curve()], [plot_shot_curve()], [shot_making()], [plot_shot_making()]
#' * Patterns: [plot_corr_matrix()], [plot_fit()], [plot_similarity_map()],
#'   [cluster_quality()], [plot_cluster_profiles()]
#' * Passing: [assist_network()], [plot_assist_network()], [plot_assist_matrix()]
#' * Courts: [geom_court()], [shot_zone()], [court_spec()]
#'
#' @keywords internal
#' @importFrom rlang .data
"_PACKAGE"
