# Opponent-adjusted team ratings

The Simple Rating System: every game's margin is modelled as home
advantage + rating of the team - rating of the opponent, fitted by least
squares over all games with ratings summing to zero within a league. A
rating is the margin a team would have against an average opponent on a
neutral court, so a team with a soft schedule is marked down.

## Usage

``` r
team_ratings(teams)
```

## Arguments

- teams:

  Team-game box scores from `box_score(pbp, by = "team")`, with
  `game_id`, `team`, `oppTeam`, `pts`, `o_pts`, `home`, `league`.

## Value

A tibble per team: `games`, `mov` (average margin), `rating`, `sos`
(average opponent rating), `w`, `l`; the home advantage of each league
is attached as attribute `home_adv`.

## Examples

``` r
r <- team_ratings(box_score(pbp_games, by = "team"))
```
