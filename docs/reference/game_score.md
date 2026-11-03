# Game Score: one number per player per game

John Hollinger's Game Score, a box-score summary on the points scale
(about 10 is an average game, 40 an outstanding one): PTS + 0.4 FGM -
0.7 FGA - 0.4 (FTA - FTM) + 0.7 ORB + 0.3 DRB + STL + 0.7 AST + 0.7
BLK - 0.4 PF - TOV.

## Usage

``` r
game_score(box)
```

## Arguments

- box:

  Player box scores from
  [`box_score()`](https://loukesio.github.io/ggbasket-site/reference/box_score.md).

## Value

`box` with `game_score`.
