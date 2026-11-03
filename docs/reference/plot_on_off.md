# Plot on/off

One row per player: the team's net rating with the player off the floor
(open circle) and on it (filled), joined by a line coloured by which is
better. Ordered by the difference.

## Usage

``` r
plot_on_off(oo, n = 12, title = NULL, subtitle = NULL, caption = NULL)
```

## Arguments

- oo:

  Output of
  [`on_off()`](https://loukesio.github.io/ggbasket-site/reference/on_off.md),
  one team (or use `n`).

- n:

  Show at most `n` players with the most minutes.

- title, subtitle, caption:

  Labels.
