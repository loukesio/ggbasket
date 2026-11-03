# Heatmap of associations

Lower-triangle heatmap of
[`association()`](https://loukesio.github.io/ggbasket-site/reference/association.md):
one sequential colour scale from 0 (independent) to 1 (perfectly
dependent); each cell names the index used, so a Cramer's V is never
mistaken for a correlation.

## Usage

``` r
plot_association(assoc, title = NULL, subtitle = NULL, caption = NULL)
```

## Arguments

- assoc:

  Output of
  [`association()`](https://loukesio.github.io/ggbasket-site/reference/association.md).

- title, subtitle, caption:

  Labels.

## Examples

``` r
set.seed(1)
sh <- shots_2024[sample(nrow(shots_2024), 5000), ]
sh$dist <- sqrt(sh$x^2 + sh$y^2)
plot_association(association(sh, c(League = "league", Value = "value",
                                   Made = "made", Distance = "dist")))
```
