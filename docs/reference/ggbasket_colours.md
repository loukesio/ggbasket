# Colours used across ggbasket

A named list: `league` (NBA / EuroLeague), `highlight` (one accent for
the subject of a figure), `context` (grey for everyone else),
`above`/`below` (the two ends of the diverging better/worse scale),
`diverging` (the full five-step scale), `offence`/`defence`,
`categorical` (groups), `ink`/`paper` (text and background) and
`court_line`/`court_floor`.

## Usage

``` r
ggbasket_colours
```

## Format

An object of class `list` of length 14.

## Details

The diverging scale is the `heatmap1` palette and the categorical
colours the `minou` palette of the 'ltc' package (Theodosiou), both
readable with red-green colour blindness.
