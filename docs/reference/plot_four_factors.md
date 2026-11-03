# Four factors: where each team sits in the league

For each of the eight factors (four on offence, four on defence), every
team in the league is a grey dot; the teams in `teams` are coloured and
labelled. Axes are oriented so that right is always better, and the
facet strips carry Dean Oliver's weights, so it is clear that a big
advantage in free-throw rate matters less than a small one in shooting.
Values are against the whole league, not only the selected teams.

## Usage

``` r
plot_four_factors(
  ff,
  teams,
  label = "team",
  scale = c("z", "raw"),
  title = NULL,
  subtitle = NULL,
  caption = NULL
)
```

## Arguments

- ff:

  Output of
  [`four_factors()`](https://loukesio.github.io/ggbasket-site/reference/four_factors.md)
  for the whole league.

- teams:

  Teams to highlight (values of `label`).

- label:

  Team column.

- scale:

  `"raw"` (natural units) or `"z"` (standard deviations from the league
  mean, all panels on one scale).

- title, subtitle, caption:

  Labels.

## Examples

``` r
ff <- four_factors(subset(team_seasons, league == "EuroLeague"))
plot_four_factors(ff, teams = c("PAN", "FEN", "MCO", "OLY"))
```
