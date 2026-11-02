# ggbasket

**Learn from basketball games, NBA and EuroLeague.** ggbasket reads play-by-play, box-score and shot data
from both leagues into one layout, computes the measures analysts use (win probability, on/off, four
factors, shot quality, pressure) and draws each answer as a finished, story-first ggplot2 figure.

```r
devtools::install("ggbasket")   # from the project root
library(ggbasket)

# one game: the 2025 NBA Finals Game 7 is bundled
plot_game_flow(pbp_games, "401766128")
plot_win_probability(win_probability(pbp_games), "401766128")
box_score(pbp_games)                        # player box score with minutes and plus-minus

# a whole season, either league
nba <- pbp_from_espn(hoopR::load_nba_pbp(seasons = 2025))   # ESPN, via hoopR
el  <- fetch_euroleague_pbp(season = 2024)                  # official EuroLeague API, with shot locations
on_off(el, team = "PAN")
```

## What you can learn from a game

| Question | Functions |
|---|---|
| How did the game unfold? Who made the runs? | `game_flow()`, `scoring_runs()`, `plot_game_flow()` |
| Which plays decided it? | `win_probability()`, `plot_win_probability()` |
| Why did the winner win: shooting, turnovers, rebounds or free throws? | `game_factors()`, `plot_game_factors()` |
| Was it a classic? | `game_summary()`: lead changes, biggest leads, best run, excitement, comeback |
| Who played well? | `box_score()`, `game_score()` |


## What you can learn from many games

| Question | Functions |
|---|---|
| Is the team better with this player on the floor? Which line-ups work? | `stints()`, `on_off()`, `lineups()`, `plot_on_off()` |
| Who can you count on every night? | `game_score()`, `plot_consistency()` |
| Who performs when it is close? | `clutch_time()` + any other function |
| Who creates for whom? | `assist_network()`, `plot_assist_network()`, `plot_assist_matrix()`, `plot_assist_roles()` |
| Does pressure (shot clock, score, streaks, end of period) change shooting? | `pressure_situations()`, `pressure_effects()`, `plot_pressure()` |
| How does a shot's value change with distance or shot clock? | `shot_curve()`, `plot_shot_curve()` |


## Teams, players and shots

| Topic | Metrics | Plots |
|---|---|---|
| Teams | `possessions()`, `four_factors()`, `expected_wins()`, `gini()`, `lorenz()` | `plot_ratings()`, `plot_four_factors()`, `plot_luck()`, `plot_lorenz()` |
| Players | `player_rates()` (TS%, usage, AST%, rebound, steal, block and turnover rates), `percentile_rank()`, `shrink_rate()` | `plot_profile()`, `plot_quadrant()`, `plot_joint()`, `plot_fit()`, `plot_spread()`, `plot_ranked()` |
| Shots | `shot_zone()`, `summarise_zones()`, `bin_shots_hex()`, `expected_fg()`, `shot_making()` | `plot_shot_hex()`, `plot_shot_zones()`, `plot_shot_density()`, `plot_shot_making()` |
| Patterns | `association()`, `cluster_quality()` | `plot_association()`, `plot_corr_matrix()`, `plot_similarity_map()`, `plot_cluster_quality()`, `plot_cluster_profiles()` |
| Courts and style | `court_spec()`, `court_lines()`, `ggbasket_fonts()` | `geom_court()` (NBA and FIBA), `theme_ggbasket()`, `theme_court()`, `colour_text()`, `ggbasket_caption()` |

## Gallery

Every figure below comes from real 2024/25 NBA and EuroLeague data; `Rscript gallery/make_gallery.R` redraws
them all.

### One game

| | |
|---|---|
| **Game flow.** The lead through Game 7 of the 2025 NBA Finals, with scoring runs. `plot_game_flow()` | **Win probability.** The season's wildest game, with the plays that swung it. `plot_win_probability()` |
| ![](gallery/figures/01_game_flow.png) | ![](gallery/figures/03_win_probability.png) |
| **Why they won.** Game 7's margin split into the four factors. `plot_game_factors()` | **A EuroLeague final.** Monaco against Fenerbahce, 2025. `plot_game_flow()` |
| ![](gallery/figures/04_game_factors.png) | ![](gallery/figures/02_game_flow_el.png) |
| **Every shot of a game.** Shot heatmap and makes and misses for both finalists. `plot_shot_density(points = TRUE)` | |
| ![](gallery/figures/37_game_shots.png) | |

### A season of games

| | |
|---|---|
| **On/off.** Denver with and without each player. `plot_on_off()` | **Consistency.** Every game of eight stars. `plot_consistency()` |
| ![](gallery/figures/05_on_off.png) | ![](gallery/figures/06_consistency.png) |
| **Assist network.** Who passes to whom in Denver. `plot_assist_network()` | **Passer to scorer.** The same network as a matrix. `plot_assist_matrix()` |
| ![](gallery/figures/07_assist_network.png) | ![](gallery/figures/08_assist_matrix.png) |
| **Hubs and two-man games.** `plot_assist_roles()` | **Pressure.** What changes the chance a shot goes in. `plot_pressure()` |
| ![](gallery/figures/09_assist_roles.png) | ![](gallery/figures/10_pressure.png) |
| **What goes with what.** Association between shot situations. `plot_association()` | **Shot clock.** Value of a shot as the clock runs down, both leagues. `plot_shot_curve()` |
| ![](gallery/figures/11_association.png) | ![](gallery/figures/12_shot_clock.png) |

### Shots on the court

| | |
|---|---|
| **Hexagons.** Four NBA stars: where they shoot and how well. `plot_shot_hex()` | **Hexagons, EuroLeague.** Four EuroLeague scorers. `plot_shot_hex()` |
| ![](gallery/figures/28_shot_hex.png) | ![](gallery/figures/34_hex_el.png) |
| **Zones.** Jokic by court zone against the league. `plot_shot_zones()` | **Zones on a FIBA court.** Vezenkov. `plot_shot_zones()` |
| ![](gallery/figures/29_shot_zones.png) | ![](gallery/figures/30_shot_zones_el.png) |
| **Shot diet.** Curry and Giannis against the average player. `plot_shot_density()` | **League against league.** EuroLeague shot locations against the NBA's. `plot_shot_density()` |
| ![](gallery/figures/31_density.png) | ![](gallery/figures/35_density_leagues.png) |
| **Team against team.** Olympiacos and Panathinaikos. `plot_shot_density()` | **Distance.** Expected points by distance, both leagues. `plot_shot_curve()` |
| ![](gallery/figures/36_density_teams.png) | ![](gallery/figures/32_curve_leagues.png) |
| **Shot-making.** Who beats the expected FG% of their shots. `plot_shot_making()` | |
| ![](gallery/figures/33_shot_making.png) | |

### Teams

| | |
|---|---|
| **Ratings map.** Offence against defence, both leagues. `plot_ratings()` | **Four factors.** The 2025 EuroLeague Final Four. `plot_four_factors()` |
| ![](gallery/figures/13_ratings.png) | ![](gallery/figures/14_four_factors.png) |
| **Luck.** Actual against Pythagorean wins. `plot_luck()` | **Scoring concentration.** Lorenz curves per team. `plot_lorenz()` |
| ![](gallery/figures/15_luck.png) | ![](gallery/figures/16_lorenz.png) |

### Players

| | |
|---|---|
| **Fingerprints.** Percentiles on nine stats. `plot_profile()` | **The same fingerprints as radars.** `plot_profile(style = "radar")` |
| ![](gallery/figures/17_profile.png) | ![](gallery/figures/18_profile_radar.png) |
| **Quadrants.** Assists against turnovers. `plot_quadrant()` | **Joint density.** Usage against efficiency. `plot_joint()` |
| ![](gallery/figures/19_quadrant.png) | ![](gallery/figures/20_joint.png) |
| **Above or below the line.** Turnovers for the assist load. `plot_fit()` | **Spread within a team.** OKC's shooting. `plot_spread()` |
| ![](gallery/figures/21_fit.png) | ![](gallery/figures/22_spread.png) |
| **Ranked bars.** OKC's shot diet by plus-minus. `plot_ranked()` | **Correlations.** What goes together in a stat line. `plot_corr_matrix()` |
| ![](gallery/figures/23_ranked.png) | ![](gallery/figures/24_corr.png) |
| **Similarity map.** The NBA in two dimensions. `plot_similarity_map()` | **How many player types?** `plot_cluster_quality()` |
| ![](gallery/figures/25_map.png) | ![](gallery/figures/26_cluster_quality.png) |
| **Seven kinds of player.** `plot_cluster_profiles()` | |
| ![](gallery/figures/27_cluster_profiles.png) | |

## Data

* **Play-by-play**: `pbp_from_espn()` (NBA via hoopR), `pbp_from_euroleague()` / `fetch_euroleague_pbp()`
  (EuroLeague live API, shot locations joined in). Both give the same layout, documented in `?pbp`; the
  players on court are rebuilt from substitutions by `add_lineups()`. BasketballAnalyzeR's `PbP` also works,
  and `as_ggbasket_teams()`, `as_ggbasket_players()`, `as_ggbasket_shots()` convert its other tables.
* **Bundled**: `pbp_games` (2025 NBA Finals Game 7 and the 2025 EuroLeague final), `team_seasons`,
  `player_seasons`, `shots_2024` (2024/25 regular seasons). `data-raw/make_pbp.R` builds the two full
  seasons (1,321 NBA and 330 EuroLeague games).
* **Conventions**: lower-case box-score columns (`pts p2m p2a p3m p3a ftm fta orb drb ast tov stl blk pf`),
  opponent columns prefixed `o_`, shot `x`, `y` in metres from the hoop centre (y towards half court).

## Tested on real games

On the 2024/25 seasons:

* **NBA box scores are reproduced from play-by-play.** Season points, assists, rebounds, steals, blocks and
  turnovers match the official totals exactly. Every team-game adds up to 240 minutes. Game 7 gives
  OKC 103-91, SGA 29 points and 12 assists, and Indiana 23 turnovers.
* **EuroLeague** final scores match the API for all 330 games. 658 of 660 team-games add up to exactly
  200 minutes. Assists match once FIBA's free-throw assists are counted.
* **Win probability** is a two-parameter score model (Stern, 1994). Its spread is fitted by likelihood on
  every in-game situation. Held-out NBA games are calibrated to within about 5 percentage points. Home
  advantage is worth 3.3 points per game in the EuroLeague and 1.6 in the NBA.
* **Pressure**: with 2 seconds or less on the shot clock, shots go in about 7.5 percentage points less often
  in the NBA and 7.4 in the EuroLeague, after accounting for location. The score and hot or cold
  streaks make no measurable difference.

`R CMD check` passes, and the tests run on the bundled finals.

## Style

`theme_ggbasket()` follows Cedric Scherer's editorial look:

* a plain white background, and a "painted" court (cool-grey floor, blue-grey key, orange rim; `geom_court(style = )` also offers `"arena"` and `"minimal"`);
* a bold title that states the finding;
* a markdown subtitle that names groups in their own colour (`colour_text()`) instead of a legend;
* a monospaced "Data · Graphic" caption.

Fonts are Fira Sans, Fira Sans Condensed and Roboto Mono, all free on Google Fonts; if they are missing, the
system sans is used. Use `ggsave(..., device = cairo_pdf)` or PNG for the full look.

## Origins

ggbasket began as a redesign of the analyses in Zuccolotto & Manisera, *Basketball Data Science* (CRC 2020).
[`BOOK_REVIEW.md`](BOOK_REVIEW.md) holds that chapter-by-chapter critique and the book's figures next to
their ggbasket counterparts.
