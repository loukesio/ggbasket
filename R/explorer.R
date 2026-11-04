#' Line-up explorer
#'
#' An interactive panel for the web: choose a team, tap one to five of its
#' players, and read how the team did while they were all on the floor
#' (minutes, score, net rating per 100 possessions) and with which
#' five-player units. With `season_pbp` the same numbers are shown for the
#' season, so a good night can be told from a good line-up. Everything is
#' computed in the browser from the [stints()] embedded in the page; no
#' server is needed.
#'
#' @param pbp Play-by-play of one game, with line-ups.
#' @param season_pbp Optional play-by-play of more games (e.g. both teams'
#'   season so far).
#' @param names Optional named vector of display names for team codes.
#' @param colours Two team colours, home first.
#' @param min_minutes Minutes together below which the numbers are flagged
#'   as a small sample.
#' @return An htmltools tag list (prints in R Markdown, or view with
#'   `htmltools::browsable()`).
#' @export
#' @examples
#' \dontrun{
#' htmltools::browsable(lineup_explorer(subset(pbp_games, game_id == "401766128")))
#' }
lineup_explorer <- function(pbp, season_pbp = NULL, names = NULL, colours = c("#1F5FA8", "#E07B00"),
                            min_minutes = 5) {
  rlang::check_installed(c("htmltools", "jsonlite"), "for the line-up explorer")
  g <- as.data.frame(pbp)
  home <- g$hometeam[1]; away <- g$awayteam[1]
  nm <- function(x) if (!is.null(names) && x %in% names(names)) names[[x]] else x
  units <- function(d, tm) {
    if (is.null(d) || !nrow(d)) return(NULL)
    st <- stints(d)
    h <- st$hometeam == tm; a <- st$awayteam == tm
    u <- data.frame(lineup = c(st$home_lineup[h], st$away_lineup[a]), sec = c(st$sec[h], st$sec[a]),
                    f = c(st$home_pts[h], st$away_pts[a]), a = c(st$away_pts[h], st$home_pts[a]),
                    pf = c(st$home_poss[h], st$away_poss[a]), pa = c(st$away_poss[h], st$home_poss[a]))
    u <- u[nzchar(u$lineup), ]
    u <- stats::aggregate(cbind(sec, f, a, pf, pa) ~ lineup, data = u, FUN = sum)
    u[u$sec > 0, ]
  }
  team_data <- function(tm, col) {
    ug <- units(g, tm)
    us <- units(season_pbp, tm)
    pl_min <- tapply(rep(ug$sec, lengths(strsplit(ug$lineup, " | ", fixed = TRUE))),
                     unlist(strsplit(ug$lineup, " | ", fixed = TRUE)), sum) / 60
    pl_min <- sort(pl_min, decreasing = TRUE)
    players <- names(pl_min)
    enc <- function(u) {
      if (is.null(u)) return(NULL)
      sp <- strsplit(u$lineup, " | ", fixed = TRUE)
      keep <- vapply(sp, function(x) any(x %in% players), logical(1))
      lapply(which(keep), function(i) list(p = match(sp[[i]], players) - 1L, s = u$sec[i], f = u$f[i], a = u$a[i],
                                           pf = round(u$pf[i], 2), pa = round(u$pa[i], 2)))
    }
    list(code = tm, name = nm(tm), colour = col, players = players, minutes = round(unname(pl_min), 1),
         game = enc(ug), season = enc(us))
  }
  data <- list(teams = list(team_data(home, colours[1]), team_data(away, colours[2])),
               min_minutes = min_minutes, has_season = !is.null(season_pbp))
  explorer_env$n <- (explorer_env$n %||% 0) + 1
  id <- sprintf("lux%d_%s", explorer_env$n, gsub("[^A-Za-z0-9]", "", g$game_id[1]))
  json <- jsonlite::toJSON(data, auto_unbox = TRUE, null = "null", digits = NA)
  htmltools::tagList(
    htmltools::tags$style(htmltools::HTML(explorer_css)),
    htmltools::tags$div(id = id, class = "lux"),
    htmltools::tags$script(htmltools::HTML(sprintf("(function(){var D=%s;var root=document.getElementById('%s');%s})();",
                                                   json, id, explorer_js))))
}

explorer_env <- new.env(parent = emptyenv())

explorer_css <- "
.lux { font-size: 0.92em; margin: 0.6em 0 1.6em; }
.lux .lux-tabs { display: flex; gap: 8px; margin-bottom: 10px; }
.lux .lux-tab { border: 2px solid var(--c); color: var(--c); background: #fff; border-radius: 4px; padding: 4px 12px;
  font: inherit; font-weight: 700; cursor: pointer; }
.lux .lux-tab.on { background: var(--c); color: #fff; }
.lux .lux-chips { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 12px; }
.lux .lux-chip { border: 1px solid #ccc; background: #fff; border-radius: 999px; padding: 3px 10px; font: inherit;
  cursor: pointer; color: #1F1F1F; }
.lux .lux-chip small { color: #888; margin-left: 4px; }
.lux .lux-chip.on { background: var(--c); border-color: var(--c); color: #fff; }
.lux .lux-chip.on small { color: rgba(255,255,255,.8); }
.lux .lux-hint { color: #777; margin: 0 0 10px; }
.lux .lux-cards { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 12px; }
.lux .lux-card { flex: 1 1 220px; background: #F5F5F7; border-left: 4px solid var(--c); border-radius: 4px; padding: 8px 12px; }
.lux .lux-card h4 { margin: 0 0 4px; font-size: 0.85em; text-transform: uppercase; letter-spacing: .04em; color: #555; }
.lux .lux-big { font-size: 1.5em; font-weight: 700; }
.lux .lux-warn { color: #A0522D; font-size: 0.85em; }
.lux table td.num, .lux table th.num { text-align: right; }
.lux .pos { color: #00798c; font-weight: 700; } .lux .neg { color: #C0392B; font-weight: 700; }
"

explorer_js <- "
var cur = 0, sel = [];
function el(tag, cls, txt) { var e = document.createElement(tag); if (cls) e.className = cls; if (txt != null) e.textContent = txt; return e; }
function has(u) { for (var i = 0; i < sel.length; i++) if (u.p.indexOf(sel[i]) < 0) return false; return true; }
function sum(us) { var t = {s:0,f:0,a:0,pf:0,pa:0}; us.forEach(function(u){ t.s+=u.s; t.f+=u.f; t.a+=u.a; t.pf+=u.pf; t.pa+=u.pa; }); return t; }
function fmtMin(s) { return (s/60).toFixed(1) + ' min'; }
function net(t) { var p = (t.pf + t.pa) / 2; return p > 0 ? 100 * (t.f - t.a) / p : NaN; }
function sgn(x, d) { return (x > 0 ? '+' : '') + x.toFixed(d || 0); }
function card(T, title, us) {
  var c = el('div', 'lux-card'); c.style.setProperty('--c', T.colour);
  c.appendChild(el('h4', null, title));
  var t = sum(us);
  if (!t.s) { c.appendChild(el('div', 'lux-big', 'never together')); return c; }
  var big = el('div', 'lux-big', fmtMin(t.s) + ' \\u00b7 ' + sgn(t.f - t.a)); c.appendChild(big);
  c.appendChild(el('div', null, 'Score ' + t.f + '-' + t.a + ' \\u00b7 net ' + (isNaN(net(t)) ? '-' : sgn(net(t), 1)) +
    ' per 100 poss. (' + Math.round((t.pf + t.pa) / 2) + ' poss.)'));
  if (t.s < 60 * D.min_minutes) c.appendChild(el('div', 'lux-warn', 'Small sample: under ' + D.min_minutes + ' minutes together.'));
  return c;
}
function table(T, us) {
  var tb = el('table'); var hr = el('tr');
  ['Line-up', 'MIN', 'Score', '+/-'].forEach(function(h, i){ hr.appendChild(el('th', i ? 'num' : null, h)); });
  var th = el('thead'); th.appendChild(hr); tb.appendChild(th);
  var body = el('tbody');
  us.slice().sort(function(a, b){ return b.s - a.s; }).forEach(function(u){
    var r = el('tr');
    r.appendChild(el('td', null, u.p.map(function(i){ return T.players[i]; }).join(', ')));
    r.appendChild(el('td', 'num', (u.s/60).toFixed(1)));
    r.appendChild(el('td', 'num', u.f + '-' + u.a));
    var d = u.f - u.a; r.appendChild(el('td', 'num ' + (d > 0 ? 'pos' : d < 0 ? 'neg' : ''), sgn(d)));
    body.appendChild(r);
  });
  tb.appendChild(body); return tb;
}
function draw() {
  root.innerHTML = '';
  var T = D.teams[cur];
  var tabs = el('div', 'lux-tabs');
  D.teams.forEach(function(t, i){
    var b = el('button', 'lux-tab' + (i === cur ? ' on' : ''), t.name); b.style.setProperty('--c', t.colour);
    b.onclick = function(){ cur = i; sel = []; draw(); }; tabs.appendChild(b);
  });
  root.appendChild(tabs);
  var chips = el('div', 'lux-chips');
  T.players.forEach(function(p, i){
    var b = el('button', 'lux-chip' + (sel.indexOf(i) >= 0 ? ' on' : ''), p); b.style.setProperty('--c', T.colour);
    b.appendChild(el('small', null, T.minutes[i].toFixed(0) + '\\u2032'));
    b.onclick = function(){ var k = sel.indexOf(i); if (k >= 0) sel.splice(k, 1); else if (sel.length < 5) sel.push(i); draw(); };
    chips.appendChild(b);
  });
  root.appendChild(chips);
  if (!sel.length) root.appendChild(el('p', 'lux-hint', 'Tap up to five players to see how ' + T.name + ' did with them all on the floor. Minutes played tonight next to each name.'));
  var g = T.game.filter(has);
  var cards = el('div', 'lux-cards');
  var who = sel.length ? (sel.length === 1 ? 'With ' + T.players[sel[0]] : 'These ' + sel.length + ' together') : 'Whole game';
  cards.appendChild(card(T, who + ', tonight', g));
  if (sel.length) cards.appendChild(card(T, 'Rest of the game, tonight', T.game.filter(function(u){ return !has(u); })));
  if (D.has_season && T.season) cards.appendChild(card(T, (sel.length ? who : 'All games') + ', season (incl. tonight)', T.season.filter(has)));
  root.appendChild(cards);
  if (g.length) { root.appendChild(el('p', 'lux-hint', 'Five-player units tonight' + (sel.length ? ' with them' : '') + ':')); root.appendChild(table(T, g)); }
}
draw();
"
