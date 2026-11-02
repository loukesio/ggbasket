# Classify shots into court zones

Five distance zones (`detail = FALSE`) or thirteen zones that also split
by side of the floor (`detail = TRUE`): rim, paint, mid-range left /
centre / right (short and long), corner 3 left / right, above-the-break
3 left / centre / right. Uses each league's own 3-point geometry. When
`value` is missing, 2 vs 3 is inferred from the coordinates.

## Usage

``` r
shot_zone(
  x,
  y,
  league = "NBA",
  value = NULL,
  detail = FALSE,
  rim_r = 1.75,
  short_r = 4.25
)

shot_zone_levels(detail = FALSE)
```

## Arguments

- x, y:

  Shot coordinates in metres (see
  [`geom_court()`](https://loukesio.github.io/ggbasket/reference/geom_court.md)).

- league:

  League rules, recycled.

- value:

  Shot value (2 or 3), optional.

- detail:

  Return the 13 side-split zones.

- rim_r, short_r:

  Radii (m) of the rim area and of short mid-range.

## Value

A factor.

## Details

The rim radius is 1.75 m by default rather than the 1.22-1.25 m
restricted area because EuroLeague operators record layups about 1.1 m
from the hoop.

## Examples

``` r
shot_zone(c(0, 3, 6.8, 0), c(0.5, 3, 0.5, 7.5), "NBA", detail = TRUE)
#> [1] Rim                  Short mid right      Corner 3 right      
#> [4] Above-break 3 centre
#> 12 Levels: Rim Paint Short mid left Short mid right ... Above-break 3 right
```
