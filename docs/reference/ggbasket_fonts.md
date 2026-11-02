# Fonts used by the ggbasket theme

Returns the first installed family from each preference list: `body`
(Fira Sans Condensed, Roboto Condensed, Arial Narrow), `title` (Fira
Sans, Roboto, Helvetica Neue) and `mono` (Roboto Mono, Fira Mono,
Menlo). Falls back to `"sans"`/`"mono"` when none is installed, when the
current device is base
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html)/[`postscript()`](https://rdrr.io/r/grDevices/postscript.html),
or when `options(ggbasket.family)` is set.

## Usage

``` r
ggbasket_fonts()
```

## Value

A list with `body`, `title` and `mono`.

## Examples

``` r
ggbasket_fonts()
#> $body
#> [1] "Fira Sans Condensed"
#> 
#> $title
#> [1] "Fira Sans"
#> 
#> $mono
#> [1] "Roboto Mono"
#> 
```
