# Box scores from play-by-play

Counts every event of a play-by-play in the ggbasket layout (see
[pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)) into player
or team box scores, one row per game. Player rows also carry minutes and
plus-minus from the line-ups on court. Team rebounds (no player
credited) are left out, as in official box scores. Team rows carry the
opponent's totals with an `o_` prefix, so they go straight into
[`four_factors()`](https://loukesio.github.io/ggbasket/reference/four_factors.md).

## Usage

``` r
box_score(pbp, by = c("player", "team"), total = FALSE)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout.

- by:

  `"player"` or `"team"`.

- total:

  If `TRUE`, sum over games (one row per player or team, with `games`).

## Value

A tibble with `league`, `season`, `game_id` (unless `total`), `team`,
(`player`), `pts p2m p2a p3m p3a ftm fta orb drb ast stl blk tov pf`,
and for players `min` and `pm`; for teams `o_*`, `min` (5 x game
minutes), `w` and `l`.

## Examples

``` r
bx <- box_score(pbp_games)
head(bx[order(-bx$pts), c("team", "player", "min", "pts", "ast", "pm")])
#> # A tibble: 6 × 6
#>   team  player                    min   pts   ast    pm
#>   <chr> <chr>                   <dbl> <dbl> <int> <dbl>
#> 1 OKC   Shai Gilgeous-Alexander  40.2    29    12    10
#> 2 IND   Bennedict Mathurin       33.4    24     3   -15
#> 3 ULK   Nigel Hayes-Davis        36.7    23     1    17
#> 4 OKC   Jalen Williams           38.2    20     4    11
#> 5 MCO   Alpha Diallo             27.2    19     2     9
#> 6 ULK   Marko Guduric            28.8    19     0    11
four_factors(box_score(pbp_games, by = "team"))[, c("game_id", "team", "ortg", "drtg", "efg")]
#> # A tibble: 4 × 5
#>   game_id   team   ortg  drtg   efg
#>   <chr>     <chr> <dbl> <dbl> <dbl>
#> 1 E2024_330 MCO    98.4 118.  0.468
#> 2 E2024_330 ULK   118.   98.4 0.492
#> 3 401766128 IND    97.1 108.  0.493
#> 4 401766128 OKC   108.   97.1 0.466
```
