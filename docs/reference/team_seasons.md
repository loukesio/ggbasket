# Team season totals, NBA and EuroLeague 2024/25

Regular-season totals for every NBA (30) and EuroLeague (18) team, with
the opponents' totals prefixed by `o_`. Ready for
[`four_factors()`](https://loukesio.github.io/ggbasket-site/reference/four_factors.md).

## Usage

``` r
team_seasons
```

## Format

A tibble with one row per team: `league`, `season` (starting year),
`team`, `games`, `w`, `l`, `min` (team minutes = 5 x game minutes),
counting stats `pts p2m p2a p3m p3a ftm fta orb drb ast tov stl blk pf`
and opponent stats `o_pts o_p2m ... o_pf`.

## Source

NBA: ESPN box scores via hoopR. EuroLeague: official EuroLeague API.
Built by `data-raw/make_data.R`.
