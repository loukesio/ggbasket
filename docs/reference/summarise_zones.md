# Summarise shots by zone (with shrinkage)

Attempts, makes, FG%, points per shot and share of attempts per zone,
plus the league average in the same zone and the player's FG% shrunk
towards it (see
[`shrink_rate()`](https://loukesio.github.io/ggbasket/reference/shrink_rate.md)).

## Usage

``` r
summarise_zones(
  shots,
  by = NULL,
  baseline = shots,
  detail = FALSE,
  prior_n = 30
)
```

## Arguments

- shots:

  Shot data (see Details in
  [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md)).

- by:

  Grouping columns (character), e.g. `"player"`.

- baseline:

  Shots used for the league reference; defaults to `shots`. Pass the
  whole league so a single player is compared with everyone.

- detail:

  Use the 12 side-split zones.

- prior_n:

  Strength of the pull towards the league zone average, in attempts: a
  zone with `prior_n` attempts is moved halfway.

## Examples

``` r
zs <- summarise_zones(subset(shots_2024, player == "Stephen Curry"),
                      baseline = shots_2024, by = "player")
zs[, c("zone", "attempts", "fg", "fg_league", "fg_shrunk")]
#> # A tibble: 5 × 5
#>   zone            attempts    fg fg_league fg_shrunk
#>   <fct>              <int> <dbl>     <dbl>     <dbl>
#> 1 Rim                  243 0.601     0.625     0.603
#> 2 Short mid-range      139 0.439     0.440     0.439
#> 3 Long mid-range        92 0.5       0.413     0.479
#> 4 Corner 3              85 0.482     0.388     0.458
#> 5 Above-break 3        699 0.386     0.351     0.385
```
