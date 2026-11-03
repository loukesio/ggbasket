# Assist matrix heatmap

Passers in rows, scorers in columns, both ordered by volume; each cell
is the number of assists. Row and column totals are printed in the
margins. Often easier to read exactly than a network.

## Usage

``` r
plot_assist_matrix(
  net,
  top_n = 10,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- net:

  Output of
  [`assist_network()`](https://loukesio.github.io/ggbasket-site/reference/assist_network.md).

- top_n:

  Keep the `top_n` players by assists + assisted baskets.

- title, subtitle, caption:

  Labels.
