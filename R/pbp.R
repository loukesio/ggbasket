#' Play-by-play in the ggbasket layout
#'
#' Every game-level function in ggbasket reads one play-by-play layout: one
#' row per event, in game order, with
#'
#' * `league`, `season`, `game_id`, `date`, `hometeam`, `awayteam`;
#' * `period`, `periodTime` (seconds elapsed in the period), `totalTime`
#'   (seconds elapsed in the game), `playlength` (seconds since the previous
#'   event);
#' * `team` (team of `player`), `oppTeam`, `event_type` (`"shot"`, `"miss"`,
#'   `"free throw"`, `"rebound"`, `"turnover"`, `"foul"`, `"sub"`,
#'   `"timeout"`, `"jump ball"`, `"start of period"`, `"end of period"`,
#'   `"violation"`, `"unknown"`), `rebound` (`"offensive"`/`"defensive"`),
#'   `result` (`"made"`/`"missed"`), `ShotType` (`"2P"`, `"3P"`, `"FT"`),
#'   `points` (scored on the event);
#' * `player`, `assist`, `steal`, `block` (the last two are players of
#'   `oppTeam`), `entered`, `left`;
#' * `home_score`, `away_score` after the event;
#' * `x`, `y` shot location in metres from the hoop centre, and
#'   `original_x`, `original_y` in tenths of feet;
#' * `a1`-`a5` (away) and `h1`-`h5` (home): the players on court;
#' * `description`.
#'
#' This is a superset of BasketballAnalyzeR's `PbP`, so data prepared with
#' `PbPmanipulation()` also works. `pbp_from_espn()` converts NBA (and WNBA,
#' college) play-by-play from ESPN as served by `hoopR::load_nba_pbp()`;
#' `pbp_from_euroleague()` converts the EuroLeague's official live API, which
#' `fetch_euroleague_pbp()` downloads.
#'
#' Who is on court is not part of either feed. [add_lineups()] rebuilds it
#' from substitutions: a player who acts in a period before being subbed in
#' started that period. A player who plays a whole period without touching
#' the ball or being substituted is carried over from the previous period.
#'
#' @param x ESPN play-by-play, one or more games (a data frame as returned by
#'   `hoopR::load_nba_pbp()` or `hoopR::espn_nba_pbp()`).
#' @param league League label.
#' @param period_length,ot_length Minutes in a regular period and in overtime.
#' @return A tibble in the ggbasket play-by-play layout.
#' @name pbp
#' @examples
#' head(pbp_games[, c("game_id", "period", "periodTime", "team", "event_type", "player", "points")])
NULL

#' @rdname pbp
#' @export
pbp_from_espn <- function(x, league = "NBA", period_length = 12, ot_length = 5) {
  x <- as.data.frame(x)
  x <- x[order(x$game_id, x$period_number, x$sequence_number_num %||% as.numeric(x$sequence_number)), ]
  abb <- c(stats::setNames(x$home_team_abbrev, x$home_team_id), stats::setNames(x$away_team_abbrev, x$away_team_id))
  abb <- abb[!duplicated(names(abb))]
  team <- unname(abb[as.character(x$team_id)])
  team[is.na(team)] <- ""
  ty <- x$type_text
  ft <- grepl("Free Throw", ty)
  fg <- x$shooting_play & !ft
  tov <- (grepl("Turnover", ty) & ty != "No Turnover") | ty == "Traveling"
  foul <- grepl("Foul", ty) & !tov | grepl("Technical|Flagrant", ty) & !ft
  ev <- dplyr::case_when(
    fg & x$scoring_play ~ "shot", fg ~ "miss", ft ~ "free throw",
    grepl("Rebound", ty) ~ "rebound", tov ~ "turnover", foul ~ "foul",
    ty == "Substitution" ~ "sub", grepl("Timeout", ty) ~ "timeout", ty == "Jumpball" ~ "jump ball",
    ty == "End Period" | ty == "End Game" ~ "end of period",
    grepl("Goaltending|Kicked Ball|Violation|Delay|Lane", ty) ~ "violation",
    .default = "unknown")
  clock <- vapply(strsplit(as.character(x$clock_display_value), ":"), function(s) {
    s <- as.numeric(s); if (length(s) == 2) 60 * s[1] + s[2] else s[1]
  }, numeric(1))
  per <- as.integer(x$period_number)
  plen <- ifelse(per <= 4, 60 * period_length, 60 * ot_length)
  start <- ifelse(per <= 4, (per - 1) * 60 * period_length, 4 * 60 * period_length + (per - 5) * 60 * ot_length)
  a1 <- x$athlete_name_1; a2 <- x$athlete_name_2
  shot_xy <- (fg) & !is.na(x$coordinate_x_raw) & abs(x$coordinate_x_raw) < 100
  xm <- ifelse(shot_xy, (x$coordinate_x_raw - 25) * 0.3048, NA_real_)
  ym <- ifelse(shot_xy, (x$coordinate_y_raw - 1) * 0.3048, NA_real_)
  home <- x$home_team_abbrev; away <- x$away_team_abbrev
  txt <- x$text
  out <- tibble::tibble(
    league = league,
    season = as.integer(x$season) - 1L,
    phase = c(`1` = "preseason", `2` = "regular", `3` = "playoffs", `5` = "play-in")[as.character(x$season_type)],
    game_id = as.character(x$game_id), date = as.Date(x$game_date),
    hometeam = home, awayteam = away,
    period = per, periodTime = plen - clock, totalTime = start + plen - clock,
    team = team, oppTeam = ifelse(team == "", "", ifelse(team == home, away, home)),
    event_type = ev,
    rebound = ifelse(ev == "rebound", ifelse(grepl("Offensive", ty), "offensive", "defensive"), NA_character_),
    result = ifelse(ev %in% c("shot", "miss", "free throw"),
                    ifelse(x$scoring_play, "made", "missed"), ""),
    ShotType = ifelse(fg, ifelse(x$points_attempted == 3, "3P", "2P"), ifelse(ft, "FT", NA_character_)),
    points = ifelse(ev %in% c("shot", "miss", "free throw"), ifelse(x$scoring_play, x$score_value, 0L), NA_integer_),
    player = ifelse(ev == "sub", NA_character_, a1),
    assist = ifelse(ev == "shot" & !is.na(a2), a2, ""),
    steal = ifelse(ev == "turnover" & !is.na(a2), a2, ""),
    block = ifelse(ev == "miss" & !is.na(a2) & grepl("blocks", x$text), a2, ""),
    entered = ifelse(ev == "sub", a1, ""), left = ifelse(ev == "sub", a2, ""),
    home_score = as.integer(x$home_score), away_score = as.integer(x$away_score),
    x = xm, y = ym, original_x = xm / 0.3048 * 10, original_y = ym / 0.3048 * 10,
    shot_distance = sqrt(xm^2 + ym^2) / 0.3048,
    description = txt
  )
  out$player[is.na(out$player)] <- ""
  finish_pbp(out, period_length, ot_length)
}

#' @rdname pbp
#' @param pbp_json,points_json One game's responses from the EuroLeague live
#'   API: `PlayByPlay` and (optional, for shot locations) `Points`, parsed by
#'   `jsonlite::fromJSON()`.
#' @param season Season start year (2024 = 2024/25).
#' @param game_code The game's code within the season.
#' @export
pbp_from_euroleague <- function(pbp_json, points_json = NULL, season, game_code, league = "EuroLeague",
                                period_length = 10, ot_length = 5) {
  qs <- c("FirstQuarter", "SecondQuarter", "ThirdQuarter", "ForthQuarter", "ExtraTime")
  ev <- lapply(seq_along(qs), function(i) {
    q <- pbp_json[[qs[i]]]
    if (is.null(q) || !length(q) || !nrow(q)) return(NULL)
    q <- as.data.frame(q)
    if (i == 5) {
      # overtimes are stacked in one block; a new "BP" (begin period) starts each
      q$period <- 4L + cumsum(trimws(q$PLAYTYPE) == "BP")
      q$period[q$period == 4L] <- 5L
    } else q$period <- i
    q
  })
  q <- dplyr::bind_rows(ev)
  q <- q[order(q$period, q$NUMBEROFPLAY), ]
  tr <- function(v) trimws(as.character(v))
  home <- tr(pbp_json$CodeTeamA); away <- tr(pbp_json$CodeTeamB)
  pt <- tr(q$PLAYTYPE)
  team <- tr(q$CODETEAM); team[is.na(team)] <- ""
  pl_name <- euroleague_name(q$PLAYER)
  et <- dplyr::case_when(
    pt %in% c("2FGM", "3FGM") ~ "shot", pt %in% c("2FGA", "3FGA") ~ "miss", pt %in% c("FTM", "FTA") ~ "free throw",
    pt %in% c("D", "O") ~ "rebound", pt == "TO" ~ "turnover",
    pt %in% c("CM", "CMU", "CMT", "CMD", "OF", "B", "C", "CMTI") ~ "foul",
    pt %in% c("IN", "OUT") ~ "sub", grepl("^TOUT", pt) ~ "timeout", pt == "JB" ~ "jump ball",
    pt == "BP" ~ "start of period", pt %in% c("EP", "EG") ~ "end of period",
    .default = "unknown")
  clock <- vapply(strsplit(ifelse(is.na(q$MARKERTIME) | q$MARKERTIME == "", NA, q$MARKERTIME), ":"),
                  function(s) if (length(s) == 2) 60 * as.numeric(s[1]) + as.numeric(s[2]) else NA_real_,
                  numeric(1))
  plen <- ifelse(q$period <= 4, 60 * period_length, 60 * ot_length)
  clock[pt == "BP" & is.na(clock)] <- plen[pt == "BP" & is.na(clock)]
  clock[pt %in% c("EP", "EG") & is.na(clock)] <- 0
  clock <- fill_down(clock)
  start <- ifelse(q$period <= 4, (q$period - 1) * 60 * period_length,
                  4 * 60 * period_length + (q$period - 5) * 60 * ot_length)
  pts <- dplyr::case_when(pt == "2FGM" ~ 2L, pt == "3FGM" ~ 3L, pt == "FTM" ~ 1L,
                          pt %in% c("2FGA", "3FGA", "FTA") ~ 0L, .default = NA_integer_)
  d <- tibble::tibble(
    league = league, season = as.integer(season), game_id = paste0("E", season, "_", game_code),
    hometeam = home, awayteam = away, period = as.integer(q$period),
    periodTime = plen - clock, totalTime = start + plen - clock,
    team = team, oppTeam = ifelse(team == "", "", ifelse(team == home, away, home)),
    event_type = et,
    rebound = ifelse(pt == "O", "offensive", ifelse(pt == "D", "defensive", NA_character_)),
    result = ifelse(et %in% c("shot", "miss", "free throw"), ifelse(pts > 0, "made", "missed"), ""),
    ShotType = ifelse(pt %in% c("2FGM", "2FGA"), "2P", ifelse(pt %in% c("3FGM", "3FGA"), "3P",
                                                             ifelse(pt %in% c("FTM", "FTA"), "FT", NA_character_))),
    points = pts, player = ifelse(et == "sub", "", pl_name),
    assist = "", steal = "", block = "",
    entered = ifelse(pt == "IN", pl_name, ""), left = ifelse(pt == "OUT", pl_name, ""),
    home_score = ifelse(team == home & !is.na(pts), pts, 0L), away_score = ifelse(team == away & !is.na(pts), pts, 0L),
    x = NA_real_, y = NA_real_,
    description = trimws(paste(ifelse(is.na(pl_name), "", pl_name), q$PLAYINFO)),
    .num = q$NUMBEROFPLAY, .pt = pt
  )
  d$player[is.na(d$player)] <- ""
  # play numbers are not always chronological (substitutions are logged late)
  d <- d[order(d$totalTime, d$.num), ]
  d$home_score <- cumsum(d$home_score); d$away_score <- cumsum(d$away_score)
  # assists, steals and blocks are their own rows: attach them to the play they belong to
  # FIBA also credits an assist on a pass that draws a shooting foul, so assists attach to free throws too
  d <- attach_credit(d, "AS", c("shot", "free throw"), same_team = TRUE, col = "assist")
  d <- attach_credit(d, "ST", c("turnover"), same_team = FALSE, col = "steal")
  d <- attach_credit(d, "FV", c("miss"), same_team = FALSE, col = "block")
  if (!is.null(points_json) && length(points_json$Rows) && nrow(as.data.frame(points_json$Rows))) {
    p <- as.data.frame(points_json$Rows)
    m <- match(d$.num, p$NUM_ANOT)
    hit <- !is.na(m) & d$event_type %in% c("shot", "miss")
    # API coordinates are centimetres from the hoop centre
    d$x[hit] <- p$COORD_X[m[hit]] / 100
    d$y[hit] <- p$COORD_Y[m[hit]] / 100
  }
  d$original_x <- d$x / 0.3048 * 10
  d$original_y <- d$y / 0.3048 * 10
  d$shot_distance <- sqrt(d$x^2 + d$y^2) / 0.3048
  d <- d[!d$.pt %in% c("AS", "ST", "FV", "RV", "AG"), ]
  d$.num <- NULL; d$.pt <- NULL
  finish_pbp(d, period_length, ot_length)
}

#' @rdname pbp
#' @param games Game codes to download (default: every played game of the
#'   season).
#' @param shots Also download shot locations?
#' @param pause Seconds to wait between requests (the API rate-limits).
#' @export
fetch_euroleague_pbp <- function(season, games = NULL, shots = TRUE, pause = 1) {
  rlang::check_installed("jsonlite", "to download EuroLeague play-by-play")
  get <- function(url) {
    for (i in 1:4) {
      r <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
      if (!is.null(r)) return(r)
      Sys.sleep(5 * i)
    }
    NULL
  }
  g <- get(sprintf("https://api-live.euroleague.net/v2/competitions/E/seasons/E%d/games", season))$data
  if (is.null(games)) games <- g$gameCode[g$played]
  phase <- c(RS = "regular", PI = "play-in", PO = "playoffs", FF = "final four")
  out <- lapply(games, function(code) {
    pj <- get(sprintf("https://live.euroleague.net/api/PlayByPlay?gamecode=%d&seasoncode=E%d", code, season))
    Sys.sleep(pause)
    if (is.null(pj)) { warning("could not download game ", code); return(NULL) }
    sj <- if (shots) get(sprintf("https://live.euroleague.net/api/Points?gamecode=%d&seasoncode=E%d", code, season))
    if (shots) Sys.sleep(pause)
    d <- pbp_from_euroleague(pj, sj, season = season, game_code = code)
    i <- if (!is.null(g)) match(code, g$gameCode) else NA
    if (!is.na(i)) {
      d$date <- as.Date(substr(g$date[i], 1, 10))
      d$phase <- unname(phase[g$phaseType$code[i]])
    }
    d
  })
  dplyr::bind_rows(out)
}

#' Who is on court
#'
#' Adds the players on court (`a1`-`a5` away, `h1`-`h5` home) to a
#' play-by-play in the ggbasket layout, rebuilt from substitutions (see
#' [pbp]). Rows of a substitution keep the line-up from before it.
#'
#' @param pbp Play-by-play in the ggbasket layout.
#' @return `pbp` with `a1`-`a5` and `h1`-`h5`.
#' @export
add_lineups <- function(pbp) {
  pbp <- as.data.frame(pbp)
  lin <- matrix(NA_character_, nrow(pbp), 10, dimnames = list(NULL, c(paste0("a", 1:5), paste0("h", 1:5))))
  for (g in split(seq_len(nrow(pbp)), pbp$game_id)) {
    d <- pbp[g, ]
    for (side in c("away", "home")) {
      tm <- if (side == "home") d$hometeam[1] else d$awayteam[1]
      cols <- if (side == "home") paste0("h", 1:5) else paste0("a", 1:5)
      prev <- character(0)
      for (pr in sort(unique(d$period))) {
        r <- which(d$period == pr)
        on_team <- d$team[r] == tm
        # every appearance of a player of this team, in order, with a flag for "entered"
        who <- c(ifelse(on_team, d$player[r], ""), ifelse(on_team, d$assist[r], ""),
                 ifelse(on_team, d$left[r], ""), ifelse(on_team, d$entered[r], ""),
                 ifelse(d$oppTeam[r] == tm, d$steal[r], ""), ifelse(d$oppTeam[r] == tm, d$block[r], ""))
        pos <- rep(seq_along(r), 6)
        ent <- rep(c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE), each = length(r))
        # an entering player counts after the others on the same row
        o <- order(pos, ent)
        who <- who[o]; ent <- ent[o]
        keep <- !is.na(who) & who != ""
        who <- who[keep]; ent <- ent[keep]
        first <- !duplicated(who)
        starters <- who[first & !ent]
        if (length(starters) < 5) {
          extra <- setdiff(prev, c(starters, who[first & ent]))
          starters <- c(starters, extra)[seq_len(min(5, length(starters) + length(extra)))]
        }
        cur <- utils::head(starters, 5)
        for (k in seq_along(r)) {
          lin[g[r[k]], cols] <- c(cur, rep(NA, 5))[1:5]
          if (d$event_type[r[k]] == "sub" && d$team[r[k]] == tm) {
            if (d$left[r[k]] != "") cur <- setdiff(cur, d$left[r[k]])
            # feeds that list "in" before "out" briefly have six on court
            if (d$entered[r[k]] != "" && !d$entered[r[k]] %in% cur) cur <- c(cur, d$entered[r[k]])
          }
        }
        prev <- utils::head(cur, 5)
      }
    }
  }
  pbp[, colnames(lin)] <- lin
  tibble::as_tibble(pbp)
}

# shared tail of the converters: order, play length, lineups
finish_pbp <- function(d, period_length, ot_length) {
  d <- d[order(d$game_id, d$totalTime, seq_len(nrow(d))), ]
  d$playlength <- stats::ave(d$totalTime, d$game_id, FUN = function(t) c(0, diff(t)))
  for (v in c("player", "assist", "steal", "block", "entered", "left", "team", "oppTeam")) d[[v]][is.na(d[[v]])] <- ""
  add_lineups(d)
}

attach_credit <- function(d, code, to, same_team, col) {
  for (i in which(d$.pt == code)) {
    # the credited play is the closest earlier one (same clock) of the right kind
    j <- i - 1
    while (j >= 1 && j >= i - 6 && !(d$event_type[j] %in% to &&
                                     (d$team[j] == d$team[i]) == same_team &&
                                     d[[col]][j] == "")) j <- j - 1
    if (j < 1 || j < i - 6) {
      # sometimes the credit row comes first
      j <- i + 1
      while (j <= nrow(d) && j <= i + 3 && !(d$event_type[j] %in% to && (d$team[j] == d$team[i]) == same_team)) j <- j + 1
      if (j > nrow(d) || j > i + 3) next
    }
    d[[col]][j] <- d$player[i]
  }
  d
}

euroleague_name <- function(x) {
  x <- trimws(as.character(x))
  el <- !is.na(x) & grepl(",", x)
  x[el] <- sub("^(.*?)\\s*,\\s*(.*)$", "\\2 \\1", x[el])
  x[el] <- gsub("(^|[ '-])([a-z])", "\\1\\U\\2", tolower(x[el]), perl = TRUE)
  tidy_name(x)
}

# fix casing that title case gets wrong: initials ("Rj" -> "RJ") and Mc names ("Mcintyre" -> "McIntyre")
tidy_name <- function(x) {
  x <- gsub("\\b([BCDFGHJKLMNPQRSTVWXZ])([bcdfghjklmnpqrstvwxz])\\b", "\\1\\U\\2", x, perl = TRUE)
  x <- gsub("\\bMc([a-z])", "Mc\\U\\1", x, perl = TRUE)
  sub("^([a-z])", "\\U\\1", x, perl = TRUE)
}

fill_down <- function(v) {
  for (i in seq_along(v)[-1]) if (is.na(v[i])) v[i] <- v[i - 1]
  v
}
