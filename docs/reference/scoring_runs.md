# Scoring runs

Stretches in which one team scores at least `min_points` while the other
scores at most `allow` points.

## Usage

``` r
scoring_runs(pbp, min_points = 8, allow = 0)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)), one or
  more games.

- min_points:

  Smallest run reported.

- allow:

  Points the other team may score during a run (0 = unanswered).

## Value

A tibble: `game_id`, `team`, `points`, `against`, `start`, `end`
(seconds of game time), `margin_before`, `margin_after` (home minus
away), `label` (e.g. `"14-0 OKC"`).
