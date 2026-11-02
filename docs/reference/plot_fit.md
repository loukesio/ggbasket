# Fit a line and name the over- and under-performers

Scatter with a fitted relationship (`"lm"`, `"loess"` or a GAM) and its
confidence band. Points are coloured by their residual, and the cases
farthest above and below the fit are labelled, which is usually the
story ("for his assist load, he barely turns it over").

## Usage

``` r
plot_fit(
  data,
  x,
  y,
  label,
  method = c("lm", "loess", "gam"),
  n_label = 4,
  highlight = NULL,
  above_is_good = TRUE,
  xlab = x,
  ylab = y,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Columns.

- label:

  Column with names.

- method:

  `"lm"`, `"loess"` or `"gam"`.

- n_label:

  Number of cases to label on each side of the fit.

- highlight:

  Extra names to label.

- above_is_good:

  Is being above the line good (affects colours)?

- xlab, ylab, title, subtitle, caption:

  Labels.

## Value

A ggplot; the fitted model is in `attr(p, "fit")`.
