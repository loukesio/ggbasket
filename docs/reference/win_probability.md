# Win probability through a game

A Brownian-motion model of the score (Stern, 1994): the home margin
drifts by `mu` points per game with standard deviation `sigma`, so with
a lead `m` and a share `r` of regulation left, P(home wins) =
\\(\Phi((m + \mu r) / (\sigma \sqrt{r}))\\). It needs only two numbers
per league, both estimated from final margins by
`fit_win_probability()`; defaults are the 2024/25 regular seasons. An
expected margin per game (a betting line, or the difference in net
ratings plus home court) can replace `mu`.

## Usage

``` r
win_probability(pbp, params = NULL, expected = NULL)

fit_win_probability(pbp)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket-site/reference/pbp.md)), one
  or more games.

- params:

  Output of `fit_win_probability()`: `league`, `mu`, `sigma`.

- expected:

  Optional named vector of expected home margins, by `game_id`.

## Value

The play-by-play with `margin`, `time_left` (share of regulation), `wp`
(home win probability after the event) and `wp_change`.

## Details

`fit_win_probability()` takes `mu` as the mean home margin at the end of
regulation and chooses `sigma` by maximum likelihood on every in-game
state (score, time left, final result), which calibrates the model to
how often leads are actually lost. A floor of 15 seconds on the time
left stands in for the possession that is still to come, so a
three-point deficit with a second left is unlikely but not impossible.
