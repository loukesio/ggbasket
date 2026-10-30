#' Team season totals, NBA and EuroLeague 2024/25
#'
#' Regular-season totals for every NBA (30) and EuroLeague (18) team, with the
#' opponents' totals prefixed by `o_`. Ready for [four_factors()].
#'
#' @format A tibble with one row per team: `league`, `season` (starting
#'   year), `team`, `games`, `w`, `l`, `min` (team minutes = 5 x game
#'   minutes), counting stats `pts p2m p2a p3m p3a ftm fta orb drb ast tov stl
#'   blk pf` and opponent stats `o_pts o_p2m ... o_pf`.
#' @source NBA: ESPN box scores via hoopR. EuroLeague: official
#'   EuroLeague API. Built by `data-raw/make_data.R`.
"team_seasons"

#' Player season totals, NBA and EuroLeague 2024/25
#'
#' @format A tibble with one row per player and team: `league`, `season`,
#'   `player`, `team`, `position` (G/F/C), `games`, `minutes`, `poss`
#'   (possessions on court), counting stats, and field-goal attempts by zone
#'   (`rim`, `short_mid`, `long_mid`, `corner3`, `above3`). Makes are not
#'   included.
#' @source As [team_seasons].
"player_seasons"

#' Every field-goal attempt of the 2024/25 regular season, NBA and EuroLeague
#'
#' @format A tibble: `league`, `team`, `player`, `x`, `y` (metres from the
#'   hoop centre, y towards half court), `value` (2/3), `made`. Eight NBA stars
#'   carry full names (Stephen Curry, Nikola Jokic, Shai Gilgeous-Alexander,
#'   Giannis Antetokounmpo, Victor Wembanyama, Anthony Edwards, Luka Doncic,
#'   Jayson Tatum); other NBA players are "Surname (TEAM)". EuroLeague names
#'   are full names.
#' @source NBA Stats shot chart detail (via hoopR) and the EuroLeague
#'   `Points` API. Built by `data-raw/make_data.R`.
"shots_2024"
