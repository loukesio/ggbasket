# Line-ups: which units work

Line-ups: which units work

## Usage

``` r
lineups(pbp, team = NULL, min_minutes = 20)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout with line-ups (see
  [`add_lineups()`](https://loukesio.github.io/ggbasket-site/reference/add_lineups.md)).

- team:

  Teams to keep (default: all).

- min_minutes:

  Line-ups with fewer minutes together are dropped.

## Value

A tibble per team and five-player unit: `min`, `pts_for`, `pts_against`,
`ortg`, `drtg`, `net`, `poss`.
