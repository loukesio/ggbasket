test_that("gini reproduces the book's OKC example (Table 2.6, 38.12%)", {
  pts <- c(318, 353, 565, 682, 1056, 1261, 1734, 2028)
  expect_equal(round(100 * gini(pts), 2), 38.12)
  expect_equal(gini(rep(5, 8)), 0)
  l <- lorenz(pts)
  expect_equal(nrow(l), 9)
  expect_equal(l$value[9], 1)
})

test_that("gini keeps only the top-n values", {
  expect_equal(gini(c(rep(100, 8), 1, 1), n = 8), 0)
})

test_that("four_factors agrees with BasketballAnalyzeR", {
  skip_if_not_installed("BasketballAnalyzeR")
  e <- new.env()
  utils::data(Tbox, Obox, package = "BasketballAnalyzeR", envir = e)
  ff <- four_factors(as_ggbasket_teams(e$Tbox, e$Obox))
  ref <- BasketballAnalyzeR::fourfactors(e$Tbox, e$Obox)
  # BasketballAnalyzeR rounds to two decimals
  expect_equal(round(ff$ortg, 2), ref$ORtg)
  expect_equal(round(ff$drtg, 2), ref$DRtg)
  expect_equal(round(100 * ff$efg, 2), ref$F1.Off)
  expect_equal(round(100 * ff$orb_pct, 2), ref$F3.Off)
})

test_that("four_factors works on the shipped data", {
  ff <- four_factors(team_seasons)
  expect_equal(nrow(ff), nrow(team_seasons))
  expect_true(all(ff$ortg > 90 & ff$ortg < 140))
  expect_true(all(ff$pace > 60 & ff$pace < 110))
  # net ratings sum to roughly zero within a league
  expect_lt(abs(mean(ff$net_rtg[ff$league == "NBA"])), 1)
})

test_that("shrink_rate pulls small samples to the prior", {
  s <- shrink_rate(c(0, 150, 30, 40, 35), c(2, 400, 80, 100, 90))
  expect_gt(s$shrunk[1], 0.25)                      # 0/2 is not 0%
  expect_lt(abs(s$shrunk[2] - 0.375), 0.01)          # 150/400 barely moves
  expect_true(all(s$lower <= s$shrunk & s$shrunk <= s$upper))
})

test_that("percentile_rank is within group", {
  pr <- percentile_rank(c(1, 2, 3, 10, 20, 30), c("a", "a", "a", "b", "b", "b"))
  expect_equal(pr[1:3], pr[4:6])
})
