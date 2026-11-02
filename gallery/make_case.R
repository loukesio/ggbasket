# Case study: understanding one EuroLeague game, Olympiacos 84-78 Olimpia Milano (round 9, 30 Oct 2026).
# Run from the package root: Rscript gallery/make_case.R
# Downloads the 2026/27 season so far once (EuroLeague live API) and caches it.
suppressMessages({ devtools::load_all(quiet = TRUE); library(ggplot2); library(dplyr) })
P <- Sys.getenv("GGBASKET_PBP", "../00_data/pbp_2024")
f <- file.path(P, "el_pbp_2026_r1-9.parquet")
if (!file.exists(f)) arrow::write_parquet(fetch_euroleague_pbp(2026), f)
el <- arrow::read_parquet(f)
g <- "E2026_90"
gm <- filter(el, game_id == g)
oly <- "#C8102E"; mil <- "#2E4057"
cols <- c(OLY = oly, MIL = mil)
cap <- ggbasket_caption("EuroLeague 2026/27, round 9, 30 October 2026 · EuroLeague live API")
cap_s <- ggbasket_caption("EuroLeague 2026/27, rounds 1-9 · EuroLeague live API")
out <- function(p, name, w = 10, h = 5.6) ggsave(file.path("man/figures/case", paste0(name, ".png")), p, width = w, height = h, dpi = 150, bg = "white")
nm <- function(x) ifelse(x == "OLY", "Olympiacos", ifelse(x == "MIL", "Milano", x))

# 1. the story of the score
s <- game_summary(gm); runs <- scoring_runs(gm, 6)
out(plot_game_flow(el, g, min_run = 6, colours = cols,
                   title = sprintf("%d lead changes in the first 21 minutes, then Olympiacos never trailed", s$lead_changes),
                   subtitle = paste("Lead of", colour_text("Olympiacos", oly), "(up) or", colour_text("Milano", mil),
                                    "(down). Brackets = runs of 6+ unanswered points"), caption = cap), "01_flow")
# 2. the plays that decided it
wp <- win_probability(gm)
out(plot_win_probability(wp, g, n_key = 4, colours = cols,
                         title = "Olympiacos were favourites from the third quarter; Milano made it close late",
                         subtitle = paste("Chance that", colour_text("Olympiacos", oly), "(up) or", colour_text("Milano", mil),
                                          "(down) wins, after every play."), caption = cap), "02_win_probability", 10, 6.2)
# 3. why Olympiacos won
gf <- game_factors(box_score(el, by = "team"))
r <- gf[gf$game_id == g & gf$team == "OLY", ]
out(plot_game_factors(gf, g, team = "OLY",
                      title = "Milano shot better; Olympiacos won on turnovers and second chances",
                      subtitle = "What each of the four factors was worth to Olympiacos's 6-point win, from a regression over the 90 games of the season so far",
                      caption = cap), "03_factors", 9.5, 5)
# 4. this game against Olympiacos's own season
tb <- four_factors(box_score(filter(el, team == "OLY" | oppTeam == "OLY"), by = "team"))
tb <- tb[tb$team == "OLY", ]
tb$this <- tb$game_id == g
vars <- c(`Shooting (eFG%)` = "efg", `Opp. shooting (eFG%)` = "o_efg", `Turnover rate` = "tov_pct",
          `Opp. turnover rate` = "o_tov_pct", `Off. rebound rate` = "orb_pct", `Def. rebound rate` = "drb_pct")
long <- bind_rows(lapply(names(vars), function(v) tibble(var = v, value = tb[[vars[[v]]]], this = tb$this, game = tb$game_id)))
long$var <- factor(long$var, levels = names(vars))
out(ggplot(long, aes(value, var)) +
      geom_point(data = filter(long, !this), shape = 21, size = 2.6, fill = "grey80", colour = "white") +
      geom_point(data = filter(long, this), shape = 21, size = 4, fill = oly, colour = "white", stroke = 0.8) +
      geom_text(data = filter(long, this), aes(label = scales::percent(value, 1)), vjust = -1.1, size = 3.1,
                colour = oly, fontface = "bold") +
      scale_x_continuous(labels = scales::label_percent()) +
      facet_wrap(~var, scales = "free", ncol = 2) +
      theme_ggbasket(grid = "x") + theme(axis.text.y = element_blank(), strip.text = element_text(face = "bold")) +
      labs(x = NULL, y = NULL, title = "Olympiacos's best shooting night and most turnovers forced, but also the best shooting they have allowed",
           subtitle = paste("Each grey dot is one of Olympiacos's nine games so far;", colour_text("red", oly),
                            "= the Milano game. Left column = Olympiacos with the ball, right = Milano with the ball"), caption = cap_s), "04_vs_season", 10, 6.5)
# 5. who mattered
wpa <- win_probability_added(wp)
out(plot_wpa(wpa, g, colours = cols, title = "Miller-McIntyre and Vezenkov moved the game most; Moses Wright led Milano",
             caption = cap), "05_wpa", 9, 6.5)
bx <- game_score(box_score(gm))
# 6. where the shots came from
sh <- as_ggbasket_shots(gm, league = "EuroLeague"); sh$team <- nm(sh$team)
out(plot_shot_density(sh, facet = "team", points = TRUE, league = "EuroLeague",
                      title = "Olympiacos attacked the paint (37 twos to 25); Milano lived behind the arc and made more threes",
                      subtitle = "Every shot of the game: heat = shot density, dots = made, crosses = missed",
                      caption = cap), "06_shots", 11, 5.8)
# 7. players on and off the floor in this game
oo <- on_off(gm, team = "OLY", min_minutes = 8)
out(plot_on_off(oo, n = 10, title = "In this game, Olympiacos were best with Miller-McIntyre on the floor",
                subtitle = "Olympiacos's net rating with each player on (filled) and off (open) the floor, Milano game only. One game: small samples",
                caption = cap), "07_on_off", 9, 6)
# 8. the season so far
ob <- game_score(box_score(filter(el, hometeam == "OLY" | awayteam == "OLY")))
ob <- ob[ob$team == "OLY", ]
top <- ob |> group_by(player) |> summarise(m = sum(min)) |> arrange(-m) |> slice(1:8) |> pull(player)
out(plot_consistency(ob, top, min_minutes = 8, title = "Nine games in, Vezenkov is the one Olympiacos can count on",
                     subtitle = "Game Score in each game of 2026/27 so far; grey box = middle half of games, black tick = median",
                     caption = cap_s), "08_consistency", 10, 6.5)
oo_s <- on_off(filter(el, hometeam == "OLY" | awayteam == "OLY"), team = "OLY", min_minutes = 60)
out(plot_on_off(oo_s, n = 12, title = "Over the season so far, Olympiacos are best with Montero on the floor",
                subtitle = "Net rating with each player on (filled) and off (open) the floor, rounds 1-9. A few hundred possessions each: early-season noise is large",
                caption = cap_s), "09_on_off_season", 9, 6.5)

# numbers for the write-up
print(as.data.frame(s)); print(as.data.frame(runs))
print(as.data.frame(r[, c("efg", "o_efg", "tov_pct", "o_tov_pct", "orb_pct", "drb_pct", "ftm", "o_ftm", "c_shooting", "c_turnovers", "c_rebounding", "c_free_throws", "c_other")]))
print(as.data.frame(tb |> group_by(this) |> summarise(across(c(efg, tov_pct, orb_pct, o_efg, o_tov_pct, drb_pct), mean))))
print(as.data.frame(head(wpa[wpa$game_id == g, c("team", "player", "wpa", "offence", "defence")], 6)))
print(as.data.frame(tail(wpa[wpa$game_id == g, c("team", "player", "wpa")], 4)))
print(as.data.frame(wp[order(-abs(wp$wp_change)), ][1:4, c("period", "periodTime", "home_score", "away_score", "wp_change", "description")]))
print(as.data.frame(bx |> arrange(-game_score) |> select(team, player, min, pts, p2m, p2a, p3m, p3a, ast, tov, pm, game_score) |> head(8)))
print(as.data.frame(tb |> filter(this) |> select(pts, o_pts, poss, ortg, drtg)))
print(as.data.frame(sh |> group_by(team, value) |> summarise(fg = mean(made), n = n(), .groups = "drop")))
cl <- box_score(clutch_time(gm)); print(as.data.frame(cl |> filter(pts > 0 | tov > 0) |> select(team, player, pts, tov, pm)))
print(as.data.frame(oo[, c("player", "min", "on_net", "off_net")]))
