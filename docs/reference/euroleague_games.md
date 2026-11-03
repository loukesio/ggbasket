# Find games to report on

`euroleague_games()` lists a EuroLeague season's games with the game
code that
[`fetch_game()`](https://loukesio.github.io/ggbasket/reference/fetch_game.md)
and
[`match_report()`](https://loukesio.github.io/ggbasket/reference/match_report.md)
need. `nba_games()` lists the NBA games on a date with ESPN's game id.

## Usage

``` r
euroleague_games(season, team = NULL, played_only = TRUE)

nba_games(date)
```

## Arguments

- season:

  EuroLeague season start year (2026 = 2026/27).

- team:

  Optional team code (e.g. `"OLY"`) to keep only its games.

- played_only:

  Keep only games already played.

- date:

  A date (`"2025-06-22"` or a `Date`).

## Value

A tibble: `game` (code or id), `date`, `round` (EuroLeague), `home`,
`away`, `home_name`, `away_name`, `home_score`, `away_score`.

## Examples

``` r
if (FALSE) { # \dontrun{
tail(euroleague_games(2026, team = "OLY"))   # Olympiacos's latest games
nba_games("2025-06-22")                       # NBA Finals Game 7
} # }
```
