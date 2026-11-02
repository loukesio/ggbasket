# Lorenz curves: how concentrated is scoring?

Several teams on one panel (instead of one panel per team), each curve
labelled directly with its Gini coefficient, plus the line of equality.
The area between the diagonal and a curve is the inequality.

## Usage

``` r
plot_lorenz(
  data,
  value,
  group,
  n = 8,
  highlight = NULL,
  value_label = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- data:

  Player-level data.

- value:

  Column to analyse (e.g. `"pts"`).

- group:

  Column identifying teams.

- n:

  Top-`n` players per team (same `n` for every team).

- highlight:

  Groups to colour; others grey. Default: the most equal team and the
  two most top-heavy.

- value_label:

  How to name `value` on the axis (e.g. "points").

- title, subtitle, caption:

  Labels.

## Examples

``` r
nba <- subset(player_seasons, league == "NBA")
plot_lorenz(nba, "pts", "team", highlight = c("OKC", "MIL", "BKN"))
```
