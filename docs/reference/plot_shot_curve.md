# Plot shooting curves

Line = estimate, ribbon = bootstrap band, line width = how many shots
are taken there (attempt density), so the eye is drawn to where the
volume is. Group labels are placed at the right end of each line instead
of in a legend. An optional dashed reference line marks e.g. the team
average.

## Usage

``` r
plot_shot_curve(
  curve,
  highlight = NULL,
  ref = NULL,
  ref_label = NULL,
  vlines = NULL,
  xlab = NULL,
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- curve:

  Output of
  [`shot_curve()`](https://loukesio.github.io/ggbasket/reference/shot_curve.md).

- highlight:

  Groups to colour; others are drawn in grey for context.

- ref:

  Optional horizontal reference value.

- ref_label:

  Label for the reference line.

- vlines:

  Optional named numeric vector of vertical markers, e.g.
  `c("3-pt line" = 7.24)`.

- xlab, ylab, title, subtitle, caption:

  Labels.

## Examples

``` r
sh <- subset(shots_2024, player %in% c("Stephen Curry", "Nikola Jokic"))
sc <- shot_curve(sh, "dist", by = "player", outcome = "points", n_boot = 50)
plot_shot_curve(sc, vlines = c("NBA 3-pt line" = 7.24),
                xlab = "Shot distance (m)")
```
