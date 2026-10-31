test_that("association() picks the right index and hits the extremes", {
  d <- data.frame(a = rep(c("x", "y"), 50), b = rep(c("p", "q"), 50), n = rep(c(1, 5), 50),
                  m = rnorm(100))
  a <- association(d, c("a", "b", "n", "m"))
  ab <- a[a$var1 == "a" & a$var2 == "b", ]
  expect_equal(ab$measure, "V")
  expect_equal(ab$value, 1)
  an <- a[a$var1 == "a" & a$var2 == "m", ]
  expect_equal(an$measure, "eta2")
  expect_true(all(a$value >= 0 & a$value <= 1))
  expect_s3_class(plot_association(a), "ggplot")
})

test_that("player_rates() matches hand calculations", {
  pr <- player_rates(player_seasons, team_seasons)
  p <- pr[1, ]
  expect_equal(p$ts_pct, p$pts / (2 * (p$p2a + p$p3a + 0.44 * p$fta)))
  expect_equal(p$tov_pct, p$tov / (p$p2a + p$p3a + 0.44 * p$fta + p$tov))
  big <- pr[pr$minutes > 1000, ]
  expect_true(all(big$usg_pct > 0.05 & big$usg_pct < 0.45))
  expect_true(all(big$ts_pct > 0.35 & big$ts_pct < 0.8))
})

test_that("expected_wins() is Pythagorean and luck sums to about zero", {
  ew <- expected_wins(team_seasons, exponent = 14)
  t1 <- ew[1, ]
  expect_equal(t1$exp_win_pct, t1$pts^14 / (t1$pts^14 + t1$o_pts^14))
  fitted <- expected_wins(team_seasons)
  expect_true(all(fitted$exponent > 8 & fitted$exponent < 20))
  expect_lt(abs(mean(fitted$luck)), 1)
  expect_s3_class(plot_luck(fitted, n = 3), "ggplot")
})

test_that("assist concentration and pressure situations work on book data", {
  skip_if_not_installed("BasketballAnalyzeR")
  e <- new.env()
  utils::data("PbP.BDB", package = "BasketballAnalyzeR", envir = e)
  pbp <- suppressWarnings(BasketballAnalyzeR::PbPmanipulation(e$PbP.BDB))
  pbp <- pbp[pbp$game_id %in% unique(pbp$game_id)[1:6], ]
  net <- assist_network(pbp[pbp$team == pbp$team[which(pbp$team != "")[1]], ])
  g <- net$nodes$ast_gini[!is.na(net$nodes$ast_gini)]
  expect_true(all(g >= 0 & g <= 1))
  expect_equal(sum(net$nodes$ast_share), 1)
  ps <- pressure_situations(pbp, orb_reset = 24)
  expect_true(all(ps$shot_clock_left >= 0 & ps$shot_clock_left <= 24))
  expect_setequal(levels(ps$shot_clock), c("early", "time-end", "middle-end", "early-middle"))
  expect_true(all(c("score_diff", "prev_miss", "team_misses", "period_end") %in% names(ps)))
})

test_that("theme helpers degrade gracefully", {
  old <- options(ggbasket.family = "sans")
  on.exit(options(old))
  expect_equal(ggbasket_fonts()$body, "sans")
  expect_match(colour_text("NBA", "NBA"), "#1F5FA8")
  expect_match(ggbasket_caption("x", note = "y"), "<br>y$")
})
