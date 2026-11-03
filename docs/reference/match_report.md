# One-click match report

Downloads a game (or takes its play-by-play), runs every game-level
analysis in ggbasket and writes a single self-contained HTML report: key
findings in words, the game flow, win probability with the plays that
swung it, what decided the result, who mattered, every shot, box scores,
clutch time and line-ups. The file has its figures inside, so it can be
e-mailed or shared as it is.

## Usage

``` r
match_report(
  game = NULL,
  league = c("EuroLeague", "NBA"),
  season = NULL,
  pbp = NULL,
  file = NULL,
  context = FALSE,
  names = NULL,
  colours = NULL,
  open = interactive()
)
```

## Arguments

- game:

  EuroLeague game code (e.g. `90`) or ESPN game id (e.g. `"401766128"`).

- league:

  `"EuroLeague"` or `"NBA"`.

- season:

  EuroLeague season start year (e.g. `2026` for 2026/27).

- pbp:

  Play-by-play of the game, if already downloaded.

- file:

  Output file (default: `"<home>-<away>-<date>.html"` in the working
  directory).

- context:

  Also compare the game with both teams' season so far.

- names:

  Named vector of display names for team codes, e.g.
  `c(OLY = "Olympiacos", MIL = "Olimpia Milano")` (default: the full
  names that come with the play-by-play).

- colours:

  Two team colours, home first.

- open:

  Open the report when done.

## Value

The path of the report, invisibly.

## Details

A EuroLeague game takes a few seconds to download. With `context = TRUE`
the teams' other games of the season are downloaded too (about a minute)
to compare this game with their season.

## Examples

``` r
if (FALSE) { # \dontrun{
match_report(90, "EuroLeague", season = 2026, names = c(OLY = "Olympiacos", MIL = "Milano"))
match_report("401766128", "NBA")
match_report(pbp = subset(pbp_games, game_id == "401766128"), context = FALSE)
} # }
```
