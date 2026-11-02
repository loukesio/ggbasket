# Hexagon shot chart: where they shoot from, and how well

Kirk Goldsberry-style chart. Hexagon **size** is how often the player
shoots from that spot, hexagon **colour** is FG% compared with the
league from the same spot (shrunk, so tiny samples stay near white).
Faceting by `facet` gives small multiples on a common scale.

## Usage

``` r
plot_shot_hex(
  shots,
  baseline = shots,
  facet = NULL,
  league = NULL,
  binwidth = 0.75,
  min_attempts = 3,
  fill = c("fg", "pps"),
  limit = NULL,
  max_size = 1,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- shots:

  Shot data (see Details in `plot_shot_hex()`).

- baseline:

  Shots used for the league reference; defaults to `shots`. Pass the
  whole league so a single player is compared with everyone.

- facet:

  Column to facet by (also used for binning).

- league:

  Court to draw; defaults to the league in the data.

- binwidth:

  Distance between hexagon centres, in metres.

- min_attempts:

  Hide hexagons with fewer attempts (they carry no information about
  efficiency and clutter the court).

- fill:

  `"fg"` (FG% vs league) or `"pps"` (points per shot vs league).

- limit:

  Colour scale limit (+-).

- max_size:

  Largest hexagon as a fraction of the full hexagon.

- title, subtitle, caption:

  Labels. A default subtitle explains the encoding.

## Details

Shot data needs `x`, `y` in metres from the hoop centre (y towards half
court), `made`, and optionally `value` and `league`. See
[`as_ggbasket_shots()`](https://loukesio.github.io/ggbasket/reference/as_ggbasket_teams.md)
to take shots out of a play-by-play.

## Examples

``` r
curry <- subset(shots_2024, player == "Stephen Curry")
plot_shot_hex(curry, baseline = subset(shots_2024, league == "NBA"),
              title = "Stephen Curry, 2024/25")
```
