test_that("box scores from play-by-play reproduce the official ones", {
  g7 <- pbp_games[pbp_games$game_id == "401766128", ]
  tb <- box_score(g7, by = "team")
  okc <- tb[tb$team == "OKC", ]
  # 2025 NBA Finals Game 7: OKC 103, IND 91; Indiana committed 23 turnovers
  expect_equal(okc$pts, 103)
  expect_equal(okc$o_pts, 91)
  expect_equal(tb$tov[tb$team == "IND"], 23)
  bx <- box_score(g7)
  sga <- bx[bx$player == "Shai Gilgeous-Alexander", ]
  expect_equal(c(sga$pts, sga$ast), c(29, 12))
  # five players on court the whole game, for both leagues
  for (g in split(pbp_games, pbp_games$game_id)) {
    b <- box_score(g)
    mins <- tapply(b$min, b$team, sum)
    expect_equal(as.numeric(mins), rep(5 * max(g$totalTime) / 60, 2), tolerance = 1e-6)
    expect_equal(sum(b$pm), 0)
  }
  expect_true(all(c("ortg", "efg") %in% names(four_factors(tb))))
})

test_that("game flow, runs and summary agree with the final score", {
  for (g in split(pbp_games, pbp_games$game_id)) {
    f <- game_flow(g)
    last <- f[nrow(f), ]
    tb <- box_score(g, by = "team")
    expect_equal(last$home_score, tb$pts[tb$team == g$hometeam[1]])
    s <- game_summary(g)
    expect_equal(s$home_pts, last$home_score)
    expect_true(s$lead_changes >= 0 && s$excitement > 0)
    r <- scoring_runs(g, min_points = 6)
    expect_true(all(r$against == 0 & r$points >= 6))
  }
})

test_that("win probability is a probability and ends at the result", {
  wp <- win_probability(pbp_games)
  expect_true(all(wp$wp >= 0 & wp$wp <= 1))
  ends <- wp[!duplicated(wp$game_id, fromLast = TRUE), ]
  expect_equal(ends$wp, as.numeric(ends$margin > 0))
  # a bigger lead means a higher chance, at the same time left
  p <- stern_wp(c(0, 5, 10), 0.5, 2, 15, 2880)
  expect_true(all(diff(p) > 0))
  fw <- fit_win_probability(pbp_games)
  expect_true(all(fw$sigma > 5 & fw$sigma < 40))
})

test_that("on/off, line-ups and stints are consistent", {
  g7 <- pbp_games[pbp_games$game_id == "401766128", ]
  st <- stints(g7)
  expect_equal(sum(st$sec), max(g7$totalTime))
  expect_equal(sum(st$home_pts), 103)
  oo <- on_off(g7, team = "OKC", min_minutes = 5)
  expect_equal(oo$on_off, oo$on_net - oo$off_net)
  lu <- lineups(g7, min_minutes = 1)
  expect_true(all(lengths(strsplit(lu$lineup, " | ", fixed = TRUE)) == 5))
  expect_s3_class(plot_on_off(oo), "ggplot")
})

test_that("clutch time, game score and the game plots work", {
  ct <- clutch_time(pbp_games)
  expect_true(all(ct$period >= 4))
  bx <- game_score(box_score(pbp_games))
  expect_true("game_score" %in% names(bx))
  expect_s3_class(plot_consistency(bx, c("Shai Gilgeous-Alexander", "Pascal Siakam"), min_minutes = 0), "ggplot")
  expect_s3_class(plot_game_flow(pbp_games), "ggplot")
  expect_s3_class(plot_win_probability(win_probability(pbp_games)), "ggplot")
  tb <- box_score(pbp_games, by = "team")
  set.seed(3)
  fake <- do.call(rbind, lapply(1:6, function(i) {
    x <- tb
    x$game_id <- paste0(x$game_id, "_", i)
    for (v in c("p2m", "p3m", "orb", "tov", "ftm")) x[[v]] <- x[[v]] + sample(-3:3, 2)
    x$pts <- 2 * x$p2m + 3 * x$p3m + x$ftm
    for (v in c("pts", "p2m", "p3m", "orb", "tov", "ftm", "drb")) x[[paste0("o_", v)]] <- rev(x[[v]])
    x
  }))
  gf <- game_factors(rbind(tb, fake))
  expect_equal(gf$margin, gf$c_shooting + gf$c_turnovers + gf$c_rebounding + gf$c_free_throws + gf$c_other)
  expect_s3_class(plot_game_factors(gf, "401766128"), "ggplot")
})

test_that("assist network and pressure run on the ggbasket layout", {
  okc <- pbp_games[pbp_games$team == "OKC", ]
  net <- assist_network(okc)
  expect_equal(sum(net$nodes$assists), 20)
  ps <- pressure_situations(pbp_games[pbp_games$league == "NBA", ], orb_reset = 14)
  expect_true(all(ps$shot_clock_left >= 0 & ps$shot_clock_left <= 24))
})

test_that("EuroLeague names are tidied", {
  expect_equal(euroleague_name(c("MCDOWELL-WHITE, WILL", "O'NEALE, ROYCE", "Doe", "COLE, RJ", "MILLER-MCINTYRE, CODI")),
               c("Will McDowell-White", "Royce O'Neale", "Doe", "RJ Cole", "Codi Miller-McIntyre"))
})

test_that("literature measures behave", {
  tb <- box_score(pbp_games, by = "team")
  wpa <- win_probability_added(win_probability(pbp_games))
  # offence and defence credit cancel within each game
  expect_equal(as.numeric(tapply(wpa$wpa, wpa$game_id, sum)), c(0, 0), tolerance = 1e-8)
  expect_s3_class(plot_wpa(wpa, "401766128"), "ggplot")
  rp <- rapm(pbp_games[pbp_games$league == "NBA", ], lambda = 500, min_poss = 10)
  expect_true(all(is.finite(rp$rapm)))
  expect_s3_class(plot_rapm(rp, n = 3), "ggplot")
  expect_s3_class(plot_lineups(lineups(pbp_games, team = "OKC", min_minutes = 1), n = 2), "ggplot")
  ff <- four_factors(team_seasons)
  expect_s3_class(plot_net_rating(ff, "EuroLeague"), "ggplot")
  expect_s3_class(plot_factor_ranks(ff, c("OLY", "PAN")), "ggplot")
  ps <- expected_fg(pressure_situations(pbp_games[pbp_games$league == "NBA", ], orb_reset = 14))
  tp <- team_shot_profile(ps)
  expect_true(all(tp$early_share >= 0 & tp$early_share <= 1))
})
