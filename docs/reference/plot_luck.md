# Who won more (or fewer) games than their points say?

Dumbbell chart from
[`expected_wins()`](https://loukesio.github.io/ggbasket-site/reference/expected_wins.md):
open circle = wins expected from points scored and allowed, filled
circle = actual wins; red = luckier than the margin says, blue =
unluckier. Teams sorted by luck; the `n` luckiest and unluckiest per
league are shown.

## Usage

``` r
plot_luck(ew, n = NULL, title = NULL, subtitle = NULL, caption = NULL)
```

## Arguments

- ew:

  Output of
  [`expected_wins()`](https://loukesio.github.io/ggbasket-site/reference/expected_wins.md).

- n:

  Teams shown at each end per league (all teams if `NULL`).

- title, subtitle, caption:

  Labels.

## Examples

``` r
plot_luck(expected_wins(team_seasons), n = 5)
```
