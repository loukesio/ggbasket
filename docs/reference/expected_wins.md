# Expected wins and luck

Pythagorean expectation: a team's win share follows from points scored
and allowed as PTS^k / (PTS^k + OPP^k). The exponent `k` is fitted per
league by least squares on log(W/L) = k log(PTS/OPP) (about 14 in the
NBA). `luck` = actual minus expected wins. Because a team has little
control over how well opponents shoot 3s, `o_p3_vs_league` (opponents'
3P% minus the league's) is added as a second luck marker.

## Usage

``` r
expected_wins(teams, exponent = NULL)
```

## Arguments

- teams:

  Team season totals with `w`, `l`, `pts`, `o_pts` and optionally
  `o_p3m`, `o_p3a`.

- exponent:

  Fixed exponent instead of fitting one.

## Value

`teams` with `exponent`, `exp_win_pct`, `exp_w`, `luck` and, if
possible, `o_p3_vs_league`.

## Examples

``` r
ew <- expected_wins(team_seasons)
head(ew[order(-ew$luck), c("league", "team", "w", "exp_w", "luck")])
#> # A tibble: 6 × 5
#>   league     team      w exp_w  luck
#>   <chr>      <chr> <int> <dbl> <dbl>
#> 1 NBA        LAL      50  44.0  6.04
#> 2 NBA        IND      50  46.2  3.76
#> 3 EuroLeague ULK      23  19.5  3.49
#> 4 EuroLeague MUN      19  16.3  2.65
#> 5 NBA        CLE      64  61.4  2.64
#> 6 NBA        WSH      18  15.5  2.52
```
