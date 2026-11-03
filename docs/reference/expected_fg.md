# Expected make probability of every shot

A league-wide model of how likely a shot from a given spot is to go in.
With `mgcv` installed this is a logistic GAM with a smooth of distance
and angle per league and shot value; otherwise a binned average (0.5 m
distance bands by zone). Extra context columns (shot clock, score
margin) can be added as `extra` smooth terms, which is the regression
version of a classification-tree "high-pressure" model (see
[`pressure_effects()`](https://loukesio.github.io/ggbasket-site/reference/pressure_effects.md)).

## Usage

``` r
expected_fg(shots, extra = NULL, method = c("gam", "bins"))
```

## Arguments

- shots:

  Shots with `x`, `y`, `made` (and optionally `value`, `league`).

- extra:

  Optional character vector of extra numeric columns to adjust for (each
  enters as a smooth).

- method:

  `"gam"` or `"bins"`.

## Value

`shots` with a column `xfg`.
