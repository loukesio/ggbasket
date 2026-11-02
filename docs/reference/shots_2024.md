# Every field-goal attempt of the 2024/25 regular season, NBA and EuroLeague

Every field-goal attempt of the 2024/25 regular season, NBA and
EuroLeague

## Usage

``` r
shots_2024
```

## Format

A tibble: `league`, `team`, `player`, `x`, `y` (metres from the hoop
centre, y towards half court), `value` (2/3), `made`. Eight NBA stars
carry full names (Stephen Curry, Nikola Jokic, Shai Gilgeous-Alexander,
Giannis Antetokounmpo, Victor Wembanyama, Anthony Edwards, Luka Doncic,
Jayson Tatum); other NBA players are "Surname (TEAM)". EuroLeague names
are full names.

## Source

NBA Stats shot chart detail (via hoopR) and the EuroLeague `Points` API.
Built by `data-raw/make_data.R`.
