# Assist network on a circle

Players sit on a circle ordered by assists made; curved arrows go from
passer to scorer, with width and darkness proportional to the number of
assists. Node size = assists made, node colour = share of the player's
own baskets that were assisted (blue = creates his own shot, red =
finisher). Edges below `min_assists` are dropped to keep the core
visible.

## Usage

``` r
plot_assist_network(
  net,
  min_assists = 10,
  top_n = 10,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- net:

  Output of
  [`assist_network()`](https://loukesio.github.io/ggbasket-site/reference/assist_network.md).

- min_assists:

  Minimum assists for an edge to be drawn.

- top_n:

  Keep the `top_n` players by assists + assisted baskets.

- title, subtitle, caption:

  Labels.
