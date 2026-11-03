#' Why the runs happened
#'
#' Takes each scoring run of [scoring_runs()] apart, play by play: how the
#' points were scored (at the rim, mid-range, threes, free throws; off
#' turnovers, second chances, on the break), how the other team came up
#' empty (shots missed, turnovers, fouls), who was on the floor and which of
#' the other team's main players sat, the timeouts called, and the play that
#' ended the run. Each run gets a one-paragraph `story`.
#'
#' A score counts as off a turnover or a second chance when the possession it
#' ends began with the opponent's turnover or included an offensive rebound;
#' on the break when it came within 7 seconds of the turnover or defensive
#' rebound that began the possession. At the rim = a two from 8 feet or less.
#'
#' @inheritParams scoring_runs
#' @param names Optional named vector of display names for team codes.
#' @return The runs of [scoring_runs()] with `clock_start`, `clock_end`
#'   (period and time left), `pts_rim`, `pts_mid`, `pts_three`, `pts_ft`,
#'   `pts_off_tov`, `pts_second`, `pts_break`, `scorers`, `opp_fgm`,
#'   `opp_fga`, `opp_3pm`, `opp_3pa`, `opp_tov`, `opp_fouls`, `on_floor`,
#'   `opp_on_floor`, `opp_bench` (the opponent's three most-used players who
#'   sat most of the run), `opp_timeouts`, `ended_by` and `story` (markdown).
#' @export
#' @examples
#' r <- explain_runs(subset(pbp_games, game_id == "401766128"), min_points = 7)
#' cat(r$story, sep = "\n\n")
explain_runs <- function(pbp, min_points = 8, allow = 0, names = NULL) {
  d <- as.data.frame(pbp)
  runs <- scoring_runs(d, min_points = min_points, allow = allow)
  if (!nrow(runs)) return(dplyr::mutate(runs, story = character()))
  out <- lapply(seq_len(nrow(runs)), function(k) {
    g <- d[d$game_id == runs$game_id[k], ]
    dplyr::bind_cols(runs[k, ], run_anatomy(g, runs[k, ], names))
  })
  dplyr::bind_rows(out)
}

game_clock <- function(g, i) {
  per <- g$period[i]
  len <- if (per > 4) 300 else reg_seconds(g[i, ]) / 4
  left <- max(0, round(len - g$periodTime[i]))
  sprintf("%s %d:%02d", if (per > 4) paste0("OT", per - 4) else paste0("Q", per), left %/% 60, left %% 60)
}

last_name <- function(x) sub("^.* ", "", x)

# where the possession that ended in the score at row i began
possession_origin <- function(g, i, tm, op) {
  second <- FALSE
  j <- i - 1
  while (j >= 1) {
    ev <- g$event_type[j]; te <- g$team[j]
    if (ev %in% "start of period") return(list(origin = "inbound", t = g$totalTime[j], second = second))
    if (te %in% op && ev %in% "turnover") return(list(origin = "turnover", t = g$totalTime[j], second = second))
    if (te %in% tm && ev %in% "rebound") {
      if (g$rebound[j] %in% "offensive") second <- TRUE
      else return(list(origin = "miss", t = g$totalTime[j], second = second))
    }
    if (te %in% op && g$result[j] %in% "made" && isTRUE(g$points[j] > 0))
      return(list(origin = "inbound", t = g$totalTime[j], second = second))
    if (te %in% tm && ev %in% c("shot", "turnover"))
      return(list(origin = "unknown", t = g$totalTime[j], second = second))
    j <- j - 1
  }
  list(origin = "inbound", t = 0, second = second)
}

on_floor_share <- function(w, cols) {
  p <- unlist(w[, cols], use.names = FALSE)
  p <- p[!is.na(p) & nzchar(p)]
  sort(table(p) / nrow(w), decreasing = TRUE)
}

run_anatomy <- function(g, r, names) {
  nm <- function(x) if (!is.null(names) && x %in% names(names)) names[[x]] else x
  tm <- r$team
  home <- g$hometeam[1]
  op <- if (tm == home) g$awayteam[1] else home
  sc <- g$result %in% "made" & !is.na(g$points) & g$points > 0
  idx <- seq_len(nrow(g))
  i_end <- max(which(sc & g$team == tm & g$totalTime <= r$end))
  i0 <- max(c(0, which(sc & g$team == op & g$totalTime <= r$start & idx < i_end)))
  rows <- (i0 + 1):i_end
  w <- g[rows, ]
  own <- w$team %in% tm; opp <- w$team %in% op
  made <- sc[rows] & own
  ft <- w$event_type %in% "free throw"
  two <- made & w$ShotType %in% "2P"
  rim <- two & !is.na(w$shot_distance) & w$shot_distance <= 8
  pts <- function(m) as.integer(sum(w$points[m]))

  tov_pts <- sec_pts <- brk_pts <- 0L
  for (i in rows[made]) {
    o <- possession_origin(g, i, tm, op)
    p <- as.integer(g$points[i])
    if (o$origin == "turnover") tov_pts <- tov_pts + p
    if (o$second) sec_pts <- sec_pts + p
    if (o$origin %in% c("turnover", "miss") && g$totalTime[i] - o$t <= 7) brk_pts <- brk_pts + p
  }
  by_player <- tapply(w$points[made], w$player[made], sum)
  by_player <- sort(by_player, decreasing = TRUE)
  scorers <- paste(sprintf("%s %d", last_name(names(by_player)), as.integer(by_player)), collapse = ", ")

  fga <- opp & w$event_type %in% c("shot", "miss")
  three <- fga & w$ShotType %in% "3P"
  o_fgm <- sum(fga & w$result %in% "made"); o_fga <- sum(fga)
  o_3pm <- sum(three & w$result %in% "made"); o_3pa <- sum(three)
  o_tov <- sum(opp & w$event_type %in% "turnover")
  o_pf <- sum(opp & w$event_type %in% "foul")

  side <- function(t) if (t == home) paste0("h", 1:5) else paste0("a", 1:5)
  have_lu <- all(c(side(tm), side(op)) %in% names(w))
  floor_of <- function(t) {
    if (!have_lu) return(character())
    s <- on_floor_share(w, side(t))
    names(s)[s >= 0.5][seq_len(min(5, sum(s >= 0.5)))]
  }
  f_own <- floor_of(tm); f_opp <- floor_of(op)
  bench <- character()
  if (have_lu) {
    bx <- box_score(g)
    main <- bx$player[bx$team == op][order(-bx$min[bx$team == op])][1:3]
    bench <- setdiff(main[!is.na(main)], f_opp)
  }
  to_rows <- rows[opp & w$event_type %in% "timeout"]
  to_kept <- to_rows[vapply(to_rows, function(i) any(sc[(i + 1):i_end] & g$team[(i + 1):i_end] == tm), logical(1))]
  nxt <- which(sc & g$team == op & idx > i_end)[1]
  ended <- if (is.na(nxt)) "the end of the game" else {
    e <- g[nxt, ]
    kind <- if (e$event_type %in% "free throw") "free throw" else if (e$ShotType %in% "3P") "three" else "basket"
    sprintf("%s's %s", last_name(e$player), kind)
  }

  how <- c(if (pts(rim)) sprintf("%d at the rim", pts(rim)),
           if (pts(two & !rim)) sprintf("%d from mid-range", pts(two & !rim)),
           if (pts(made & w$ShotType %in% "3P")) sprintf("%d from three", pts(made & w$ShotType %in% "3P")),
           if (pts(made & ft)) sprintf("%d from the line", pts(made & ft)))
  src <- c(if (tov_pts) sprintf("%d off turnovers", tov_pts), if (sec_pts) sprintf("%d second-chance", sec_pts),
           if (brk_pts) sprintf("%d on the break", brk_pts))
  dur <- round(r$end - r$start)
  clock0 <- if (i0 > 0) game_clock(g, i0) else game_clock(g, 1)
  and_list <- function(x) if (length(x) < 2) x else paste(paste(x[-length(x)], collapse = ", "), "and", x[length(x)])
  story <- paste0(
    sprintf("**%s %s** (%s to %s, %d:%02d of play). ", sprintf("%d-%d", as.integer(r$points), as.integer(r$against)), nm(tm),
            clock0, game_clock(g, i_end), dur %/% 60, dur %% 60),
    sprintf("**How:** %s%s. ", paste(how, collapse = ", "), if (length(src)) paste0("; ", paste(src, collapse = ", ")) else ""),
    sprintf("**Scorers:** %s. ", scorers),
    sprintf("**%s:** %s%s, %d turnover%s, %d foul%s",
            nm(op), if (o_fga) sprintf("%d/%d from the field", o_fgm, o_fga) else "no shots",
            if (o_3pa) sprintf(" (%d/%d threes)", o_3pm, o_3pa) else "",
            o_tov, if (o_tov == 1) "" else "s", o_pf, if (o_pf == 1) "" else "s"),
    if (length(bench)) sprintf("; %s %s on the bench", and_list(last_name(bench)),
                               if (length(bench) == 1) "was" else "were") else "",
    ". ",
    if (length(to_kept)) sprintf("A timeout by %s (%s) did not stop it. ", nm(op), game_clock(g, to_kept[1])) else "",
    sprintf("**Ended by** %s.", ended))

  tibble::tibble(
    clock_start = clock0, clock_end = game_clock(g, i_end),
    pts_rim = pts(rim), pts_mid = pts(two & !rim), pts_three = pts(made & w$ShotType %in% "3P"), pts_ft = pts(made & ft),
    pts_off_tov = tov_pts, pts_second = sec_pts, pts_break = brk_pts, scorers = scorers,
    opp_fgm = o_fgm, opp_fga = o_fga, opp_3pm = o_3pm, opp_3pa = o_3pa, opp_tov = o_tov, opp_fouls = o_pf,
    on_floor = paste(f_own, collapse = ", "), opp_on_floor = paste(f_opp, collapse = ", "),
    opp_bench = paste(bench, collapse = ", "), opp_timeouts = length(to_rows), ended_by = ended, story = story)
}
