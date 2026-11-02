# Joint distribution of two statistics

Where do players concentrate on two statistics at once? The
two-dimensional kernel density is drawn as soft filled contours behind
the players, with the marginal distributions on the edges, a few
highlighted players labelled, and optional groups coloured.

## Usage

``` r
plot_joint(
  data,
  x,
  y,
  label = NULL,
  highlight = NULL,
  xlab = x,
  ylab = y,
  x_labels = ggplot2::waiver(),
  y_labels = ggplot2::waiver(),
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- data:

  A data frame, one row per player (or team).

- x, y:

  Column names.

- label:

  Column with names.

- highlight:

  Names to label and emphasise.

- xlab, ylab, title, subtitle, caption:

  Labels.

- x_labels, y_labels:

  Axis label functions, e.g.
  [`scales::label_percent()`](https://scales.r-lib.org/reference/label_percent.html).

## Value

A patchwork object (needs the patchwork package).
