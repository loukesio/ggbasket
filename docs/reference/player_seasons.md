# Player season totals, NBA and EuroLeague 2024/25

Player season totals, NBA and EuroLeague 2024/25

## Usage

``` r
player_seasons
```

## Format

A tibble with one row per player and team: `league`, `season`, `player`,
`team`, `position` (G/F/C), `games`, `minutes`, `poss` (possessions on
court), counting stats, and field-goal attempts by zone (`rim`,
`short_mid`, `long_mid`, `corner3`, `above3`). Makes are not included.

## Source

As
[team_seasons](https://loukesio.github.io/ggbasket/reference/team_seasons.md).
