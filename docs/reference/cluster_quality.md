# How many clusters? Explained variance by k

For each k, the share of total variance explained by the clustering
(between deviance / total deviance) and its gain over k - 1. Variables
are standardised. k-means uses `nstart` random starts (more starts give
a more stable answer); `"ward"` uses Ward hierarchical clustering. Also
returns the average silhouette width (when the `cluster` package is
available) as a second opinion.

## Usage

``` r
cluster_quality(
  data,
  vars,
  k = 2:12,
  method = c("kmeans", "ward"),
  nstart = 25,
  seed = 1
)

plot_cluster_quality(cq, choose = NULL)
```

## Arguments

- data:

  A data frame.

- vars:

  Columns to cluster on.

- k:

  Values of k to try.

- method:

  `"kmeans"` or `"ward"`.

- nstart:

  Random starts for k-means.

- seed:

  Random seed.

- cq:

  Output of `cluster_quality()`.

- choose:

  Optional chosen k, highlighted.
