# Zone shot chart with annotated makes and attempts

The court painted by zone. Fill is FG% versus the league in that zone
(shrunk), and each zone is labelled with makes/attempts, FG% and its
share of the player's shots: real court zones and a diverging scale.

## Usage

``` r
plot_shot_zones(
  shots,
  baseline = shots,
  league = NULL,
  detail = TRUE,
  limit = 0.1,
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- shots:

  Shot data (see Details in
  [`plot_shot_hex()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_hex.md)).

- baseline:

  Shots used for the league reference; defaults to `shots`. Pass the
  whole league so a single player is compared with everyone.

- league:

  Court to draw; defaults to the league in the data.

- detail:

  Use 12 side-split zones (default) or 5 distance zones.

- limit:

  Colour scale limit (+-).

- title, subtitle, caption:

  Labels. A default subtitle explains the encoding.

## Examples

``` r
plot_shot_zones(subset(shots_2024, player == "Nikola Jokic"),
                baseline = subset(shots_2024, league == "NBA"),
                title = "Nikola Jokic")
```
