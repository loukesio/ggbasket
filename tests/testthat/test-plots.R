test_that("all plot functions return ggplot objects that build", {
  nba <- subset(shots_2024, league == "NBA")
  curry <- subset(nba, player == "Stephen Curry")
  ff <- four_factors(team_seasons)
  pl <- subset(player_seasons, league == "NBA" & minutes >= 1500)
  pl$ast36 <- 36 * pl$ast / pl$minutes; pl$tov36 <- 36 * pl$tov / pl$minutes
  pl$pts36 <- 36 * pl$pts / pl$minutes
  plots <- list(
    plot_shot_hex(curry, baseline = nba),
    plot_shot_zones(curry, baseline = nba),
    plot_shot_density(curry, compare = nba),
    plot_ratings(subset(ff, league == "NBA"), highlight = "OKC"),
    plot_four_factors(subset(ff, league == "NBA"), teams = c("OKC", "BOS")),
    plot_lorenz(subset(player_seasons, league == "NBA"), "pts", "team", highlight = "OKC"),
    plot_quadrant(pl, "ast36", "tov36", label = "player"),
    plot_profile(pl, "player", c("pts36", "ast36", "tov36"), subjects = "Nikola Jokic"),
    plot_profile(pl, "player", c("pts36", "ast36", "tov36"), subjects = "Nikola Jokic", style = "radar"),
    plot_corr_matrix(pl, c("pts36", "ast36", "tov36")),
    plot_fit(pl, "ast36", "tov36", label = "player"),
    plot_similarity_map(pl, c("pts36", "ast36", "tov36"), label = "player"),
    plot_cluster_quality(cluster_quality(pl, c("pts36", "ast36", "tov36"), k = 2:4)),
    plot_shot_curve(shot_curve(curry, "y", n_boot = 5))
  )
  for (p in plots) {
    expect_s3_class(p, "ggplot")
    expect_no_error(ggplot2::ggplot_build(p))
  }
})
