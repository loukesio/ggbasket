# Who is on court

Adds the players on court (`a1`-`a5` away, `h1`-`h5` home) to a
play-by-play in the ggbasket layout, rebuilt from substitutions (see
[pbp](https://loukesio.github.io/ggbasket/reference/pbp.md)). Rows of a
substitution keep the line-up from before it.

## Usage

``` r
add_lineups(pbp)
```

## Arguments

- pbp:

  Play-by-play in the ggbasket layout.

## Value

`pbp` with `a1`-`a5` and `h1`-`h5`.
