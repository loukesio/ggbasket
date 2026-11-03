# Win probability added

Credits every change in win probability (from
[`win_probability()`](https://loukesio.github.io/ggbasket-site/reference/win_probability.md))
to the players involved, from their team's point of view: the player who
made the play (shooter, free-throw shooter, player who lost the ball)
gets the change, and the five opponents on the floor share the opposite
change equally (a fifth each), so defence counts and the two teams'
totals cancel. For a steal, the stealer takes half of the defence's
share. +0.30 means the player's plays added 30 percentage points to
their team's chance of winning.

## Usage

``` r
win_probability_added(wp)
```

## Arguments

- wp:

  Output of
  [`win_probability()`](https://loukesio.github.io/ggbasket-site/reference/win_probability.md),
  with line-ups.

## Value

A tibble per game and player: `team`, `wpa`, `offence`, `defence`,
`plays`.
