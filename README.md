# ggbasket

Story-driven **ggplot2** graphics and tidy metrics for basketball box-score, shot and play-by-play data,
for **NBA and FIBA/EuroLeague** courts. The package takes the analyses in Zuccolotto & Manisera,
*Basketball Data Science* (CRC 2020) and its `BasketballAnalyzeR` package and redesigns them.
It adds uncertainty, shrinkage of small samples, league context and direct labelling, plus the modern rate
statistics the book leaves out. Every figure uses an editorial theme in the style of Cedric Scherer's graphics
(see *Style* below).
See [`BOOK_REVIEW.md`](BOOK_REVIEW.md) for the chapter-by-chapter critique behind each design.

```r
devtools::install("ggbasket")   # from the project root
library(ggbasket)

ff <- four_factors(team_seasons)                      # pace, ratings, four factors (NBA + EuroLeague 2024/25)
plot_ratings(ff, facet = "league", highlight = c("OKC", "PAN"))

nba <- subset(shots_2024, league == "NBA")
plot_shot_hex(subset(nba, player == "Stephen Curry"), baseline = nba)
plot_shot_zones(subset(shots_2024, player == "Sasha Vezenkov"), baseline = shots_2024, league = "EuroLeague")

sc <- shot_curve(shots_2024, "dist", by = "league", outcome = "points", split_value = TRUE)
plot_shot_curve(sc, vlines = c("FIBA 3pt" = 6.75, "NBA 3pt" = 7.24))
```

## Conventions

* lower-case box-score columns (`pts p2m p2a p3m p3a ftm fta orb drb ast tov stl blk pf`),
  opponent columns prefixed `o_`;
* shots: `x`, `y` in **metres from the hoop centre** (y towards half court), `made`, optional `value`, `league`;
* `as_ggbasket_teams()`, `as_ggbasket_players()`, `as_ggbasket_shots()` convert the book's
  `Tbox`/`Obox`/`Pbox`/`PbP` data, so every book example runs.

## Functions

| Topic | Metrics | Plots |
|---|---|---|
| Teams | `possessions()`, `four_factors()`, `gini()`, `lorenz()`, `expected_wins()` | `plot_ratings()`, `plot_four_factors()`, `plot_lorenz()`, `plot_luck()` |
| Players | `player_rates()` (TS%, usage, AST%, ORB%/DRB%, STL%, BLK%, TOV%), `percentile_rank()`, `shrink_rate()` | `plot_profile()` (bars / radar), `plot_quadrant()`, `plot_spread()`, `plot_ranked()`, `plot_joint()` |
| Shots | `shot_zone()`, `summarise_zones()`, `bin_shots_hex()`, `shot_curve()`, `expected_fg()`, `shot_making()` | `plot_shot_hex()`, `plot_shot_zones()`, `plot_shot_density()`, `plot_shot_curve()`, `plot_shot_making()` |
| Pressure | `pressure_situations()`, `pressure_effects()` | `plot_pressure()` |
| Patterns | `association()` (Cramer's V, eta-squared, \|r\|), `cluster_quality()` | `plot_association()`, `plot_corr_matrix()`, `plot_fit()`, `plot_similarity_map()`, `plot_cluster_quality()`, `plot_cluster_profiles()` |
| Passing | `assist_network()` (with assist concentration per player) | `plot_assist_network()`, `plot_assist_matrix()`, `plot_assist_roles()` |
| Courts & style | `court_spec()`, `court_lines()`, `court_zone_grid()`, `ggbasket_fonts()` | `geom_court()`, `theme_ggbasket()`, `theme_court()`, `scale_fill_vs_average()`, `colour_text()`, `ggbasket_caption()` |

## Style

`theme_ggbasket()` follows Cedric Scherer's editorial look: warm paper background, bold title that states the
finding, a markdown subtitle in which groups are named in their own colour (`colour_text("NBA", "NBA")`) instead
of a legend, a monospaced "Data · Graphic" caption (`ggbasket_caption()`), and one annotation at most.
Fonts are Fira Sans, Fira Sans Condensed and Roboto Mono (free on Google Fonts); missing fonts fall back to
the system sans. Base `pdf()` cannot use system fonts, so the theme falls back to `"sans"` there; use
`ggsave(..., device = cairo_pdf)` or PNG for the full look, or `options(ggbasket.family = "sans")` to opt out.

Data: `team_seasons`, `player_seasons`, `shots_2024` (2024/25 regular season, both leagues; built by
`data-raw/make_data.R` from the project's processed tables).

## Gallery: book vs ggbasket

`Rscript gallery/make_gallery.R [figure ...]` redraws everything. `gallery/before/` holds the
BasketballAnalyzeR originals and `gallery/after/` the redesigns.

| Book (BasketballAnalyzeR) | ggbasket |
|---|---|
| ![](gallery/before/01_ratings.png) | ![](gallery/after/01_ratings.png) |
| ![](gallery/before/02_fourfactors.png) | ![](gallery/after/02_fourfactors.png) |
| ![](gallery/before/03_lorenz.png) | ![](gallery/after/03_lorenz.png) |
| ![](gallery/before/04_profile.png) | ![](gallery/after/04_profile.png) |
| ![](gallery/before/05_quadrant.png) | ![](gallery/after/05_quadrant.png) |
| ![](gallery/before/06_spread.png) | ![](gallery/after/06_spread.png) |
| ![](gallery/before/07_ranked.png) | ![](gallery/after/07_ranked.png) |
| ![](gallery/before/08_shots.png) | ![](gallery/after/08_shot_hex.png) ![](gallery/after/09_shot_zones.png) |
| ![](gallery/before/10_density.png) | ![](gallery/after/10_density.png) |
| ![](gallery/before/11_curve.png) | ![](gallery/after/11_curve_leagues.png) ![](gallery/after/11b_curve_playlength.png) |
| *(CART tables, Fig. 3.18-3.19)* | ![](gallery/after/12_shot_making.png) |
| ![](gallery/before/13_corr.png) | ![](gallery/after/13_corr.png) ![](gallery/after/14_fit.png) |
| ![](gallery/before/15_map.png) | ![](gallery/after/15_map.png) |
| ![](gallery/before/16_clusters.png) | ![](gallery/after/16_cluster_quality.png) ![](gallery/after/16b_cluster_profiles.png) |
| ![](gallery/before/17_network.png) | ![](gallery/after/17_network.png) ![](gallery/after/17b_assist_matrix.png) ![](gallery/after/17c_assist_roles.png) |

### Book techniques without a plot in BasketballAnalyzeR

| Book section | ggbasket |
|---|---|
| 3.1 Cramer's V and eta-squared | ![](gallery/after/18_association.png) |
| 3.5.3 Joint density of two variables | ![](gallery/after/19_joint.png) |
| 3.6 High-pressure situations (CART) | ![](gallery/after/20_pressure.png) |

### Beyond the book

| Measure | ggbasket |
|---|---|
| Pythagorean expected wins and luck | ![](gallery/after/21_luck.png) |

## Status

v0.2.0. `R CMD check` passes with 0 errors, 0 warnings and 0 notes, and 75 tests pass. The four factors
match BasketballAnalyzeR, and `gini()` reproduces the book's worked example (38.12%).
