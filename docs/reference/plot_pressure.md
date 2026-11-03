# Plot pressure effects

One row per situation level: dot = change in make probability against
the reference level, bar = interval. Red = easier than expected, blue =
harder, grey = interval crosses zero.

## Usage

``` r
plot_pressure(
  eff,
  labels = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- eff:

  Output of
  [`pressure_effects()`](https://loukesio.github.io/ggbasket-site/reference/pressure_effects.md).

- labels:

  Optional named vector of display names for the situations.

- title, subtitle, caption:

  Labels.
