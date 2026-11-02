# Regularised adjusted plus-minus (RAPM)

Each stint (see
[`stints()`](https://loukesio.github.io/ggbasket/reference/stints.md))
is one observation: the home margin per 100 possessions, explained by +1
for every home player on court, -1 for every away player, and a
home-court intercept, weighted by possessions. Ridge regression (penalty
`lambda`) shrinks players with little or collinear playing time towards
zero, which is what makes plus-minus usable. A value is points per 100
possessions added to the team's margin, against an average player.

## Usage

``` r
rapm(pbp, lambda = 2000, min_poss = 200)
```

## Arguments

- pbp:

  Play-by-play with line-ups, one league.

- lambda:

  Ridge penalty (in possessions). Larger = more shrinkage.

- min_poss:

  Players with fewer possessions on court are pooled into one
  "replacement" column.

## Value

A tibble per player: `team` (most minutes), `poss`, `rapm`; the
home-court intercept as attribute `home_adv`.
