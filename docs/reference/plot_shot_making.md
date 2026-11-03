# Shot difficulty vs shot making

Each player is a point: x = how hard their shots are (expected FG%,
reversed so harder is to the right), y = how much better or worse than
expected they finish them. Point size = attempts. The four corners have
a story (tough-shot makers, efficient finishers, ...), which is written
on the plot.

## Usage

``` r
plot_shot_making(
  sm,
  label = "player",
  highlight = NULL,
  n_label = 8,
  min_attempts = 200,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- sm:

  Output of
  [`shot_making()`](https://loukesio.github.io/ggbasket/reference/shot_making.md).

- label:

  Column with names.

- highlight:

  Names to colour and always label.

- n_label:

  Also label the `n_label` most extreme players.

- min_attempts:

  Drop players with fewer attempts.

- title, subtitle, caption:

  Labels.
