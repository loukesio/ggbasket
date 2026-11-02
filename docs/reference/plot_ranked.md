# Ranked composition bars with a companion stat

Bars and a line on two different y axes invite false comparisons between
them, so this draws the ranked (stacked) bars on the left and the
companion variable as a dot column on the right, sharing the rows, each
on its own honest axis.

## Usage

``` r
plot_ranked(
  data,
  id,
  bars,
  line = NULL,
  order_by = NULL,
  line_label = line,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- data:

  A data frame, one row per subject.

- id:

  Column with names.

- bars:

  Columns to stack (named to relabel).

- line:

  Companion column shown as dots.

- order_by:

  Column to sort by (default: total of the bars).

- line_label:

  Title of the companion panel.

- title, subtitle, caption:

  Labels.

## Examples

``` r
hou <- subset(player_seasons, league == "NBA" & team == "HOU" & minutes >= 500)
plot_ranked(hou, "player", c(`2PA` = "p2a", `3PA` = "p3a", FTA = "fta"), line = "minutes",
            line_label = "Minutes")
```
