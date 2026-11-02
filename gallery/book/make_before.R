# The book figures (BasketballAnalyzeR, NBA 2017/18) that ggbasket was first designed against.
# Kept for the design critique in BOOK_REVIEW.md. Run from the package root:
#   Rscript gallery/book/make_before.R
suppressMessages({ library(ggplot2); library(BasketballAnalyzeR) })
before <- function(expr, name, w = 8, h = 6) {
  png(file.path("gallery/book/before", paste0(name, ".png")), width = w, height = h, units = "in", res = 110)
  p <- expr
  if (inherits(p, "gg") || inherits(p, "ggplot")) print(p)
  dev.off()
}
data(Tbox, Obox, Pbox, Tadd, PbP.BDB, package = "BasketballAnalyzeR")
PbP <- suppressWarnings(PbPmanipulation(PbP.BDB))

before(grid::grid.draw(gridExtra::arrangeGrob(grobs = plot(fourfactors(Tbox, Obox))[1:2], ncol = 1)), "01_ratings", 8, 9)
tm <- c("BOS", "CLE", "GSW", "HOU")
before(grid::grid.draw(gridExtra::arrangeGrob(grobs = plot(fourfactors(Tbox[Tadd$team %in% tm, ], Obox[Tadd$team %in% tm, ]))[3:4], ncol = 1)), "02_fourfactors", 8, 8)
before(gridExtra::grid.arrange(plot(inequality(subset(Pbox, Team == "Brooklyn Nets")$PTS, nplayers = 8), title = "Brooklyn Nets"),
                               plot(inequality(subset(Pbox, Team == "Milwaukee Bucks")$PTS, nplayers = 8), title = "Milwaukee Bucks"), nrow = 1), "03_lorenz", 10, 5)
sel <- c("Russell Westbrook", "Stephen Curry", "Chris Paul", "Kyrie Irving", "Damian Lillard", "Kyle Lowry", "John Wall", "Rajon Rondo", "Kemba Walker")
Pg <- subset(Pbox, Player %in% sel)
X <- with(Pg, data.frame(P2M, P3M, FTM, REB = OREB + DREB, AST, STL, BLK) / MIN)
before(radialprofile(data = X, title = Pg$Player, std = FALSE), "04_profile", 9, 9)
Ps <- subset(Pbox, MIN >= 500)
X <- data.frame(AST = Ps$AST, TOV = Ps$TOV, PTS = Ps$PTS) / Ps$MIN
before(scatterplot(X, data.var = c("AST", "TOV"), z.var = "PTS", labels = 1:nrow(X),
                   palette = colorRampPalette(c("blue", "yellow", "red"))), "05_quadrant")
okc <- subset(Pbox, Team == "Oklahoma City Thunder" & MIN >= 500)
before(plot(variability(data = okc, data.var = c("P2p", "P3p", "FTp"), size.var = c("P2A", "P3A", "FTA"), weight = TRUE), title = "Variability diagram - OKC"), "06_spread")
hr <- subset(Pbox, Team == "Houston Rockets" & MIN >= 500)
before(barline(data = hr, id = "Player", bars = c("P2p", "P3p", "FTp"), line = "MIN", order.by = "PM",
               labels.bars = c("2P%", "3P%", "FT%"), title = "Houston Rockets"), "07_ranked")
kd <- subset(PbP, player == "Kevin Durant"); kd$xx <- kd$original_x / 10; kd$yy <- kd$original_y / 10 - 41.75
before(shotchart(data = kd, x = "xx", y = "yy", z = "playlength", num.sect = 5, type = "sectors", scatter = TRUE), "08_shots")
kt <- subset(PbP, player == "Klay Thompson"); kt$xx <- kt$original_x / 10; kt$yy <- kt$original_y / 10 - 41.75
before(shotchart(data = kt, x = "xx", y = "yy", type = "density-polygons"), "10_density")
GSW <- subset(PbP, team == "GSW")
before(expectedpts(data = GSW, players = c("Stephen Curry", "Kevin Durant"), col.team = "gray",
                   palette = colorRampPalette(c("red", "green")), col.hline = "gray"), "11_curve")
Ps <- merge(Pbox, Tadd, by = "Team"); Ps <- subset(Ps, MIN >= 500)
X <- with(Ps, data.frame(PTS, P3M, P2M, REB = OREB + DREB, AST, TOV, STL, BLK) / MIN)
before(plot(corranalysis(X, threshold = 0.5)), "13_corr", 11, 5.5)
before(plot(MDSmap(with(subset(Pbox, MIN >= 1500), data.frame(PTS, P3M, P2M, REB = OREB + DREB, AST, TOV, STL, BLK))),
            labels = subset(Pbox, MIN >= 1500)$Player), "15_map", 9, 7)
before(plot(kclustering(with(subset(Pbox, MIN >= 1500), data.frame(PTS, P3M, REB = OREB + DREB, AST, TOV, STL, BLK, PF)))), "16_clusters")
GSW <- subset(PbP, team == "GSW")
set.seed(7); before(plot(assistnet(GSW), layout = "circle", edge.thr = 20), "17_network", 9, 8)
