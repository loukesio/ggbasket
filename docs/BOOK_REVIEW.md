# Basketball Data Science (Zuccolotto & Manisera, CRC 2020): a close reading

ggbasket started as a redesign of this book’s analyses; this note
records that starting point. Covers what each chapter does, what holds
up, and what to change. Page numbers are the book’s printed pages.

------------------------------------------------------------------------

## 1. What the book is

The book is a statistics course built around one season (NBA 2017/18)
and mostly one team (Golden State). Every analysis runs through the
authors’ package **BasketballAnalyzeR** (Sandri). It has three levels:

| Part | Content | Level |
|----|----|----|
| I. Ch. 1–2 | Why data science in basketball; data types; possessions, pace, ratings, four factors; bar-line, radial, scatter and bubble plots; variability; Lorenz/Gini; shot charts | introductory |
| II\. Ch. 3 | Association (χ², Cramér’s V, η², Pearson/Spearman); correlation matrix and network; MDS maps; assist networks; kernel densities of shots in time and space. **FOCUS:** CART on “high-pressure” shots (Serie A2 2015/16, Rio 2016) and a shot-making measure | intermediate |
| II\. Ch. 4 | k-means (teams, GSW shots), Ward hierarchical clustering (players), BD/TD “explained variance”, CHI heterogeneity index. **FOCUS:** new player roles (TDA, SOM + fuzzy clustering) | intermediate |
| II\. Ch. 5 | Simple linear regression, LOESS, Nadaraya–Watson kernel smoothing; scoring probability and expected points as functions of distance, shot clock and game time. **FOCUS:** GPS convex-hull “surface area” with Markov-switching and VAR models | intermediate / expert |
| III\. Ch. 6 | The R package: data preparation (Kaggle box scores → Tbox/Obox/Pbox), customising ggplot objects, plotly | technical |

Datasets: `Tbox`, `Obox` (team and opponent totals), `Pbox` (players),
`Tadd` (conference, playoffs) and `PbP.BDB` (BigDataBall play-by-play of
the 82 GSW games, with shot coordinates, play length and lineups).

**Philosophy.** The opening “Marc Gasol is right” (p. 3) and Messina’s
foreword set the tone: analytics supports a coach’s decisions and does
not replace them. Three of Messina’s remarks become analyses in the
book: - points against good vs bad teams → expected points by opponent
tier, Fig. 5.8; - points early vs late → densities and scoring
probability by game time, §3.5.1, §5.2.2; - who can hit the mid-range
shot when the defence takes away the rim and the 3 → Fig. 5.6.

This “question first” framing is the book’s best feature, and ggbasket
keeps it.

------------------------------------------------------------------------

## 2. Chapter by chapter: what works and what doesn’t

### Ch. 2: Basic statistics

| Topic (book function) | What it does | Problems | ggbasket fix |
|----|----|----|----|
| Possessions, pace, ORtg/DRtg, four factors (`fourfactors`) | Kubatko et al. formulas: POSS = FGA + 0.44·FTA − ORB + TOV | 0.44 is fitted to the NBA, not FIBA. Pace is “per minute”, so the axis reads 10.2–10.7. The four-factor bars are **differences from the mean of the selected teams only** (p. 25), so with 4 teams you learn nothing about the league | `four_factors(ft_coef=)` gives pace per 48/40 by league; [`plot_four_factors()`](https://loukesio.github.io/ggbasket-site/reference/plot_four_factors.md) puts the selected teams in the whole-league distribution, right = better, with Oliver’s weights in the strip titles |
| ORtg and DRtg as two bar charts (Fig. 2.2) | Two panels, each sorted alphabetically | The trade-off between the two ratings can’t be seen | [`plot_ratings()`](https://loukesio.github.io/ggbasket-site/reference/plot_ratings.md): ORtg × DRtg map, net-rating diagonals, quadrants |
| Bar-line plot (`barline`) | Stacked bars + a line on a **secondary y-axis** | Dual axes invite false comparisons (bar height vs line height). The bars ordered by plus-minus are shooting *percentages*, which don’t stack meaningfully | [`plot_ranked()`](https://loukesio.github.io/ggbasket-site/reference/plot_ranked.md): stacked *counts* + an aligned dot column with its own axis |
| Radial plots (`radialprofile`) | One common min–max axis for all variables; optional standardisation over the *selected* 9 players | The authors flag the problems themselves (p. 30–33): area and variable order mislead, and the common scale flattens small-range stats (steals 0.029–0.052 on a 0.005–0.313 axis). Standardising over 9 hand-picked players makes “average” meaningless | [`plot_profile()`](https://loukesio.github.io/ggbasket-site/reference/plot_profile.md): **percentiles within a reference group** (league, position), so every axis is 0–100 and comparable. Bars by default, radar optional |
| Scatter / bubble (`scatterplot`, `bubbleplot`) | Points labelled by case number, rainbow / blue–yellow–red palettes; bubble size rescaled 0–100 | Case numbers make the reader cross-reference a table. Rescaled sizes hide units. Red–green palettes (Fig. 5.6) fail for colour-blind readers | [`plot_quadrant()`](https://loukesio.github.io/ggbasket-site/reference/plot_quadrant.md): mean cross, corner captions, repelled labels on highlights and extremes, size = area in real units, ColorBrewer RdBu / Okabe–Ito |
| Variability (`variability`) | Range, CV, weighted CV; bubble diagram | The 3P% example’s range (40 pts) is driven by **Steven Adams 0/2** (p. 44). The book notes this but doesn’t fix it; raw small-sample percentages are the issue | [`plot_spread()`](https://loukesio.github.io/ggbasket-site/reference/plot_spread.md) with [`shrink_rate()`](https://loukesio.github.io/ggbasket-site/reference/shrink_rate.md): empirical-Bayes beta-binomial shrinkage, weighted CV in the axis label |
| Inequality (`inequality`) | Lorenz curve + Gini for top-n players | One panel per team. The Gini depends on n (the book says to keep n fixed, p. 46) and on traded players | [`plot_lorenz()`](https://loukesio.github.io/ggbasket-site/reference/plot_lorenz.md): all teams on one panel (grey), extremes highlighted, Gini written on the plot. [`gini()`](https://loukesio.github.io/ggbasket-site/reference/gini.md) reproduces the book’s 38.12% |
| Shot charts (`shotchart`) | NBA court in feet; “sectors” are pie slices × distance rings, rainbow colour on e.g. play length; density polygons/raster/hexbin | Sectors don’t follow court lines (the 3-point line cuts through them). There is no league baseline, so “50% here” has no reference. NBA only. Coordinates need manual rescaling | [`plot_shot_zones()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_zones.md): real zones (rim, paint, mid L/C/R, corner 3s, above-break 3s) for **NBA and FIBA** geometry, coloured by FG% vs league (shrunk). [`plot_shot_hex()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_hex.md): size = frequency, colour = vs league from the same spot. `plot_shot_density(compare=)`: density *difference* map |

### Ch. 3: Discovering patterns

- **Association measures** (χ², Cramér’s V, η²). These are sound and
  well explained. But the GSW opponent × event-type table (Table 3.1)
  shows “significant but tiny” association (V = 0.06) and does not
  account for the unequal schedule (as the book admits). That is a
  lesson about effect size, and the book could say so more strongly.
- **η² of playoff qualification** (Table 3.2). DRtg/ORtg explain about
  40% and single box-score stats under 6%. This is a good point (“the
  game as a whole counts”). Net rating would explain far more and would
  close the argument.
- **Correlation matrix + network** (`corranalysis`, Fig. 3.2). It uses
  ellipses, crosses for non-significant cells, no multiplicity
  correction, and a hard 0.5 threshold for the network. →
  [`plot_corr_matrix()`](https://loukesio.github.io/ggbasket-site/reference/plot_corr_matrix.md):
  clustered order, Holm-adjusted significance shown by fading,
  coefficients printed.
- **Scatter-plot matrix by playoff group** (Fig. 3.3). The claim that
  “players in better teams strengthen positive synergies” (p. 71) comes
  from eyeballing ~28 pairs of correlations with no uncertainty. With n
  ≈ 180 per group, the differences are within noise. Treat it as a
  hypothesis.
- **MDS** (`MDSmap`). A Kruskal map plus *four separate LOESS level
  plots* to interpret it (Fig. 3.5). →
  [`plot_similarity_map()`](https://loukesio.github.io/ggbasket-site/reference/plot_similarity_map.md):
  one map with variable arrows (a biplot), PCA by default (more stable,
  reproducible) or MDS with stress reported.
- **Assist network** (`assistnet`, Fig. 3.6–3.8). Kamada–Kawai layout
  changes with the seed, edge colour uses a white-blue-red scale, and
  node size and colour carry two more statistics. The “without Draymond
  Green” comparison (1.16 vs 1.11 points per shot, 10.8 vs 11.2 s) is
  **on/off data confounded by lineups, opponents and garbage time**, and
  has no uncertainty. →
  [`plot_assist_network()`](https://loukesio.github.io/ggbasket-site/reference/plot_assist_network.md)
  (fixed circular order by assists, width = count, colour = share of own
  baskets assisted) and
  [`plot_assist_matrix()`](https://loukesio.github.io/ggbasket-site/reference/plot_assist_matrix.md),
  which is often clearer than any network.
- **Kernel densities in time** (`densityplot`). Frequencies in three
  hand-set windows with “best scorer” labels. The windows (e.g. 4 ft /
  18 ft) are arbitrary, and the reported shares (52% vs 49%) are within
  sampling noise. The book says so (“rather weak evidence”), which is
  good, but nothing quantifies it.
- **FOCUS: high-pressure shooting (CART)**. Its idea of **grading each
  shot as made − P(make \| situation)** (eq. 3.1) is the most valuable
  in the book; it is today’s “shot-making over expected”. The
  implementation has weaknesses:
  - continuous predictors are cut into categories and fed to a single
    pruned tree, which is unstable;
  - shot location is reduced to “type” (2P/3P/FT), and no shooter effect
    is included;
  - P_i is unshrunk, so a 15-attempt threshold still leaves noisy
    rankings. →
    [`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md)
    (logistic GAM on distance × angle per league and shot value, plus
    optional `extra` smooths such as shot clock or score margin) and
    [`shot_making()`](https://loukesio.github.io/ggbasket-site/reference/shot_making.md)
    (FG% over expected, shrunk, points added) with
    [`plot_shot_making()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_making.md).

### Ch. 4: Finding groups

- **k-means of teams** (`kclustering`). Variables are ratios such as
  F1.r = eFG_off/eFG_def. The number of clusters is chosen from the
  elbow of BD/TD increments, 10 random starts are used, and clusters are
  labelled by radial plots + CHI. With 30 teams and 7 variables, five
  clusters means ~6 teams each. Cluster membership is not checked for
  stability, and the order of clusters changes between runs (hence
  `set.seed(29)`). →
  [`cluster_quality()`](https://loukesio.github.io/ggbasket-site/reference/cluster_quality.md)
  (25 starts, silhouette as a second criterion) and
  [`plot_cluster_profiles()`](https://loukesio.github.io/ggbasket-site/reference/plot_cluster_profiles.md)
  (a heatmap of cluster means in SD with n, CHI and the most typical
  members named).
- **k-means of GSW shots** (points, distance, quarter time, play
  length). Clustering on **points scored** makes made/missed the
  dominant split. The book notices that four of six clusters are
  all-made or all-missed (p. 128) but doesn’t draw the conclusion: the
  outcome shouldn’t be a clustering input if the goal is to describe
  shot types.
- **Ward clustering of players**. Per-game totals over 1,500+ minutes
  make the groups reflect minutes and usage as much as style. Per-36 or
  per-100 rates, plus shot-diet shares, give style clusters. The gallery
  example (`16b_cluster_profiles`) does this.
- **FOCUS: new roles**. A good summary of Alagappan (TDA) and Bianchi et
  al. (SOM + fuzzy clustering). A natural modern extension is
  model-based clustering (Gaussian mixtures with uncertainty of
  membership) or a hierarchical Bayesian mixture.

### Ch. 5: Modelling relationships

- **Simple regression** (`simplereg`). TOV ~ AST and P3M ~ REB. The book
  correctly notes the violated assumptions (counts, negative
  predictions) and moves to LOESS. The useful output is the
  **residual**: who turns it over less than their assist load predicts.
  [`plot_fit()`](https://loukesio.github.io/ggbasket-site/reference/plot_fit.md)
  makes this the point by colouring by residual and naming the extremes.
- **Scoring probability and expected points** (`scoringprob`,
  `expectedpts`). Nadaraya–Watson Gaussian kernel smoothing over
  distance, play length, period time and total time. These are the
  book’s most basketball-relevant charts, but:
  1.  **There is no uncertainty.** Curve wiggles (e.g. “Draymond better
      in the second half”, the overtime bump in Fig. 5.8) may be noise.
  2.  **The kernel smooths across the 3-point line.** The jump in shot
      value becomes a fake ramp (Fig. 5.6 shows expected points rising
      smoothly from ~15 ft to a hump at ~28 ft).
  3.  **Bandwidths are chosen by eye** (`bw = 300`, `1200`, `1500`).
  4.  **Curves are drawn where there are almost no shots.** Fig. 5.6
      runs to 80 ft and dives to zero past half court.

  →
  [`shot_curve()`](https://loukesio.github.io/ggbasket-site/reference/shot_curve.md)
  adds bootstrap bands, `split_value = TRUE` (2s and 3s smoothed
  separately, keeping the discontinuity), a default bandwidth, and
  attempt density.
  [`plot_shot_curve()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_curve.md)
  maps density to line width, so thin line = few shots.
- **FOCUS: surface area dynamics** (Metulini et al.). Convex hull of 5
  players from 80 Hz GPS, a two-regime Markov-switching model and a VAR
  on points. This is interesting and needs tracking data the project
  doesn’t have. Kept as a pointer only.

### Ch. 6: The package

Good intentions: it works with ggplot objects and documents the data
contract. Problems in the code style that the book teaches: -
[`attach()`](https://rdrr.io/r/base/attach.html)/[`detach()`](https://rdrr.io/r/base/detach.html)
everywhere; - [`subset()`](https://rdrr.io/r/base/subset.html) with long
chains of `Player == "A" | Player == "B"`; - magic numbers
(`original_y/10 - 41.75`); - capitalised mixed-case column names (`P2p`
is a percentage in some tables and a proportion in others).

ggbasket uses lower-case columns, an `o_` prefix for opponents, metres
from the hoop, and `as_ggbasket_*()` converters so every book example
still runs.

------------------------------------------------------------------------

## 3. Problems that run through the whole book

1.  **Uncertainty is never shown.** No interval or band appears on any
    percentage, Gini, cluster mean, kernel curve or correlation
    difference. The text often then says “rather weak evidence”. The fix
    is simple: bootstrap bands, beta-binomial intervals and, for this
    project, Bayesian posteriors.
2.  **Small samples are taken at face value.** Shrinkage (empirical
    Bayes or hierarchical) is the standard remedy and fits the project’s
    brms/Stan goal.
3.  **Everything is relative to the analysed subset.** Four-factor
    differences from 4 teams, radial plots standardised over 9 point
    guards, η² on 30 teams. Comparisons should be relative to the league
    (or position), with the subset highlighted inside it.
4.  **Per-minute, not per-possession.** Player rates are per minute, so
    pace differences leak in. That matters for NBA vs EuroLeague
    comparisons (40 vs 48 minutes, different pace).
5.  **One team, one season, one league.** The book raises “space
    generalizability” (NBA ≠ Europe, p. 6) but never tests it. The NBA
    vs EuroLeague project does exactly that.
6.  **Graphics.** Some figures here make one or more of these mistakes:
    - rainbow or red–green palettes;
    - dual axes;
    - legends where direct labels would work;
    - case numbers as labels;
    - 9-panel radial grids;
    - default ggplot grey;
    - court sectors that ignore court lines.

    ggbasket’s rules:
    - lead with the story (title as finding, subtitle as encoding);
    - put the subject in context (grey league, coloured subject);
    - label directly;
    - use one diverging scale where red = better than average;
    - encode volume in size or line width so the eye goes where the data
      is.
7.  **Causal language from observational splits.** On/off assist
    networks, top vs bottom opponents, playoff vs non-playoff
    correlations. These are fine as descriptions and should be framed as
    such (or adjusted for lineup and opponent with a model).

------------------------------------------------------------------------

## 4. From BasketballAnalyzeR to ggbasket

| BasketballAnalyzeR | ggbasket | Main change |
|----|----|----|
| `fourfactors()` + [`plot()`](https://rdrr.io/r/graphics/plot.default.html) | [`four_factors()`](https://loukesio.github.io/ggbasket-site/reference/four_factors.md), [`plot_ratings()`](https://loukesio.github.io/ggbasket-site/reference/plot_ratings.md), [`plot_four_factors()`](https://loukesio.github.io/ggbasket-site/reference/plot_four_factors.md) | league context, net-rating map, FIBA pace |
| `barline()` | [`plot_ranked()`](https://loukesio.github.io/ggbasket-site/reference/plot_ranked.md) | no dual axis |
| `radialprofile()` | `plot_profile(style = "bars" / "radar")` | percentiles in a reference group |
| `scatterplot()`, `bubbleplot()` | [`plot_quadrant()`](https://loukesio.github.io/ggbasket-site/reference/plot_quadrant.md), [`plot_fit()`](https://loukesio.github.io/ggbasket-site/reference/plot_fit.md), [`plot_corr_matrix()`](https://loukesio.github.io/ggbasket-site/reference/plot_corr_matrix.md) | direct labels, residual story, Holm-adjusted significance |
| `variability()` | [`plot_spread()`](https://loukesio.github.io/ggbasket-site/reference/plot_spread.md), [`shrink_rate()`](https://loukesio.github.io/ggbasket-site/reference/shrink_rate.md) | shrinkage of small samples |
| `inequality()` | [`lorenz()`](https://loukesio.github.io/ggbasket-site/reference/gini.md), [`gini()`](https://loukesio.github.io/ggbasket-site/reference/gini.md), [`plot_lorenz()`](https://loukesio.github.io/ggbasket-site/reference/plot_lorenz.md) | all teams in one panel |
| `shotchart()` | [`plot_shot_zones()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_zones.md), [`plot_shot_hex()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_hex.md), [`plot_shot_density()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_density.md), [`geom_court()`](https://loukesio.github.io/ggbasket-site/reference/geom_court.md), [`shot_zone()`](https://loukesio.github.io/ggbasket-site/reference/shot_zone.md) | real zones, NBA + FIBA, vs-league colour, metres |
| `densityplot()`, `scoringprob()`, `expectedpts()` | [`shot_curve()`](https://loukesio.github.io/ggbasket-site/reference/shot_curve.md), [`plot_shot_curve()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_curve.md) | bootstrap bands, split at the 3-point line, density as line width |
| CART shot-making (FOCUS 3.6) | [`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md), [`shot_making()`](https://loukesio.github.io/ggbasket-site/reference/shot_making.md), [`plot_shot_making()`](https://loukesio.github.io/ggbasket-site/reference/plot_shot_making.md) | GAM expected FG%, shrunk FG% over expected |
| `corranalysis()` | [`plot_corr_matrix()`](https://loukesio.github.io/ggbasket-site/reference/plot_corr_matrix.md) | clustered order, Holm |
| `MDSmap()` | [`plot_similarity_map()`](https://loukesio.github.io/ggbasket-site/reference/plot_similarity_map.md) | biplot arrows instead of level plots |
| `kclustering()`, `hclustering()` | [`cluster_quality()`](https://loukesio.github.io/ggbasket-site/reference/cluster_quality.md), [`plot_cluster_quality()`](https://loukesio.github.io/ggbasket-site/reference/cluster_quality.md), [`plot_cluster_profiles()`](https://loukesio.github.io/ggbasket-site/reference/plot_cluster_profiles.md) | silhouette, one heatmap with typical members |
| `assistnet()` | [`assist_network()`](https://loukesio.github.io/ggbasket-site/reference/assist_network.md), [`plot_assist_network()`](https://loukesio.github.io/ggbasket-site/reference/plot_assist_network.md), [`plot_assist_matrix()`](https://loukesio.github.io/ggbasket-site/reference/plot_assist_matrix.md) | stable layout, matrix view |
| `PbPmanipulation()` + manual rescaling | `as_ggbasket_teams/players/shots()` | converters into one convention |
| Cramer’s V, eta-squared (Sec. 3.1, no BAR function) | [`association()`](https://loukesio.github.io/ggbasket-site/reference/association.md), [`plot_association()`](https://loukesio.github.io/ggbasket-site/reference/plot_association.md) | all three indices on one 0-1 heatmap, index named in each cell |
| Assist Gini per player (Sec. 3.4) | [`assist_network()`](https://loukesio.github.io/ggbasket-site/reference/assist_network.md) (`ast_gini`, `recv_gini`, `partners`), [`plot_assist_roles()`](https://loukesio.github.io/ggbasket-site/reference/plot_assist_roles.md) | hub vs two-man-game map |
| Joint density (Sec. 3.5.3, `ggpairs`) | [`plot_joint()`](https://loukesio.github.io/ggbasket-site/reference/plot_joint.md) | filled 2-D density + marginals + labelled players |
| High-pressure CART (Sec. 3.6) | [`pressure_situations()`](https://loukesio.github.io/ggbasket-site/reference/pressure_situations.md), [`pressure_effects()`](https://loukesio.github.io/ggbasket-site/reference/pressure_effects.md), [`plot_pressure()`](https://loukesio.github.io/ggbasket-site/reference/plot_pressure.md) | logistic model with expected FG% offset, effects in percentage points with intervals; shot clock estimated from play-by-play |
| *(not in the book)* | [`player_rates()`](https://loukesio.github.io/ggbasket-site/reference/player_rates.md), [`expected_wins()`](https://loukesio.github.io/ggbasket-site/reference/expected_wins.md), [`plot_luck()`](https://loukesio.github.io/ggbasket-site/reference/plot_luck.md) | TS%, usage, AST%, rebound/steal/block/turnover rates; Pythagorean wins and luck |

Not covered: the GPS/convex-hull spacing analysis of Section 5.3 (needs
player-tracking data) and the self-organising-map / topological roles
mentioned in Chapter 4 (a mixture model, Section 5 below, is the better
tool).

------------------------------------------------------------------------

## 5. Where to take it next (Bayesian, to match the project’s learning goal)

1.  **Hierarchical shooting.** `made ~ 1 + (1 | player)` per zone with
    brms (beta-binomial or logit). This is the full-Bayes version of
    [`shrink_rate()`](https://loukesio.github.io/ggbasket-site/reference/shrink_rate.md).
    Posterior intervals then show on every percentage and zone chart.
2.  **xFG with a shooter effect.**
    `made ~ s(dist, angle, by = league) + (1 | player) + (1 | defender_team)`.
    The player random effect *is* shot-making over expected, with honest
    uncertainty. It replaces the book’s CART + P_i.
3.  **Shot surface per league.** A 2-D Gaussian-process or `t2()` tensor
    smooth of FG% over the court, NBA vs EuroLeague. RQ1 already does a
    version.
4.  **Uncertain clusters.** A Gaussian mixture in brms/Stan (or
    `mclust`) gives each player a membership probability (“60% stretch
    big, 40% wing”), which is what the book’s FOCUS on new roles wants.
5.  **Lead-lag style.** Combine
    [`plot_profile()`](https://loukesio.github.io/ggbasket-site/reference/plot_profile.md)
    percentiles with the RQ4 “ahead of their time” smoothed path.

------------------------------------------------------------------------

## 6. Book figures next to their ggbasket counterparts

The book’s figures (`man/figures/book/`, NBA 2017/18, drawn with
BasketballAnalyzeR by `gallery/book/make_before.R`) next to the ggbasket
figures that answer the same question on 2024/25 data.

| Book (BasketballAnalyzeR) | ggbasket |
|----|----|
| ![book figure: ratings](reference/figures/book/01_ratings.png) | ![gallery figure: ratings](reference/figures/gallery/13_ratings.png) |
| ![book figure: fourfactors](reference/figures/book/02_fourfactors.png) | ![gallery figure: four factors](reference/figures/gallery/14_four_factors.png) |
| ![book figure: lorenz](reference/figures/book/03_lorenz.png) | ![gallery figure: lorenz](reference/figures/gallery/16_lorenz.png) |
| ![book figure: profile](reference/figures/book/04_profile.png) | ![gallery figure: profile](reference/figures/gallery/17_profile.png) |
| ![book figure: quadrant](reference/figures/book/05_quadrant.png) | ![gallery figure: quadrant](reference/figures/gallery/19_quadrant.png) |
| ![book figure: spread](reference/figures/book/06_spread.png) | ![gallery figure: spread](reference/figures/gallery/22_spread.png) |
| ![book figure: ranked](reference/figures/book/07_ranked.png) | ![gallery figure: ranked](reference/figures/gallery/23_ranked.png) |
| ![book figure: shots](reference/figures/book/08_shots.png) | ![gallery figure: shot hex](reference/figures/gallery/28_shot_hex.png)![gallery figure: shot zones](reference/figures/gallery/29_shot_zones.png) |
| ![book figure: density](reference/figures/book/10_density.png) | ![gallery figure: density](reference/figures/gallery/31_density.png) |
| ![book figure: curve](reference/figures/book/11_curve.png) | ![gallery figure: curve leagues](reference/figures/gallery/32_curve_leagues.png)![gallery figure: shot clock](reference/figures/gallery/12_shot_clock.png) |
| ![book figure: corr](reference/figures/book/13_corr.png) | ![gallery figure: corr](reference/figures/gallery/24_corr.png)![gallery figure: fit](reference/figures/gallery/21_fit.png) |
| ![book figure: map](reference/figures/book/15_map.png) | ![gallery figure: map](reference/figures/gallery/25_map.png) |
| ![book figure: clusters](reference/figures/book/16_clusters.png) | ![gallery figure: cluster quality](reference/figures/gallery/26_cluster_quality.png)![gallery figure: cluster profiles](reference/figures/gallery/27_cluster_profiles.png) |
| ![book figure: network](reference/figures/book/17_network.png) | ![gallery figure: assist network](reference/figures/gallery/07_assist_network.png)![gallery figure: assist matrix](reference/figures/gallery/08_assist_matrix.png)![gallery figure: assist roles](reference/figures/gallery/09_assist_roles.png) |
| *(CART tables, Section 3.6)* | ![gallery figure: pressure](reference/figures/gallery/10_pressure.png)![gallery figure: association](reference/figures/gallery/11_association.png) |
