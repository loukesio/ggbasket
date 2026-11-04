#' Download one game's play-by-play
#'
#' `fetch_game()` gets a single game in the ggbasket layout, from the
#' EuroLeague live API (`league = "EuroLeague"`, with `season` and the game
#' code) or from ESPN via hoopR (`league = "NBA"`, with ESPN's game id).
#' `fetch_nba_pbp()` is the NBA download on its own.
#'
#' @param game EuroLeague game code (e.g. `90`) or ESPN game id
#'   (e.g. `"401766128"`).
#' @param league `"EuroLeague"` or `"NBA"`.
#' @param season EuroLeague season start year (e.g. `2026` for 2026/27).
#' @return A tibble in the ggbasket play-by-play layout (see [pbp]).
#' @export
fetch_game <- function(game, league = c("EuroLeague", "NBA"), season = NULL) {
  league <- match.arg(league)
  if (league == "EuroLeague") {
    if (is.null(season)) rlang::abort("`season` is needed for EuroLeague games (2026 = 2026/27).")
    out <- fetch_euroleague_pbp(season, games = as.integer(game), pause = 0.5)
  } else {
    out <- fetch_nba_pbp(game)
  }
  if (!nrow(out)) rlang::abort(paste("No play-by-play found for game", game))
  out
}

#' @rdname fetch_game
#' @param game_ids One or more ESPN NBA game ids.
#' @export
fetch_nba_pbp <- function(game_ids) {
  rlang::check_installed("hoopR", "to download NBA play-by-play from ESPN")
  dplyr::bind_rows(lapply(as.character(game_ids), function(id) {
    p <- as.data.frame(suppressMessages(hoopR::espn_nba_pbp(game_id = id)))
    if (!"athlete_name_1" %in% names(p)) {
      r <- as.data.frame(suppressMessages(hoopR::espn_nba_game_rosters(game_id = id)))
      nm <- stats::setNames(r$athlete_display_name, r$athlete_id)
      for (k in 1:3) p[[paste0("athlete_name_", k)]] <- unname(nm[as.character(p[[paste0("athlete_id_", k)]])])
    }
    pbp_from_espn(p)
  }))
}

# Four-factor regression coefficients (points of margin per percentage point of difference),
# fitted with game_factors() on every 2024/25 game, regular season and playoffs (data-raw/make_pbp.R).
# Used when too few games are supplied to fit them.
factor_coefs <- list(
  NBA = c(d_efg = 1.5074, d_tov = -1.3285, d_orb = 0.5764, d_ftr = 0.2497),
  EuroLeague = c(d_efg = 1.0097, d_tov = -0.9937, d_orb = 0.3834, d_ftr = 0.1792)
)

#' The key findings of a game, in words
#'
#' Turns the analyses of one game into short sentences for a report or an
#' e-mail: the result and how it unfolded, what decided it, the biggest play,
#' who mattered most and where the shots came from.
#'
#' @param pbp Play-by-play of one game (ggbasket layout).
#' @param names Optional named vector of display names for team codes.
#' @return A character vector of findings (markdown).
#' @export
#' @examples
#' match_story(subset(pbp_games, game_id == "401766128"))
match_story <- function(pbp, names = NULL) {
  g <- as.data.frame(pbp)
  nm <- function(x) ifelse(x %in% names(names), names[x], x)
  s <- game_summary(g)
  home <- s$hometeam; away <- s$awayteam
  win <- s$winner; lose <- if (win == home) away else home
  margin <- abs(s$home_pts - s$away_pts)
  gf <- game_factors(box_score(g, by = "team"))
  r <- gf[gf$team == win, ][1, ]
  comp <- c(Shooting = r$c_shooting, Turnovers = r$c_turnovers, `Offensive rebounding` = r$c_rebounding,
            `Free throws` = r$c_free_throws)
  top <- names(which.max(comp))
  pc <- function(x) sprintf("%.0f%%", 100 * x)
  detail <- switch(top,
                   Shooting = sprintf("effective FG%% %s against %s", pc(r$efg), pc(r$o_efg)),
                   Turnovers = sprintf("%d turnovers against %d", as.integer(r$o_tov), as.integer(r$tov)),
                   `Offensive rebounding` = sprintf("%s of their misses rebounded against %s", pc(r$orb_pct), pc(1 - r$drb_pct)),
                   `Free throws` = sprintf("%d free throws made against %d", as.integer(r$ftm), as.integer(r$o_ftm)))
  shot_note <- if (r$c_shooting < 0) sprintf(" even though %s shot better (%s against %s effective FG%%)", nm(lose), pc(r$o_efg), pc(r$efg)) else ""
  wp <- win_probability(g)
  k <- wp[which.max(abs(wp$wp_change)), ]
  k_team <- if (k$wp_change > 0) home else away
  wpa <- win_probability_added(wp)
  best <- function(t) wpa[wpa$team == t, ][1, ]
  bw <- best(win); bl <- best(lose)
  bx <- box_score(g)
  pts_of <- function(p, t) as.integer(bx$pts[bx$player == p & bx$team == t][1])
  sh <- box_score(g, by = "team")
  shot_line <- function(t) {
    x <- sh[sh$team == t, ]
    sprintf("%s %d/%d twos, %d/%d threes", nm(t), as.integer(x$p2m), as.integer(x$p2a), as.integer(x$p3m), as.integer(x$p3a))
  }
  ct <- clutch_time(g)
  clutch <- if (nrow(ct)) {
    cb <- box_score(ct, by = "team")
    sprintf("**Clutch time** (last 5 minutes within 5 points): %s %d, %s %d.", nm(cb$team[1]), as.integer(cb$pts[1]),
            nm(cb$team[2]), as.integer(cb$pts[2]))
  } else "The game never reached clutch time (last 5 minutes within 5 points)."
  c(
    sprintf("**%s beat %s by %d** (%d-%d)%s. There were %d lead changes and %d ties; the biggest leads were %d for %s and %d for %s.",
            nm(win), nm(lose), margin, max(s$home_pts, s$away_pts), min(s$home_pts, s$away_pts),
            if (isTRUE(s$overtime)) " after overtime" else "", s$lead_changes, s$ties,
            s$home_max_lead, nm(home), s$away_max_lead, nm(away)),
    sprintf("**What decided it: %s.** It was worth about %+.1f points to %s (%s)%s.",
            tolower(top), comp[[top]], nm(win), detail, shot_note),
    sprintf("**The biggest swing:** %s (%d-%d, period %d), which moved %s's chances by %.0f points.",
            trimws(sub("\\s*\\(.*$", "", k$description)), as.integer(k$home_score), as.integer(k$away_score),
            as.integer(k$period), nm(k_team), 100 * abs(k$wp_change)),
    sprintf("**Who mattered most:** %s for %s (%d points, %+.0f points of win probability); %s for %s (%d points, %+.0f).",
            bw$player, nm(win), pts_of(bw$player, win), 100 * bw$wpa, bl$player, nm(lose), pts_of(bl$player, lose), 100 * bl$wpa),
    sprintf("**Best run:** %s.", paste0(sub("(\\S+)$", "", s$best_run), nm(sub("^.* ", "", s$best_run)))),
    sprintf("**Shots:** %s; %s.", shot_line(home), shot_line(away)),
    clutch
  )
}

#' One-click match report
#'
#' Downloads a game (or takes its play-by-play), runs every game-level
#' analysis in ggbasket and writes a single self-contained HTML report:
#' key findings in words, the game flow, win probability with the plays
#' that swung it, what decided the result, who mattered, every shot, box
#' scores, clutch time and line-ups. The file has its figures inside, so it
#' can be e-mailed or shared as it is.
#'
#' A EuroLeague game takes a few seconds to download. With `context = TRUE`
#' the teams' other games of the season are downloaded too (about a minute)
#' to compare this game with their season.
#'
#' @inheritParams fetch_game
#' @param pbp Play-by-play of the game, if already downloaded.
#' @param season_pbp Play-by-play of the teams' other games, if already
#'   downloaded (used instead of `context`).
#' @param file Output file (default: `"<home>-<away>-<date>.html"` in the
#'   working directory).
#' @param context Also compare the game with both teams' season so far.
#' @param names Named vector of display names for team codes, e.g.
#'   `c(OLY = "Olympiacos", MIL = "Olimpia Milano")` (default: the full
#'   names that come with the play-by-play).
#' @param colours Two team colours, home first.
#' @param interactive Make the game-flow chart interactive (hover for the
#'   players on the floor and for why each run happened); needs ggiraph.
#' @param open Open the report when done.
#' @return The path of the report, invisibly.
#' @export
#' @examples
#' \dontrun{
#' match_report(90, "EuroLeague", season = 2026, names = c(OLY = "Olympiacos", MIL = "Milano"))
#' match_report("401766128", "NBA")
#' match_report(pbp = subset(pbp_games, game_id == "401766128"), context = FALSE)
#' }
match_report <- function(game = NULL, league = c("EuroLeague", "NBA"), season = NULL, pbp = NULL, season_pbp = NULL,
                         file = NULL,
                         context = FALSE, names = NULL, colours = NULL, interactive = TRUE,
                         open = base::interactive()) {
  rlang::check_installed("rmarkdown", "to write the report")
  league <- match.arg(league)
  if (is.null(pbp)) pbp <- fetch_game(game, league, season)
  pbp <- as.data.frame(pbp)
  league <- pbp$league[1]
  if (is.null(names) && all(c("hometeam_name", "awayteam_name") %in% names(pbp))) {
    names <- stats::setNames(trimws(c(pbp$hometeam_name[1], pbp$awayteam_name[1])), c(pbp$hometeam[1], pbp$awayteam[1]))
  }
  if (!is.null(season_pbp)) context <- FALSE
  if (context && league == "EuroLeague" && !is.null(season)) {
    teams <- c(pbp$hometeam[1], pbp$awayteam[1])
    g <- jsonlite::fromJSON(sprintf("https://api-live.euroleague.net/v2/competitions/E/seasons/E%d/games", season))$data
    codes <- g$gameCode[g$played & (g$local$club$code %in% teams | g$road$club$code %in% teams)]
    season_pbp <- fetch_euroleague_pbp(season, games = codes, pause = 0.5)
  } else if (context && league == "NBA") {
    rlang::check_installed("hoopR")
    raw <- hoopR::load_nba_pbp(seasons = pbp$season[1] + 1)
    raw <- raw[raw$home_team_abbrev %in% c(pbp$hometeam[1], pbp$awayteam[1]) |
                 raw$away_team_abbrev %in% c(pbp$hometeam[1], pbp$awayteam[1]), ]
    season_pbp <- dplyr::bind_rows(lapply(split(raw, raw$game_id), pbp_from_espn))
  }
  date <- if ("date" %in% names(pbp) && !all(is.na(pbp$date))) as.character(pbp$date[1]) else format(Sys.Date())
  file <- file %||% sprintf("%s-%s-%s.html", pbp$hometeam[1], pbp$awayteam[1], date)
  if (!grepl("^(/|[A-Za-z]:)", file)) file <- file.path(getwd(), file)
  last <- pbp[nrow(pbp), ]
  dn <- function(t) if (!is.null(names) && t %in% names(names)) names[[t]] else t
  title_text <- sprintf("%s %d-%d %s", dn(last$hometeam), as.integer(last$home_score), as.integer(last$away_score),
                        dn(last$awayteam))
  tmpl <- system.file("report", "match_report.Rmd", package = "ggbasket")
  if (!nzchar(tmpl)) tmpl <- file.path("inst", "report", "match_report.Rmd")
  work <- tempfile("ggbasket_report"); dir.create(work)
  file.copy(tmpl, file.path(work, "match_report.Rmd"))
  rmarkdown::render(file.path(work, "match_report.Rmd"), output_file = basename(file), output_dir = dirname(file),
                    params = list(pbp = pbp, season_pbp = season_pbp, names = names, colours = colours, date = date,
                                  title_text = title_text,
                                  interactive = interactive && requireNamespace("ggiraph", quietly = TRUE)),
                    envir = new.env(parent = globalenv()), quiet = TRUE)
  if (open) utils::browseURL(file)
  invisible(file)
}

#' Find games to report on
#'
#' `euroleague_games()` lists a EuroLeague season's games with the game code
#' that [fetch_game()] and [match_report()] need. `nba_games()` lists the NBA
#' games on a date with ESPN's game id.
#'
#' @param season EuroLeague season start year (2026 = 2026/27).
#' @param team Optional team code (e.g. `"OLY"`) to keep only its games.
#' @param played_only Keep only games already played.
#' @return A tibble: `game` (code or id), `date`, `round` (EuroLeague),
#'   `home`, `away`, `home_name`, `away_name`, `home_score`, `away_score`.
#' @export
#' @examples
#' \dontrun{
#' tail(euroleague_games(2026, team = "OLY"))   # Olympiacos's latest games
#' nba_games("2025-06-22")                       # NBA Finals Game 7
#' }
euroleague_games <- function(season, team = NULL, played_only = TRUE) {
  rlang::check_installed("jsonlite")
  g <- jsonlite::fromJSON(sprintf("https://api-live.euroleague.net/v2/competitions/E/seasons/E%d/games", season))$data
  out <- tibble::tibble(game = g$gameCode, date = as.Date(substr(g$date, 1, 10)), round = g$round,
                        home = g$local$club$code, away = g$road$club$code,
                        home_name = g$local$club$name, away_name = g$road$club$name,
                        home_score = g$local$score, away_score = g$road$score, played = g$played)
  if (played_only) out <- out[out$played, ]
  if (!is.null(team)) out <- out[out$home %in% team | out$away %in% team, ]
  out <- out[order(out$date, out$game), ]
  out$played <- NULL
  out
}

#' @rdname euroleague_games
#' @param date A date (`"2025-06-22"` or a `Date`).
#' @export
nba_games <- function(date) {
  rlang::check_installed("hoopR")
  x <- as.data.frame(suppressMessages(hoopR::espn_nba_scoreboard(season = format(as.Date(date), "%Y%m%d"))))
  tibble::tibble(game = as.character(x$game_id), date = as.Date(x$game_date), home = x$home_team_abb,
                 away = x$away_team_abb, home_name = x$home_team_full_name, away_name = x$away_team_full_name,
                 home_score = as.integer(x$home_score), away_score = as.integer(x$away_score))
}
