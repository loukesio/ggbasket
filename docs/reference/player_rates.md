# Possession-based player rates

The rate statistics of modern analysis, with Basketball-Reference
definitions. They put players from teams (and leagues) with different
pace and game length on the same footing:

## Usage

``` r
player_rates(players, teams, ft_coef = 0.44)
```

## Arguments

- players:

  Player season totals (`minutes`, `pts`, `p2a`, `p3a`, `fta`, `tov`,
  `orb`, `drb`, `ast`, `stl`, `blk`; optionally `p2m`, `p3m`) with
  `team` and, if present, `league` and `season`.

- teams:

  Team totals with opponent columns (`o_` prefix), as in `team_seasons`;
  `min` = total player minutes.

- ft_coef:

  Free-throw weight in possessions (0.44).

## Value

`players` with the rate columns added.

## Details

- `ts_pct`: true shooting, points per shooting possession, PTS / (2
  (FGA + 0.44 FTA)).

- `usg_pct`: share of team possessions a player uses while on the floor.

- `tov_pct`: turnovers per 100 plays (FGA + 0.44 FTA + TOV).

- `orb_pct`, `drb_pct`: share of available rebounds grabbed on the
  floor.

- `stl_pct`: steals per opponent possession on the floor.

- `blk_pct`: share of opponent 2-point attempts blocked on the floor.

- `ast_pct`: share of teammates' baskets assisted on the floor (only
  when player makes `p2m`, `p3m` are available).

- `efg_pct`: effective FG% (also needs makes).

All are returned as proportions (0.25, not 25).

## Examples

``` r
pr <- player_rates(player_seasons, team_seasons)
head(pr[order(-pr$usg_pct), c("player", "usg_pct", "ts_pct")])
#> # A tibble: 6 × 3
#>   player           usg_pct ts_pct
#>   <chr>              <dbl>  <dbl>
#> 1 Achille Lonati     0.611  0    
#> 2 Declan Duru        0.502  0    
#> 3 Joseba Querejeta   0.458  0.333
#> 4 James Wiseman      0.426  0.615
#> 5 Tyrone Wallace     0.377  0.364
#> 6 LaMelo Ball        0.361  0.536
```
