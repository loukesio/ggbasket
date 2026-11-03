# One line per game: what kind of game was it?

One line per game: what kind of game was it?

## Usage

``` r
game_summary(pbp, params = NULL)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket-site/reference/pbp.md)), one
  or more games.

- params:

  Win-probability parameters, see
  [`win_probability()`](https://loukesio.github.io/ggbasket-site/reference/win_probability.md).

## Value

A tibble per game: teams and final score, `lead_changes`, `ties`,
`home_max_lead`, `away_max_lead`, `best_run` (label), `excitement`
(total win-probability movement: how much the game swung), `comeback`
(the winner's lowest win probability), `overtime`.
