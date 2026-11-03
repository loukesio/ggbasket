# Game situations that put a shooter under pressure

Following Zuccolotto et al. (2018), every field-goal attempt in a
play-by-play is tagged with five situations that may make a shot harder,
with their cut-offs:

## Usage

``` r
pressure_situations(pbp, league = "NBA", orb_reset = 14)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout (see
  [pbp](https://loukesio.github.io/ggbasket-site/reference/pbp.md)), all
  teams of each game.

- league:

  League label for
  [`expected_fg()`](https://loukesio.github.io/ggbasket-site/reference/expected_fg.md).

- orb_reset:

  Shot clock after an offensive rebound: 14 (NBA from 2018/19, FIBA
  from 2014) or 24 (NBA before 2018/19).

## Value

The field-goal attempts as from
[`as_ggbasket_shots()`](https://loukesio.github.io/ggbasket-site/reference/as_ggbasket_teams.md),
plus `shot_clock_left`, `score_margin`, `team_miss_rate` and the five
situation factors.

## Details

- `shot_clock`: seconds left on the shot clock, in four bands (`"early"`
  \> 17, `"early-middle"` 10-17, `"middle-end"` 2-10, `"time-end"` \<=
  2). Play-by-play feeds have no shot clock, so it is *estimated* as 24
  minus the seconds since the opponent's last action (shot, rebound,
  turnover), with a reset to `orb_reset` seconds after an offensive
  rebound.

- `period_end`: the last 100 seconds of a period.

- `score_diff`: shooting team's margin before the shot, in five bands.

- `team_misses`: share of the team's field goals missed so far in the
  game, split at its 25th and 75th percentiles.

- `prev_miss`: whether the shooter missed their previous shot in the
  game.
