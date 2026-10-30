#' Convert BasketballAnalyzeR data to ggbasket conventions
#'
#' The book's package uses `Tbox`/`Obox` (team and opponent totals),
#' `Pbox` (players) and `PbP` (play-by-play, coordinates in tenths of feet).
#' These helpers rename columns to ggbasket's lower-case convention, attach
#' opponent stats with an `o_` prefix and convert shot coordinates to metres,
#' so every ggbasket function can be run on the book's examples.
#'
#' @param Tbox,Obox Team and opponent box scores (same row order).
#' @param Pbox Player box scores.
#' @param PbP Play-by-play from `BasketballAnalyzeR::PbPmanipulation()`.
#' @param league League label to attach.
#' @export
#' @examples
#' if (requireNamespace("BasketballAnalyzeR", quietly = TRUE)) {
#'   data(Tbox, Obox, package = "BasketballAnalyzeR")
#'   ff <- four_factors(as_ggbasket_teams(Tbox, Obox))
#'   head(ff[, c("team", "ortg", "drtg", "pace")])
#' }
as_ggbasket_teams <- function(Tbox, Obox, league = "NBA") {
  ren <- function(d) {
    d <- as.data.frame(d)
    names(d) <- tolower(names(d))
    names(d)[names(d) == "oreb"] <- "orb"
    names(d)[names(d) == "dreb"] <- "drb"
    d
  }
  t <- ren(Tbox); o <- ren(Obox)
  keep <- c("pts", "p2m", "p2a", "p3m", "p3a", "ftm", "fta", "orb", "drb", "ast", "tov", "stl", "blk", "pf")
  oo <- o[, keep]
  names(oo) <- paste0("o_", keep)
  out <- cbind(t[, setdiff(names(t), c("p2p", "p3p", "ftp"))], oo)
  out$team_name <- out$team
  out$league <- league
  tibble::as_tibble(out)
}

#' @rdname as_ggbasket_teams
#' @export
as_ggbasket_players <- function(Pbox, league = "NBA") {
  d <- as.data.frame(Pbox)
  names(d) <- tolower(names(d))
  names(d)[names(d) == "oreb"] <- "orb"
  names(d)[names(d) == "dreb"] <- "drb"
  names(d)[names(d) == "min"] <- "minutes"
  d$league <- league
  tibble::as_tibble(d)
}

#' @rdname as_ggbasket_teams
#' @export
as_ggbasket_shots <- function(PbP, league = "NBA") {
  d <- as.data.frame(PbP)
  d <- d[d$result %in% c("made", "missed") & d$ShotType %in% c("2P", "3P") & !is.na(d$original_x), ]
  ft2m <- 0.3048
  tibble::tibble(
    league = league, game_id = d$game_id, team = as.character(d$team),
    opp = as.character(d$oppTeam), player = as.character(d$player),
    assist = as.character(d$assist),
    x = d$original_x / 10 * ft2m, y = d$original_y / 10 * ft2m,
    dist = d$shot_distance * ft2m,
    value = ifelse(d$ShotType == "3P", 3L, 2L), made = d$result == "made",
    pts = ifelse(d$result == "made", ifelse(d$ShotType == "3P", 3L, 2L), 0L),
    period = d$period, periodTime = d$periodTime, totalTime = d$totalTime,
    playlength = d$playlength
  )
}
