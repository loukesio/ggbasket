# Win probability chart

Home win probability through the game, from
[`win_probability()`](https://loukesio.github.io/ggbasket-site/reference/win_probability.md),
with the plays that moved it most numbered and listed under the title.

## Usage

``` r
plot_win_probability(
  wp,
  game = NULL,
  n_key = 4,
  colours = c("#1F5FA8", "#E07B00"),
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- wp:

  Output of
  [`win_probability()`](https://loukesio.github.io/ggbasket-site/reference/win_probability.md).

- game:

  `game_id` (default: the first game).

- n_key:

  Number of biggest swings to label.

- colours:

  Two colours, home first.

- title, subtitle, caption:

  Labels.
