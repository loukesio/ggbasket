# How much each pressure situation changes the chance of scoring

One logistic regression (instead of a classification tree) that holds
shot location fixed: the location-based expected FG% from
[`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md)
enters as an offset, so each coefficient is the effect of the situation
*on top of* where the shot was taken, adjusted for the other situations.
Effects are reported as average changes in make probability (percentage
points) against each situation's reference level, with 90% intervals.

## Usage

``` r
pressure_effects(
  shots,
  situations = c("shot_clock", "period_end", "score_diff", "team_misses", "prev_miss"),
  level = 0.9
)
```

## Arguments

- shots:

  Output of
  [`pressure_situations()`](https://loukesio.github.io/ggbasket-site/reference/pressure_situations.md),
  with `xfg` from
  [`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md)
  (computed if absent).

- situations:

  Situation columns to include.

- level:

  Interval width.

## Value

A tibble: `situation`, `level`, `reference`, `effect`, `lower`, `upper`,
`n`.
