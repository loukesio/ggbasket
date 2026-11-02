# How dependable is a player, game to game?

One dot per game for each player (Game Score by default), with the
middle half of games shaded and the median marked. A tight strip is a
player you can count on; a wide one swings between quiet nights and big
games. Players are ordered by median.

## Usage

``` r
plot_consistency(
  box,
  players,
  stat = "game_score",
  stat_label = "Game Score",
  min_minutes = 10,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- box:

  Player-game rows, e.g. `game_score(box_score(pbp))`.

- players:

  Players to show.

- stat:

  Column to plot.

- stat_label:

  Axis label.

- min_minutes:

  Games with fewer minutes are dropped.

- title, subtitle, caption:

  Labels.
