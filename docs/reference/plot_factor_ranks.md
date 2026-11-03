# Four factors as a ranking table

One row per chosen team, one column per factor on offence and defence.
Each cell shows the team's value and its rank in the league, coloured
from best (red) to worst (blue), so strengths and weaknesses read at a
glance. Columns carry Dean Oliver's weights.

## Usage

``` r
plot_factor_ranks(ff, teams, title = NULL, subtitle = NULL, caption = NULL)
```

## Arguments

- ff:

  Output of
  [`four_factors()`](https://loukesio.github.io/ggbasket-site/reference/four_factors.md).

- teams:

  Teams to show (ranks are within their league).

- title, subtitle, caption:

  Labels.
