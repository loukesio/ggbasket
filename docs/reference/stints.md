# Stints: stretches with the same ten players on court

Stints: stretches with the same ten players on court

## Usage

``` r
stints(pbp)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout with line-ups (see
  [`add_lineups()`](https://loukesio.github.io/ggbasket/reference/add_lineups.md)).

## Value

A tibble per stint: `game_id`, `hometeam`, `awayteam`, `home_lineup`,
`away_lineup` (players sorted and joined by `" | "`), `sec`, `home_pts`,
`away_pts`, `home_poss`, `away_poss`.
