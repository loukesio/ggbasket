# The score, event by event

The score, event by event

## Usage

``` r
game_flow(pbp)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket-site/reference/pbp.md)), one
  or more games.

## Value

A tibble with one row per scoring event (plus each game's start and
end): `game_id`, `hometeam`, `awayteam`, `period`, `totalTime`, `team`,
`points`, `home_score`, `away_score` and `margin` (home minus away).
