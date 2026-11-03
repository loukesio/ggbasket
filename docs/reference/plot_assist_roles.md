# Hubs and two-man games

An assist network can be summarised by how *concentrated* each player's
passes are (a Gini index over teammates). Here that becomes a map: x =
share of the team's assists the player makes (how much of a hub), y =
how evenly those assists are spread over teammates (1 - Gini), point
size = assisted baskets received, colour = share of own baskets that
were assisted. Top right: a hub who feeds everyone; top left: a
connector with few assists; bottom: assists that go mostly to one
partner.

## Usage

``` r
plot_assist_roles(
  net,
  min_assists = 30,
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

  Players with fewer assists made are dropped.

- title, subtitle, caption:

  Labels.
