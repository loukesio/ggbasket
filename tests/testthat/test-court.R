test_that("shot_zone uses each league's 3-point line", {
  # 7.0 m straight on: three in FIBA (6.75), two in the NBA (7.24)
  expect_equal(as.character(shot_zone(0, 7.0, "EuroLeague")), "Above-break 3")
  expect_equal(as.character(shot_zone(0, 7.0, "NBA")), "Long mid-range")
  expect_equal(as.character(shot_zone(6.8, 0.5, "NBA")), "Corner 3")
  expect_equal(as.character(shot_zone(0.3, 0.3, "NBA")), "Rim")
  z <- shot_zone(c(-3, 3), c(1, 1), "NBA", detail = TRUE)
  expect_equal(as.character(z), c("Short mid left", "Short mid right"))
})

test_that("the zone classifier agrees with the recorded shot value", {
  s <- shots_2024[sample(nrow(shots_2024), 20000), ]
  inferred <- ifelse(shot_zone(s$x, s$y, s$league) %in% c("Corner 3", "Above-break 3"), 3, 2)
  expect_gt(mean(inferred == s$value), 0.97)
})

test_that("court_lines returns closed pieces", {
  for (lg in c("NBA", "FIBA")) {
    d <- court_lines(lg)
    expect_true(all(c("three", "lane", "hoop") %in% d$piece))
  }
  expect_error(court_spec("WNBA_XYZ"))
})
