# Colour words in titles and subtitles

`colour_text()` wraps text in a coloured (and by default bold) HTML
span, for titles and subtitles drawn by
[`theme_ggbasket()`](https://loukesio.github.io/ggbasket-site/reference/theme_ggbasket.md):
naming the groups in their own colour makes a legend unnecessary.
`ggbasket_caption()` builds the standard "Data · Graphic" caption.

## Usage

``` r
colour_text(text, colour, bold = TRUE)

ggbasket_caption(data, graphic = "Loukas Theodosiou · ggbasket", note = NULL)
```

## Arguments

- text:

  Text to colour.

- colour:

  A colour; a name from `ggbasket_colours$league` also works.

- bold:

  Make it bold.

- data:

  Data source.

- graphic:

  Author credit.

- note:

  Optional extra line(s).

## Examples

``` r
colour_text("NBA", "NBA")
#> [1] "<span style='color:#1F5FA8'>**NBA**</span>"
ggbasket_caption("2024/25 regular season, NBA Stats and EuroLeague API")
#> [1] "**Data** 2024/25 regular season, NBA Stats and EuroLeague API &nbsp;·&nbsp; **Graphic** Loukas Theodosiou · ggbasket"
```
