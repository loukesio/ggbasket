# Diverging and sequential scales

`scale_*_vs_average()` centres a blue-white-red scale on `midpoint`
(typically 0 for "difference from league average"). Red always means
"better than average" for the quantity shown, so flip `reverse` for
quantities where lower is better (turnovers, defensive rating).

## Usage

``` r
scale_fill_vs_average(
  ...,
  midpoint = 0,
  reverse = FALSE,
  limits = NULL,
  oob = scales::squish
)

scale_colour_vs_average(
  ...,
  midpoint = 0,
  reverse = FALSE,
  limits = NULL,
  oob = scales::squish
)

scale_colour_league(...)

scale_fill_league(...)
```

## Arguments

- ...:

  Passed to
  [`ggplot2::scale_fill_gradient2()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
  or
  [`ggplot2::scale_fill_viridis_c()`](https://ggplot2.tidyverse.org/reference/scale_viridis.html).

- midpoint:

  Centre of the diverging scale.

- reverse:

  Swap the two ends.

- limits, oob:

  Scale limits; values outside are squished, so a single extreme cell
  does not wash out the rest.
