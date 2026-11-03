# Offence against defence: how each team wins

One dot per team. Both axes are measured against the league average, so
the centre of the chart is an average team and up and right are both
good: x = points scored per 100 possessions above average (offence), y =
points allowed per 100 possessions below average (defence). The four
corners are labelled in words, dot colour is net rating (offence +
defence), and the dashed diagonal separates teams that outscore their
opponents from those that do not. Both axes use the same scale, so five
points of offence look as big as five points of defence.

## Usage

``` r
plot_ratings(
  ff,
  label = "team",
  highlight = NULL,
  colour = NULL,
  size = NULL,
  net_breaks = NULL,
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
  (needs `ortg`, `drtg`, `pts`, `poss`).

- label:

  Column used for labels.

- highlight:

  Labels to emphasise (bold, with a dark outline).

- colour:

  Optional column to colour by instead of net rating (e.g. `"league"`).

- size:

  Optional column for point size (e.g. wins).

- net_breaks:

  Extra net-rating diagonals to draw (the zero line is always drawn).

- facet:

  Optional column to facet by (e.g. `"league"`); each panel is centred
  on its own league average.

- title, subtitle, caption:

  Labels.

## Examples

``` r
ff <- four_factors(team_seasons)
plot_ratings(subset(ff, league == "NBA"), highlight = c("OKC", "CLE", "BOS"))
```
