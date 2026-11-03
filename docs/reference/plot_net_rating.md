# Where each team's net rating comes from

Net rating split into its two halves against the league average: offence
(points scored per 100 possessions above average) and defence (points
allowed below average). One row per team, sorted by net rating, so the
ranking and the way each team gets there read together.

## Usage

``` r
plot_net_rating(
  ff,
  league = NULL,
  highlight = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- ff:

  Output of
  [`four_factors()`](https://loukesio.github.io/ggbasket/reference/four_factors.md),
  one league (or use `league`).

- league:

  League to show (default: the first in `ff`).

- highlight:

  Teams to mark with a light band.

- title, subtitle, caption:

  Labels.

## Examples

``` r
plot_net_rating(four_factors(team_seasons), "EuroLeague")
```
