# Offensive vs defensive rating, with net-rating contours

One point per team: points scored per 100 possessions (x) against points
allowed (y, reversed so good defence is up). Diagonal lines are constant
net rating, so "how good is this team overall" is read off the diagonals
and "how do they get there" off the axes, a trade-off that side-by-side
bar charts of ORtg and DRtg hide.

## Usage

``` r
plot_ratings(
  ff,
  label = "team",
  highlight = NULL,
  colour = NULL,
  size = NULL,
  net_breaks = seq(-15, 15, by = 5),
  facet = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- ff:

  Output of
  [`four_factors()`](https://loukesio.github.io/ggbasket/reference/four_factors.md)
  (needs `ortg`, `drtg`).

- label:

  Column used for labels.

- highlight:

  Labels to emphasise.

- colour:

  Optional column to colour by (e.g. `"league"` or a cluster).

- size:

  Optional column for point size (e.g. wins).

- net_breaks:

  Net-rating contours to draw.

- facet:

  Optional column to facet by (e.g. `"league"`), each with its own
  scales.

- title, subtitle, caption:

  Labels.

## Examples

``` r
ff <- four_factors(team_seasons)
plot_ratings(subset(ff, league == "NBA"), highlight = c("OKC", "CLE", "BOS"))
```
