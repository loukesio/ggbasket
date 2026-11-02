# Convert BasketballAnalyzeR data to ggbasket conventions

The book's package uses `Tbox`/`Obox` (team and opponent totals), `Pbox`
(players) and `PbP` (play-by-play, coordinates in tenths of feet). These
helpers rename columns to ggbasket's lower-case convention, attach
opponent stats with an `o_` prefix and convert shot coordinates to
metres, so every ggbasket function can be run on the book's examples.

## Usage

``` r
as_ggbasket_teams(Tbox, Obox, league = "NBA")

as_ggbasket_players(Pbox, league = "NBA")

as_ggbasket_shots(PbP, league = "NBA")
```

## Arguments

- Tbox, Obox:

  Team and opponent box scores (same row order).

- league:

  League label to attach.

- Pbox:

  Player box scores.

- PbP:

  Play-by-play from
  [`BasketballAnalyzeR::PbPmanipulation()`](https://rdrr.io/pkg/BasketballAnalyzeR/man/PbPmanipulation.html).

## Examples

``` r
if (requireNamespace("BasketballAnalyzeR", quietly = TRUE)) {
  data(Tbox, Obox, package = "BasketballAnalyzeR")
  ff <- four_factors(as_ggbasket_teams(Tbox, Obox))
  head(ff[, c("team", "ortg", "drtg", "pace")])
}
#> # A tibble: 6 × 4
#>   team                 ortg  drtg  pace
#>   <chr>               <dbl> <dbl> <dbl>
#> 1 Atlanta Hawks        102.  108. 101. 
#> 2 Boston Celtics       105.  102.  98.2
#> 3 Brooklyn Nets        104.  108. 101. 
#> 4 Charlotte Hornets    107.  107. 101. 
#> 5 Chicago Bulls        101.  109. 100. 
#> 6 Cleveland Cavaliers  111.  110. 100. 
```
