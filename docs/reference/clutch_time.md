# Keep only clutch time

Events in the last `minutes` of the fourth quarter or overtime with the
score within `margin` points (the NBA's definition: last 5 minutes,
within 5). Feed the result to
[`box_score()`](https://loukesio.github.io/ggbasket-site/reference/box_score.md)
or
[`on_off()`](https://loukesio.github.io/ggbasket-site/reference/on_off.md).

## Usage

``` r
clutch_time(pbp, minutes = 5, margin = 5)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket-site/reference/pbp.md)), one
  or more games.

- minutes, margin:

  Window and score difference.
