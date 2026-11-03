# What decided the game?

Splits each game's margin into Dean Oliver's four factors. Across all
the games supplied, the margin is regressed on the four differences
between the teams (eFG%, turnover rate, offensive-rebound rate,
free-throw rate); a game's contribution of a factor is its coefficient
times that game's difference, in points. What the factors leave over
(mostly the number of possessions and how they ended) is `other`.

## Usage

``` r
game_factors(teams, coefs = NULL, min_games = 30)
```

## Arguments

- teams:

  Team-game box scores from `box_score(pbp, by = "team")`, many games (a
  season), both teams of each game.

- coefs:

  Coefficients to use instead of fitting them (named `d_efg`, `d_tov`,
  `d_orb`, `d_ftr`).

- min_games:

  With fewer games than this (and no `coefs`), the coefficients fitted
  on every 2024/25 game of the league are used, so a single game can be
  explained on its own.

## Value

The four factors per team and game plus `margin`, the four contributions
(`c_shooting`, `c_turnovers`, `c_rebounding`, `c_free_throws`),
`c_other`; the model (if fitted) is attached as attribute `fit`.
