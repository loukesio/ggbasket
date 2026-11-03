# The key findings of a game, in words

Turns the analyses of one game into short sentences for a report or an
e-mail: the result and how it unfolded, what decided it, the biggest
play, who mattered most and where the shots came from.

## Usage

``` r
match_story(pbp, names = NULL)
```

## Arguments

- pbp:

  Play-by-play of one game (ggbasket layout).

- names:

  Optional named vector of display names for team codes.

## Value

A character vector of findings (markdown).

## Examples

``` r
match_story(subset(pbp_games, game_id == "401766128"))
#> [1] "**OKC beat IND by 12** (103-91). There were 11 lead changes and 10 ties; the biggest leads were 22 for OKC and 5 for IND."                                   
#> [2] "**What decided it: turnovers.** It was worth about +21.5 points to OKC (23 turnovers against 8) even though IND shot better (49% against 47% effective FG%)."
#> [3] "**The biggest swing:** Cason Wallace makes 22-foot three point jumper (73-66, period 3), which moved OKC's chances by 10 points."                            
#> [4] "**Who mattered most:** Shai Gilgeous-Alexander for OKC (29 points, +33 points of win probability); T.J. McConnell for IND (16 points, +19)."                 
#> [5] "**Best run:** 13-0 OKC."                                                                                                                                     
#> [6] "**Shots:** OKC 24/47 twos, 11/40 threes; IND 18/42 twos, 11/28 threes."                                                                                      
#> [7] "The game never reached clutch time (last 5 minutes within 5 points)."                                                                                        
```
