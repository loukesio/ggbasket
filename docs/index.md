# ggbasket

**Learn from basketball games, NBA and EuroLeague.** ggbasket reads
play-by-play, box-score and shot data from both leagues into one layout,
computes the measures analysts use (win probability, on/off, four
factors, shot quality, pressure) and draws each answer as a finished,
story-first ggplot2 figure.

\
`devtools``::`[`install`](https://devtools.r-lib.org/reference/install.html)`(``"ggbasket"``)``   ``# from the project root`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggbasket`](https://loukesio.github.io/ggbasket/)`)`\
\
`# one game: the 2025 NBA Finals Game 7 is bundled`\
[`plot_game_flow`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md)`(``pbp_games``, ``"401766128"``)`\
[`plot_win_probability`](https://loukesio.github.io/ggbasket/reference/plot_win_probability.md)`(`[`win_probability`](https://loukesio.github.io/ggbasket/reference/win_probability.md)`(``pbp_games``)``, ``"401766128"``)`\
[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(``pbp_games``)``                        ``# player box score with minutes and plus-minus`\
\
`# a whole season, either league`\
`nba`` ``<-`` `[`pbp_from_espn`](https://loukesio.github.io/ggbasket/reference/pbp.md)`(``hoopR``::`[`load_nba_pbp`](https://hoopR.sportsdataverse.org/reference/load_nba_pbp.html)`(``seasons ``=`` ``2025``)``)``   ``# ESPN, via hoopR`\
`el``  ``<-`` `[`fetch_euroleague_pbp`](https://loukesio.github.io/ggbasket/reference/pbp.md)`(``season ``=`` ``2024``)``                  ``# official EuroLeague API, with shot locations`\
[`on_off`](https://loukesio.github.io/ggbasket/reference/on_off.md)`(``el``, team ``=`` ``"PAN"``)`

## Case study: what can we learn from one game?

**Olympiacos 84-78 Olimpia Milano**, EuroLeague round 9, 30 October
2026. Everything below comes from the game’s play-by-play, downloaded
with one call, and is redrawn by `Rscript gallery/make_case.R`.

\
`el`` ``<-`` `[`fetch_euroleague_pbp`](https://loukesio.github.io/ggbasket/reference/pbp.md)`(``2026``)``            ``# the season so far, with shot locations`\
`gm`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``el``, ``game_id`` ``==`` ``"E2026_90"``)`

**1. How did the game unfold?** The first half was a coin toss: 14 lead
changes and 9 ties, with five runs of six or more unanswered points.
Milano led for the last time in the 21st minute. Olympiacos’s biggest
run was 9-0 and their biggest lead 11; Milano never led by more than 3.

![](reference/figures/case/01_flow.png)

**2. Which plays decided it?** Olympiacos were favourites from the third
quarter on, up to 95% when they led by 11. Milano’s 7-0 run early in the
fourth made it close again, and the biggest swings all came late: \*
Jason Burnell’s three made it 75-73 and took 18 points off Olympiacos’s
chances. \* Cory Joseph answered with a basket for 77-73 (+15). \*
Leandro Bolmaro’s three at 79-76 was Milano’s last push.

![](reference/figures/case/02_win_probability.png)

**3. Why did Olympiacos win?** Not by shooting: Milano’s effective
field-goal percentage was higher (66% against 64%). The margin came from
possessions. \* **Turnovers:** Milano lost the ball 18 times against
Olympiacos’s 14 (26% of possessions against 20%), worth about +6.5
points. \* **Offensive rebounds:** Olympiacos grabbed 42% of their own
misses against Milano’s 33%, worth +3.4. \* **Free throws:** almost
level (10 made against 11).

![](reference/figures/case/03_factors.png)

**4. Was this a typical Olympiacos game?** No. Against their eight other
games so far: \* It was their best shooting night (64% eFG) and the most
turnovers they have forced (26%). \* It was also the best shooting they
have allowed (66%), so the defence won the ball back rather than
contesting shots.

![](reference/figures/case/04_vs_season.png)

**5. Who made the difference?** Codi Miller-McIntyre (24 points, 4 of 9
threes, +18 on the floor) and Sasha Vezenkov (23 points, 8 of 10 twos)
moved Olympiacos’s win probability the most. Win probability added
counts a player’s own plays and a fifth of every opponent play while
they were on the floor. For Milano, Moses Wright and Burnell added the
most; RJ Cole scored 17 but was −10 on the floor.

![](reference/figures/case/05_wpa.png)

**6. Where did the shots come from?** Olympiacos attacked the paint: 37
twos at 68%, against Milano’s 25. Milano lived behind the arc and made
more threes: 11 of 26 (42%), against Olympiacos’s 8 of 21 (38%).

![](reference/figures/case/06_shots.png)

**7. Who did Olympiacos play best with?** In this game, Olympiacos were
best with Miller-McIntyre on the floor. Over the nine games so far,
Vezenkov is the steadiest player (median Game Score 15.5), and the team
is +21 per 100 possessions with Jean Montero on the floor against +2
without him. These are small early-season samples, worth watching rather
than concluding from.

|  |  |
|----|----|
| ![](reference/figures/case/07_on_off.png) | ![](reference/figures/case/08_consistency.png) |

![](reference/figures/case/09_on_off_season.png)

**In one sentence:** Milano shot better, but Olympiacos won the
possession battle. Four more turnovers forced and three more offensive
rebounds were worth about 10 points. Miller-McIntyre and Vezenkov turned
those chances into points, and Cory Joseph’s basket at 77-73 settled a
game that was level for its first 21 minutes.

## What you can learn from a game

| Question | Functions |
|----|----|
| How did the game unfold? Who made the runs? | [`game_flow()`](https://loukesio.github.io/ggbasket/reference/game_flow.md), [`scoring_runs()`](https://loukesio.github.io/ggbasket/reference/scoring_runs.md), [`plot_game_flow()`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md) |
| Which plays decided it? | [`win_probability()`](https://loukesio.github.io/ggbasket/reference/win_probability.md), [`plot_win_probability()`](https://loukesio.github.io/ggbasket/reference/plot_win_probability.md) |
| Why did the winner win: shooting, turnovers, rebounds or free throws? | [`game_factors()`](https://loukesio.github.io/ggbasket/reference/game_factors.md), [`plot_game_factors()`](https://loukesio.github.io/ggbasket/reference/plot_game_factors.md) |
| Was it a classic? | [`game_summary()`](https://loukesio.github.io/ggbasket/reference/game_summary.md): lead changes, biggest leads, best run, excitement, comeback |
| Who played well? | [`box_score()`](https://loukesio.github.io/ggbasket/reference/box_score.md), [`game_score()`](https://loukesio.github.io/ggbasket/reference/game_score.md) |

## What you can learn from many games

| Question | Functions |
|----|----|
| Is the team better with this player on the floor? Which line-ups work? | [`stints()`](https://loukesio.github.io/ggbasket/reference/stints.md), [`on_off()`](https://loukesio.github.io/ggbasket/reference/on_off.md), [`lineups()`](https://loukesio.github.io/ggbasket/reference/lineups.md), [`plot_on_off()`](https://loukesio.github.io/ggbasket/reference/plot_on_off.md) |
| Who can you count on every night? | [`game_score()`](https://loukesio.github.io/ggbasket/reference/game_score.md), [`plot_consistency()`](https://loukesio.github.io/ggbasket/reference/plot_consistency.md) |
| Who performs when it is close? | [`clutch_time()`](https://loukesio.github.io/ggbasket/reference/clutch_time.md) + any other function |
| Who creates for whom? | [`assist_network()`](https://loukesio.github.io/ggbasket/reference/assist_network.md), [`plot_assist_network()`](https://loukesio.github.io/ggbasket/reference/plot_assist_network.md), [`plot_assist_matrix()`](https://loukesio.github.io/ggbasket/reference/plot_assist_matrix.md), [`plot_assist_roles()`](https://loukesio.github.io/ggbasket/reference/plot_assist_roles.md) |
| Does pressure (shot clock, score, streaks, end of period) change shooting? | [`pressure_situations()`](https://loukesio.github.io/ggbasket/reference/pressure_situations.md), [`pressure_effects()`](https://loukesio.github.io/ggbasket/reference/pressure_effects.md), [`plot_pressure()`](https://loukesio.github.io/ggbasket/reference/plot_pressure.md) |
| How does a shot’s value change with distance or shot clock? | [`shot_curve()`](https://loukesio.github.io/ggbasket/reference/shot_curve.md), [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |

## Teams, players and shots

| Topic | Metrics | Plots |
|----|----|----|
| Teams | [`possessions()`](https://loukesio.github.io/ggbasket/reference/possessions.md), [`four_factors()`](https://loukesio.github.io/ggbasket/reference/four_factors.md), [`team_ratings()`](https://loukesio.github.io/ggbasket/reference/team_ratings.md), [`team_shot_profile()`](https://loukesio.github.io/ggbasket/reference/team_shot_profile.md), [`expected_wins()`](https://loukesio.github.io/ggbasket/reference/expected_wins.md), [`gini()`](https://loukesio.github.io/ggbasket/reference/gini.md), [`lorenz()`](https://loukesio.github.io/ggbasket/reference/gini.md) | [`plot_net_rating()`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md), [`plot_factor_ranks()`](https://loukesio.github.io/ggbasket/reference/plot_factor_ranks.md), [`plot_team_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_team_ratings.md), [`plot_luck()`](https://loukesio.github.io/ggbasket/reference/plot_luck.md), [`plot_lorenz()`](https://loukesio.github.io/ggbasket/reference/plot_lorenz.md), [`plot_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md), [`plot_four_factors()`](https://loukesio.github.io/ggbasket/reference/plot_four_factors.md) |
| Player impact | [`rapm()`](https://loukesio.github.io/ggbasket/reference/rapm.md), [`win_probability_added()`](https://loukesio.github.io/ggbasket/reference/win_probability_added.md), [`on_off()`](https://loukesio.github.io/ggbasket/reference/on_off.md), [`lineups()`](https://loukesio.github.io/ggbasket/reference/lineups.md) | [`plot_rapm()`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md), [`plot_wpa()`](https://loukesio.github.io/ggbasket/reference/plot_wpa.md), [`plot_on_off()`](https://loukesio.github.io/ggbasket/reference/plot_on_off.md), [`plot_lineups()`](https://loukesio.github.io/ggbasket/reference/plot_lineups.md) |
| Players | [`player_rates()`](https://loukesio.github.io/ggbasket/reference/player_rates.md) (TS%, usage, AST%, rebound, steal, block and turnover rates), [`percentile_rank()`](https://loukesio.github.io/ggbasket/reference/percentile_rank.md), [`shrink_rate()`](https://loukesio.github.io/ggbasket/reference/shrink_rate.md) | [`plot_profile()`](https://loukesio.github.io/ggbasket/reference/plot_profile.md), [`plot_quadrant()`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md), [`plot_joint()`](https://loukesio.github.io/ggbasket/reference/plot_joint.md), [`plot_fit()`](https://loukesio.github.io/ggbasket/reference/plot_fit.md), [`plot_spread()`](https://loukesio.github.io/ggbasket/reference/plot_spread.md), [`plot_ranked()`](https://loukesio.github.io/ggbasket/reference/plot_ranked.md) |
| Shots | [`shot_zone()`](https://loukesio.github.io/ggbasket/reference/shot_zone.md), [`summarise_zones()`](https://loukesio.github.io/ggbasket/reference/summarise_zones.md), [`bin_shots_hex()`](https://loukesio.github.io/ggbasket/reference/bin_shots_hex.md), [`expected_fg()`](https://loukesio.github.io/ggbasket/reference/expected_fg.md), [`shot_making()`](https://loukesio.github.io/ggbasket/reference/shot_making.md) | [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md), [`plot_shot_zones()`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md), [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md), [`plot_shot_making()`](https://loukesio.github.io/ggbasket/reference/plot_shot_making.md) |
| Patterns | [`association()`](https://loukesio.github.io/ggbasket/reference/association.md), [`cluster_quality()`](https://loukesio.github.io/ggbasket/reference/cluster_quality.md) | [`plot_association()`](https://loukesio.github.io/ggbasket/reference/plot_association.md), [`plot_corr_matrix()`](https://loukesio.github.io/ggbasket/reference/plot_corr_matrix.md), [`plot_similarity_map()`](https://loukesio.github.io/ggbasket/reference/plot_similarity_map.md), [`plot_cluster_quality()`](https://loukesio.github.io/ggbasket/reference/cluster_quality.md), [`plot_cluster_profiles()`](https://loukesio.github.io/ggbasket/reference/plot_cluster_profiles.md) |
| Courts and style | [`court_spec()`](https://loukesio.github.io/ggbasket/reference/court_spec.md), [`court_lines()`](https://loukesio.github.io/ggbasket/reference/court_lines.md), [`ggbasket_fonts()`](https://loukesio.github.io/ggbasket/reference/ggbasket_fonts.md) | [`geom_court()`](https://loukesio.github.io/ggbasket/reference/geom_court.md) (NBA and FIBA), [`theme_ggbasket()`](https://loukesio.github.io/ggbasket/reference/theme_ggbasket.md), [`theme_court()`](https://loukesio.github.io/ggbasket/reference/theme_ggbasket.md), [`colour_text()`](https://loukesio.github.io/ggbasket/reference/colour_text.md), [`ggbasket_caption()`](https://loukesio.github.io/ggbasket/reference/colour_text.md) |

## Gallery

Every figure below comes from real 2024/25 NBA and EuroLeague data;
`Rscript gallery/make_gallery.R` redraws them all.

### One game

|  |  |
|----|----|
| **Game flow.** The lead through Game 7 of the 2025 NBA Finals, with scoring runs. [`plot_game_flow()`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md) | **Win probability.** The season’s wildest game, with the plays that swung it. [`plot_win_probability()`](https://loukesio.github.io/ggbasket/reference/plot_win_probability.md) |
| ![](reference/figures/gallery/01_game_flow.png) | ![](reference/figures/gallery/03_win_probability.png) |
| **Why they won.** Game 7’s margin split into the four factors. [`plot_game_factors()`](https://loukesio.github.io/ggbasket/reference/plot_game_factors.md) | **A EuroLeague final.** Monaco against Fenerbahce, 2025. [`plot_game_flow()`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md) |
| ![](reference/figures/gallery/04_game_factors.png) | ![](reference/figures/gallery/02_game_flow_el.png) |
| **Every shot of a game.** Shot heatmap and makes and misses for both finalists. `plot_shot_density(points = TRUE)` |  |
| ![](reference/figures/gallery/37_game_shots.png) |  |

### A season of games

|  |  |
|----|----|
| **On/off.** Denver with and without each player. [`plot_on_off()`](https://loukesio.github.io/ggbasket/reference/plot_on_off.md) | **Consistency.** Every game of eight stars. [`plot_consistency()`](https://loukesio.github.io/ggbasket/reference/plot_consistency.md) |
| ![](reference/figures/gallery/05_on_off.png) | ![](reference/figures/gallery/06_consistency.png) |
| **Assist network.** Who passes to whom in Denver. [`plot_assist_network()`](https://loukesio.github.io/ggbasket/reference/plot_assist_network.md) | **Passer to scorer.** The same network as a matrix. [`plot_assist_matrix()`](https://loukesio.github.io/ggbasket/reference/plot_assist_matrix.md) |
| ![](reference/figures/gallery/07_assist_network.png) | ![](reference/figures/gallery/08_assist_matrix.png) |
| **Hubs and two-man games.** [`plot_assist_roles()`](https://loukesio.github.io/ggbasket/reference/plot_assist_roles.md) | **Pressure.** What changes the chance a shot goes in. [`plot_pressure()`](https://loukesio.github.io/ggbasket/reference/plot_pressure.md) |
| ![](reference/figures/gallery/09_assist_roles.png) | ![](reference/figures/gallery/10_pressure.png) |
| **What goes with what.** Association between shot situations. [`plot_association()`](https://loukesio.github.io/ggbasket/reference/plot_association.md) | **Shot clock.** Value of a shot as the clock runs down, both leagues. [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |
| ![](reference/figures/gallery/11_association.png) | ![](reference/figures/gallery/12_shot_clock.png) |

### Shots on the court

|  |  |
|----|----|
| **Hexagons.** Four NBA stars: where they shoot and how well. [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md) | **Hexagons, EuroLeague.** Four EuroLeague scorers. [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md) |
| ![](reference/figures/gallery/28_shot_hex.png) | ![](reference/figures/gallery/34_hex_el.png) |
| **Zones.** Jokic by court zone against the league. [`plot_shot_zones()`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md) | **Zones on a FIBA court.** Vezenkov. [`plot_shot_zones()`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md) |
| ![](reference/figures/gallery/29_shot_zones.png) | ![](reference/figures/gallery/30_shot_zones_el.png) |
| **Shot diet.** Curry and Giannis against the average player. [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md) | **League against league.** EuroLeague shot locations against the NBA’s. [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md) |
| ![](reference/figures/gallery/31_density.png) | ![](reference/figures/gallery/35_density_leagues.png) |
| **Team against team.** Olympiacos and Panathinaikos. [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md) | **Distance.** Expected points by distance, both leagues. [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |
| ![](reference/figures/gallery/36_density_teams.png) | ![](reference/figures/gallery/32_curve_leagues.png) |
| **Shot-making.** Who beats the expected FG% of their shots. [`plot_shot_making()`](https://loukesio.github.io/ggbasket/reference/plot_shot_making.md) | **Play length.** Expected points by how long the play has run, OKC. [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |
| ![](reference/figures/gallery/33_shot_making.png) | ![](reference/figures/gallery/32b_curve_playlength.png) |

### Teams

|  |  |
|----|----|
| **Where net rating comes from.** EuroLeague teams split into offence and defence. [`plot_net_rating()`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md) | **The same for the NBA.** OKC’s defence was the league’s best. [`plot_net_rating()`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md) |
| ![](reference/figures/gallery/13_ratings.png) | ![](reference/figures/gallery/13b_ratings_nba.png) |
| **Offence against defence map.** Every team as a dot, both leagues. [`plot_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md) | **Four factors against the whole league.** Final Four teams on every team’s spread. [`plot_four_factors()`](https://loukesio.github.io/ggbasket/reference/plot_four_factors.md) |
| ![](reference/figures/gallery/13c_ratings_map.png) | ![](reference/figures/gallery/14b_four_factors_spread.png) |
| **Four factors as a ranking table.** The 2025 EuroLeague Final Four. [`plot_factor_ranks()`](https://loukesio.github.io/ggbasket/reference/plot_factor_ranks.md) | **Schedule-adjusted ratings.** Simple Rating System with home advantage, both leagues. [`team_ratings()`](https://loukesio.github.io/ggbasket/reference/team_ratings.md), [`plot_team_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_team_ratings.md) |
| ![](reference/figures/gallery/14_four_factors.png) | ![](reference/figures/gallery/38_team_ratings.png) |
| **Transition.** How often teams run, and how well. [`team_shot_profile()`](https://loukesio.github.io/ggbasket/reference/team_shot_profile.md) + [`plot_quadrant()`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md) | **Shot quality.** Expected value of shots taken and allowed (EuroLeague). [`team_shot_profile()`](https://loukesio.github.io/ggbasket/reference/team_shot_profile.md) |
| ![](reference/figures/gallery/43_transition.png) | ![](reference/figures/gallery/44_shot_quality.png) |
| **Luck.** Actual against Pythagorean wins. [`plot_luck()`](https://loukesio.github.io/ggbasket/reference/plot_luck.md) | **Scoring concentration.** Lorenz curves per team. [`plot_lorenz()`](https://loukesio.github.io/ggbasket/reference/plot_lorenz.md) |
| ![](reference/figures/gallery/15_luck.png) | ![](reference/figures/gallery/16_lorenz.png) |

### Player impact

|  |  |
|----|----|
| **Adjusted plus-minus, NBA.** Ridge regression on every line-up stint. [`rapm()`](https://loukesio.github.io/ggbasket/reference/rapm.md), [`plot_rapm()`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md) | **Adjusted plus-minus, EuroLeague.** [`rapm()`](https://loukesio.github.io/ggbasket/reference/rapm.md), [`plot_rapm()`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md) |
| ![](reference/figures/gallery/39_rapm.png) | ![](reference/figures/gallery/40_rapm_el.png) |
| **Win probability added.** Who moved Game 7, defence included. [`win_probability_added()`](https://loukesio.github.io/ggbasket/reference/win_probability_added.md), [`plot_wpa()`](https://loukesio.github.io/ggbasket/reference/plot_wpa.md) | **Line-ups.** OKC’s five-player units by net rating. [`lineups()`](https://loukesio.github.io/ggbasket/reference/lineups.md), [`plot_lineups()`](https://loukesio.github.io/ggbasket/reference/plot_lineups.md) |
| ![](reference/figures/gallery/41_wpa.png) | ![](reference/figures/gallery/42_lineups.png) |

### Players

|  |  |
|----|----|
| **Fingerprints.** Percentiles on nine stats. [`plot_profile()`](https://loukesio.github.io/ggbasket/reference/plot_profile.md) | **The same fingerprints as radars.** `plot_profile(style = "radar")` |
| ![](reference/figures/gallery/17_profile.png) | ![](reference/figures/gallery/18_profile_radar.png) |
| **Quadrants.** Assists against turnovers. [`plot_quadrant()`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md) | **Joint density.** Usage against efficiency. [`plot_joint()`](https://loukesio.github.io/ggbasket/reference/plot_joint.md) |
| ![](reference/figures/gallery/19_quadrant.png) | ![](reference/figures/gallery/20_joint.png) |
| **Above or below the line.** Turnovers for the assist load. [`plot_fit()`](https://loukesio.github.io/ggbasket/reference/plot_fit.md) | **Spread within a team.** OKC’s shooting. [`plot_spread()`](https://loukesio.github.io/ggbasket/reference/plot_spread.md) |
| ![](reference/figures/gallery/21_fit.png) | ![](reference/figures/gallery/22_spread.png) |
| **Ranked bars.** OKC’s shot diet by plus-minus. [`plot_ranked()`](https://loukesio.github.io/ggbasket/reference/plot_ranked.md) | **Correlations.** What goes together in a stat line. [`plot_corr_matrix()`](https://loukesio.github.io/ggbasket/reference/plot_corr_matrix.md) |
| ![](reference/figures/gallery/23_ranked.png) | ![](reference/figures/gallery/24_corr.png) |
| **Similarity map.** The NBA in two dimensions. [`plot_similarity_map()`](https://loukesio.github.io/ggbasket/reference/plot_similarity_map.md) | **How many player types?** [`plot_cluster_quality()`](https://loukesio.github.io/ggbasket/reference/cluster_quality.md) |
| ![](reference/figures/gallery/25_map.png) | ![](reference/figures/gallery/26_cluster_quality.png) |
| **Seven kinds of player.** [`plot_cluster_profiles()`](https://loukesio.github.io/ggbasket/reference/plot_cluster_profiles.md) |  |
| ![](reference/figures/gallery/27_cluster_profiles.png) |  |

## Data

- **Play-by-play**:
  [`pbp_from_espn()`](https://loukesio.github.io/ggbasket/reference/pbp.md)
  (NBA via hoopR),
  [`pbp_from_euroleague()`](https://loukesio.github.io/ggbasket/reference/pbp.md)
  /
  [`fetch_euroleague_pbp()`](https://loukesio.github.io/ggbasket/reference/pbp.md)
  (EuroLeague live API, shot locations joined in). Both give the same
  layout, documented in
  [`?pbp`](https://loukesio.github.io/ggbasket/reference/pbp.md); the
  players on court are rebuilt from substitutions by
  [`add_lineups()`](https://loukesio.github.io/ggbasket/reference/add_lineups.md).
  BasketballAnalyzeR’s `PbP` also works, and
  [`as_ggbasket_teams()`](https://loukesio.github.io/ggbasket/reference/as_ggbasket_teams.md),
  [`as_ggbasket_players()`](https://loukesio.github.io/ggbasket/reference/as_ggbasket_teams.md),
  [`as_ggbasket_shots()`](https://loukesio.github.io/ggbasket/reference/as_ggbasket_teams.md)
  convert its other tables.
- **Bundled**: `pbp_games` (2025 NBA Finals Game 7 and the 2025
  EuroLeague final), `team_seasons`, `player_seasons`, `shots_2024`
  (2024/25 regular seasons). `data-raw/make_pbp.R` builds the two full
  seasons (1,321 NBA and 330 EuroLeague games).
- **Conventions**: lower-case box-score columns
  (`pts p2m p2a p3m p3a ftm fta orb drb ast tov stl blk pf`), opponent
  columns prefixed `o_`, shot `x`, `y` in metres from the hoop centre (y
  towards half court).

## Tested on real games

On the 2024/25 seasons:

- **NBA box scores are reproduced from play-by-play.** Season points,
  assists, rebounds, steals, blocks and turnovers match the official
  totals exactly. Every team-game adds up to 240 minutes. Game 7 gives
  OKC 103-91, SGA 29 points and 12 assists, and Indiana 23 turnovers.
- **EuroLeague** final scores match the API for all 330 games. 658 of
  660 team-games add up to exactly 200 minutes. Assists match once
  FIBA’s free-throw assists are counted.
- **Win probability** is a two-parameter score model (Stern, 1994). Its
  spread is fitted by likelihood on every in-game situation. Held-out
  NBA games are calibrated to within about 5 percentage points. Home
  advantage is worth 3.3 points per game in the EuroLeague and 1.6 in
  the NBA.
- **Pressure**: with 2 seconds or less on the shot clock, shots go in
  about 7.5 percentage points less often in the NBA and 7.4 in the
  EuroLeague, after accounting for location. The score and hot or cold
  streaks make no measurable difference.

`R CMD check` passes, and the tests run on the bundled finals.

## Style

[`theme_ggbasket()`](https://loukesio.github.io/ggbasket/reference/theme_ggbasket.md)
follows Cedric Scherer’s editorial look:

- a plain white background; colours from the `heatmap1` and `minou`
  palettes of [ltc](https://github.com/loukesio/ltc-color-palettes); and
  a “painted” court (cool-grey floor, blue-grey key, orange rim;
  `geom_court(style = )` also offers `"arena"` and `"minimal"`);
- a bold title that states the finding;
- a markdown subtitle that names groups in their own colour
  ([`colour_text()`](https://loukesio.github.io/ggbasket/reference/colour_text.md))
  instead of a legend;
- a monospaced “Data · Graphic” caption.

Fonts are Fira Sans, Fira Sans Condensed and Roboto Mono, all free on
Google Fonts; if they are missing, the system sans is used. Use
`ggsave(..., device = cairo_pdf)` or PNG for the full look.

## Origins

ggbasket began as a redesign of the analyses in Zuccolotto & Manisera,
*Basketball Data Science* (CRC 2020).
[`BOOK_REVIEW.md`](https://loukesio.github.io/ggbasket/BOOK_REVIEW.md)
holds that chapter-by-chapter critique and the book’s figures next to
their ggbasket counterparts.
