# Gallery

All 49 figures, grouped by question: one game, a season of games, shots
on the court, teams, player impact and players.

Every figure takes one to three lines of code once the data is loaded.
Open **Code for these figures** under each section for the exact calls;
the shared setup is:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`ggbasket`](https://loukesio.github.io/ggbasket/)`)``; `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)``; `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`\
`# season play-by-play, built once by data-raw/make_pbp.R (or with fetch_euroleague_pbp() / pbp_from_espn())`\
`nba_pbp`` ``<-`` ``arrow``::`[`read_parquet`](https://arrow.apache.org/docs/r/reference/read_parquet.html)`(``"nba_pbp_2024.parquet"``)``; ``el_pbp`` ``<-`` ``arrow``::`[`read_parquet`](https://arrow.apache.org/docs/r/reference/read_parquet.html)`(``"el_pbp_2024.parquet"``)`\
`nba_reg`` ``<-`` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_pbp``, ``phase`` ``==`` ``"regular"``)``; ``el_reg`` ``<-`` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``el_pbp``, ``phase`` ``==`` ``"regular"``)`\
`nba_sh`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``shots_2024``, ``league`` ``==`` ``"NBA"``)``; ``el_sh`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``shots_2024``, ``league`` ``==`` ``"EuroLeague"``)`\
`ff`` ``<-`` `[`four_factors`](https://loukesio.github.io/ggbasket/reference/four_factors.md)`(``team_seasons``)`\
`g7`` ``<-`` ``"401766128"``; ``okc`` ``<-`` ``"#007AC1"``   ``# cap_* are captions made with ggbasket_caption("...")`

Every figure below comes from real 2024/25 NBA and EuroLeague data;
`Rscript gallery/make_gallery.R` redraws them all.

### One game

|  |  |
|----|----|
| **Game flow.** The lead through Game 7 of the 2025 NBA Finals, with scoring runs. [`plot_game_flow()`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md) | **Win probability.** The season’s wildest game, with the plays that swung it. [`plot_win_probability()`](https://loukesio.github.io/ggbasket/reference/plot_win_probability.md) |
| ![gallery figure: game flow](../reference/figures/gallery/01_game_flow.png) | ![gallery figure: win probability](../reference/figures/gallery/03_win_probability.png) |
| **Why they won.** Game 7’s margin split into the four factors. [`plot_game_factors()`](https://loukesio.github.io/ggbasket/reference/plot_game_factors.md) | **A EuroLeague final.** Monaco against Fenerbahce, 2025. [`plot_game_flow()`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md) |
| ![gallery figure: game factors](../reference/figures/gallery/04_game_factors.png) | ![gallery figure: game flow el](../reference/figures/gallery/02_game_flow_el.png) |
| **Every shot of a game.** Shot heatmap and makes and misses for both finalists. `plot_shot_density(points = TRUE)` |  |
| ![gallery figure: game shots](../reference/figures/gallery/37_game_shots.png) |  |

**Code for these figures**

\
`out``(`[`plot_game_flow`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md)`(``nba_pbp``, ``g7``, min_run ``=`` ``7``, colours ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``okc``, ``"#B8860B"``)``,`\
`                   title ``=`` ``"Game 7 was close for 27 minutes, then OKC ran away"``,`\
`                   subtitle ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"2025 NBA Finals, Game 7. Lead of"``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"Oklahoma City"``, ``okc``)``, ``"(up) or"``,`\
`                                    `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"Indiana"``, ``"#B8860B"``)``, ``"(down). Tyrese Haliburton tore his Achilles in the first quarter; OKC broke the game open with a **13-0 run** in the third. Brackets = runs of 7+ unanswered points"``)``,`\
`                   caption ``=`` ``cap_nba``)``, ``"01_game_flow"``, ``10``, ``5.5``)`\
`el_final`` ``<-`` ``"E2024_330"`\
`f`` ``<-`` `[`game_flow`](https://loukesio.github.io/ggbasket/reference/game_flow.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``el_pbp``, ``game_id`` ``==`` ``el_final``)``)``; ``last`` ``<-`` ``f``[`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``f``)``, ``]`\
`half`` ``<-`` ``f``[``f``$``totalTime`` ``<=`` ``1200``, ``]``; ``half`` ``<-`` ``half``[`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``half``)``, ``]`\
`out``(`[`plot_game_flow`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md)`(``el_pbp``, ``el_final``, min_run ``=`` ``7``, colours ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"#C8102E"``, ``"#1B2A4A"``)``,`\
`                   title ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Monaco controlled the first half; Fenerbahce won the second %d-%d"``,`\
`                                   ``last``$``away_score`` ``-`` ``half``$``away_score``, ``last``$``home_score`` ``-`` ``half``$``home_score``)``,`\
`                   subtitle ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"EuroLeague final 2025, %s %d-%d %s. Lead of %s (up) or %s (down); brackets = runs of 7+ unanswered points"``,`\
`                                      ``last``$``hometeam``, ``last``$``home_score``, ``last``$``away_score``, ``last``$``awayteam``,`\
`                                      `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"Monaco"``, ``"#C8102E"``)``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"Fenerbahce"``, ``"#1B2A4A"``)``)``,`\
`                   caption ``=`` ``cap_el``)``, ``"02_game_flow_el"``, ``10``, ``5.5``)`\
\
`gs`` ``<-`` `[`game_summary`](https://loukesio.github.io/ggbasket/reference/game_summary.md)`(``nba_reg``)`\
`top`` ``<-`` ``gs``$``game_id``[`[`which.max`](https://rdrr.io/r/base/which.min.html)`(``gs``$``excitement``)``]`\
`bx`` ``<-`` `[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_reg``, ``game_id`` ``==`` ``top``)``)`\
`star`` ``<-`` ``bx``[`[`which.max`](https://rdrr.io/r/base/which.min.html)`(``bx``$``pts``)``, ``]`\
`wp`` ``<-`` `[`win_probability`](https://loukesio.github.io/ggbasket/reference/win_probability.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_reg``, ``game_id`` ``==`` ``top``)``)`\
`r`` ``<-`` ``gs``[``gs``$``game_id`` ``==`` ``top``, ``]`\
`out``(`[`plot_win_probability`](https://loukesio.github.io/ggbasket/reference/plot_win_probability.md)`(``wp``, ``top``, n_key ``=`` ``4``, colours ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"#0E2240"``, ``"#78BE20"``)``,`\
`                         title ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"The season's wildest game: %s scored %d and %s lost by one"``, ``star``$``player``,`\
`                                         `[`as.integer`](https://rdrr.io/r/base/integer.html)`(``star``$``pts``)``, ``star``$``team``)``,`\
`                         subtitle ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s after two overtimes, %d lead changes. Chance that %s (up) or %s (down) wins after every play, from a two-parameter score model fitted on the season."``,`\
`                                            ``r``$``score``, ``r``$``lead_changes``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``r``$``hometeam``, ``"#0E2240"``)``,`\
`                                            `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``r``$``awayteam``, ``"#5A9A12"``)``)``,`\
`                         caption ``=`` ``cap_nba``)``, ``"03_win_probability"``, ``10``, ``6.3``)`\
\
`gf`` ``<-`` `[`game_factors`](https://loukesio.github.io/ggbasket/reference/game_factors.md)`(`[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_pbp``, ``phase`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"regular"``, ``"playoffs"``)``)``, by ``=`` ``"team"``)``)`\
`out``(`[`plot_game_factors`](https://loukesio.github.io/ggbasket/reference/plot_game_factors.md)`(``gf``, ``g7``, team ``=`` ``"OKC"``,`\
`                      title ``=`` ``"Game 7 was won on turnovers, not shooting"``,`\
`                      subtitle ``=`` ``"OKC shot worse than Indiana but had 15 more chances: what each of the four factors was worth to OKC's 12-point win, from a regression of margin on four-factor differences over all 1,314 games of the season"``,`\
`                      caption ``=`` ``cap_nba``)``, ``"04_game_factors"``, ``9``, ``5``)`

### A season of games

|  |  |
|----|----|
| **On/off.** Denver with and without each player. [`plot_on_off()`](https://loukesio.github.io/ggbasket/reference/plot_on_off.md) | **Consistency.** Every game of eight stars. [`plot_consistency()`](https://loukesio.github.io/ggbasket/reference/plot_consistency.md) |
| ![gallery figure: on off](../reference/figures/gallery/05_on_off.png) | ![gallery figure: consistency](../reference/figures/gallery/06_consistency.png) |
| **Assist network.** Who passes to whom in Denver. [`plot_assist_network()`](https://loukesio.github.io/ggbasket/reference/plot_assist_network.md) | **Passer to scorer.** The same network as a matrix. [`plot_assist_matrix()`](https://loukesio.github.io/ggbasket/reference/plot_assist_matrix.md) |
| ![gallery figure: assist network](../reference/figures/gallery/07_assist_network.png) | ![gallery figure: assist matrix](../reference/figures/gallery/08_assist_matrix.png) |
| **Hubs and two-man games.** [`plot_assist_roles()`](https://loukesio.github.io/ggbasket/reference/plot_assist_roles.md) | **Pressure.** What changes the chance a shot goes in. [`plot_pressure()`](https://loukesio.github.io/ggbasket/reference/plot_pressure.md) |
| ![gallery figure: assist roles](../reference/figures/gallery/09_assist_roles.png) | ![gallery figure: pressure](../reference/figures/gallery/10_pressure.png) |
| **What goes with what.** Association between shot situations. [`plot_association()`](https://loukesio.github.io/ggbasket/reference/plot_association.md) | **Shot clock.** Value of a shot as the clock runs down, both leagues. [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |
| ![gallery figure: association](../reference/figures/gallery/11_association.png) | ![gallery figure: shot clock](../reference/figures/gallery/12_shot_clock.png) |

**Code for these figures**

\
`oo`` ``<-`` `[`on_off`](https://loukesio.github.io/ggbasket/reference/on_off.md)`(``nba_reg``, team ``=`` ``"DEN"``, min_minutes ``=`` ``500``)`\
`j`` ``<-`` ``oo``[``oo``$``player`` ``==`` ``"Nikola Jokic"``, ``]`\
`out``(`[`plot_on_off`](https://loukesio.github.io/ggbasket/reference/plot_on_off.md)`(``oo``, n ``=`` ``11``,`\
`                title ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Denver were %+.0f with Jokic on the floor and %+.0f without him"``, ``j``$``on_net``, ``j``$``off_net``)``,`\
`                subtitle ``=`` ``"Denver's net rating (points per 100 possessions) with each player on (filled) and off (open) the floor, 2024/25 regular season. On/off mixes a player's impact with that of their team-mates, so read it with minutes"``,`\
`                caption ``=`` ``cap_nba``)``, ``"05_on_off"``, ``9``, ``6``)`\
\
`bx`` ``<-`` `[`game_score`](https://loukesio.github.io/ggbasket/reference/game_score.md)`(`[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(``nba_reg``)``)`\
`stars`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Nikola Jokic"``, ``"Shai Gilgeous-Alexander"``, ``"Giannis Antetokounmpo"``, ``"Luka Doncic"``, ``"Anthony Edwards"``,`\
`           ``"Jayson Tatum"``, ``"Stephen Curry"``, ``"Victor Wembanyama"``)`\
`out``(`[`plot_consistency`](https://loukesio.github.io/ggbasket/reference/plot_consistency.md)`(``bx``, ``stars``, min_minutes ``=`` ``15``,`\
`                     title ``=`` ``"Jokic's bad nights are other stars' good ones"``,`\
`                     subtitle ``=`` ``"Game Score in every game of 2024/25 (Hollinger's box-score summary, about 10 = an average game, 40 = outstanding). Grey box = middle half of games, black tick = median"``,`\
`                     caption ``=`` ``cap_nba``)``, ``"06_consistency"``, ``10``, ``7``)`\
\
`net`` ``<-`` `[`assist_network`](https://loukesio.github.io/ggbasket/reference/assist_network.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_reg``, ``team`` ``==`` ``"DEN"``)``)`\
`out``(`[`plot_assist_network`](https://loukesio.github.io/ggbasket/reference/plot_assist_network.md)`(``net``, min_assists ``=`` ``25``, top_n ``=`` ``9``,`\
`                        title ``=`` ``"Denver's offence runs through Jokic"``, caption ``=`` ``cap_nba``)``, ``"07_assist_network"``, ``10``, ``8``)`\
`out``(`[`plot_assist_matrix`](https://loukesio.github.io/ggbasket/reference/plot_assist_matrix.md)`(``net``, top_n ``=`` ``9``, title ``=`` ``"Denver 2024/25: passer to scorer"``, caption ``=`` ``cap_nba``)``,`\
`    ``"08_assist_matrix"``, ``8.5``, ``7``)`\
`jk`` ``<-`` ``net``$``nodes``[``net``$``nodes``$``player`` ``==`` ``"Nikola Jokic"``, ``]`\
`out``(`[`plot_assist_roles`](https://loukesio.github.io/ggbasket/reference/plot_assist_roles.md)`(``net``, min_assists ``=`` ``60``,`\
`                      title ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Jokic is the hub: %d assists, %.0f%% of Denver's, %.1f times the next player"``,`\
`                                      `[`as.integer`](https://rdrr.io/r/base/integer.html)`(``jk``$``assists``)``, ``100`` ``*`` ``jk``$``ast_share``,`\
`                                      ``jk``$``assists`` ``/`` `[`sort`](https://rdrr.io/r/base/sort.html)`(``net``$``nodes``$``assists``, decreasing ``=`` ``TRUE``)``[``2``]``)``,`\
`                      caption ``=`` ``cap_nba``)``, ``"09_assist_roles"``, ``9``, ``6.5``)`\
\
`ps_nba`` ``<-`` `[`expected_fg`](https://loukesio.github.io/ggbasket/reference/expected_fg.md)`(`[`pressure_situations`](https://loukesio.github.io/ggbasket/reference/pressure_situations.md)`(``nba_reg``, league ``=`` ``"NBA"``, orb_reset ``=`` ``14``)``)`\
`ps_el`` ``<-`` `[`expected_fg`](https://loukesio.github.io/ggbasket/reference/expected_fg.md)`(`[`pressure_situations`](https://loukesio.github.io/ggbasket/reference/pressure_situations.md)`(``el_reg``, league ``=`` ``"EuroLeague"``, orb_reset ``=`` ``14``)``)`\
\
`e_nba`` ``<-`` `[`pressure_effects`](https://loukesio.github.io/ggbasket/reference/pressure_effects.md)`(``ps_nba``)``; ``e_el`` ``<-`` `[`pressure_effects`](https://loukesio.github.io/ggbasket/reference/pressure_effects.md)`(``ps_el``)`\
`te`` ``<-`` ``function``(``e``)`` ``100`` ``*`` ``e``$``effect``[``e``$``situation`` ``==`` ``"shot_clock"`` ``&`` ``e``$``level`` ``==`` ``"time-end"``]`\
`out``(`[`plot_pressure`](https://loukesio.github.io/ggbasket/reference/plot_pressure.md)`(``e_nba``,`\
`                  title ``=`` ``"The shot clock is the real pressure"``,`\
`                  subtitle ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"Change in make probability against each situation's reference, after accounting for where the shot was taken. In the NBA, shots with **2 seconds or less** on the (estimated) shot clock go in **%.1f points less often** (EuroLeague: %.1f); the score and hot or cold streaks barely matter. Bars = 90%% intervals"``,`\
`                                     `[`abs`](https://rdrr.io/r/base/MathFun.html)`(``te``(``e_nba``)``)``, `[`abs`](https://rdrr.io/r/base/MathFun.html)`(``te``(``e_el``)``)``)``,`\
`                  caption ``=`` `[`ggbasket_caption`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"NBA 2024/25 regular season, every field-goal attempt · ESPN via hoopR"``,`\
`                                             note ``=`` ``"Shot clock estimated from play-by-play. Logistic regression with location-based expected FG% as offset"``)``)``,`\
`    ``"10_pressure"``, ``9``, ``8``)`\
\
`ps_nba``$``dist`` ``<-`` `[`sqrt`](https://rdrr.io/r/base/MathFun.html)`(``ps_nba``$``x``^``2`` ``+`` ``ps_nba``$``y``^``2``)`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``1``)`\
`s`` ``<-`` ``ps_nba``[`[`sample`](https://rdrr.io/r/base/sample.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``ps_nba``)``, ``40000``)``, ``]`\
`out``(`[`plot_association`](https://loukesio.github.io/ggbasket/reference/plot_association.md)`(`[`association`](https://loukesio.github.io/ggbasket/reference/association.md)`(``s``, `[`c`](https://rdrr.io/r/base/c.html)`(``Made ``=`` ``"made"``` , `Shot value`  ```=`` ``"value"``, Distance ``=`` ``"dist"``,`\
``                                       `Shot clock`  ```=`` ``"shot_clock_left"``` , `End of period`  ```=`` ``"period_end"``,`\
`                                      Score ``=`` ``"score_diff"``` , `Last shot`  ```=`` ``"prev_miss"``, Period ``=`` ``"period"``)``)``,`\
`                     title ``=`` ``"Location matters; the situation barely registers"``,`\
`                     caption ``=`` ``cap_nba``)``, ``"11_association"``, ``9``, ``8``)`\
\
`both`` ``<-`` `[`bind_rows`](https://dplyr.tidyverse.org/reference/bind_rows.html)`(``ps_nba``, ``ps_el``)`\
`sc`` ``<-`` `[`shot_curve`](https://loukesio.github.io/ggbasket/reference/shot_curve.md)`(``both``, ``"shot_clock_left"``, by ``=`` ``"league"``, outcome ``=`` ``"points"``, n_boot ``=`` ``100``, bw ``=`` ``1.2``)`\
`out``(`[`plot_shot_curve`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md)`(``sc``, xlab ``=`` ``"Seconds left on the shot clock (estimated)"``,`\
`                    title ``=`` ``"As the shot clock runs down, so does the value of a shot"``,`\
`                    subtitle ``=`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"Expected points per field-goal attempt by time left on the shot clock, in the "``,`\
`                                      `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"NBA"``, ``"NBA"``)``, ``" and the "``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"EuroLeague"``, ``"EuroLeague"``)``,`\
`                                      ``". Early shots (mostly transition) are worth 1.25-1.35 points; with 2 seconds left, under 1. EuroLeague attempts are worth more at almost every clock reading. Line width = where shots are taken; band = 90% bootstrap"``)``,`\
`                    caption ``=`` ``cap_both``)`` ``+`` `[`scale_x_reverse`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``)``, ``"12_shot_clock"``, ``9``, ``5.8``)`

### Shots on the court

|  |  |
|----|----|
| **Hexagons.** Four NBA stars: where they shoot and how well. [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md) | **Hexagons, EuroLeague.** Four EuroLeague scorers. [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md) |
| ![gallery figure: shot hex](../reference/figures/gallery/28_shot_hex.png) | ![gallery figure: hex el](../reference/figures/gallery/34_hex_el.png) |
| **Zones.** Jokic by court zone against the league. [`plot_shot_zones()`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md) | **Zones on a FIBA court.** Vezenkov. [`plot_shot_zones()`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md) |
| ![gallery figure: shot zones](../reference/figures/gallery/29_shot_zones.png) | ![gallery figure: shot zones el](../reference/figures/gallery/30_shot_zones_el.png) |
| **Shot diet.** Curry and Giannis against the average player. [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md) | **League against league.** EuroLeague shot locations against the NBA’s. [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md) |
| ![gallery figure: density](../reference/figures/gallery/31_density.png) | ![gallery figure: density leagues](../reference/figures/gallery/35_density_leagues.png) |
| **Team against team.** Olympiacos and Panathinaikos. [`plot_shot_density()`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md) | **Distance.** Expected points by distance, both leagues. [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |
| ![gallery figure: density teams](../reference/figures/gallery/36_density_teams.png) | ![gallery figure: curve leagues](../reference/figures/gallery/32_curve_leagues.png) |
| **Shot-making.** Who beats the expected FG% of their shots. [`plot_shot_making()`](https://loukesio.github.io/ggbasket/reference/plot_shot_making.md) | **Play length.** Expected points by how long the play has run, OKC. [`plot_shot_curve()`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md) |
| ![gallery figure: shot making](../reference/figures/gallery/33_shot_making.png) | ![gallery figure: curve playlength](../reference/figures/gallery/32b_curve_playlength.png) |

**Code for these figures**

\
`out``(`[`plot_shot_hex`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``nba_sh``, ``player`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``mvps``)``, baseline ``=`` ``nba_sh``, facet ``=`` ``"player"``,`\
`                  title ``=`` ``"Four stars, four shot diets"``, caption ``=`` ``cap_now``)``, ``"28_shot_hex"``, ``10``, ``9``)`\
\
`out``(`[`plot_shot_zones`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``nba_sh``, ``player`` ``==`` ``"Nikola Jokic"``)``, baseline ``=`` ``nba_sh``,`\
`                    title ``=`` ``"Nikola Jokic, 2024/25: elite from everywhere inside the arc"``, caption ``=`` ``cap_now``)``, ``"29_shot_zones"``, ``8``, ``6.5``)`\
`out``(`[`plot_shot_zones`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``el_sh``, ``player`` ``==`` ``"Sasha Vezenkov"``)``, baseline ``=`` ``el_sh``, league ``=`` ``"EuroLeague"``,`\
`                    title ``=`` ``"Sasha Vezenkov, EuroLeague 2024/25 (FIBA court)"``, caption ``=`` ``cap_now``)``, ``"30_shot_zones_el"``, ``8``, ``6.5``)`\
\
`out``(`[`plot_shot_density`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``nba_sh``, ``player`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"Stephen Curry"``, ``"Giannis Antetokounmpo"``)``)``, compare ``=`` ``nba_sh``,`\
`                      facet ``=`` ``"player"``, title ``=`` ``"Shot diet compared with the average NBA player"``,`\
`                      caption ``=`` ``cap_now``)``, ``"31_density"``, ``11``, ``5.5``)`\
\
`el_stars`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Carsen Edwards"``, ``"Kendrick Nunn"``, ``"Mike James"``, ``"Sasha Vezenkov"``)`\
`out``(`[`plot_shot_hex`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``el_sh``, ``player`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``el_stars``)``, baseline ``=`` ``el_sh``, facet ``=`` ``"player"``, league ``=`` ``"EuroLeague"``,`\
`                  title ``=`` ``"Four EuroLeague scorers, four shot diets"``, caption ``=`` ``cap_now``)``, ``"34_hex_el"``, ``10``, ``9``)`\
`out``(`[`plot_shot_density`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md)`(``el_sh``, compare ``=`` ``nba_sh``, league ``=`` ``"EuroLeague"``,`\
`                      title ``=`` ``"A shorter three-point line pulls EuroLeague shots inwards"``,`\
`                      subtitle ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"Where"``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"EuroLeague"``, ``"EuroLeague"``)``, ``"teams shoot from, compared with the"``,`\
`                                       `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"NBA"``, ``"NBA"``)``, ``"(metres from the hoop, FIBA court drawn). Red = a bigger share of shots from there than in the NBA; blue = smaller. The FIBA arc is 0.5 m closer, so EuroLeague threes sit just inside the NBA arc"``)``,`\
`                      caption ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``cap_now``, ``"Note: EuroLeague operators record layups about 1 m from the hoop, so the blue at the rim and the red ring around it are partly a recording artefact."``, sep ``=`` ``"<br>"``)``)``,`\
`    ``"35_density_leagues"``, ``8``, ``7.2``)`\
`op`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``el_sh``, ``team`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"OLY"``, ``"PAN"``)``)`\
`op``$``team`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``OLY ``=`` ``"Olympiacos"``, PAN ``=`` ``"Panathinaikos"``)``[``op``$``team``]`\
`out``(`[`plot_shot_density`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md)`(``op``, compare ``=`` ``el_sh``, facet ``=`` ``"team"``, league ``=`` ``"EuroLeague"``,`\
`                      title ``=`` ``"Olympiacos and Panathinaikos: two ways to attack"``,`\
`                      subtitle ``=`` ``"Each team's shot locations compared with the average EuroLeague team, 2024/25 regular season. Red = shoots there more, blue = less"``,`\
`                      caption ``=`` ``cap_now``)``, ``"36_density_teams"``, ``11``, ``5.6``)`\
`fin`` ``<-`` `[`as_ggbasket_shots`](https://loukesio.github.io/ggbasket/reference/as_ggbasket_teams.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``el_pbp``, ``game_id`` ``==`` ``"E2024_330"``)``, league ``=`` ``"EuroLeague"``)`\
`fin``$``team`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``ULK ``=`` ``"Fenerbahce"``, MCO ``=`` ``"Monaco"``)``[``fin``$``team``]`\
`out``(`[`plot_shot_density`](https://loukesio.github.io/ggbasket/reference/plot_shot_density.md)`(``fin``, facet ``=`` ``"team"``, points ``=`` ``TRUE``, league ``=`` ``"EuroLeague"``,`\
`                      title ``=`` ``"The 2025 EuroLeague final, every shot"``,`\
`                      subtitle ``=`` ``"Where each team shot from in the final (Fenerbahce 81, Monaco 70): heat = shot density, dots = made, crosses = missed"``,`\
`                      caption ``=`` ``cap_el``)``, ``"37_game_shots"``, ``11``, ``5.8``)`\
\
`both`` ``<-`` ``shots_2024`\
`both``$``dist`` ``<-`` `[`sqrt`](https://rdrr.io/r/base/MathFun.html)`(``both``$``x``^``2`` ``+`` ``both``$``y``^``2``)`\
`both`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``both``, ``dist`` ``<`` ``9``)`\
`sc`` ``<-`` `[`shot_curve`](https://loukesio.github.io/ggbasket/reference/shot_curve.md)`(``both``, ``"dist"``, by ``=`` ``"league"``, outcome ``=`` ``"points"``, n_boot ``=`` ``100``, bw ``=`` ``0.25``, split_value ``=`` ``TRUE``)`\
`out``(`[`plot_shot_curve`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md)`(``sc``, vlines ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"FIBA 3pt 6.75 m"`` ``=`` ``6.75``, ``"NBA 3pt 7.24 m"`` ``=`` ``7.24``)``,`\
`                    xlab ``=`` ``"Shot distance from the hoop (m)"``,`\
`                    title ``=`` ``"Same mid-range desert, different oasis"``,`\
`                    subtitle ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"Expected points per shot by distance in the"``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"NBA"``, ``"NBA"``)``, ``"and the"``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"EuroLeague"``, ``"EuroLeague"``)``, ``"(2s and 3s smoothed separately). Both lose value between the rim and the arc, but the FIBA line is half a metre closer, so **EuroLeague shooters reach 1+ point per shot sooner**. Line width = where shots are taken; band = 90% bootstrap"``)``,`\
`                    caption ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``cap_now``, ``"Note: EuroLeague operators record layups ~1 m from the hoop, so the EuroLeague curve starts late."``, sep ``=`` ``"<br>"``)``)``,`\
`    ``"32_curve_leagues"``, ``9``, ``5.8``)`\
\
`okc_sh`` ``<-`` `[`as_ggbasket_shots`](https://loukesio.github.io/ggbasket/reference/as_ggbasket_teams.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_reg``, ``team`` ``==`` ``"OKC"``)``)`\
`pl4`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Shai Gilgeous-Alexander"``, ``"Jalen Williams"``, ``"Chet Holmgren"``, ``"Luguentz Dort"``)`\
`sc2`` ``<-`` `[`shot_curve`](https://loukesio.github.io/ggbasket/reference/shot_curve.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``okc_sh``, ``player`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``pl4`` ``&`` ``playlength`` ``<=`` ``24``)``, ``"playlength"``, by ``=`` ``"player"``,`\
`                  outcome ``=`` ``"points"``, n_boot ``=`` ``100``, bw ``=`` ``2``)`\
`out``(`[`plot_shot_curve`](https://loukesio.github.io/ggbasket/reference/plot_shot_curve.md)`(``sc2``, ref ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``okc_sh``$``pts``)``, ref_label ``=`` ``"OKC average"``,`\
`                    xlab ``=`` ``"Seconds since the previous event (how long the play has run)"``,`\
`                    title ``=`` ``"No OKC scorer is clearly better late in a play: the bands overlap"``,`\
`                    subtitle ``=`` ``"Expected points per shot by how long the play has run, OKC 2024/25. Line width = how often each player shoots at that moment; band = 90% bootstrap"``,`\
`                    caption ``=`` ``cap_nba``)``, ``"32b_curve_playlength"``, ``9``, ``5.5``)`\
\
`sm`` ``<-`` `[`shot_making`](https://loukesio.github.io/ggbasket/reference/shot_making.md)`(`[`expected_fg`](https://loukesio.github.io/ggbasket/reference/expected_fg.md)`(``shots_2024``)``, prior_n ``=`` ``150``)`\
`out``(`[`plot_shot_making`](https://loukesio.github.io/ggbasket/reference/plot_shot_making.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``sm``, ``league`` ``==`` ``"NBA"``)``, min_attempts ``=`` ``500``,`\
`                     highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Stephen Curry"``, ``"Nikola Jokic"``, ``"Shai Gilgeous-Alexander"``)``,`\
`                     title ``=`` ``"Jokic, Curry and SGA make hard shots look easy"``,`\
`                     subtitle ``=`` ``"NBA 2024/25. Each shot graded against a league model of make probability by location; players with 500+ attempts"``,`\
`                     caption ``=`` ``cap_now``)``, ``"33_shot_making"``, ``9``, ``7``)`

### Teams

|  |  |
|----|----|
| **Where net rating comes from.** EuroLeague teams split into offence and defence. [`plot_net_rating()`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md) | **The same for the NBA.** OKC’s defence was the league’s best. [`plot_net_rating()`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md) |
| ![gallery figure: ratings](../reference/figures/gallery/13_ratings.png) | ![gallery figure: ratings nba](../reference/figures/gallery/13b_ratings_nba.png) |
| **Offence against defence, EuroLeague.** Centred on the league average; corners say how a team wins. [`plot_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md) | **Offence against defence, NBA.** [`plot_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md) |
| ![gallery figure: ratings map](../reference/figures/gallery/13c_ratings_map.png) | ![gallery figure: ratings map nba](../reference/figures/gallery/13d_ratings_map_nba.png) |
| **Four factors against the whole league.** Final Four teams on every team’s spread. [`plot_four_factors()`](https://loukesio.github.io/ggbasket/reference/plot_four_factors.md) |  |
| ![gallery figure: four factors spread](../reference/figures/gallery/14b_four_factors_spread.png) |  |
| **Four factors as a ranking table.** The 2025 EuroLeague Final Four. [`plot_factor_ranks()`](https://loukesio.github.io/ggbasket/reference/plot_factor_ranks.md) | **Schedule-adjusted ratings.** Simple Rating System with home advantage, both leagues. [`team_ratings()`](https://loukesio.github.io/ggbasket/reference/team_ratings.md), [`plot_team_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_team_ratings.md) |
| ![gallery figure: four factors](../reference/figures/gallery/14_four_factors.png) | ![gallery figure: team ratings](../reference/figures/gallery/38_team_ratings.png) |
| **Transition.** How often teams run, and how well. [`team_shot_profile()`](https://loukesio.github.io/ggbasket/reference/team_shot_profile.md) + [`plot_quadrant()`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md) | **Shot quality.** Expected value of shots taken and allowed (EuroLeague). [`team_shot_profile()`](https://loukesio.github.io/ggbasket/reference/team_shot_profile.md) |
| ![gallery figure: transition](../reference/figures/gallery/43_transition.png) | ![gallery figure: shot quality](../reference/figures/gallery/44_shot_quality.png) |
| **Luck.** Actual against Pythagorean wins. [`plot_luck()`](https://loukesio.github.io/ggbasket/reference/plot_luck.md) | **Scoring concentration.** Lorenz curves per team. [`plot_lorenz()`](https://loukesio.github.io/ggbasket/reference/plot_lorenz.md) |
| ![gallery figure: luck](../reference/figures/gallery/15_luck.png) | ![gallery figure: lorenz](../reference/figures/gallery/16_lorenz.png) |

**Code for these figures**

\
`el_ff`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``ff``, ``league`` ``==`` ``"EuroLeague"``)`\
`out``(`[`plot_net_rating`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md)`(``ff``, ``"EuroLeague"``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"OLY"``, ``"PAN"``, ``"ULK"``, ``"MCO"``)``,`\
`                    title ``=`` ``"Panathinaikos and Olympiacos won with offence, Fenerbahce and Real Madrid with defence"``,`\
`                    subtitle ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"EuroLeague 2024/25. Net rating (black dot and number) ="``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"offence"``, ``ggbasket_colours``$``offence``)``,`\
`                                     ``"(points scored above average) +"``, `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"defence"``, ``ggbasket_colours``$``defence``)``,`\
`                                     ``"(points allowed below average), per 100 possessions. Grey band = the Final Four"``)``,`\
`                    caption ``=`` ``cap_now``)``, ``"13_ratings"``, ``9``, ``7``)`\
`out``(`[`plot_net_rating`](https://loukesio.github.io/ggbasket/reference/plot_net_rating.md)`(``ff``, ``"NBA"``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"OKC"``, ``"CLE"``, ``"BOS"``, ``"HOU"``)``,`\
`                    title ``=`` ``"OKC's net rating was built on the league's best defence"``,`\
`                    caption ``=`` ``cap_now``)``, ``"13b_ratings_nba"``, ``9``, ``9.5``)`\
`out``(`[`plot_ratings`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``ff``, ``league`` ``==`` ``"EuroLeague"``)``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"OLY"``, ``"PAN"``, ``"ULK"``, ``"MCO"``)``,`\
`                 title ``=`` ``"Panathinaikos and Olympiacos win with offence, Real Madrid and Fenerbahce with defence"``,`\
`                 subtitle ``=`` ``"EuroLeague 2024/25. The centre is an average team; up and right are both better. Colour = net rating. Bold = the Final Four"``,`\
`                 caption ``=`` ``cap_now``)``, ``"13c_ratings_map"``, ``9``, ``8.4``)`\
`out``(`[`plot_ratings`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``ff``, ``league`` ``==`` ``"NBA"``)``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"OKC"``, ``"CLE"``, ``"BOS"``, ``"HOU"``)``,`\
`                 title ``=`` ``"OKC's defence set them apart; Cleveland and Boston won mostly with offence"``,`\
`                 subtitle ``=`` ``"NBA 2024/25. The centre is an average team; up and right are both better. Colour = net rating"``,`\
`                 caption ``=`` ``cap_now``)``, ``"13d_ratings_map_nba"``, ``9``, ``8.4``)`\
\
`ff4`` ``<-`` ``ff`\
`nm`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``OLY ``=`` ``"Olympiacos"``, PAN ``=`` ``"Panathinaikos"``, ULK ``=`` ``"Fenerbahce"``, MCO ``=`` ``"Monaco"``)`\
`ff4``$``team``[``ff4``$``team`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``nm``)``]`` ``<-`` ``nm``[``ff4``$``team``[``ff4``$``team`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`names`](https://rdrr.io/r/base/names.html)`(``nm``)``]``]`\
`out``(`[`plot_factor_ranks`](https://loukesio.github.io/ggbasket/reference/plot_factor_ranks.md)`(``ff4``, `[`unname`](https://rdrr.io/r/base/unname.html)`(``nm``)``,`\
`                      title ``=`` ``"Panathinaikos shot best, Fenerbahce defended best, Monaco looked after the ball, Olympiacos lived at the line"``,`\
`                      caption ``=`` ``cap_now``)``, ``"14_four_factors"``, ``10``, ``7``)`\
`out``(`[`plot_four_factors`](https://loukesio.github.io/ggbasket/reference/plot_four_factors.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``ff``, ``league`` ``==`` ``"EuroLeague"``)``, teams ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"ULK"``, ``"PAN"``, ``"OLY"``, ``"MCO"``)``,`\
`                      title ``=`` ``"The same four factors against every EuroLeague team (grey)"``,`\
`                      subtitle ``=`` ``"Standard deviations from the league average, right = better for the team. Offence = the team's own numbers, defence = what opponents managed against it"``,`\
`                      caption ``=`` ``cap_now``)``, ``"14b_four_factors_spread"``, ``9``, ``9``)`\
\
`out``(`[`plot_luck`](https://loukesio.github.io/ggbasket/reference/plot_luck.md)`(`[`expected_wins`](https://loukesio.github.io/ggbasket/reference/expected_wins.md)`(``team_seasons``)``, n ``=`` ``6``,`\
`              title ``=`` ``"The Lakers won six more games than their point margin says"``,`\
`              subtitle ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"Open circle = wins expected from points scored and allowed; filled = actual wins."``,`\
`                               `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"Red"``, ``ggbasket_colours``$``above``)``, ``"= luckier,"``,`\
`                               `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"blue"``, ``ggbasket_colours``$``below``)``, ``"= unluckier. Six luckiest and unluckiest per league"``)``,`\
`              caption ``=`` ``cap_now``)``, ``"15_luck"``, ``10``, ``6``)`\
\
`out``(`[`plot_lorenz`](https://loukesio.github.io/ggbasket/reference/plot_lorenz.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``player_seasons``, ``league`` ``==`` ``"NBA"``)``, ``"pts"``, ``"team"``, n ``=`` ``8``, value_label ``=`` ``"points"``,`\
`                title ``=`` ``"Who depends on a few scorers?"``, caption ``=`` ``cap_now``)``, ``"16_lorenz"``, ``7.5``, ``7.5``)`

### Player impact

|  |  |
|----|----|
| **Adjusted plus-minus, NBA.** Ridge regression on every line-up stint. [`rapm()`](https://loukesio.github.io/ggbasket/reference/rapm.md), [`plot_rapm()`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md) | **Adjusted plus-minus, EuroLeague.** [`rapm()`](https://loukesio.github.io/ggbasket/reference/rapm.md), [`plot_rapm()`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md) |
| ![gallery figure: rapm](../reference/figures/gallery/39_rapm.png) | ![gallery figure: rapm el](../reference/figures/gallery/40_rapm_el.png) |
| **Win probability added.** Who moved Game 7, defence included. [`win_probability_added()`](https://loukesio.github.io/ggbasket/reference/win_probability_added.md), [`plot_wpa()`](https://loukesio.github.io/ggbasket/reference/plot_wpa.md) | **Line-ups.** OKC’s five-player units by net rating. [`lineups()`](https://loukesio.github.io/ggbasket/reference/lineups.md), [`plot_lineups()`](https://loukesio.github.io/ggbasket/reference/plot_lineups.md) |
| ![gallery figure: wpa](../reference/figures/gallery/41_wpa.png) | ![gallery figure: lineups](../reference/figures/gallery/42_lineups.png) |

**Code for these figures**

\
`tr`` ``<-`` `[`team_ratings`](https://loukesio.github.io/ggbasket/reference/team_ratings.md)`(`[`bind_rows`](https://dplyr.tidyverse.org/reference/bind_rows.html)`(`[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(``nba_reg``, by ``=`` ``"team"``)``, `[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(``el_reg``, by ``=`` ``"team"``)``)``)`\
`out``(`[`plot_team_ratings`](https://loukesio.github.io/ggbasket/reference/plot_team_ratings.md)`(``tr``, title ``=`` ``"Once the schedule is accounted for, OKC were 12.7 points better than an average team"``,`\
`                      caption ``=`` ``cap_both``)``, ``"38_team_ratings"``, ``11``, ``9``)`\
`rp`` ``<-`` `[`rapm`](https://loukesio.github.io/ggbasket/reference/rapm.md)`(``nba_reg``, lambda ``=`` ``3000``, min_poss ``=`` ``1000``)`\
`out``(`[`plot_rapm`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md)`(``rp``, n ``=`` ``12``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Shai Gilgeous-Alexander"``, ``"Nikola Jokic"``)``,`\
`              title ``=`` ``"Separated from their team-mates, SGA and Jokic still add the most"``,`\
`              caption ``=`` `[`ggbasket_caption`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"NBA 2024/25 regular season, every line-up stint · ESPN via hoopR"``,`\
`                                         note ``=`` ``"Players with 1,000+ possessions; ridge penalty 3,000 possessions"``)``)``, ``"39_rapm"``, ``11``, ``7``)`\
`rpe`` ``<-`` `[`rapm`](https://loukesio.github.io/ggbasket/reference/rapm.md)`(``el_reg``, lambda ``=`` ``1500``, min_poss ``=`` ``500``)`\
`out``(`[`plot_rapm`](https://loukesio.github.io/ggbasket/reference/plot_rapm.md)`(``rpe``, n ``=`` ``10``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Sasha Vezenkov"``, ``"Walter Tavares"``)``,`\
`              title ``=`` ``"EuroLeague adjusted plus-minus: Jantunen, Weiler-Babb and Tavares lead"``,`\
`              caption ``=`` `[`ggbasket_caption`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"EuroLeague 2024/25 regular season, every line-up stint · EuroLeague live API"``,`\
`                                         note ``=`` ``"Players with 500+ possessions; ridge penalty 1,500 possessions. One season of a 34-game league: treat as a rough guide"``)``)``, ``"40_rapm_el"``, ``11``, ``6.5``)`\
`wpa`` ``<-`` `[`win_probability_added`](https://loukesio.github.io/ggbasket/reference/win_probability_added.md)`(`[`win_probability`](https://loukesio.github.io/ggbasket/reference/win_probability.md)`(`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``nba_pbp``, ``game_id`` ``==`` ``g7``)``)``)`\
`out``(`[`plot_wpa`](https://loukesio.github.io/ggbasket/reference/plot_wpa.md)`(``wpa``, ``g7``, colours ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``OKC ``=`` ``okc``, IND ``=`` ``"#B8860B"``)``,`\
`             title ``=`` ``"Game 7: Gilgeous-Alexander's plays moved the needle most"``,`\
`             caption ``=`` ``cap_nba``)``, ``"41_wpa"``, ``9``, ``6``)`\
`lu`` ``<-`` `[`lineups`](https://loukesio.github.io/ggbasket/reference/lineups.md)`(``nba_reg``, team ``=`` ``"OKC"``, min_minutes ``=`` ``30``)`\
`out``(`[`plot_lineups`](https://loukesio.github.io/ggbasket/reference/plot_lineups.md)`(``lu``, n ``=`` ``6``, title ``=`` ``"OKC's best units all start with Gilgeous-Alexander, Williams and Dort"``,`\
`                 subtitle ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"OKC's %d five-player units with 30+ minutes together, 2024/25 regular season, by net rating; dot size = minutes. %d of them outscored opponents"``,`\
`                                    `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``lu``)``, `[`sum`](https://rdrr.io/r/base/sum.html)`(``lu``$``net`` ``>`` ``0``)``)``,`\
`                 caption ``=`` ``cap_nba``)``, ``"42_lineups"``, ``10``, ``6.5``)`\
`ps_all`` ``<-`` `[`bind_rows`](https://dplyr.tidyverse.org/reference/bind_rows.html)`(`[`expected_fg`](https://loukesio.github.io/ggbasket/reference/expected_fg.md)`(`[`pressure_situations`](https://loukesio.github.io/ggbasket/reference/pressure_situations.md)`(``nba_reg``, ``"NBA"``, ``14``)``)``, `[`expected_fg`](https://loukesio.github.io/ggbasket/reference/expected_fg.md)`(`[`pressure_situations`](https://loukesio.github.io/ggbasket/reference/pressure_situations.md)`(``el_reg``, ``"EuroLeague"``, ``14``)``)``)`\
`tp`` ``<-`` `[`team_shot_profile`](https://loukesio.github.io/ggbasket/reference/team_shot_profile.md)`(``ps_all``)`\
`lg`` ``<-`` ``tp`` ``|>`` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``league``)`` ``|>`` `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``s ``=`` `[`weighted.mean`](https://rdrr.io/r/stats/weighted.mean.html)`(``early_share``, ``fga``)``, p ``=`` `[`weighted.mean`](https://rdrr.io/r/stats/weighted.mean.html)`(``pps_early``, ``fga`` ``*`` ``early_share``)``)`\
`out``(`[`plot_quadrant`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md)`(``tp``, ``"early_share"``, ``"pps_early"``, label ``=`` ``"team"``, colour ``=`` ``"league"``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"ATL"``, ``"DEN"``, ``"MEM"``, ``"OKC"``, ``"OLY"``, ``"PAN"``, ``"BAS"``)``,`\
`                  corners ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Rarely, but deadly"``, ``"Often and well"``, ``"Rarely and poorly"``, ``"Often, often wasted"``)``,`\
`                  xlab ``=`` ``"Share of shots taken early in the clock (17+ seconds left)"``, ylab ``=`` ``"Points per early shot"``,`\
`                  title ``=`` ``"EuroLeague teams run less but score more when they do"``,`\
`                  subtitle ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s teams take %.0f%% of their shots early in the clock and score %.2f points per early shot; %s teams %.0f%% and %.2f. Olympiacos and Baskonia ran rarely but scored about 1.4 points a time"``,`\
`                                     `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"NBA"``, ``"NBA"``)``, ``100`` ``*`` ``lg``$``s``[``lg``$``league`` ``==`` ``"NBA"``]``, ``lg``$``p``[``lg``$``league`` ``==`` ``"NBA"``]``,`\
`                                     `[`colour_text`](https://loukesio.github.io/ggbasket/reference/colour_text.md)`(``"EuroLeague"``, ``"EuroLeague"``)``, ``100`` ``*`` ``lg``$``s``[``lg``$``league`` ``==`` ``"EuroLeague"``]``, ``lg``$``p``[``lg``$``league`` ``==`` ``"EuroLeague"``]``)``,`\
`                  caption ``=`` ``cap_both``)`` ``+`` ``ggplot2``::`[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` ``scales``::`[`label_percent`](https://scales.r-lib.org/reference/label_percent.html)`(``)``)``, ``"43_transition"``, ``9``, ``7``)`\
`tpe`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``tp``, ``league`` ``==`` ``"EuroLeague"``)``; ``tpe``$``net`` ``<-`` ``tpe``$``xpps`` ``-`` ``tpe``$``o_xpps`\
`best`` ``<-`` ``tpe``$``team``[`[`which.max`](https://rdrr.io/r/base/which.min.html)`(``tpe``$``net``)``]`\
`out``(`[`plot_quadrant`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md)`(``tpe``, ``"xpps"``, ``"o_xpps"``, label ``=`` ``"team"``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``best``, ``"OLY"``, ``"PAN"``, ``"ULK"``, ``"MCO"``)``,`\
`                  corners ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Losing the shot battle"``, ``"Good shots both ways"``, ``"Defence first"``, ``"Winning the shot battle"``)``,`\
`                  xlab ``=`` ``"Expected points per shot taken (from location) \u2192 better shots"``, ylab ``=`` ``"Expected points per shot allowed \u2192 easier shots for opponents"``,`\
`                  title ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s won the EuroLeague's shot-quality battle by the most"``, ``best``)``,`\
`                  subtitle ``=`` ``"Each team's shots and its opponents' shots, valued by a EuroLeague model of make probability by location, 2024/25 regular season. Bottom right is best: good shots taken, poor shots allowed"``,`\
`                  caption ``=`` ``cap_el``)``, ``"44_shot_quality"``, ``9``, ``7``)`

### Players

|  |  |
|----|----|
| **Fingerprints.** Percentiles on nine stats. [`plot_profile()`](https://loukesio.github.io/ggbasket/reference/plot_profile.md) | **The same fingerprints as radars.** `plot_profile(style = "radar")` |
| ![gallery figure: profile](../reference/figures/gallery/17_profile.png) | ![gallery figure: profile radar](../reference/figures/gallery/18_profile_radar.png) |
| **Quadrants.** Assists against turnovers. [`plot_quadrant()`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md) | **Joint density.** Usage against efficiency. [`plot_joint()`](https://loukesio.github.io/ggbasket/reference/plot_joint.md) |
| ![gallery figure: quadrant](../reference/figures/gallery/19_quadrant.png) | ![gallery figure: joint](../reference/figures/gallery/20_joint.png) |
| **Above or below the line.** Turnovers for the assist load. [`plot_fit()`](https://loukesio.github.io/ggbasket/reference/plot_fit.md) | **Spread within a team.** OKC’s shooting. [`plot_spread()`](https://loukesio.github.io/ggbasket/reference/plot_spread.md) |
| ![gallery figure: fit](../reference/figures/gallery/21_fit.png) | ![gallery figure: spread](../reference/figures/gallery/22_spread.png) |
| **Ranked bars.** OKC’s shot diet by plus-minus. [`plot_ranked()`](https://loukesio.github.io/ggbasket/reference/plot_ranked.md) | **Correlations.** What goes together in a stat line. [`plot_corr_matrix()`](https://loukesio.github.io/ggbasket/reference/plot_corr_matrix.md) |
| ![gallery figure: ranked](../reference/figures/gallery/23_ranked.png) | ![gallery figure: corr](../reference/figures/gallery/24_corr.png) |
| **Similarity map.** The NBA in two dimensions. [`plot_similarity_map()`](https://loukesio.github.io/ggbasket/reference/plot_similarity_map.md) | **How many player types?** [`plot_cluster_quality()`](https://loukesio.github.io/ggbasket/reference/cluster_quality.md) |
| ![gallery figure: map](../reference/figures/gallery/25_map.png) | ![gallery figure: cluster quality](../reference/figures/gallery/26_cluster_quality.png) |
| **Seven kinds of player.** [`plot_cluster_profiles()`](https://loukesio.github.io/ggbasket/reference/plot_cluster_profiles.md) |  |
| ![gallery figure: cluster profiles](../reference/figures/gallery/27_cluster_profiles.png) |  |

**Code for these figures**

\
`pl`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``player_seasons``, ``minutes`` ``>=`` ``1000``)`\
`pl`` ``<-`` `[`transform`](https://rdrr.io/r/base/transform.html)`(``pl``, pts36 ``=`` ``36`` ``*`` ``pts`` ``/`` ``minutes``, ast36 ``=`` ``36`` ``*`` ``ast`` ``/`` ``minutes``, reb36 ``=`` ``36`` ``*`` ``(``orb`` ``+`` ``drb``)`` ``/`` ``minutes``,`\
`                stl36 ``=`` ``36`` ``*`` ``stl`` ``/`` ``minutes``, blk36 ``=`` ``36`` ``*`` ``blk`` ``/`` ``minutes``, tov36 ``=`` ``36`` ``*`` ``tov`` ``/`` ``minutes``,`\
`                three_rate ``=`` ``p3a`` ``/`` ``(``p2a`` ``+`` ``p3a``)``, rim_rate ``=`` ``rim`` ``/`` ``(``p2a`` ``+`` ``p3a``)``, ft_rate ``=`` ``fta`` ``/`` ``(``p2a`` ``+`` ``p3a``)``)`\
`stat_vars`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``Points ``=`` ``"pts36"``, Assists ``=`` ``"ast36"``, Rebounds ``=`` ``"reb36"``, Steals ``=`` ``"stl36"``, Blocks ``=`` ``"blk36"``,`\
`               Turnovers ``=`` ``"tov36"``` , `3PA share`  ```=`` ``"three_rate"``` , `Rim share`  ```=`` ``"rim_rate"``` , `FT rate`  ```=`` ``"ft_rate"``)`\
`prof_vars`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``Points ``=`` ``"pts36"``, Assists ``=`` ``"ast36"``, Rebounds ``=`` ``"reb36"``, Steals ``=`` ``"stl36"``, Blocks ``=`` ``"blk36"``,`\
``                `Ball security`  ```=`` ``"tov36"``` , `3PA share`  ```=`` ``"three_rate"``` , `Rim share`  ```=`` ``"rim_rate"``` , `FT rate`  ```=`` ``"ft_rate"``)`\
`mvps`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Nikola Jokic"``, ``"Shai Gilgeous-Alexander"``, ``"Victor Wembanyama"``, ``"Stephen Curry"``)`\
\
`nba`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``pl``, ``league`` ``==`` ``"NBA"``)`\
`out``(`[`plot_profile`](https://loukesio.github.io/ggbasket/reference/plot_profile.md)`(``nba``, ``"player"``, ``prof_vars``, reverse ``=`` ``"tov36"``, subjects ``=`` ``mvps``, ncol ``=`` ``2``,`\
`                 title ``=`` ``"Four MVP-level fingerprints"``,`\
`                 subtitle ``=`` ``"Percentile among NBA players with 1,000+ minutes (per 36 minutes; shaded = middle half)"``,`\
`                 caption ``=`` ``cap_now``)``, ``"17_profile"``, ``9``, ``7``)`\
`out``(`[`plot_profile`](https://loukesio.github.io/ggbasket/reference/plot_profile.md)`(``nba``, ``"player"``, ``prof_vars``, reverse ``=`` ``"tov36"``, style ``=`` ``"radar"``, subjects ``=`` ``mvps``, ncol ``=`` ``4``,`\
`                 title ``=`` ``"The same fingerprints as radars, on percentiles"``, caption ``=`` ``cap_now``)``, ``"18_profile_radar"``, ``13``, ``4.2``)`\
\
`out``(`[`plot_quadrant`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``pl``, ``minutes`` ``>=`` ``1500``)``, ``"ast36"``, ``"tov36"``, label ``=`` ``"player"``, colour ``=`` ``"league"``,`\
`                  size ``=`` ``"pts36"``, highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Nikola Jokic"``, ``"Trae Young"``, ``"Kendrick Nunn"``, ``"Facundo Campazzo"``, ``"Tyrese Haliburton"``)``,`\
`                  corners ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Turnover-prone"``, ``"High-load creators"``, ``"Off-ball roles"``, ``"Careful creators"``)``,`\
`                  xlab ``=`` ``"Assists per 36 minutes"``, ylab ``=`` ``"Turnovers per 36 minutes"``, size_lab ``=`` ``"Points per 36"``,`\
`                  title ``=`` ``"Creating costs turnovers - but not equally"``, caption ``=`` ``cap_now``)``, ``"19_quadrant"``, ``9``, ``7``)`\
\
`pr`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(`[`player_rates`](https://loukesio.github.io/ggbasket/reference/player_rates.md)`(``player_seasons``, ``team_seasons``)``, ``league`` ``==`` ``"NBA"`` ``&`` ``minutes`` ``>=`` ``1500``)`\
`out``(`[`plot_joint`](https://loukesio.github.io/ggbasket/reference/plot_joint.md)`(``pr``, ``"usg_pct"``, ``"ts_pct"``, label ``=`` ``"player"``,`\
`               highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Shai Gilgeous-Alexander"``, ``"Nikola Jokic"``, ``"Giannis Antetokounmpo"``, ``"Stephen Curry"``,`\
`                             ``"Victor Wembanyama"``, ``"Anthony Edwards"``, ``"Luka Doncic"``, ``"Jayson Tatum"``)``,`\
`               xlab ``=`` ``"Usage rate (share of team plays used on the floor) →"``,`\
`               ylab ``=`` ``"True shooting % →"``, x_labels ``=`` ``scales``::`[`label_percent`](https://scales.r-lib.org/reference/label_percent.html)`(``)``, y_labels ``=`` ``scales``::`[`label_percent`](https://scales.r-lib.org/reference/label_percent.html)`(``)``,`\
`               title ``=`` ``"Stars bend the usage–efficiency curve"``,`\
`               subtitle ``=`` ``"Most NBA players with 1,500+ minutes sit in the purple cloud. The stars use a third of their team's plays and still score efficiently"``,`\
`               caption ``=`` ``cap_now``)``, ``"20_joint"``, ``9``, ``8``)`\
\
`out``(`[`plot_fit`](https://loukesio.github.io/ggbasket/reference/plot_fit.md)`(`[`subset`](https://rdrr.io/r/base/subset.html)`(``pl``, ``league`` ``==`` ``"NBA"``)``, ``"ast36"``, ``"tov36"``, label ``=`` ``"player"``, above_is_good ``=`` ``FALSE``,`\
`             xlab ``=`` ``"Assists per 36"``, ylab ``=`` ``"Turnovers per 36"``,`\
`             title ``=`` ``"For their assist load, who protects the ball?"``, caption ``=`` ``cap_now``)``, ``"21_fit"``, ``9``, ``6.5``)`\
\
`okc_box`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(`[`box_score`](https://loukesio.github.io/ggbasket/reference/box_score.md)`(``nba_reg``, total ``=`` ``TRUE``)``, ``team`` ``==`` ``"OKC"`` ``&`` ``min`` ``>=`` ``600``)`\
\
`out``(`[`plot_spread`](https://loukesio.github.io/ggbasket/reference/plot_spread.md)`(``okc_box``, `[`c`](https://rdrr.io/r/base/c.html)`(``"p2m"``, ``"p3m"``, ``"ftm"``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``"p2a"``, ``"p3a"``, ``"fta"``)``,`\
`                labels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"2-point shots"``, ``"3-point shots"``, ``"Free throws"``)``, shrink ``=`` ``FALSE``, min_attempts ``=`` ``50``, label_top ``=`` ``2``,`\
`                title ``=`` ``"OKC 2024/25: who carries the shooting?"``,`\
`                subtitle ``=`` ``"Season percentages of every player with 600+ minutes and 50+ attempts of that kind (size = attempts); red tick = team average; CV = weighted coefficient of variation"``,`\
`                caption ``=`` ``cap_nba``)``, ``"22_spread"``, ``9``, ``5``)`\
\
`out``(`[`plot_ranked`](https://loukesio.github.io/ggbasket/reference/plot_ranked.md)`(``okc_box``, ``"player"``, `[`c`](https://rdrr.io/r/base/c.html)`(``` `2PA`  ```=`` ``"p2a"``` , `3PA`  ```=`` ``"p3a"``, FTA ``=`` ``"fta"``)``, line ``=`` ``"pm"``,`\
`                order_by ``=`` ``"pm"``, line_label ``=`` ``"Plus-minus"``,`\
`                title ``=`` ``"OKC 2024/25: shot diet, ordered by plus-minus"``, caption ``=`` ``cap_nba``)``, ``"23_ranked"``, ``9``, ``6``)`\
\
`out``(`[`plot_corr_matrix`](https://loukesio.github.io/ggbasket/reference/plot_corr_matrix.md)`(``pl``, `[`c`](https://rdrr.io/r/base/c.html)`(``Points ``=`` ``"pts36"``, Assists ``=`` ``"ast36"``, Turnovers ``=`` ``"tov36"``, Rebounds ``=`` ``"reb36"``,`\
`                           Blocks ``=`` ``"blk36"``, Steals ``=`` ``"stl36"``` , `3PA share`  ```=`` ``"three_rate"``,`\
``                            `Rim share`  ```=`` ``"rim_rate"``` , `FT rate`  ```=`` ``"ft_rate"``)``,`\
`                     title ``=`` ``"What goes together in a stat line"``, caption ``=`` ``cap_now``)``, ``"24_corr"``, ``8``, ``7``)`\
\
`big`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``pl``, ``league`` ``==`` ``"NBA"`` ``&`` ``minutes`` ``>=`` ``1500``)`\
`out``(`[`plot_similarity_map`](https://loukesio.github.io/ggbasket/reference/plot_similarity_map.md)`(``big``, ``stat_vars``, label ``=`` ``"player"``, colour ``=`` ``"position"``,`\
`                        highlight ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Nikola Jokic"``, ``"Victor Wembanyama"``, ``"Stephen Curry"``)``,`\
`                        title ``=`` ``"The NBA in two dimensions"``, caption ``=`` ``cap_now``)``, ``"25_map"``, ``10``, ``8``)`\
\
`big`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``pl``, ``league`` ``==`` ``"NBA"`` ``&`` ``minutes`` ``>=`` ``1500``)`\
`cq`` ``<-`` `[`cluster_quality`](https://loukesio.github.io/ggbasket/reference/cluster_quality.md)`(``big``, `[`unname`](https://rdrr.io/r/base/unname.html)`(``stat_vars``)``, k ``=`` ``2``:``12``)`\
`out``(`[`plot_cluster_quality`](https://loukesio.github.io/ggbasket/reference/cluster_quality.md)`(``cq``, choose ``=`` ``7``)``, ``"26_cluster_quality"``, ``8``, ``5``)`\
[`set.seed`](https://rdrr.io/r/base/Random.html)`(``1``)``; ``km`` ``<-`` `[`kmeans`](https://rdrr.io/r/stats/kmeans.html)`(`[`scale`](https://rdrr.io/r/base/scale.html)`(``big``[``, `[`unname`](https://rdrr.io/r/base/unname.html)`(``stat_vars``)``]``)``, ``7``, nstart ``=`` ``50``)`\
`out``(`[`plot_cluster_profiles`](https://loukesio.github.io/ggbasket/reference/plot_cluster_profiles.md)`(``big``, ``stat_vars``, ``km``$``cluster``, label ``=`` ``"player"``,`\
`                          title ``=`` ``"Seven kinds of NBA player"``, caption ``=`` ``cap_now``)``, ``"27_cluster_profiles"``, ``11``, ``7``)`
