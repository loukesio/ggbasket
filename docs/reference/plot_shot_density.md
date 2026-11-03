# Shot density on the court

Where a player (or group) shoots from, as filled density contours, with
optional made/missed points on top. With `compare`, shows the difference
between the group's shot density and the reference density (red = shoots
there more than the reference), which answers "how is this shot diet
different?" rather than "where is the rim?".

## Usage

``` r
plot_shot_density(
  shots,
  compare = NULL,
  facet = NULL,
  league = NULL,
  points = FALSE,
  bw = 0.6,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- shots:

  Shot data (see Details in
  [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md)).

- compare:

  Optional reference shots for a density difference map.

- facet:

  Column to facet by (also used for binning).

- league:

  Court to draw; defaults to the league in the data.

- points:

  Overlay individual shots.

- bw:

  Kernel bandwidth in metres.

- title, subtitle, caption:

  Labels. A default subtitle explains the encoding.
