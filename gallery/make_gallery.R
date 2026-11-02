# The ggbasket gallery: every figure drawn from real 2024/25 NBA and EuroLeague data.
# Run from the package root: Rscript gallery/make_gallery.R [figure ...]
# Season play-by-play comes from data-raw/make_pbp.R ($GGBASKET_PBP, default ../00_data/pbp_2024).
suppressMessages({ devtools::load_all(quiet = TRUE); library(ggplot2); library(dplyr) })
out <- function(p, name, w = 8, h = 6) {
  ggsave(file.path("gallery/figures", paste0(name, ".png")), p, width = w, height = h, dpi = 150,
         bg = ggbasket_colours$paper)
}
which_fig <- commandArgs(trailingOnly = TRUE)
want <- function(x) length(which_fig) == 0 || x %in% which_fig

P <- Sys.getenv("GGBASKET_PBP", "../00_data/pbp_2024")
nba_pbp <- arrow::read_parquet(file.path(P, "nba_pbp_2024.parquet"))
el_pbp <- arrow::read_parquet(file.path(P, "el_pbp_2024.parquet"))
nba_reg <- filter(nba_pbp, phase == "regular"); el_reg <- filter(el_pbp, phase == "regular")
cap_nba <- ggbasket_caption("NBA 2024/25 play-by-play · ESPN via hoopR")
cap_el <- ggbasket_caption("EuroLeague 2024/25 play-by-play · EuroLeague live API")
cap_both <- ggbasket_caption("2024/25 play-by-play · ESPN via hoopR, EuroLeague live API")
cap_now <- ggbasket_caption("2024/25 regular season · NBA Stats, ESPN, EuroLeague API")
okc <- "#007AC1"; ind <- "#FDBB30"

# ---- One game ---------------------------------------------------------------------------------
g7 <- "401766128"
if (want("flow")) {
  out(plot_game_flow(nba_pbp, g7, min_run = 7, colours = c(okc, "#B8860B"),
                     title = "Game 7 was close for 27 minutes, then OKC ran away",
                     subtitle = paste("2025 NBA Finals, Game 7. Lead of", colour_text("Oklahoma City", okc), "(up) or",
                                      colour_text("Indiana", "#B8860B"), "(down). Tyrese Haliburton tore his Achilles in the first quarter; OKC broke the game open with a **13-0 run** in the third. Brackets = runs of 7+ unanswered points"),
                     caption = cap_nba), "01_game_flow", 10, 5.5)
  el_final <- "E2024_330"
  f <- game_flow(filter(el_pbp, game_id == el_final)); last <- f[nrow(f), ]
  half <- f[f$totalTime <= 1200, ]; half <- half[nrow(half), ]
  out(plot_game_flow(el_pbp, el_final, min_run = 7, colours = c("#C8102E", "#1B2A4A"),
                     title = sprintf("Monaco controlled the first half; Fenerbahce won the second %d-%d",
                                     last$away_score - half$away_score, last$home_score - half$home_score),
                     subtitle = sprintf("EuroLeague final 2025, %s %d-%d %s. Lead of %s (up) or %s (down); brackets = runs of 7+ unanswered points",
                                        last$hometeam, last$home_score, last$away_score, last$awayteam,
                                        colour_text("Monaco", "#C8102E"), colour_text("Fenerbahce", "#1B2A4A")),
                     caption = cap_el), "02_game_flow_el", 10, 5.5)
}
if (want("wp")) {
  gs <- game_summary(nba_reg)
  top <- gs$game_id[which.max(gs$excitement)]
  bx <- box_score(filter(nba_reg, game_id == top))
  star <- bx[which.max(bx$pts), ]
  wp <- win_probability(filter(nba_reg, game_id == top))
  r <- gs[gs$game_id == top, ]
  out(plot_win_probability(wp, top, n_key = 4, colours = c("#0E2240", "#78BE20"),
                           title = sprintf("The season's wildest game: %s scored %d and %s lost by one", star$player,
                                           as.integer(star$pts), star$team),
                           subtitle = sprintf("%s after two overtimes, %d lead changes. Chance that %s (up) or %s (down) wins after every play, from a two-parameter score model fitted on the season.",
                                              r$score, r$lead_changes, colour_text(r$hometeam, "#0E2240"),
                                              colour_text(r$awayteam, "#5A9A12")),
                           caption = cap_nba), "03_win_probability", 10, 6.3)
}
if (want("factors")) {
  gf <- game_factors(box_score(filter(nba_pbp, phase %in% c("regular", "playoffs")), by = "team"))
  out(plot_game_factors(gf, g7, team = "OKC",
                        title = "Game 7 was won on turnovers, not shooting",
                        subtitle = "OKC shot worse than Indiana but had 15 more chances: what each of the four factors was worth to OKC's 12-point win, from a regression of margin on four-factor differences over all 1,314 games of the season",
                        caption = cap_nba), "04_game_factors", 9, 5)
}

# ---- A season of games ------------------------------------------------------------------------
if (want("onoff")) {
  oo <- on_off(nba_reg, team = "DEN", min_minutes = 500)
  j <- oo[oo$player == "Nikola Jokic", ]
  out(plot_on_off(oo, n = 11,
                  title = sprintf("Denver were %+.0f with Jokic on the floor and %+.0f without him", j$on_net, j$off_net),
                  subtitle = "Denver's net rating (points per 100 possessions) with each player on (filled) and off (open) the floor, 2024/25 regular season. On/off mixes a player's impact with that of their team-mates, so read it with minutes",
                  caption = cap_nba), "05_on_off", 9, 6)
}
if (want("consistency")) {
  bx <- game_score(box_score(nba_reg))
  stars <- c("Nikola Jokic", "Shai Gilgeous-Alexander", "Giannis Antetokounmpo", "Luka Doncic", "Anthony Edwards",
             "Jayson Tatum", "Stephen Curry", "Victor Wembanyama")
  out(plot_consistency(bx, stars, min_minutes = 15,
                       title = "Jokic's bad nights are other stars' good ones",
                       subtitle = "Game Score in every game of 2024/25 (Hollinger's box-score summary, about 10 = an average game, 40 = outstanding). Grey box = middle half of games, black tick = median",
                       caption = cap_nba), "06_consistency", 10, 7)
}
if (want("network")) {
  net <- assist_network(filter(nba_reg, team == "DEN"))
  out(plot_assist_network(net, min_assists = 25, top_n = 9,
                          title = "Denver's offence runs through Jokic", caption = cap_nba), "07_assist_network", 10, 8)
  out(plot_assist_matrix(net, top_n = 9, title = "Denver 2024/25: passer to scorer", caption = cap_nba),
      "08_assist_matrix", 8.5, 7)
  jk <- net$nodes[net$nodes$player == "Nikola Jokic", ]
  out(plot_assist_roles(net, min_assists = 60,
                        title = sprintf("Jokic is the hub: %d assists, %.0f%% of Denver's, %.1f times the next player",
                                        as.integer(jk$assists), 100 * jk$ast_share,
                                        jk$assists / sort(net$nodes$assists, decreasing = TRUE)[2]),
                        caption = cap_nba), "09_assist_roles", 9, 6.5)
}
if (want("pressure") || want("association") || want("shotclock")) {
  ps_nba <- expected_fg(pressure_situations(nba_reg, league = "NBA", orb_reset = 14))
  ps_el <- expected_fg(pressure_situations(el_reg, league = "EuroLeague", orb_reset = 14))
}
if (want("pressure")) {
  e_nba <- pressure_effects(ps_nba); e_el <- pressure_effects(ps_el)
  te <- function(e) 100 * e$effect[e$situation == "shot_clock" & e$level == "time-end"]
  out(plot_pressure(e_nba,
                    title = "The shot clock is the real pressure",
                    subtitle = sprintf("Change in make probability against each situation's reference, after accounting for where the shot was taken. In the NBA, shots with **2 seconds or less** on the (estimated) shot clock go in **%.1f points less often** (EuroLeague: %.1f); the score and hot or cold streaks barely matter. Bars = 90%% intervals",
                                       abs(te(e_nba)), abs(te(e_el))),
                    caption = ggbasket_caption("NBA 2024/25 regular season, every field-goal attempt · ESPN via hoopR",
                                               note = "Shot clock estimated from play-by-play. Logistic regression with location-based expected FG% as offset")),
      "10_pressure", 9, 8)
}
if (want("association")) {
  ps_nba$dist <- sqrt(ps_nba$x^2 + ps_nba$y^2)
  set.seed(1)
  s <- ps_nba[sample(nrow(ps_nba), 40000), ]
  out(plot_association(association(s, c(Made = "made", `Shot value` = "value", Distance = "dist",
                                        `Shot clock` = "shot_clock_left", `End of period` = "period_end",
                                        Score = "score_diff", `Last shot` = "prev_miss", Period = "period")),
                       title = "Location matters; the situation barely registers",
                       caption = cap_nba), "11_association", 9, 8)
}
if (want("shotclock")) {
  both <- bind_rows(ps_nba, ps_el)
  sc <- shot_curve(both, "shot_clock_left", by = "league", outcome = "points", n_boot = 100, bw = 1.2)
  out(plot_shot_curve(sc, xlab = "Seconds left on the shot clock (estimated)",
                      title = "As the shot clock runs down, so does the value of a shot",
                      subtitle = paste0("Expected points per field-goal attempt by time left on the shot clock, in the ",
                                        colour_text("NBA", "NBA"), " and the ", colour_text("EuroLeague", "EuroLeague"),
                                        ". Early shots (mostly transition) are worth 1.25-1.35 points; with 2 seconds left, under 1. EuroLeague attempts are worth more at almost every clock reading. Line width = where shots are taken; band = 90% bootstrap"),
                      caption = cap_both) + scale_x_reverse(), "12_shot_clock", 9, 5.8)
}

# ---- Teams --------------------------------------------------------------------------------------
ff <- four_factors(team_seasons)
if (want("ratings")) {
  el_ff <- subset(ff, league == "EuroLeague")
  out(plot_net_rating(ff, "EuroLeague", highlight = c("OLY", "PAN", "ULK", "MCO"),
                      title = "Panathinaikos and Olympiacos won with offence, Fenerbahce and Real Madrid with defence",
                      subtitle = paste("EuroLeague 2024/25. Net rating (black dot and number) =", colour_text("offence", "#E07B00"),
                                       "(points scored above average) +", colour_text("defence", "#1F5FA8"),
                                       "(points allowed below average), per 100 possessions. Grey band = the Final Four"),
                      caption = cap_now), "13_ratings", 9, 7)
  out(plot_net_rating(ff, "NBA", highlight = c("OKC", "CLE", "BOS", "HOU"),
                      title = "OKC's net rating was built on the league's best defence",
                      caption = cap_now), "13b_ratings_nba", 9, 9.5)
}
if (want("fourfactors")) {
  ff4 <- ff
  nm <- c(OLY = "Olympiacos", PAN = "Panathinaikos", ULK = "Fenerbahce", MCO = "Monaco")
  ff4$team[ff4$team %in% names(nm)] <- nm[ff4$team[ff4$team %in% names(nm)]]
  out(plot_factor_ranks(ff4, unname(nm),
                        title = "Panathinaikos shot best, Fenerbahce defended best, Monaco looked after the ball, Olympiacos lived at the line",
                        caption = cap_now), "14_four_factors", 11.5, 4.8)
}
if (want("luck")) {
  out(plot_luck(expected_wins(team_seasons), n = 6,
                title = "The Lakers won six more games than their point margin says",
                subtitle = paste("Open circle = wins expected from points scored and allowed; filled = actual wins.",
                                 colour_text("Red", ggbasket_colours$above), "= luckier,",
                                 colour_text("blue", ggbasket_colours$below), "= unluckier. Six luckiest and unluckiest per league"),
                caption = cap_now), "15_luck", 10, 6)
}
if (want("lorenz")) {
  out(plot_lorenz(subset(player_seasons, league == "NBA"), "pts", "team", n = 8, value_label = "points",
                  title = "Who depends on a few scorers?", caption = cap_now), "16_lorenz", 7.5, 7.5)
}

# ---- Players ------------------------------------------------------------------------------------
pl <- subset(player_seasons, minutes >= 1000)
pl <- transform(pl, pts36 = 36 * pts / minutes, ast36 = 36 * ast / minutes, reb36 = 36 * (orb + drb) / minutes,
                stl36 = 36 * stl / minutes, blk36 = 36 * blk / minutes, tov36 = 36 * tov / minutes,
                three_rate = p3a / (p2a + p3a), rim_rate = rim / (p2a + p3a), ft_rate = fta / (p2a + p3a))
stat_vars <- c(Points = "pts36", Assists = "ast36", Rebounds = "reb36", Steals = "stl36", Blocks = "blk36",
               Turnovers = "tov36", `3PA share` = "three_rate", `Rim share` = "rim_rate", `FT rate` = "ft_rate")
prof_vars <- c(Points = "pts36", Assists = "ast36", Rebounds = "reb36", Steals = "stl36", Blocks = "blk36",
               `Ball security` = "tov36", `3PA share` = "three_rate", `Rim share` = "rim_rate", `FT rate` = "ft_rate")
mvps <- c("Nikola Jokic", "Shai Gilgeous-Alexander", "Victor Wembanyama", "Stephen Curry")
if (want("profile")) {
  nba <- subset(pl, league == "NBA")
  out(plot_profile(nba, "player", prof_vars, reverse = "tov36", subjects = mvps, ncol = 2,
                   title = "Four MVP-level fingerprints",
                   subtitle = "Percentile among NBA players with 1,000+ minutes (per 36 minutes; shaded = middle half)",
                   caption = cap_now), "17_profile", 9, 7)
  out(plot_profile(nba, "player", prof_vars, reverse = "tov36", style = "radar", subjects = mvps, ncol = 4,
                   title = "The same fingerprints as radars, on percentiles", caption = cap_now), "18_profile_radar", 13, 4.2)
}
if (want("quadrant")) {
  out(plot_quadrant(subset(pl, minutes >= 1500), "ast36", "tov36", label = "player", colour = "league",
                    size = "pts36", highlight = c("Nikola Jokic", "Trae Young", "Kendrick Nunn", "Facundo Campazzo", "Tyrese Haliburton"),
                    corners = c("Turnover-prone", "High-load creators", "Off-ball roles", "Careful creators"),
                    xlab = "Assists per 36 minutes", ylab = "Turnovers per 36 minutes", size_lab = "Points per 36",
                    title = "Creating costs turnovers - but not equally", caption = cap_now), "19_quadrant", 9, 7)
}
if (want("joint")) {
  pr <- subset(player_rates(player_seasons, team_seasons), league == "NBA" & minutes >= 1500)
  out(plot_joint(pr, "usg_pct", "ts_pct", label = "player",
                 highlight = c("Shai Gilgeous-Alexander", "Nikola Jokic", "Giannis Antetokounmpo", "Stephen Curry",
                               "Victor Wembanyama", "Anthony Edwards", "Luka Doncic", "Jayson Tatum"),
                 xlab = "Usage rate (share of team plays used on the floor) →",
                 ylab = "True shooting % →", x_labels = scales::label_percent(), y_labels = scales::label_percent(),
                 title = "Stars bend the usage–efficiency curve",
                 subtitle = "Most NBA players with 1,500+ minutes sit in the purple cloud. The stars use a third of their team's plays and still score efficiently",
                 caption = cap_now), "20_joint", 9, 8)
}
if (want("fit")) {
  out(plot_fit(subset(pl, league == "NBA"), "ast36", "tov36", label = "player", above_is_good = FALSE,
               xlab = "Assists per 36", ylab = "Turnovers per 36",
               title = "For their assist load, who protects the ball?", caption = cap_now), "21_fit", 9, 6.5)
}
if (want("spread") || want("ranked")) {
  okc_box <- subset(box_score(nba_reg, total = TRUE), team == "OKC" & min >= 600)
}
if (want("spread")) {
  out(plot_spread(okc_box, c("p2m", "p3m", "ftm"), c("p2a", "p3a", "fta"),
                  labels = c("2-point shots", "3-point shots", "Free throws"), shrink = FALSE, min_attempts = 50, label_top = 2,
                  title = "OKC 2024/25: who carries the shooting?",
                  subtitle = "Season percentages of every player with 600+ minutes and 50+ attempts of that kind (size = attempts); red tick = team average; CV = weighted coefficient of variation",
                  caption = cap_nba), "22_spread", 9, 5)
}
if (want("ranked")) {
  out(plot_ranked(okc_box, "player", c(`2PA` = "p2a", `3PA` = "p3a", FTA = "fta"), line = "pm",
                  order_by = "pm", line_label = "Plus-minus",
                  title = "OKC 2024/25: shot diet, ordered by plus-minus", caption = cap_nba), "23_ranked", 9, 6)
}
if (want("corr")) {
  out(plot_corr_matrix(pl, c(Points = "pts36", Assists = "ast36", Turnovers = "tov36", Rebounds = "reb36",
                             Blocks = "blk36", Steals = "stl36", `3PA share` = "three_rate",
                             `Rim share` = "rim_rate", `FT rate` = "ft_rate"),
                       title = "What goes together in a stat line", caption = cap_now), "24_corr", 8, 7)
}
if (want("map")) {
  big <- subset(pl, league == "NBA" & minutes >= 1500)
  out(plot_similarity_map(big, stat_vars, label = "player", colour = "position",
                          highlight = c("Nikola Jokic", "Victor Wembanyama", "Stephen Curry"),
                          title = "The NBA in two dimensions", caption = cap_now), "25_map", 10, 8)
}
if (want("clusters")) {
  big <- subset(pl, league == "NBA" & minutes >= 1500)
  cq <- cluster_quality(big, unname(stat_vars), k = 2:12)
  out(plot_cluster_quality(cq, choose = 7), "26_cluster_quality", 8, 5)
  set.seed(1); km <- kmeans(scale(big[, unname(stat_vars)]), 7, nstart = 50)
  out(plot_cluster_profiles(big, stat_vars, km$cluster, label = "player",
                            title = "Seven kinds of NBA player", caption = cap_now), "27_cluster_profiles", 11, 7)
}

# ---- Shots --------------------------------------------------------------------------------------
nba_sh <- subset(shots_2024, league == "NBA"); el_sh <- subset(shots_2024, league == "EuroLeague")
if (want("hex")) {
  out(plot_shot_hex(subset(nba_sh, player %in% mvps), baseline = nba_sh, facet = "player",
                    title = "Four stars, four shot diets", caption = cap_now), "28_shot_hex", 10, 9)
}
if (want("zones")) {
  out(plot_shot_zones(subset(nba_sh, player == "Nikola Jokic"), baseline = nba_sh,
                      title = "Nikola Jokic, 2024/25: elite from everywhere inside the arc", caption = cap_now), "29_shot_zones", 8, 6.5)
  out(plot_shot_zones(subset(el_sh, player == "Sasha Vezenkov"), baseline = el_sh, league = "EuroLeague",
                      title = "Sasha Vezenkov, EuroLeague 2024/25 (FIBA court)", caption = cap_now), "30_shot_zones_el", 8, 6.5)
}
if (want("density")) {
  out(plot_shot_density(subset(nba_sh, player %in% c("Stephen Curry", "Giannis Antetokounmpo")), compare = nba_sh,
                        facet = "player", title = "Shot diet compared with the average NBA player",
                        caption = cap_now), "31_density", 11, 5.5)
}
if (want("curve")) {
  both <- shots_2024
  both$dist <- sqrt(both$x^2 + both$y^2)
  both <- subset(both, dist < 9)
  sc <- shot_curve(both, "dist", by = "league", outcome = "points", n_boot = 100, bw = 0.25, split_value = TRUE)
  out(plot_shot_curve(sc, vlines = c("FIBA 3pt 6.75 m" = 6.75, "NBA 3pt 7.24 m" = 7.24),
                      xlab = "Shot distance from the hoop (m)",
                      title = "Same mid-range desert, different oasis",
                      subtitle = paste("Expected points per shot by distance in the", colour_text("NBA", "NBA"), "and the", colour_text("EuroLeague", "EuroLeague"), "(2s and 3s smoothed separately). Both lose value between the rim and the arc, but the FIBA line is half a metre closer, so **EuroLeague shooters reach 1+ point per shot sooner**. Line width = where shots are taken; band = 90% bootstrap"),
                      caption = paste(cap_now, "Note: EuroLeague operators record layups ~1 m from the hoop, so the EuroLeague curve starts late.", sep = "<br>")),
      "32_curve_leagues", 9, 5.8)
}
if (want("making")) {
  sm <- shot_making(expected_fg(shots_2024), prior_n = 150)
  out(plot_shot_making(subset(sm, league == "NBA"), min_attempts = 500,
                       highlight = c("Stephen Curry", "Nikola Jokic", "Shai Gilgeous-Alexander"),
                       title = "Jokic, Curry and SGA make hard shots look easy",
                       subtitle = "NBA 2024/25. Each shot graded against a league model of make probability by location; players with 500+ attempts",
                       caption = cap_now), "33_shot_making", 9, 7)
}
if (want("courts")) {
  el_stars <- c("Carsen Edwards", "Kendrick Nunn", "Mike James", "Sasha Vezenkov")
  out(plot_shot_hex(subset(el_sh, player %in% el_stars), baseline = el_sh, facet = "player", league = "EuroLeague",
                    title = "Four EuroLeague scorers, four shot diets", caption = cap_now), "34_hex_el", 10, 9)
  out(plot_shot_density(el_sh, compare = nba_sh, league = "EuroLeague",
                        title = "A shorter three-point line pulls EuroLeague shots inwards",
                        subtitle = paste("Where", colour_text("EuroLeague", "EuroLeague"), "teams shoot from, compared with the",
                                         colour_text("NBA", "NBA"), "(metres from the hoop, FIBA court drawn). Red = a bigger share of shots from there than in the NBA; blue = smaller. The FIBA arc is 0.5 m closer, so EuroLeague threes sit just inside the NBA arc"),
                        caption = paste(cap_now, "Note: EuroLeague operators record layups about 1 m from the hoop, so the blue at the rim and the red ring around it are partly a recording artefact.", sep = "<br>")),
      "35_density_leagues", 8, 7.2)
  op <- subset(el_sh, team %in% c("OLY", "PAN"))
  op$team <- c(OLY = "Olympiacos", PAN = "Panathinaikos")[op$team]
  out(plot_shot_density(op, compare = el_sh, facet = "team", league = "EuroLeague",
                        title = "Olympiacos and Panathinaikos: two ways to attack",
                        subtitle = "Each team's shot locations compared with the average EuroLeague team, 2024/25 regular season. Red = shoots there more, blue = less",
                        caption = cap_now), "36_density_teams", 11, 5.6)
  fin <- as_ggbasket_shots(filter(el_pbp, game_id == "E2024_330"), league = "EuroLeague")
  fin$team <- c(ULK = "Fenerbahce", MCO = "Monaco")[fin$team]
  out(plot_shot_density(fin, facet = "team", points = TRUE, league = "EuroLeague",
                        title = "The 2025 EuroLeague final, every shot",
                        subtitle = "Where each team shot from in the final (Fenerbahce 81, Monaco 70): heat = shot density, dots = made, crosses = missed",
                        caption = cap_el), "37_game_shots", 11, 5.8)
}
if (want("literature")) {
  tr <- team_ratings(bind_rows(box_score(nba_reg, by = "team"), box_score(el_reg, by = "team")))
  out(plot_team_ratings(tr, title = "Once the schedule is accounted for, OKC were 12.7 points better than an average team",
                        caption = cap_both), "38_team_ratings", 11, 9)
  rp <- rapm(nba_reg, lambda = 3000, min_poss = 1000)
  out(plot_rapm(rp, n = 12, highlight = c("Shai Gilgeous-Alexander", "Nikola Jokic"),
                title = "Separated from their team-mates, SGA and Jokic still add the most",
                caption = ggbasket_caption("NBA 2024/25 regular season, every line-up stint · ESPN via hoopR",
                                           note = "Players with 1,000+ possessions; ridge penalty 3,000 possessions")), "39_rapm", 11, 7)
  rpe <- rapm(el_reg, lambda = 1500, min_poss = 500)
  out(plot_rapm(rpe, n = 10, highlight = c("Sasha Vezenkov", "Walter Tavares"),
                title = "EuroLeague adjusted plus-minus: Jantunen, Weiler-Babb and Tavares lead",
                caption = ggbasket_caption("EuroLeague 2024/25 regular season, every line-up stint · EuroLeague live API",
                                           note = "Players with 500+ possessions; ridge penalty 1,500 possessions. One season of a 34-game league: treat as a rough guide")), "40_rapm_el", 11, 6.5)
  wpa <- win_probability_added(win_probability(filter(nba_pbp, game_id == g7)))
  out(plot_wpa(wpa, g7, colours = c(OKC = okc, IND = "#B8860B"),
               title = "Game 7: Gilgeous-Alexander's plays moved the needle most",
               caption = cap_nba), "41_wpa", 9, 6)
  lu <- lineups(nba_reg, team = "OKC", min_minutes = 30)
  out(plot_lineups(lu, n = 6, title = "OKC's best units all start with Gilgeous-Alexander, Williams and Dort",
                   subtitle = sprintf("OKC's %d five-player units with 30+ minutes together, 2024/25 regular season, by net rating; dot size = minutes. %d of them outscored opponents",
                                      nrow(lu), sum(lu$net > 0)),
                   caption = cap_nba), "42_lineups", 10, 6.5)
  ps_all <- bind_rows(expected_fg(pressure_situations(nba_reg, "NBA", 14)), expected_fg(pressure_situations(el_reg, "EuroLeague", 14)))
  tp <- team_shot_profile(ps_all)
  lg <- tp |> group_by(league) |> summarise(s = weighted.mean(early_share, fga), p = weighted.mean(pps_early, fga * early_share))
  out(plot_quadrant(tp, "early_share", "pps_early", label = "team", colour = "league", highlight = c("ATL", "DEN", "MEM", "OKC", "OLY", "PAN", "BAS"),
                    corners = c("Rarely, but deadly", "Often and well", "Rarely and poorly", "Often, often wasted"),
                    xlab = "Share of shots taken early in the clock (17+ seconds left)", ylab = "Points per early shot",
                    title = "EuroLeague teams run less but score more when they do",
                    subtitle = sprintf("%s teams take %.0f%% of their shots early in the clock and score %.2f points per early shot; %s teams %.0f%% and %.2f. Olympiacos and Baskonia ran rarely but scored about 1.4 points a time",
                                       colour_text("NBA", "NBA"), 100 * lg$s[lg$league == "NBA"], lg$p[lg$league == "NBA"],
                                       colour_text("EuroLeague", "EuroLeague"), 100 * lg$s[lg$league == "EuroLeague"], lg$p[lg$league == "EuroLeague"]),
                    caption = cap_both) + ggplot2::scale_x_continuous(labels = scales::label_percent()), "43_transition", 9, 7)
  tpe <- subset(tp, league == "EuroLeague"); tpe$net <- tpe$xpps - tpe$o_xpps
  best <- tpe$team[which.max(tpe$net)]
  out(plot_quadrant(tpe, "xpps", "o_xpps", label = "team", highlight = c(best, "OLY", "PAN", "ULK", "MCO"),
                    corners = c("Losing the shot battle", "Good shots both ways", "Defence first", "Winning the shot battle"),
                    xlab = "Expected points per shot taken (from location) \u2192 better shots", ylab = "Expected points per shot allowed \u2192 easier shots for opponents",
                    title = sprintf("%s won the EuroLeague's shot-quality battle by the most", best),
                    subtitle = "Each team's shots and its opponents' shots, valued by a EuroLeague model of make probability by location, 2024/25 regular season. Bottom right is best: good shots taken, poor shots allowed",
                    caption = cap_el), "44_shot_quality", 9, 7)
}
cat("done\n")
