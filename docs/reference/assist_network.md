# Who assists whom

Builds passer-to-scorer counts from play-by-play data with one row per
event and columns `player` (scorer), `assist` (passer, empty when
unassisted), `result` (`"made"`/`"missed"`) and `points`: the ggbasket
play-by-play layout (see
[pbp](https://loukesio.github.io/ggbasket-site/reference/pbp.md)).

## Usage

``` r
assist_network(pbp)
```

## Arguments

- pbp:

  Play-by-play rows of one team.

## Value

A list: `edges` (from, to, assists, points) and `nodes` (player,
assists, assisted_fgm, fgm, pct_assisted, points_created, plus the
network-centrality measures: `partners` = teammates assisted,
`ast_share` = share of the team's assists, `ast_gini` / `recv_gini` =
how concentrated a player's assists made / received are across
teammates, from 0 = spread evenly to 1 = all to / from one player).
