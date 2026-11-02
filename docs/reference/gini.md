# Lorenz curve and Gini coefficient

How concentrated is a quantity (points, shots, assists) among the top
`n` contributors? `lorenz()` returns the curve, `gini()` the coefficient
in `[0, 1]`. Only the `n` largest values are used, because adding
deep-bench players inflates inequality; compare teams with the same `n`.
The Gini is the normalised area between the line of equality and the
curve, so with `n` players its maximum is 1.

## Usage

``` r
gini(x, n = NULL)

lorenz(x, n = NULL)
```

## Arguments

- x:

  Non-negative values (one per player).

- n:

  Number of largest values to keep (`NULL` = all).

## Examples

``` r
pts <- c(2028, 1734, 1261, 1056, 1918, 1236, 600, 400, 50)
gini(pts, n = 8)
#> [1] 0.2798369
lorenz(pts, n = 8)
#> # A tibble: 9 × 3
#>    rank people  value
#>   <int>  <dbl>  <dbl>
#> 1     0  0     0     
#> 2     1  0.125 0.0391
#> 3     2  0.25  0.0977
#> 4     3  0.375 0.201 
#> 5     4  0.5   0.322 
#> 6     5  0.625 0.445 
#> 7     6  0.75  0.614 
#> 8     7  0.875 0.802 
#> 9     8  1     1     
```
