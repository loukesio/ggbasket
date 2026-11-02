#' Possessions
#'
#' The Kubatko et al. (2007) estimate:
#' `FGA + ft_coef * FTA - ORB + TOV`. The 0.44 coefficient fits the NBA; FIBA
#' studies often use 0.4 or 0.5, so it is an argument.
#'
#' @param fga Field-goal attempts (2PA + 3PA).
#' @param fta,orb,tov Free-throw attempts, offensive rebounds, turnovers.
#' @param ft_coef Weight of a free-throw attempt.
#' @export
#' @examples
#' possessions(fga = 88, fta = 22, orb = 10, tov = 13)
possessions <- function(fga, fta, orb, tov, ft_coef = 0.44) {
  fga + ft_coef * fta - orb + tov
}

#' Pace, ratings and the four factors
#'
#' Takes one row per team (season totals or single games) with the team's
#' counting stats and the opponent's counting stats prefixed by `o_`
#' (`o_p2a`, `o_tov`, ...), and returns possessions, pace, offensive /
#' defensive / net rating and Dean Oliver's four factors for offence and
#' defence. Rows are kept, so you can pass grouped game data and summarise
#' first, or pass totals directly.
#'
#' Columns needed: `pts p2m p2a p3m p3a ftm fta orb drb tov` and the same with
#' `o_`. Optional `min` (team minutes, i.e. 5 x game minutes, or game minutes
#' when `min_is_team = FALSE`) enables pace.
#'
#' @param data A data frame.
#' @param ft_coef Passed to [possessions()].
#' @param min_is_team Is `min` the sum of player minutes (240 per NBA game)?
#' @param per Minutes the pace refers to (48 NBA, 40 FIBA).
#' @return `data` with added columns `poss`, `o_poss`, `pace`, `ortg`, `drtg`,
#'   `net_rtg`, `efg`, `tov_pct`, `orb_pct`, `ft_rate`, `o_efg`, `o_tov_pct`,
#'   `drb_pct`, `o_ft_rate`.
#' @export
#' @examples
#' ff <- four_factors(team_seasons)
#' head(ff[, c("team", "league", "ortg", "drtg", "efg", "tov_pct")])
four_factors <- function(data, ft_coef = 0.44, min_is_team = TRUE, per = NULL) {
  need <- c("pts", "p2m", "p2a", "p3m", "p3a", "ftm", "fta", "orb", "drb", "tov")
  miss <- setdiff(c(need, paste0("o_", need)), names(data))
  if (length(miss)) rlang::abort(paste("Missing columns:", paste(miss, collapse = ", ")))
  out <- dplyr::mutate(
    data,
    poss = possessions(.data$p2a + .data$p3a, .data$fta, .data$orb, .data$tov, ft_coef),
    o_poss = possessions(.data$o_p2a + .data$o_p3a, .data$o_fta, .data$o_orb, .data$o_tov, ft_coef),
    ortg = 100 * .data$pts / .data$poss,
    drtg = 100 * .data$o_pts / .data$o_poss,
    net_rtg = .data$ortg - .data$drtg,
    efg = (.data$p2m + 1.5 * .data$p3m) / (.data$p2a + .data$p3a),
    tov_pct = .data$tov / .data$poss,
    orb_pct = .data$orb / (.data$orb + .data$o_drb),
    ft_rate = .data$ftm / (.data$p2a + .data$p3a),
    o_efg = (.data$o_p2m + 1.5 * .data$o_p3m) / (.data$o_p2a + .data$o_p3a),
    o_tov_pct = .data$o_tov / .data$o_poss,
    drb_pct = .data$drb / (.data$o_orb + .data$drb),
    o_ft_rate = .data$o_ftm / (.data$o_p2a + .data$o_p3a)
  )
  if ("min" %in% names(data)) {
    game_min <- if (min_is_team) out$min / 5 else out$min
    if (is.null(per)) {
      per <- if ("league" %in% names(out)) ifelse(toupper(out$league) == "NBA", 48, 40) else 48
    }
    out$pace <- per * (out$poss + out$o_poss) / 2 / game_min
  }
  out
}

#' Names, direction and Oliver weights of the four factors
#'
#' A lookup table used by [plot_four_factors()]: one row per factor and side
#' with the column name, a label, whether higher is better for the team, and
#' Dean Oliver's approximate weight (40/25/20/15).
#' @export
four_factor_info <- function() {
  tibble::tribble(
    ~factor,          ~side,     ~column,     ~higher_is_better, ~weight,
    "Shooting (eFG%)", "Offence", "efg",       TRUE,              0.40,
    "Turnovers (TOV%)", "Offence", "tov_pct",   FALSE,             0.25,
    "Rebounding (ORB%)", "Offence", "orb_pct",   TRUE,              0.20,
    "Free throws (FT/FGA)", "Offence", "ft_rate",   TRUE,              0.15,
    "Shooting (eFG%)", "Defence", "o_efg",     FALSE,             0.40,
    "Turnovers (TOV%)", "Defence", "o_tov_pct", TRUE,              0.25,
    "Rebounding (ORB%)", "Defence", "drb_pct",   TRUE,              0.20,
    "Free throws (FT/FGA)", "Defence", "o_ft_rate", FALSE,             0.15
  )
}

#' Lorenz curve and Gini coefficient
#'
#' How concentrated is a quantity (points, shots, assists) among the top `n`
#' contributors? `lorenz()` returns the curve, `gini()` the coefficient in
#' `[0, 1]`. Only the `n` largest values are used, because
#' adding deep-bench players inflates inequality; compare teams with the same
#' `n`. The Gini is the normalised area between the line of equality and the
#' curve, so with `n` players its maximum is 1.
#'
#' @param x Non-negative values (one per player).
#' @param n Number of largest values to keep (`NULL` = all).
#' @export
#' @examples
#' pts <- c(2028, 1734, 1261, 1056, 1918, 1236, 600, 400, 50)
#' gini(pts, n = 8)
#' lorenz(pts, n = 8)
gini <- function(x, n = NULL) {
  l <- lorenz(x, n)
  attr(l, "gini")
}

#' @rdname gini
#' @export
lorenz <- function(x, n = NULL) {
  x <- x[is.finite(x)]
  if (any(x < 0)) rlang::abort("Lorenz curves need non-negative values.")
  x <- sort(x, decreasing = TRUE)
  if (!is.null(n)) x <- utils::head(x, n)
  x <- sort(x)
  k <- length(x)
  cum_share_people <- c(0, seq_len(k) / k)
  cum_share_value <- c(0, cumsum(x) / sum(x))
  # definition: sum over i < k of (p_i - q_i) / sum over i < k of p_i
  g <- if (k > 1) sum(cum_share_people[2:k] - cum_share_value[2:k]) / sum(cum_share_people[2:k]) else 0
  out <- tibble::tibble(rank = 0:k, people = cum_share_people, value = cum_share_value)
  attr(out, "gini") <- g
  out
}

#' Shrink rates towards the group average (empirical Bayes)
#'
#' Fits a beta distribution to the observed rates `made / attempts` across
#' all rows (or within `group`) by marginal maximum likelihood of the
#' beta-binomial, and returns each row's posterior mean and a credible
#' interval. A player who is 0/2 from three is pulled almost all the way to the
#' average; a player who is 150/400 barely moves. This replaces raw
#' percentages wherever small samples would otherwise dominate a figure (the
#' range of a team's 3P% is otherwise set by a 0/2 shooter).
#'
#' @param made,attempts Counts.
#' @param group Optional grouping vector (e.g. league or zone): a separate
#'   prior is fitted per group.
#' @param level Width of the credible interval.
#' @return A tibble with `raw`, `shrunk`, `lower`, `upper`, `prior_mean`,
#'   `prior_n` (the prior's weight in pseudo-attempts).
#' @export
#' @examples
#' shrink_rate(c(0, 150, 30), c(2, 400, 80))
shrink_rate <- function(made, attempts, group = NULL, level = 0.8) {
  if (is.null(group)) group <- rep(1, length(made))
  out <- tibble::tibble(made = made, attempts = attempts, group = group, raw = made / attempts,
                        shrunk = NA_real_, lower = NA_real_, upper = NA_real_,
                        prior_mean = NA_real_, prior_n = NA_real_)
  for (g in unique(group)) {
    i <- which(group == g & attempts > 0)
    ab <- fit_beta_binomial(made[i], attempts[i])
    a <- ab[1] + made[i]
    b <- ab[2] + attempts[i] - made[i]
    out$shrunk[i] <- a / (a + b)
    out$lower[i] <- stats::qbeta((1 - level) / 2, a, b)
    out$upper[i] <- stats::qbeta(1 - (1 - level) / 2, a, b)
    out$prior_mean[i] <- ab[1] / sum(ab)
    out$prior_n[i] <- sum(ab)
  }
  out$group <- NULL
  out
}

fit_beta_binomial <- function(k, n) {
  p <- sum(k) / sum(n)
  if (length(k) < 3 || p <= 0 || p >= 1) return(c(p, 1 - p) * 10)
  nll <- function(par) {
    m <- stats::plogis(par[1]); s <- exp(par[2])
    -sum(lbeta(k + m * s, n - k + (1 - m) * s) - lbeta(m * s, (1 - m) * s))
  }
  fit <- stats::optim(c(stats::qlogis(p), log(50)), nll, method = "Nelder-Mead")
  m <- stats::plogis(fit$par[1]); s <- min(exp(fit$par[2]), 1e5)
  c(m * s, (1 - m) * s)
}

#' Percentile of each value within a reference group
#'
#' @param x Values.
#' @param group Optional group (e.g. league or position); percentiles are
#'   computed within group.
#' @return Percentiles in `[0, 100]` (mid-rank, so ties share a value).
#' @export
percentile_rank <- function(x, group = NULL) {
  if (is.null(group)) group <- rep(1, length(x))
  out <- rep(NA_real_, length(x))
  for (g in unique(group)) {
    i <- which(group == g & !is.na(x))
    out[i] <- 100 * (rank(x[i]) - 0.5) / length(i)
  }
  out
}
