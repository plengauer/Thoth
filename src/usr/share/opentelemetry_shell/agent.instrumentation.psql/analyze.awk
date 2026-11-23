function space() { if (out != "" && substr(out, length(out), 1) != " ") out = out " " }
function add(text, type) {
  if (length(out) < 2048) out = out text
  if (ntok < 4096) { ntok++; tt[ntok] = type; tv[ntok] = text; tu[ntok] = toupper(text); td[ntok] = depth }
}
function collapse(s,    prefix) {
  while (match(s, /(^|[^A-Za-z0-9_])[Ii][Nn] ?\(\?( ?, ?\?)+\)/)) {
    prefix = (RSTART == 1 || substr(s, RSTART, 1) ~ /[Ii]/) ? "" : substr(s, RSTART, 1)
    s = substr(s, 1, RSTART - 1) prefix substr(s, RSTART + length(prefix), 2) " (?)" substr(s, RSTART + RLENGTH)
  }
  return s
}
function reset() { out = ""; ntok = 0; depth = 0 }
function target(k, stop,    j, name) {
  j = k + 1
  while (tu[j] == "ONLY" || tu[j] == "TABLE" || tu[j] == "LATERAL") j++
  while (j <= ntok) {
    if ((tt[j] != "w" && tt[j] != "q") || (stop && tv[j + 1] == "(")) return
    name = tv[j]
    while (tv[j + 1] == "." && (tt[j + 2] == "w" || tt[j + 2] == "q")) { name = name "." tv[j + 2]; j += 2 }
    found[name] = 1
    if (length(sum) + length(name) < 255) sum = sum " " name
    if (tu[j + 1] == "AS" && tt[j + 2] == "w") j += 2
    else if (tt[j + 1] == "w" && tv[j + 2] == ",") j++
    if (tv[j + 1] != ",") return
    j += 2
  }
}
function infunc(k,    j, d) {
  for (j = k - 1; j >= 1; j--) {
    if (tv[j] == ")") d++
    else if (tv[j] == "(") { if (d == 0) return tu[j - 1] == "EXTRACT" || tu[j - 1] == "SUBSTRING" || tu[j - 1] == "TRIM" || tu[j - 1] == "OVERLAY" || tu[j - 1] == "POSITION"; d-- }
  }
  return 0
}
function finish(    f, k, op) {
  for (f = 1; f <= ntok && tt[f] != "w"; f++) ;
  if (f > ntok) { reset(); return }
  op = tu[f]; sum = ""
  if (op == "CREATE" || op == "ALTER" || op == "DROP") {
    for (k = f + 1; k <= ntok && (tu[k] == "OR" || tu[k] == "REPLACE" || tu[k] == "TEMP" || tu[k] == "TEMPORARY" || tu[k] == "UNLOGGED" || tu[k] == "UNIQUE" || tu[k] == "GLOBAL" || tu[k] == "LOCAL"); k++) ;
    op = op " " tu[k]
    if (tu[k] == "MATERIALIZED") { op = op " VIEW"; k++ }
    sum = op
    for (k++; k <= ntok && (tu[k] == "IF" || tu[k] == "NOT" || tu[k] == "EXISTS" || tu[k] == "ONLY" || tu[k] == "CONCURRENTLY"); k++) ;
    k--
    target(k, 0)
  } else {
    if (op == "WITH") {
      for (k = f + 1; k <= ntok; k++) if (td[k] == td[f] && (tu[k] == "SELECT" || tu[k] == "INSERT" || tu[k] == "UPDATE" || tu[k] == "DELETE" || tu[k] == "MERGE")) { op = tu[k]; break }
    } else sum = op
    for (k = f; k <= ntok; k++) {
      if (tt[k] != "w") continue
      if (k > f && (tu[k] == "SELECT" || tu[k] == "INSERT" || tu[k] == "DELETE" || tu[k] == "MERGE" || (tu[k] == "UPDATE" && tu[k - 1] != "DO" && tu[k - 1] != "FOR" && tu[k - 1] != "KEY"))) { if (length(sum) + length(tu[k]) < 255) sum = sum " " tu[k] }
      else if (tu[k] == "JOIN" || (tu[k] == "FROM" && tu[k - 1] != "DISTINCT" && !infunc(k))) target(k, 1)
      else if (tu[k] == "INTO" || (k == f && (tu[k] == "UPDATE" || tu[k] == "COPY" || tu[k] == "TRUNCATE"))) target(k, 0)
    }
  }
  sub(/^ +/, "", sum)
  sub(/ +$/, "", out)
  out = collapse(out)
  count++
  if (count == 1) { op1 = op; sum1 = sum; text1 = out; sameop = 1; samesum = 1; sametext = 1; alltext = out }
  else {
    if (op != op1) sameop = 0
    if (sum != sum1) samesum = 0
    if (out != text1) sametext = 0
    if (length(alltext) < 1100) alltext = alltext "; " out
  }
  if (toupper(out) ~ /^COPY .* FROM +STDIN/) copy = 1
  reset()
}
BEGIN { Q = "\047"; D = "\""; B = "\\"; SPECIAL = " \t\n\r\f()[]{},;.:+-*/<>=~!@#%^&|`?\\\047\""; reset() }
{
  if (copy) { if ($0 == B ".") copy = 0; next }
  bytes += length($0) + 1
  if (bytes > 1048576) truncated = 1
  if (truncated) next
  line = $0 "\n"; n = length(line); i = 1
  while (i <= n) {
    c = substr(line, i, 1)
    if (mode == 3) {
      two = substr(line, i, 2)
      if (two == "*/") { cd--; i += 2; if (cd == 0) { mode = 0; space() } }
      else if (two == "/*") { cd++; i += 2 }
      else i++
    } else if (mode == 1) {
      if (c == Q) { if (substr(line, i + 1, 1) == Q) i += 2; else { mode = 0; i++ } }
      else if (c == B && esc) i += 2
      else i++
    } else if (mode == 2) {
      if (c == "$" && substr(line, i, length(tag)) == tag) { i += length(tag); mode = 0 } else i++
    } else if (mode == 4) {
      if (c == D) { if (substr(line, i + 1, 1) == D) { word = word D D; i += 2 } else { add(word D, "q"); mode = 0; i++ } }
      else { word = word (c == "\n" ? " " : c); i++ }
    } else if (c == " " || c == "\t" || c == "\n" || c == "\r" || c == "\f") { space(); i++ }
    else if (substr(line, i, 2) == "--") { space(); i = n + 1 }
    else if (substr(line, i, 2) == "/*") { mode = 3; cd = 1; i += 2 }
    else if (c == Q) {
      esc = 0
      if (ntok > 0 && tt[ntok] == "w" && length(tv[ntok]) == 1 && substr(out, length(out), 1) != " " && index("EeBbXxNn", tv[ntok]) > 0) {
        esc = (tv[ntok] == "E" || tv[ntok] == "e"); out = substr(out, 1, length(out) - 1); ntok--
      }
      add("?", "l"); mode = 1; i++
    }
    else if (c == D) { mode = 4; word = D; i++ }
    else if (c == "$") {
      rest = substr(line, i, 200)
      if (match(rest, /^\$([A-Za-z_][A-Za-z0-9_]*)?\$/)) { tag = substr(rest, 1, RLENGTH); add("?", "l"); mode = 2; i += RLENGTH }
      else if (match(rest, /^\$[0-9]+/)) { add(substr(rest, 1, RLENGTH), "p"); i += RLENGTH }
      else { add(c, "p"); i++ }
    }
    else if (c ~ /[0-9]/ || (c == "." && substr(line, i + 1, 1) ~ /[0-9]/ && (ntok == 0 || tt[ntok] == "p" || tt[ntok] == "l"))) {
      rest = substr(line, i, 200)
      if (!match(rest, /^0[xX][0-9A-Fa-f]+/)) match(rest, /^([0-9]+\.?[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?/)
      add("?", "l"); i += RLENGTH
    }
    else if (index(SPECIAL, c) == 0) {
      word = c; i++
      while (i <= n && index(SPECIAL, substr(line, i, 1)) == 0) word = word substr(line, i++, 1)
      if (toupper(word) == "TRUE" || toupper(word) == "FALSE") add("?", "l"); else add(word, "w")
    }
    else if (c == "(") { depth++; add(c, "p"); i++ }
    else if (c == ")") { if (depth > 0) depth--; add(c, "p"); i++ }
    else if (c == ";") { if (depth == 0) { finish(); i = copy ? n + 1 : i + 1 } else { add(c, "p"); i++ } }
    else if (c == B) {
      if (substr(line, i + 1, 1) == ";") { finish(); i += 2 }
      else {
        if (substr(line, i + 1, 1) == "g") finish()
        if (tolower(substr(line, i)) ~ /^\\copy .* from +p?stdin/) copy = 1
        i = n + 1
      }
    }
    else { add(c, "p"); i++ }
  }
}
END {
  if (!truncated) finish()
  if (count == 0) exit
  if (!truncated) print "count=" count
  single = (count == 1 && !truncated)
  print "operation=" (single ? op1 : (sameop ? "BATCH " op1 : "BATCH"))
  print "summary=" (single ? sum1 : (samesum ? "BATCH " sum1 : "BATCH"))
  print "text=" substr(sametext ? text1 : alltext, 1, 1024)
  for (name in found) { names++; only = name }
  if (names == 1) print "collection=" only
}
