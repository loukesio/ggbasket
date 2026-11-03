# Strength of association between any two variables

Dependence is measured with the index suited to each pair of variable
types (Zuccolotto & Manisera, 2020, Section 3.1): Cramer's V for two
categorical variables, the correlation ratio eta-squared for a
categorical and a numerical one, and Pearson's correlation for two
numerical ones. `association()` does all three for every pair in `vars`
and puts them on one 0-1 scale (\|r\| for two numerical variables), with
a test p-value, so they can be read in one table or one heatmap
([`plot_association()`](https://loukesio.github.io/ggbasket-site/reference/plot_association.md)).

## Usage

``` r
association(data, vars)
```

## Arguments

- data:

  A data frame.

- vars:

  Columns to use; a named vector sets display names.

## Value

A tibble with `var1`, `var2`, `measure` (`"V"`, `"eta2"` or `"|r|"`),
`value` and `p_value`.

## Details

Logical columns and character columns are treated as categorical. With
large data almost everything is "significant"; read the strength, not
the p-value.

## Examples

``` r
set.seed(1)
sh <- shots_2024[sample(nrow(shots_2024), 5000), ]
sh$dist <- sqrt(sh$x^2 + sh$y^2)
association(sh, c("league", "value", "made", "dist"))
#> # A tibble: 6 × 5
#>   var1   var2  measure      value  p_value
#>   <chr>  <chr> <chr>        <dbl>    <dbl>
#> 1 league value V       0.00537    7.04e- 1
#> 2 league made  V       0.0183     1.95e- 1
#> 3 league dist  eta2    0.00000650 8.57e- 1
#> 4 value  made  V       0.186      1.10e-39
#> 5 value  dist  eta2    0.817      0       
#> 6 made   dist  eta2    0.0568     1.74e-65
```
