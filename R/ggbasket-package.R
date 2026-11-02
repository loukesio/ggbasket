#' ggbasket: learn from basketball games, NBA and EuroLeague
#'
#' Tools to read play-by-play, box-score and shot data from the NBA and the
#' EuroLeague, turn them into the measures analysts use, and draw each answer
#' as a finished, story-first ggplot2 figure.
#'
#' Conventions: column names are lower case (`pts`, `p3a`, `orb`, `tov`,
#' ...), opponent stats carry an `o_` prefix, shot coordinates are metres
#' from the hoop centre with y pointing towards half court, and
#' play-by-play follows one layout for both leagues (see [pbp]).
#'
#' Main entry points:
#' * Data: [pbp_from_espn()], [fetch_euroleague_pbp()], [add_lineups()], [box_score()]
#' * One game: [plot_game_flow()], [scoring_runs()], [win_probability()],
#'   [plot_win_probability()], [game_factors()], [plot_game_factors()], [game_summary()]
#' * A season of games: [on_off()], [lineups()], [plot_on_off()], [game_score()],
#'   [plot_consistency()], [clutch_time()], [pressure_effects()], [assist_network()]
#' * Teams: [four_factors()], [expected_wins()], [plot_ratings()], [plot_four_factors()], [plot_luck()]
#' * Players: [player_rates()], [plot_profile()], [plot_quadrant()], [plot_joint()], [plot_spread()]
#' * Shots: [plot_shot_hex()], [plot_shot_zones()], [shot_curve()], [shot_making()]
#' * Courts and style: [geom_court()], [theme_ggbasket()], [colour_text()]
#'
#' @keywords internal
#' @importFrom rlang .data %||%
"_PACKAGE"

utils::globalVariables(c("level", "w", "l", "pts", "o_pts", "margin", "d_efg", "d_tov", "d_orb", "d_ftr"))
