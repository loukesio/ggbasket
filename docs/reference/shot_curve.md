# Scoring probability and expected points along one variable

Nadaraya-Watson Gaussian kernel smoothing, with two additions that make
the curve readable: a bootstrap confidence band, so a wiggle can be told
apart from noise, and the density of attempts, so the curve can be drawn
thick where shots actually happen and thin where it rests on a handful
of attempts.

## Usage

``` r
shot_curve(
  shots,
  x,
  by = NULL,
  outcome = c("prob", "points"),
  bw = NULL,
  n_boot = 200,
  level = 0.9,
  grid = NULL,
  min_density = 0.02,
  split_value = FALSE
)
```

## Arguments

- shots:

  A data frame with `made` and the variable `x`; for expected points
  also `value` (or `pts`).

- x:

  Name of the variable (e.g. `"dist"`, `"playlength"`, `"periodTime"`).
  `"dist"` is computed from `x`, `y` if absent.

- by:

  Optional grouping column (e.g. `"player"`).

- outcome:

  `"prob"` (scoring probability) or `"points"` (expected points per
  shot).

- bw:

  Kernel bandwidth in units of `x`. Default: Silverman's rule on the
  pooled data.

- n_boot:

  Bootstrap resamples for the band (0 to skip).

- level:

  Width of the band.

- grid:

  Points at which to evaluate; default 100 points over the central 99%
  of `x`.

- min_density:

  Grid points where a group's attempt density falls below this fraction
  of its peak are dropped, so curves are not extrapolated into places a
  player never shoots from.

- split_value:

  Smooth 2-point and 3-point attempts separately. A kernel smoother run
  across the 3-point line blurs the jump in value into a fake ramp;
  splitting keeps the discontinuity (use with distance).

## Value

A tibble with `x`, `estimate`, `lower`, `upper`, `density` and the
grouping column.

## Examples

``` r
sc <- shot_curve(subset(shots_2024, league == "NBA"), "dist", outcome = "points", n_boot = 0)
head(sc)
#> # A tibble: 6 × 6
#>       x estimate lower upper density attempts
#>   <dbl>    <dbl> <dbl> <dbl>   <dbl>    <int>
#> 1 0         1.43    NA    NA   0.533   219527
#> 2 0.101     1.41    NA    NA   0.612   219527
#> 3 0.201     1.40    NA    NA   0.684   219527
#> 4 0.302     1.38    NA    NA   0.747   219527
#> 5 0.402     1.36    NA    NA   0.796   219527
#> 6 0.503     1.33    NA    NA   0.830   219527
```
