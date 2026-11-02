# A fine grid of the half court labelled by zone

Used to paint zone charts: each cell of a `res`-metre grid is classified
with
[`shot_zone()`](https://loukesio.github.io/ggbasket/reference/shot_zone.md),
so zone shapes follow the real court lines exactly without hand-made
polygons.

## Usage

``` r
court_zone_grid(
  league = "NBA",
  detail = TRUE,
  res = 0.05,
  ymax = 9.25,
  rim_r = 1.75,
  short_r = 4.25
)
```

## Arguments

- league:

  League rules, recycled.

- detail:

  Return the 13 side-split zones.

- res:

  Grid resolution in metres.

- ymax:

  Depth of the grid from the hoop.

- rim_r, short_r:

  Radii (m) of the rim area and of short mid-range.
