# Book figure (BasketballAnalyzeR) vs ggbasket redesign.
# Run from the package root: Rscript gallery/make_gallery.R
suppressMessages({ devtools::load_all(quiet = TRUE); library(ggplot2); library(BasketballAnalyzeR) })
out <- function(p, name, w = 8, h = 6, dir = "gallery/after") {
  ggsave(file.path(dir, paste0(name, ".png")), p, width = w, height = h, dpi = 150, bg = "white")
}
before <- function(expr, name, w = 8, h = 6) {
  png(file.path("gallery/before", paste0(name, ".png")), width = w, height = h, units = "in", res = 110)
  p <- expr
  if (inherits(p, "gg") || inherits(p, "ggplot")) print(p)
  dev.off()
}
data(Tbox, Obox, Pbox, Tadd, PbP.BDB, package = "BasketballAnalyzeR")
PbP <- suppressWarnings(PbPmanipulation(PbP.BDB))
cap_book <- "Data: NBA 2017/18 regular season (BasketballAnalyzeR / BigDataBall)"
cap_now <- "Data: 2024/25 regular season (NBA Stats, ESPN, EuroLeague API)"
cap_el_rim <- paste(cap_now, "Note: EuroLeague operators record layups ~1 m from the hoop, so the EuroLeague curve starts late.", sep = "\n")
which_fig <- commandArgs(trailingOnly = TRUE)
want <- function(x) length(which_fig) == 0 || x %in% which_fig

ff <- four_factors(team_seasons)
nba_sh <- subset(shots_2024, league == "NBA"); el_sh <- subset(shots_2024, league == "EuroLeague")

if (want("ratings")) {
  before(grid::grid.draw(gridExtra::arrangeGrob(grobs = plot(fourfactors(Tbox, Obox))[1:2], ncol = 1)), "01_ratings", 8, 9)
  out(plot_ratings(ff, facet = "league", highlight = c("OKC", "CLE", "BOS", "HOU", "OLY", "ULK", "PAN", "MCO", "WAS", "ALB"),
                   title = "Two leagues, one map: how teams win",
                   caption = cap_now), "01_ratings", 11, 6)
}
if (want("fourfactors")) {
  tm <- c("BOS", "CLE", "GSW", "HOU")
  before(grid::grid.draw(gridExtra::arrangeGrob(grobs = plot(fourfactors(Tbox[Tadd$team %in% tm, ], Obox[Tadd$team %in% tm, ]))[3:4], ncol = 1)), "02_fourfactors", 8, 8)
  out(plot_four_factors(subset(ff, league == "EuroLeague"), teams = c("ULK", "PAN", "OLY", "MCO"),
                        title = "EuroLeague Final Four 2025: four roads to Abu Dhabi", caption = cap_now),
      "02_fourfactors", 9, 9)
}
if (want("lorenz")) {
  before(gridExtra::grid.arrange(plot(inequality(subset(Pbox, Team == "Brooklyn Nets")$PTS, nplayers = 8), title = "Brooklyn Nets"),
                                 plot(inequality(subset(Pbox, Team == "Milwaukee Bucks")$PTS, nplayers = 8), title = "Milwaukee Bucks"), nrow = 1), "03_lorenz", 10, 5)
  out(plot_lorenz(subset(player_seasons, league == "NBA"), "pts", "team", n = 8,
                  value_label = "points",
                  title = "Who depends on a few scorers?", caption = cap_now), "03_lorenz", 7.5, 7.5)
}
pl <- subset(player_seasons, minutes >= 1000)
pl <- transform(pl, pts36 = 36 * pts / minutes, ast36 = 36 * ast / minutes, reb36 = 36 * (orb + drb) / minutes,
                stl36 = 36 * stl / minutes, blk36 = 36 * blk / minutes, tov36 = 36 * tov / minutes,
                three_rate = p3a / (p2a + p3a), rim_rate = rim / (p2a + p3a), ft_rate = fta / (p2a + p3a))
stat_vars <- c(Points = "pts36", Assists = "ast36", Rebounds = "reb36", Steals = "stl36", Blocks = "blk36",
               Turnovers = "tov36", `3PA share` = "three_rate", `Rim share` = "rim_rate", `FT rate` = "ft_rate")
prof_vars <- c(Points = "pts36", Assists = "ast36", Rebounds = "reb36", Steals = "stl36", Blocks = "blk36",
               `Ball security` = "tov36", `3PA share` = "three_rate", `Rim share` = "rim_rate", `FT rate` = "ft_rate")
if (want("profile")) {
  sel <- c("Russell Westbrook", "Stephen Curry", "Chris Paul", "Kyrie Irving", "Damian Lillard", "Kyle Lowry", "John Wall", "Rajon Rondo", "Kemba Walker")
  Pg <- subset(Pbox, Player %in% sel)
  X <- with(Pg, data.frame(P2M, P3M, FTM, REB = OREB + DREB, AST, STL, BLK) / MIN)
  before(radialprofile(data = X, title = Pg$Player, std = FALSE), "04_profile", 9, 9)
  nba <- subset(pl, league == "NBA")
  out(plot_profile(nba, "player", prof_vars, reverse = "tov36",
                   subjects = c("Nikola Jokic", "Shai Gilgeous-Alexander", "Victor Wembanyama", "Stephen Curry"),
                   ncol = 2, title = "Four MVP-level fingerprints",
                   subtitle = "Percentile among NBA players with 1,000+ minutes (per 36 minutes; shaded = middle half)",
                   caption = cap_now), "04_profile", 9, 7)
  out(plot_profile(nba, "player", prof_vars, reverse = "tov36", style = "radar",
                   subjects = c("Nikola Jokic", "Shai Gilgeous-Alexander", "Victor Wembanyama", "Stephen Curry"),
                   ncol = 4, title = "The same fingerprints as radars, on percentiles", caption = cap_now), "04b_profile_radar", 13, 4.2)
}
if (want("quadrant")) {
  Ps <- subset(Pbox, MIN >= 500)
  X <- data.frame(AST = Ps$AST, TOV = Ps$TOV, PTS = Ps$PTS) / Ps$MIN
  before(scatterplot(X, data.var = c("AST", "TOV"), z.var = "PTS", labels = 1:nrow(X),
                     palette = colorRampPalette(c("blue", "yellow", "red"))), "05_quadrant")
  out(plot_quadrant(subset(pl, minutes >= 1500), "ast36", "tov36", label = "player", colour = "league",
                    size = "pts36", highlight = c("Nikola Jokic", "Trae Young", "Kendrick Nunn", "Facundo Campazzo", "Tyrese Haliburton"),
                    corners = c("Turnover-prone", "High-load creators", "Off-ball roles", "Careful creators"),
                    xlab = "Assists per 36 minutes", ylab = "Turnovers per 36 minutes", size_lab = "Points per 36",
                    title = "Creating costs turnovers - but not equally", caption = cap_now), "05_quadrant", 9, 7)
}
if (want("spread")) {
  okc <- subset(Pbox, Team == "Oklahoma City Thunder" & MIN >= 500)
  before(plot(variability(data = okc, data.var = c("P2p", "P3p", "FTp"), size.var = c("P2A", "P3A", "FTA"), weight = TRUE), title = "Variability diagram - OKC"), "06_spread")
  out(plot_spread(as_ggbasket_players(okc), c("p2m", "p3m", "ftm"), c("p2a", "p3a", "fta"),
                  labels = c("2-point shots", "3-point shots", "Free throws"),
                  title = "OKC 2017/18: who carries the shooting?", caption = cap_book), "06_spread", 9, 5)
}
if (want("ranked")) {
  hr <- subset(Pbox, Team == "Houston Rockets" & MIN >= 500)
  before(barline(data = hr, id = "Player", bars = c("P2p", "P3p", "FTp"), line = "MIN", order.by = "PM",
                 labels.bars = c("2P%", "3P%", "FT%"), title = "Houston Rockets"), "07_ranked")
  out(plot_ranked(as_ggbasket_players(hr), "player", c(`2PA` = "p2a", `3PA` = "p3a", FTA = "fta"), line = "pm",
                  order_by = "pm", line_label = "Plus-minus",
                  title = "Houston 2017/18: shot diet, ordered by plus-minus", caption = cap_book), "07_ranked", 9, 6)
}
if (want("hex")) {
  kd <- subset(PbP, player == "Kevin Durant"); kd$xx <- kd$original_x / 10; kd$yy <- kd$original_y / 10 - 41.75
  before(shotchart(data = kd, x = "xx", y = "yy", z = "playlength", num.sect = 5, type = "sectors", scatter = TRUE), "08_shots")
  four <- subset(nba_sh, player %in% c("Stephen Curry", "Nikola Jokic", "Shai Gilgeous-Alexander", "Victor Wembanyama"))
  out(plot_shot_hex(four, baseline = nba_sh, facet = "player",
                    title = "Four stars, four shot diets", caption = cap_now), "08_shot_hex", 10, 9)
}
if (want("zones")) {
  out(plot_shot_zones(subset(nba_sh, player == "Nikola Jokic"), baseline = nba_sh,
                      title = "Nikola Jokic, 2024/25: elite from everywhere inside the arc", caption = cap_now), "09_shot_zones", 8, 6.5)
  out(plot_shot_zones(subset(el_sh, player == "Sasha Vezenkov"), baseline = el_sh, league = "EuroLeague",
                      title = "Sasha Vezenkov, EuroLeague 2024/25 (FIBA court)", caption = cap_now), "09b_shot_zones_el", 8, 6.5)
}
if (want("density")) {
  kt <- subset(PbP, player == "Klay Thompson"); kt$xx <- kt$original_x / 10; kt$yy <- kt$original_y / 10 - 41.75
  before(shotchart(data = kt, x = "xx", y = "yy", type = "density-polygons"), "10_density")
  out(plot_shot_density(subset(nba_sh, player %in% c("Stephen Curry", "Giannis Antetokounmpo")), compare = nba_sh,
                        facet = "player", title = "Shot diet compared with the average NBA player",
                        caption = cap_now), "10_density", 11, 5.5)
}
if (want("curve")) {
  GSW <- subset(PbP, team == "GSW")
  before(expectedpts(data = GSW, players = c("Stephen Curry", "Kevin Durant"), col.team = "gray",
                     palette = colorRampPalette(c("red", "green")), col.hline = "gray"), "11_curve")
  both <- shots_2024
  both$dist <- sqrt(both$x^2 + both$y^2)
  both <- subset(both, dist < 9)
  sc <- shot_curve(both, "dist", by = "league", outcome = "points", n_boot = 100, bw = 0.25, split_value = TRUE)
  out(plot_shot_curve(sc, vlines = c("FIBA 3pt 6.75 m" = 6.75, "NBA 3pt 7.24 m" = 7.24),
                      xlab = "Shot distance from the hoop (m)",
                      title = "Same mid-range desert, different oasis",
                      subtitle = "Expected points per shot by distance, 2s and 3s smoothed separately. Line width = where shots are taken; band = 90% bootstrap.\nThe FIBA line is half a metre closer, so EuroLeague teams reach 1+ points per shot sooner",
                      caption = cap_el_rim), "11_curve_leagues", 9, 5.8)
  gs <- as_ggbasket_shots(subset(PbP, team == "GSW"))
  pl5 <- c("Stephen Curry", "Kevin Durant", "Klay Thompson", "Draymond Green")
  sc2 <- shot_curve(subset(gs, player %in% pl5), "playlength", by = "player", outcome = "points", n_boot = 100, bw = 2)
  out(plot_shot_curve(sc2, ref = mean(gs$pts), ref_label = "GSW average", xlab = "Seconds since the previous event",
                      title = "Who to give the ball to late in the clock?", caption = cap_book), "11b_curve_playlength", 9, 5.5)
}
if (want("making")) {
  xs <- expected_fg(shots_2024)
  sm <- shot_making(xs, prior_n = 150)
  out(plot_shot_making(subset(sm, league == "NBA"), min_attempts = 500,
                       highlight = c("Stephen Curry", "Nikola Jokic", "Shai Gilgeous-Alexander"),
                       title = "Shot difficulty vs shot making, NBA 2024/25", caption = cap_now), "12_shot_making", 9, 7)
}
if (want("corr")) {
  Ps <- merge(Pbox, Tadd, by = "Team"); Ps <- subset(Ps, MIN >= 500)
  X <- with(Ps, data.frame(PTS, P3M, P2M, REB = OREB + DREB, AST, TOV, STL, BLK) / MIN)
  before(plot(corranalysis(X, threshold = 0.5)), "13_corr", 11, 5.5)
  out(plot_corr_matrix(pl, c(Points = "pts36", Assists = "ast36", Turnovers = "tov36", Rebounds = "reb36",
                             Blocks = "blk36", Steals = "stl36", `3PA share` = "three_rate",
                             `Rim share` = "rim_rate", `FT rate` = "ft_rate"),
                       title = "What goes together in a stat line", caption = cap_now), "13_corr", 8, 7)
}
if (want("fit")) {
  out(plot_fit(subset(pl, league == "NBA"), "ast36", "tov36", label = "player", above_is_good = FALSE,
               xlab = "Assists per 36", ylab = "Turnovers per 36",
               title = "For their assist load, who protects the ball?", caption = cap_now), "14_fit", 9, 6.5)
}
if (want("map")) {
  big <- subset(pl, league == "NBA" & minutes >= 1500)
  before(plot(MDSmap(with(subset(Pbox, MIN >= 1500), data.frame(PTS, P3M, P2M, REB = OREB + DREB, AST, TOV, STL, BLK))),
              labels = subset(Pbox, MIN >= 1500)$Player), "15_map", 9, 7)
  out(plot_similarity_map(big, stat_vars, label = "player", colour = "position",
                          highlight = c("Nikola Jokic", "Victor Wembanyama", "Stephen Curry"),
                          title = "The NBA in two dimensions", caption = cap_now), "15_map", 10, 8)
}
if (want("clusters")) {
  big <- subset(pl, league == "NBA" & minutes >= 1500)
  v <- stat_vars
  cq <- cluster_quality(big, unname(v), k = 2:12)
  before(plot(kclustering(with(subset(Pbox, MIN >= 1500), data.frame(PTS, P3M, REB = OREB + DREB, AST, TOV, STL, BLK, PF)))), "16_clusters")
  out(plot_cluster_quality(cq, choose = 7), "16_cluster_quality", 8, 5)
  set.seed(1); km <- kmeans(scale(big[, unname(v)]), 7, nstart = 50)
  out(plot_cluster_profiles(big, v, km$cluster, label = "player",
                            title = "Seven kinds of NBA player", caption = cap_now), "16b_cluster_profiles", 11, 7)
}
if (want("network")) {
  GSW <- subset(PbP, team == "GSW")
  set.seed(7); before(plot(assistnet(GSW), layout = "circle", edge.thr = 20), "17_network", 9, 8)
  net <- assist_network(GSW)
  out(plot_assist_network(net, min_assists = 20, top_n = 10,
                          title = "Golden State 2017/18: Draymond Green runs the offence", caption = cap_book), "17_network", 10, 8)
  out(plot_assist_matrix(net, top_n = 10, title = "Golden State 2017/18: passer to scorer", caption = cap_book), "17b_assist_matrix", 8.5, 7)
}
cat("done\n")
