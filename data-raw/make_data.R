# Builds the example datasets from the project's processed tables (2024/25 regular season).
# Run from the package root: Rscript data-raw/make_data.R
suppressMessages(library(dplyr))
P <- Sys.getenv("NBA_EL_DATA", "/Volumes/Untitled/NBA_VS_Euroleague_data")
P <- file.path(P, "processed")
nice_player <- function(x) {
  el <- grepl(",", x)
  x[el] <- tools::toTitleCase(tolower(sub("^(.*), (.*)$", "\\2 \\1", x[el])))
  x
}

tg <- arrow::read_parquet(file.path(P, "team_games.parquet")) |>
  filter(season == 2024, phase == "regular")
team_seasons <- tg |>
  group_by(league, season, team) |>
  summarise(games = n(), w = sum(win), l = sum(!win), min = 5 * sum(game_min),
            across(c(pts, p2m, p2a, p3m, p3a, ftm, fta, orb, drb, ast, tov, stl, blk, pf), sum),
            o_pts = sum(opp_pts),
            across(c(o_p2m, o_p2a, o_p3m, o_p3a, o_ftm, o_fta, o_orb, o_drb, o_tov, o_pf), sum),
            .groups = "drop") |>
  as_tibble()

ps <- arrow::read_parquet(file.path(P, "player_seasons.parquet")) |>
  filter(season == 2024, minutes > 0)
player_seasons <- ps |>
  transmute(league, season, player = nice_player(player), team, position, games, minutes, poss,
            pts, p2a, p3a, fta, ast, tov, orb, drb, stl, blk, pf,
            rim = n_rim, short_mid = n_short_mid, long_mid = n_long_mid,
            corner3 = n_corner3, above3 = n_above3) |>
  as_tibble()

sh <- arrow::read_parquet(file.path(P, "shots.parquet")) |>
  filter(season == 2024, phase == "regular")
featured_nba <- c("201939" = "Stephen Curry", "203999" = "Nikola Jokic", "1628983" = "Shai Gilgeous-Alexander",
                  "203507" = "Giannis Antetokounmpo", "1641705" = "Victor Wembanyama",
                  "1630162" = "Anthony Edwards", "1629029" = "Luka Doncic", "1628369" = "Jayson Tatum")
shots_2024 <- sh |>
  mutate(player = ifelse(league == "NBA",
                         ifelse(player_id %in% names(featured_nba), featured_nba[player_id],
                                paste0(player, " (", team, ")")),
                         nice_player(player))) |>
  transmute(league, team, player, x = round(x, 2), y = round(y, 2), value = as.integer(value), made) |>
  as_tibble()
print(count(shots_2024, league)); print(count(filter(shots_2024, player %in% featured_nba), player))
usethis::use_data(team_seasons, player_seasons, shots_2024, overwrite = TRUE, compress = "xz")
