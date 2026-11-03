# Plot what decided one game

Bars from zero for the points each factor gave the chosen team, with the
teams' own numbers written next to each bar.

## Usage

``` r
plot_game_factors(
  gf,
  game,
  team = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- gf:

  Output of
  [`game_factors()`](https://loukesio.github.io/ggbasket/reference/game_factors.md).

- game:

  `game_id`.

- team:

  Team whose view to take (default: the winner).

- title, subtitle, caption:

  Labels.
