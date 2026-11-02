# Possessions

The Kubatko et al. (2007) estimate: `FGA + ft_coef * FTA - ORB + TOV`.
The 0.44 coefficient fits the NBA; FIBA studies often use 0.4 or 0.5, so
it is an argument.

## Usage

``` r
possessions(fga, fta, orb, tov, ft_coef = 0.44)
```

## Arguments

- fga:

  Field-goal attempts (2PA + 3PA).

- fta, orb, tov:

  Free-throw attempts, offensive rebounds, turnovers.

- ft_coef:

  Weight of a free-throw attempt.

## Examples

``` r
possessions(fga = 88, fta = 22, orb = 10, tov = 13)
#> [1] 100.68
```
