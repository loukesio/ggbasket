# Court specification

Dimensions (in metres) of the NBA or FIBA half court used by every court
drawing and zone function. `"EuroLeague"` is accepted as an alias of
`"FIBA"`.

## Usage

``` r
court_spec(league = "NBA")
```

## Arguments

- league:

  `"NBA"`, `"FIBA"` or `"EuroLeague"`.

## Value

A named list of dimensions.

## Examples

``` r
court_spec("NBA")$arc_r     # 7.24 m
#> [1] 7.24
court_spec("EuroLeague")$arc_r  # 6.75 m
#> [1] 6.75
```
