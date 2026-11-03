# Download one game's play-by-play

`fetch_game()` gets a single game in the ggbasket layout, from the
EuroLeague live API (`league = "EuroLeague"`, with `season` and the game
code) or from ESPN via hoopR (`league = "NBA"`, with ESPN's game id).
`fetch_nba_pbp()` is the NBA download on its own.

## Usage

``` r
fetch_game(game, league = c("EuroLeague", "NBA"), season = NULL)

fetch_nba_pbp(game_ids)
```

## Arguments

- game:

  EuroLeague game code (e.g. `90`) or ESPN game id (e.g. `"401766128"`).

- league:

  `"EuroLeague"` or `"NBA"`.

- season:

  EuroLeague season start year (e.g. `2026` for 2026/27).

- game_ids:

  One or more ESPN NBA game ids.

## Value

A tibble in the ggbasket play-by-play layout (see
[pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)).
