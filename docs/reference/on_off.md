# On/off: how a team plays with and without each player

Points scored and allowed per 100 possessions while a player is on the
floor and while he or she sits, from the stints of every game supplied.
`on_off` = net rating on minus net rating off: the raw version of what
adjusted plus-minus models refine. It mixes the player's impact with who
they share the floor with, so read it alongside minutes.

## Usage

``` r
on_off(pbp, team = NULL, min_minutes = 100)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout with line-ups (see
  [`add_lineups()`](https://loukesio.github.io/ggbasket/reference/add_lineups.md)).

- team:

  Teams to keep (default: all).

- min_minutes:

  Players with fewer minutes are dropped.

## Value

A tibble per player and team: `min`, `on_ortg`, `on_drtg`, `on_net`,
`off_net`, `on_off`, `pm` (raw plus-minus), `poss_on`, `poss_off`.
