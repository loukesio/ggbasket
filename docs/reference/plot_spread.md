# Spread within a team: who carries each skill?

One row per variable, players as dots (size = volume, e.g. attempts),
the team's weighted average as a line, and the coefficient of variation
written at the end. Players named in `label_top` are labelled at their
dots.

## Usage

``` r
plot_spread(
  data,
  made,
  attempts,
  labels = made,
  player = "player",
  shrink = TRUE,
  min_attempts = 1,
  label_top = 3,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- data:

  Player rows for one team.

- made, attempts:

  Character vectors of paired columns (e.g. `c("p2m", "p3m", "ftm")` and
  `c("p2a", "p3a", "fta")`).

- labels:

  Row labels.

- player:

  Column with names.

- shrink:

  Shrink percentages.

- min_attempts:

  Players with fewer attempts of a kind are left out of that row.

- label_top:

  Number of highest-volume players to name per row.

- title, subtitle, caption:

  Labels.

## Details

With `shrink = TRUE` and `made`/`attempts` pairs, percentages are shrunk
(see
[`shrink_rate()`](https://loukesio.github.io/ggbasket-site/reference/shrink_rate.md))
so a 0/2 shooter no longer defines the range.

## Examples

``` r
okc <- subset(box_score(pbp_games), team == "OKC" & min >= 10)
plot_spread(okc, c("p2m", "p3m", "ftm"), c("p2a", "p3a", "fta"),
            labels = c("2-point FG%", "3-point FG%", "Free throws"))
```
