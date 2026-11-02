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

## Case study: what can we learn from one game?

**Olympiacos 84-78 Olimpia Milano**, EuroLeague round 9, 30 October 2026. Everything below comes from
the game's play-by-play, downloaded with one call, and is redrawn by `Rscript gallery/make_case.R`.

```r
el <- fetch_euroleague_pbp(2026)            # the season so far, with shot locations
gm <- subset(el, game_id == "E2026_90")
```

**1. How did the game unfold?** The first half was a coin toss: 14 lead changes and 9 ties, with five runs
of six or more unanswered points. Milano led for the last time in the 21st minute. Olympiacos's biggest
run was 9-0 and their biggest lead 11; Milano never led by more than 3.

![case figure: flow](man/figures/case/01_flow.png)

**2. Which plays decided it?** Olympiacos were favourites from the third quarter on, up to 95% when they led
by 11. Milano's 7-0 run early in the fourth made it close again, and the biggest swings all came late:
* Jason Burnell's three made it 75-73 and took 18 points off Olympiacos's chances.
* Cory Joseph answered with a basket for 77-73 (+15).
* Leandro Bolmaro's three at 79-76 was Milano's last push.

![case figure: win probability](man/figures/case/02_win_probability.png)

**3. Why did Olympiacos win?** Not by shooting: Milano's effective field-goal percentage was higher
(66% against 64%). The margin came from possessions.
* **Turnovers:** Milano lost the ball 18 times against Olympiacos's 14 (26% of possessions against 20%),
  worth about +6.5 points.
* **Offensive rebounds:** Olympiacos grabbed 42% of their own misses against Milano's 33%, worth +3.4.
* **Free throws:** almost level (10 made against 11).

![case figure: factors](man/figures/case/03_factors.png)

**4. Was this a typical Olympiacos game?** No. Against their eight other games so far:
* It was their best shooting night (64% eFG) and the most turnovers they have forced (26%).
* It was also the best shooting they have allowed (66%), so the defence won the ball back rather than
  contesting shots.

![case figure: vs season](man/figures/case/04_vs_season.png)

**5. Who made the difference?** Codi Miller-McIntyre (24 points, 4 of 9 threes, +18 on the floor) and
Sasha Vezenkov (23 points, 8 of 10 twos) moved Olympiacos's win probability the most. Win probability added
counts a player's own plays and a fifth of every opponent play while they were on the floor. For Milano,
Moses Wright and Burnell added the most; RJ Cole scored 17 but was −10 on the floor.

![case figure: wpa](man/figures/case/05_wpa.png)

**6. Where did the shots come from?** Olympiacos attacked the paint: 37 twos at 68%, against Milano's 25.
Milano lived behind the arc and made more threes: 11 of 26 (42%), against Olympiacos's 8 of 21 (38%).

![case figure: shots](man/figures/case/06_shots.png)

**7. Who did Olympiacos play best with?** In this game, Olympiacos were best with Miller-McIntyre on the
floor. Over the nine games so far, Vezenkov is the steadiest player (median Game Score 15.5), and the team
is +21 per 100 possessions with Jean Montero on the floor against +2 without him. These are small
early-season samples, worth watching rather than concluding from.

| | |
|---|---|
| ![case figure: on off](man/figures/case/07_on_off.png) | ![case figure: consistency](man/figures/case/08_consistency.png) |

![case figure: on off season](man/figures/case/09_on_off_season.png)

**In one sentence:** Milano shot better, but Olympiacos won the possession battle. Four more turnovers forced
and three more offensive rebounds were worth about 10 points. Miller-McIntyre and Vezenkov turned those chances into points, and
Cory Joseph's basket at 77-73 settled a game that was level for its first 21 minutes.

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
| Teams | `possessions()`, `four_factors()`, `team_ratings()`, `team_shot_profile()`, `expected_wins()`, `gini()`, `lorenz()` | `plot_net_rating()`, `plot_factor_ranks()`, `plot_team_ratings()`, `plot_luck()`, `plot_lorenz()`, `plot_ratings()`, `plot_four_factors()` |
| Player impact | `rapm()`, `win_probability_added()`, `on_off()`, `lineups()` | `plot_rapm()`, `plot_wpa()`, `plot_on_off()`, `plot_lineups()` |
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
| ![gallery figure: game flow](man/figures/gallery/01_game_flow.png) | ![gallery figure: win probability](man/figures/gallery/03_win_probability.png) |
| **Why they won.** Game 7's margin split into the four factors. `plot_game_factors()` | **A EuroLeague final.** Monaco against Fenerbahce, 2025. `plot_game_flow()` |
| ![gallery figure: game factors](man/figures/gallery/04_game_factors.png) | ![gallery figure: game flow el](man/figures/gallery/02_game_flow_el.png) |
| **Every shot of a game.** Shot heatmap and makes and misses for both finalists. `plot_shot_density(points = TRUE)` | |
| ![gallery figure: game shots](man/figures/gallery/37_game_shots.png) | |

### A season of games

| | |
|---|---|
| **On/off.** Denver with and without each player. `plot_on_off()` | **Consistency.** Every game of eight stars. `plot_consistency()` |
| ![gallery figure: on off](man/figures/gallery/05_on_off.png) | ![gallery figure: consistency](man/figures/gallery/06_consistency.png) |
| **Assist network.** Who passes to whom in Denver. `plot_assist_network()` | **Passer to scorer.** The same network as a matrix. `plot_assist_matrix()` |
| ![gallery figure: assist network](man/figures/gallery/07_assist_network.png) | ![gallery figure: assist matrix](man/figures/gallery/08_assist_matrix.png) |
| **Hubs and two-man games.** `plot_assist_roles()` | **Pressure.** What changes the chance a shot goes in. `plot_pressure()` |
| ![gallery figure: assist roles](man/figures/gallery/09_assist_roles.png) | ![gallery figure: pressure](man/figures/gallery/10_pressure.png) |
| **What goes with what.** Association between shot situations. `plot_association()` | **Shot clock.** Value of a shot as the clock runs down, both leagues. `plot_shot_curve()` |
| ![gallery figure: association](man/figures/gallery/11_association.png) | ![gallery figure: shot clock](man/figures/gallery/12_shot_clock.png) |

### Shots on the court

| | |
|---|---|
| **Hexagons.** Four NBA stars: where they shoot and how well. `plot_shot_hex()` | **Hexagons, EuroLeague.** Four EuroLeague scorers. `plot_shot_hex()` |
| ![gallery figure: shot hex](man/figures/gallery/28_shot_hex.png) | ![gallery figure: hex el](man/figures/gallery/34_hex_el.png) |
| **Zones.** Jokic by court zone against the league. `plot_shot_zones()` | **Zones on a FIBA court.** Vezenkov. `plot_shot_zones()` |
| ![gallery figure: shot zones](man/figures/gallery/29_shot_zones.png) | ![gallery figure: shot zones el](man/figures/gallery/30_shot_zones_el.png) |
| **Shot diet.** Curry and Giannis against the average player. `plot_shot_density()` | **League against league.** EuroLeague shot locations against the NBA's. `plot_shot_density()` |
| ![gallery figure: density](man/figures/gallery/31_density.png) | ![gallery figure: density leagues](man/figures/gallery/35_density_leagues.png) |
| **Team against team.** Olympiacos and Panathinaikos. `plot_shot_density()` | **Distance.** Expected points by distance, both leagues. `plot_shot_curve()` |
| ![gallery figure: density teams](man/figures/gallery/36_density_teams.png) | ![gallery figure: curve leagues](man/figures/gallery/32_curve_leagues.png) |
| **Shot-making.** Who beats the expected FG% of their shots. `plot_shot_making()` | **Play length.** Expected points by how long the play has run, OKC. `plot_shot_curve()` |
| ![gallery figure: shot making](man/figures/gallery/33_shot_making.png) | ![gallery figure: curve playlength](man/figures/gallery/32b_curve_playlength.png) |

### Teams

| | |
|---|---|
| **Where net rating comes from.** EuroLeague teams split into offence and defence. `plot_net_rating()` | **The same for the NBA.** OKC's defence was the league's best. `plot_net_rating()` |
| ![gallery figure: ratings](man/figures/gallery/13_ratings.png) | ![gallery figure: ratings nba](man/figures/gallery/13b_ratings_nba.png) |
| **Offence against defence map.** Every team as a dot, both leagues. `plot_ratings()` | **Four factors against the whole league.** Final Four teams on every team's spread. `plot_four_factors()` |
| ![gallery figure: ratings map](man/figures/gallery/13c_ratings_map.png) | ![gallery figure: four factors spread](man/figures/gallery/14b_four_factors_spread.png) |
| **Four factors as a ranking table.** The 2025 EuroLeague Final Four. `plot_factor_ranks()` | **Schedule-adjusted ratings.** Simple Rating System with home advantage, both leagues. `team_ratings()`, `plot_team_ratings()` |
| ![gallery figure: four factors](man/figures/gallery/14_four_factors.png) | ![gallery figure: team ratings](man/figures/gallery/38_team_ratings.png) |
| **Transition.** How often teams run, and how well. `team_shot_profile()` + `plot_quadrant()` | **Shot quality.** Expected value of shots taken and allowed (EuroLeague). `team_shot_profile()` |
| ![gallery figure: transition](man/figures/gallery/43_transition.png) | ![gallery figure: shot quality](man/figures/gallery/44_shot_quality.png) |
| **Luck.** Actual against Pythagorean wins. `plot_luck()` | **Scoring concentration.** Lorenz curves per team. `plot_lorenz()` |
| ![gallery figure: luck](man/figures/gallery/15_luck.png) | ![gallery figure: lorenz](man/figures/gallery/16_lorenz.png) |

### Player impact

| | |
|---|---|
| **Adjusted plus-minus, NBA.** Ridge regression on every line-up stint. `rapm()`, `plot_rapm()` | **Adjusted plus-minus, EuroLeague.** `rapm()`, `plot_rapm()` |
| ![gallery figure: rapm](man/figures/gallery/39_rapm.png) | ![gallery figure: rapm el](man/figures/gallery/40_rapm_el.png) |
| **Win probability added.** Who moved Game 7, defence included. `win_probability_added()`, `plot_wpa()` | **Line-ups.** OKC's five-player units by net rating. `lineups()`, `plot_lineups()` |
| ![gallery figure: wpa](man/figures/gallery/41_wpa.png) | ![gallery figure: lineups](man/figures/gallery/42_lineups.png) |

### Players

| | |
|---|---|
| **Fingerprints.** Percentiles on nine stats. `plot_profile()` | **The same fingerprints as radars.** `plot_profile(style = "radar")` |
| ![gallery figure: profile](man/figures/gallery/17_profile.png) | ![gallery figure: profile radar](man/figures/gallery/18_profile_radar.png) |
| **Quadrants.** Assists against turnovers. `plot_quadrant()` | **Joint density.** Usage against efficiency. `plot_joint()` |
| ![gallery figure: quadrant](man/figures/gallery/19_quadrant.png) | ![gallery figure: joint](man/figures/gallery/20_joint.png) |
| **Above or below the line.** Turnovers for the assist load. `plot_fit()` | **Spread within a team.** OKC's shooting. `plot_spread()` |
| ![gallery figure: fit](man/figures/gallery/21_fit.png) | ![gallery figure: spread](man/figures/gallery/22_spread.png) |
| **Ranked bars.** OKC's shot diet by plus-minus. `plot_ranked()` | **Correlations.** What goes together in a stat line. `plot_corr_matrix()` |
| ![gallery figure: ranked](man/figures/gallery/23_ranked.png) | ![gallery figure: corr](man/figures/gallery/24_corr.png) |
| **Similarity map.** The NBA in two dimensions. `plot_similarity_map()` | **How many player types?** `plot_cluster_quality()` |
| ![gallery figure: map](man/figures/gallery/25_map.png) | ![gallery figure: cluster quality](man/figures/gallery/26_cluster_quality.png) |
| **Seven kinds of player.** `plot_cluster_profiles()` | |
| ![gallery figure: cluster profiles](man/figures/gallery/27_cluster_profiles.png) | |

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

* a plain white background; colours from the `heatmap1` and `minou` palettes of [ltc](https://github.com/loukesio/ltc-color-palettes); and a "painted" court (cool-grey floor, blue-grey key, orange rim; `geom_court(style = )` also offers `"arena"` and `"minimal"`);
* a bold title that states the finding;
* a markdown subtitle that names groups in their own colour (`colour_text()`) instead of a legend;
* a monospaced "Data · Graphic" caption.

Fonts are Fira Sans, Fira Sans Condensed and Roboto Mono, all free on Google Fonts; if they are missing, the
system sans is used. Use `ggsave(..., device = cairo_pdf)` or PNG for the full look.

## Origins

ggbasket began as a redesign of the analyses in Zuccolotto & Manisera, *Basketball Data Science* (CRC 2020).
[`BOOK_REVIEW.md`](BOOK_REVIEW.md) holds that chapter-by-chapter critique and the book's figures next to
their ggbasket counterparts.
