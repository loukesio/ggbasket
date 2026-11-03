# Transition and shot quality, per team

From the field-goal attempts of
[`pressure_situations()`](https://loukesio.github.io/ggbasket-site/reference/pressure_situations.md)
(with `xfg` from
[`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md)):
how often each team shoots early in the clock (`early_share`, at least
`early` seconds left, mostly transition), points per early and per
half-court shot, and the quality of the shots it takes and allows:
expected points per shot from location alone (`xpps`, `o_xpps`) and how
far actual points beat it (`making`, `o_making`).

## Usage

``` r
team_shot_profile(shots, early = 17)
```

## Arguments

- shots:

  Output of
  [`pressure_situations()`](https://loukesio.github.io/ggbasket-site/reference/pressure_situations.md),
  with `xfg`.

- early:

  Seconds left on the shot clock that count as early.
