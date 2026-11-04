test_that("explain_runs takes Game 7's runs apart", {
  g7 <- subset(pbp_games, game_id == "401766128")
  r <- explain_runs(g7, min_points = 7)
  expect_equal(nrow(r), nrow(scoring_runs(g7, min_points = 7)))
  # the points of each run are accounted for by how they were scored
  expect_equal(r$pts_rim + r$pts_mid + r$pts_three + r$pts_ft, r$points)
  expect_true(all(r$pts_off_tov <= r$points & r$pts_second <= r$points & r$pts_break <= r$points))
  expect_true(all(r$opp_fgm == 0))
  big <- r[r$points == 13, ]
  expect_equal(big$team, "OKC")
  expect_match(big$story, "13-0 OKC")
  expect_match(big$story, "Ended by")
})

test_that("explain_runs returns an empty tibble when there are no runs", {
  g7 <- subset(pbp_games, game_id == "401766128")
  expect_equal(nrow(explain_runs(g7, min_points = 40)), 0)
})

test_that("plot_game_flow_interactive builds a widget", {
  skip_if_not_installed("ggiraph")
  w <- plot_game_flow_interactive(subset(pbp_games, game_id == "401766128"), min_run = 7)
  expect_s3_class(w, "girafe")
  expect_false(any(grepl("^liberation", vapply(w$dependencies, `[[`, "", "name"))))
})

test_that("lineup_explorer embeds stints that add up to the final score", {
  skip_if_not_installed("htmltools")
  g7 <- subset(pbp_games, game_id == "401766128")
  x <- as.character(lineup_explorer(g7))
  js <- regmatches(x, regexpr("var D=\\{.*?\\};var root", x))
  d <- jsonlite::fromJSON(sub(";var root$", "", sub("^var D=", "", js)), simplifyVector = FALSE)
  okc <- d$teams[[1]]
  expect_equal(okc$code, "OKC")
  expect_equal(sum(vapply(okc$game, `[[`, 0, "f")), 103)
  expect_equal(sum(vapply(okc$game, `[[`, 0, "a")), 91)
  expect_equal(sum(vapply(okc$game, `[[`, 0, "s")), 48 * 60)
})
