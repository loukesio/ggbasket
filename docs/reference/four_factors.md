# Pace, ratings and the four factors

Takes one row per team (season totals or single games) with the team's
counting stats and the opponent's counting stats prefixed by `o_`
(`o_p2a`, `o_tov`, ...), and returns possessions, pace, offensive /
defensive / net rating and Dean Oliver's four factors for offence and
defence. Rows are kept, so you can pass grouped game data and summarise
first, or pass totals directly.

## Usage

``` r
four_factors(data, ft_coef = 0.44, min_is_team = TRUE, per = NULL)
```

## Arguments

- data:

  A data frame.

- ft_coef:

  Passed to
  [`possessions()`](https://loukesio.github.io/ggbasket-site/reference/possessions.md).

- min_is_team:

  Is `min` the sum of player minutes (240 per NBA game)?

- per:

  Minutes the pace refers to (48 NBA, 40 FIBA).

## Value

`data` with added columns `poss`, `o_poss`, `pace`, `ortg`, `drtg`,
`net_rtg`, `efg`, `tov_pct`, `orb_pct`, `ft_rate`, `o_efg`, `o_tov_pct`,
`drb_pct`, `o_ft_rate`.

## Details

Columns needed: `pts p2m p2a p3m p3a ftm fta orb drb tov` and the same
with `o_`. Optional `min` (team minutes, i.e. 5 x game minutes, or game
minutes when `min_is_team = FALSE`) enables pace.

## Examples

``` r
ff <- four_factors(team_seasons)
head(ff[, c("team", "league", "ortg", "drtg", "efg", "tov_pct")])
#> # A tibble: 6 × 6
#>   team  league      ortg  drtg   efg tov_pct
#>   <chr> <chr>      <dbl> <dbl> <dbl>   <dbl>
#> 1 ASV   EuroLeague  110.  115. 0.543   0.179
#> 2 BAR   EuroLeague  117.  112. 0.580   0.151
#> 3 BAS   EuroLeague  113.  114. 0.534   0.154
#> 4 BER   EuroLeague  102.  119. 0.512   0.189
#> 5 IST   EuroLeague  119.  112. 0.587   0.160
#> 6 MAD   EuroLeague  112.  109. 0.554   0.168
```
