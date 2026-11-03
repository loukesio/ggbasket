# The story of a game

The home team's lead over time, filled in each team's colour, with
quarters marked, scoring runs bracketed and labelled, and the final
score.

## Usage

``` r
plot_game_flow(
  pbp,
  game = NULL,
  min_run = 8,
  colours = c("#1F5FA8", "#E07B00"),
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)), one or
  more games.

- game:

  `game_id` (default: the first game).

- min_run:

  Smallest scoring run labelled (unanswered points).

- colours:

  Two colours, home first.

- title, subtitle, caption:

  Labels.
