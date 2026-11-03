# Plot raw against schedule-adjusted margin

One row per team: open circle = average margin, filled = rating against
an average opponent. A long line means the schedule flattered (line to
the left) or hurt (to the right) the raw margin.

## Usage

``` r
plot_team_ratings(tr, title = NULL, subtitle = NULL, caption = NULL)
```

## Arguments

- tr:

  Output of
  [`team_ratings()`](https://loukesio.github.io/ggbasket-site/reference/team_ratings.md).

- title, subtitle, caption:

  Labels.
