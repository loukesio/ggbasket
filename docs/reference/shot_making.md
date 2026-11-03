# Shot-making over expected

The idea of grading every shot by `made - P(make)`, so a difficult make
is worth more than an easy one, (Zuccolotto et al., 2018), turned into a
per-player table:

## Usage

``` r
shot_making(shots, by = "player", prior_n = 100)
```

## Arguments

- shots:

  Shots with an `xfg` column (see
  [`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md)),
  or raw shots (then
  [`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md)
  is called on them).

- by:

  Grouping columns, default `"player"`.

- prior_n:

  Shrinkage strength in attempts.

## Details

- `xfg`: average expected FG% of the player's shots (shot difficulty;
  lower = harder diet);

- `fg_oe`: FG% over expected, shrunk towards 0 by `prior_n`
  pseudo-attempts so that low-volume players do not top the list;

- `pts_added`: points added over an average shooter taking the same
  shots.
