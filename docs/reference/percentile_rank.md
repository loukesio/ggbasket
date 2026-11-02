# Percentile of each value within a reference group

Percentile of each value within a reference group

## Usage

``` r
percentile_rank(x, group = NULL)
```

## Arguments

- x:

  Values.

- group:

  Optional group (e.g. league or position); percentiles are computed
  within group.

## Value

Percentiles in `[0, 100]` (mid-rank, so ties share a value).
