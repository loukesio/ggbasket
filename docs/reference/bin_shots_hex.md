# Hexagonal shot bins

Bins shots into hexagons and returns, per hexagon, attempts, share of
the group's attempts, FG%, points per shot, and the league FG% from the
same spot (`fg_league`, from `baseline`). `fg_vs_league` uses FG% shrunk
towards the league value from the same hexagon, so a 2/2 hexagon is not
shown as "+50%".

## Usage

``` r
bin_shots_hex(
  shots,
  by = NULL,
  baseline = shots,
  binwidth = 0.75,
  min_attempts = 1,
  prior_n = 20
)
```

## Arguments

- shots:

  Shot data (see Details in
  [`plot_shot_hex()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_hex.md)).

- by:

  Grouping columns (character), e.g. `"player"`.

- baseline:

  Shots used for the league reference; defaults to `shots`. Pass the
  whole league so a single player is compared with everyone.

- binwidth:

  Distance between hexagon centres, in metres.

- min_attempts:

  Drop hexagons with fewer attempts.

- prior_n:

  Pull towards the league FG% of the same hexagon, in attempts.
