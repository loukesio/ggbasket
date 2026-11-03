# Play-by-play in the ggbasket layout

Every game-level function in ggbasket reads one play-by-play layout: one
row per event, in game order, with

## Usage

``` r
pbp_from_espn(x, league = "NBA", period_length = 12, ot_length = 5)

pbp_from_euroleague(
  pbp_json,
  points_json = NULL,
  season,
  game_code,
  league = "EuroLeague",
  period_length = 10,
  ot_length = 5
)

fetch_euroleague_pbp(season, games = NULL, shots = TRUE, pause = 1)
```

## Arguments

- x:

  ESPN play-by-play, one or more games (a data frame as returned by
  [`hoopR::load_nba_pbp()`](https://hoopR.sportsdataverse.org/reference/load_nba_pbp.html)
  or
  [`hoopR::espn_nba_pbp()`](https://hoopR.sportsdataverse.org/reference/espn_mbb_game_all.html)).

- league:

  League label.

- period_length, ot_length:

  Minutes in a regular period and in overtime.

- pbp_json, points_json:

  One game's responses from the EuroLeague live API: `PlayByPlay` and
  (optional, for shot locations) `Points`, parsed by
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).

- season:

  Season start year (2024 = 2024/25).

- game_code:

  The game's code within the season.

- games:

  Game codes to download (default: every played game of the season).

- shots:

  Also download shot locations?

- pause:

  Seconds to wait between requests (the API rate-limits).

## Value

A tibble in the ggbasket play-by-play layout.

## Details

- `league`, `season`, `game_id`, `date`, `hometeam`, `awayteam` (codes)
  and `hometeam_name`, `awayteam_name` (full names);

- `period`, `periodTime` (seconds elapsed in the period), `totalTime`
  (seconds elapsed in the game), `playlength` (seconds since the
  previous event);

- `team` (team of `player`), `oppTeam`, `event_type` (`"shot"`,
  `"miss"`, `"free throw"`, `"rebound"`, `"turnover"`, `"foul"`,
  `"sub"`, `"timeout"`, `"jump ball"`, `"start of period"`,
  `"end of period"`, `"violation"`, `"unknown"`), `rebound`
  (`"offensive"`/`"defensive"`), `result` (`"made"`/`"missed"`),
  `ShotType` (`"2P"`, `"3P"`, `"FT"`), `points` (scored on the event);

- `player`, `assist`, `steal`, `block` (the last two are players of
  `oppTeam`), `entered`, `left`;

- `home_score`, `away_score` after the event;

- `x`, `y` shot location in metres from the hoop centre, and
  `original_x`, `original_y` in tenths of feet;

- `a1`-`a5` (away) and `h1`-`h5` (home): the players on court;

- `description`.

This is a superset of BasketballAnalyzeR's `PbP`, so data prepared with
`PbPmanipulation()` also works. `pbp_from_espn()` converts NBA (and
WNBA, college) play-by-play from ESPN as served by
[`hoopR::load_nba_pbp()`](https://hoopR.sportsdataverse.org/reference/load_nba_pbp.html);
`pbp_from_euroleague()` converts the EuroLeague's official live API,
which `fetch_euroleague_pbp()` downloads.

Who is on court is not part of either feed.
[`add_lineups()`](https://loukesio.github.io/ggbasket-site/reference/add_lineups.md)
rebuilds it from substitutions: a player who acts in a period before
being subbed in started that period. A player who plays a whole period
without touching the ball or being substituted is carried over from the
previous period.

## Examples

``` r
head(pbp_games[, c("game_id", "period", "periodTime", "team", "event_type", "player", "points")])
#> # A tibble: 6 × 7
#>   game_id   period periodTime team  event_type player          points
#>   <chr>      <int>      <dbl> <chr> <chr>      <chr>            <int>
#> 1 401766128      1          0 IND   jump ball  Myles Turner        NA
#> 2 401766128      1         16 IND   shot       Andrew Nembhard      2
#> 3 401766128      1         31 OKC   miss       Jalen Williams       0
#> 4 401766128      1         35 IND   rebound    Aaron Nesmith       NA
#> 5 401766128      1         43 OKC   foul       Luguentz Dort       NA
#> 6 401766128      1         49 IND   miss       Myles Turner         0
```
