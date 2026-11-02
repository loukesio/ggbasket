# Two finals, play by play

Every event of the 2025 NBA Finals Game 7 (Oklahoma City 103, Indiana
91) and the 2025 EuroLeague final, in the ggbasket play-by-play layout
(see [pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)), with
the players on court.

## Usage

``` r
pbp_games
```

## Format

A tibble, one row per event; columns as described in
[pbp](https://loukesio.github.io/ggbasket/reference/pbp.md).

## Source

NBA: ESPN play-by-play via hoopR. EuroLeague: official live API
(`PlayByPlay` and `Points`). Built by `data-raw/make_pbp.R`.
