# Builds full-season play-by-play (2024/25, regular season + playoffs, NBA and EuroLeague) in the
# ggbasket layout, the bundled example `pbp_games`, and the default win-probability parameters.
# Run from the package root: Rscript data-raw/make_pbp.R
# Output goes to $GGBASKET_PBP (default ../00_data/pbp_2024); raw EuroLeague JSON is cached there.
suppressMessages({ devtools::load_all(quiet = TRUE); library(dplyr) })
P <- Sys.getenv("GGBASKET_PBP", "../00_data/pbp_2024")
dir.create(file.path(P, "el_json"), recursive = TRUE, showWarnings = FALSE)

# NBA: ESPN play-by-play via hoopR's release files (hoopR seasons are end years)
nba_file <- file.path(P, "nba_pbp_2024.parquet")
if (!file.exists(nba_file)) {
  raw <- hoopR::load_nba_pbp(seasons = 2025)
  raw <- raw[raw$season_type %in% c(2, 3, 5), ]
  nba <- bind_rows(lapply(split(raw, raw$game_id), pbp_from_espn))
  # drop the All-Star games; the NBA Cup final does not count in the regular-season record
  teams <- unique(team_seasons$team[team_seasons$league == "NBA"])
  nba <- filter(nba, hometeam %in% teams, awayteam %in% teams)
  nba$phase[nba$date == as.Date("2024-12-17") & nba$phase == "regular"] <- "cup final"
  arrow::write_parquet(nba, nba_file)
}
nba <- arrow::read_parquet(nba_file)

# EuroLeague: official live API, one PlayByPlay and one Points (shot locations) file per game
el_file <- file.path(P, "el_pbp_2024.parquet")
if (!file.exists(el_file)) {
  games <- jsonlite::fromJSON("https://api-live.euroleague.net/v2/competitions/E/seasons/E2024/games")$data
  phase <- setNames(c(RS = "regular", PI = "play-in", PO = "playoffs", FF = "final four")[games$phaseType$code],
                    games$gameCode)
  cached <- function(kind, code) {
    f <- file.path(P, "el_json", sprintf("%s_%d.json", kind, code))
    if (!file.exists(f) || file.size(f) == 0) {
      url <- sprintf("https://live.euroleague.net/api/%s?gamecode=%d&seasoncode=E2024", kind, code)
      for (i in 1:5) if (!inherits(try(download.file(url, f, quiet = TRUE)), "try-error")) break else Sys.sleep(10 * i)
      Sys.sleep(1.5)
    }
    jsonlite::fromJSON(f)
  }
  el <- bind_rows(lapply(games$gameCode[games$played], function(code) {
    d <- pbp_from_euroleague(cached("PlayByPlay", code), cached("Points", code), season = 2024, game_code = code)
    d$phase <- phase[[as.character(code)]]
    d$date <- as.Date(substr(games$date[games$gameCode == code], 1, 10))
    d
  }))
  arrow::write_parquet(el, el_file)
}
el <- arrow::read_parquet(el_file)

wp <- fit_win_probability(bind_rows(filter(nba, phase == "regular"), filter(el, phase == "regular")))
print(wp)  # copy into wp_default in R/games.R

# bundled example: the 2025 NBA Finals Game 7 and the 2025 EuroLeague final
pbp_games <- bind_rows(filter(nba, game_id == "401766128"), filter(el, game_id == "E2024_330"))
usethis::use_data(pbp_games, overwrite = TRUE, compress = "xz")
