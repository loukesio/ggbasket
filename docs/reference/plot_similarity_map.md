# Similarity map (MDS or PCA) with variable arrows

Places subjects so that similar statistical profiles sit close together.
Each variable is drawn as an arrow pointing in the direction in which it
increases (its correlation with the two map axes), so the whole map can
be read at once.

## Usage

``` r
plot_similarity_map(
  data,
  vars,
  label,
  method = c("pca", "mds"),
  colour = NULL,
  highlight = NULL,
  n_label = 12,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- data:

  A data frame.

- vars:

  Columns (named to relabel); standardised internally.

- label:

  Column with names.

- method:

  `"mds"` (Kruskal non-metric, needs MASS) or `"pca"`.

- colour:

  Optional column to colour by (e.g. a cluster or position).

- highlight:

  Names to emphasise.

- n_label:

  Also label the most outlying `n_label` subjects.

- title, subtitle, caption:

  Labels.
