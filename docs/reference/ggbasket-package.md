# ggbasket: learn from basketball games, NBA and EuroLeague

Tools to read play-by-play, box-score and shot data from the NBA and the
EuroLeague, turn them into the measures analysts use, and draw each
answer as a finished, story-first ggplot2 figure.

## Details

Conventions: column names are lower case (`pts`, `p3a`, `orb`, `tov`,
...), opponent stats carry an `o_` prefix, shot coordinates are metres
from the hoop centre with y pointing towards half court, and
play-by-play follows one layout for both leagues (see
[pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)).

Main entry points:

- Data:
  [`pbp_from_espn()`](https://loukesio.github.io/ggbasket/reference/pbp.md),
  [`fetch_euroleague_pbp()`](https://loukesio.github.io/ggbasket/reference/pbp.md),
  [`add_lineups()`](https://loukesio.github.io/ggbasket/reference/add_lineups.md),
  [`box_score()`](https://loukesio.github.io/ggbasket/reference/box_score.md)

- One game:
  [`plot_game_flow()`](https://loukesio.github.io/ggbasket/reference/plot_game_flow.md),
  [`scoring_runs()`](https://loukesio.github.io/ggbasket/reference/scoring_runs.md),
  [`win_probability()`](https://loukesio.github.io/ggbasket/reference/win_probability.md),
  [`plot_win_probability()`](https://loukesio.github.io/ggbasket/reference/plot_win_probability.md),
  [`game_factors()`](https://loukesio.github.io/ggbasket/reference/game_factors.md),
  [`plot_game_factors()`](https://loukesio.github.io/ggbasket/reference/plot_game_factors.md),
  [`game_summary()`](https://loukesio.github.io/ggbasket/reference/game_summary.md)

- A season of games:
  [`on_off()`](https://loukesio.github.io/ggbasket/reference/on_off.md),
  [`lineups()`](https://loukesio.github.io/ggbasket/reference/lineups.md),
  [`plot_on_off()`](https://loukesio.github.io/ggbasket/reference/plot_on_off.md),
  [`game_score()`](https://loukesio.github.io/ggbasket/reference/game_score.md),
  [`plot_consistency()`](https://loukesio.github.io/ggbasket/reference/plot_consistency.md),
  [`clutch_time()`](https://loukesio.github.io/ggbasket/reference/clutch_time.md),
  [`pressure_effects()`](https://loukesio.github.io/ggbasket/reference/pressure_effects.md),
  [`assist_network()`](https://loukesio.github.io/ggbasket/reference/assist_network.md)

- Teams:
  [`four_factors()`](https://loukesio.github.io/ggbasket/reference/four_factors.md),
  [`expected_wins()`](https://loukesio.github.io/ggbasket/reference/expected_wins.md),
  [`plot_ratings()`](https://loukesio.github.io/ggbasket/reference/plot_ratings.md),
  [`plot_four_factors()`](https://loukesio.github.io/ggbasket/reference/plot_four_factors.md),
  [`plot_luck()`](https://loukesio.github.io/ggbasket/reference/plot_luck.md)

- Players:
  [`player_rates()`](https://loukesio.github.io/ggbasket/reference/player_rates.md),
  [`plot_profile()`](https://loukesio.github.io/ggbasket/reference/plot_profile.md),
  [`plot_quadrant()`](https://loukesio.github.io/ggbasket/reference/plot_quadrant.md),
  [`plot_joint()`](https://loukesio.github.io/ggbasket/reference/plot_joint.md),
  [`plot_spread()`](https://loukesio.github.io/ggbasket/reference/plot_spread.md)

- Shots:
  [`plot_shot_hex()`](https://loukesio.github.io/ggbasket/reference/plot_shot_hex.md),
  [`plot_shot_zones()`](https://loukesio.github.io/ggbasket/reference/plot_shot_zones.md),
  [`shot_curve()`](https://loukesio.github.io/ggbasket/reference/shot_curve.md),
  [`shot_making()`](https://loukesio.github.io/ggbasket/reference/shot_making.md)

- Courts and style:
  [`geom_court()`](https://loukesio.github.io/ggbasket/reference/geom_court.md),
  [`theme_ggbasket()`](https://loukesio.github.io/ggbasket/reference/theme_ggbasket.md),
  [`colour_text()`](https://loukesio.github.io/ggbasket/reference/colour_text.md)

## See also

Useful links:

- <https://loukesio.github.io/ggbasket/>

- <https://github.com/loukesio/ggbasket>

- Report bugs at <https://github.com/loukesio/ggbasket/issues>

## Author

**Maintainer**: Loukas Theodosiou <loukesio@gmail.com>
