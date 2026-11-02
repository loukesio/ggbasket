# Shrink rates towards the group average (empirical Bayes)

Fits a beta distribution to the observed rates `made / attempts` across
all rows (or within `group`) by marginal maximum likelihood of the
beta-binomial, and returns each row's posterior mean and a credible
interval. A player who is 0/2 from three is pulled almost all the way to
the average; a player who is 150/400 barely moves. This replaces raw
percentages wherever small samples would otherwise dominate a figure
(the range of a team's 3P% is otherwise set by a 0/2 shooter).

## Usage

``` r
shrink_rate(made, attempts, group = NULL, level = 0.8)
```

## Arguments

- made, attempts:

  Counts.

- group:

  Optional grouping vector (e.g. league or zone): a separate prior is
  fitted per group.

- level:

  Width of the credible interval.

## Value

A tibble with `raw`, `shrunk`, `lower`, `upper`, `prior_mean`, `prior_n`
(the prior's weight in pseudo-attempts).

## Examples

``` r
shrink_rate(c(0, 150, 30), c(2, 400, 80))
#> # A tibble: 3 × 8
#>    made attempts   raw shrunk lower upper prior_mean prior_n
#>   <dbl>    <dbl> <dbl>  <dbl> <dbl> <dbl>      <dbl>   <dbl>
#> 1     0        2 0      0.374 0.372 0.375      0.374  100000
#> 2   150      400 0.375  0.374 0.372 0.375      0.374  100000
#> 3    30       80 0.375  0.374 0.372 0.375      0.374  100000
```
