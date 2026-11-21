/^\[/ { in_section = ($0 == "[" service "]"); if (in_section) found = 1; next }
in_section && index($0, key) == 1 { rest = substr($0, length(key) + 1); if (match(rest, /^[ \t]*=[ \t]*/)) value = substr(rest, RLENGTH + 1) }
END { if (found) { print value; exit 0 } exit 1 }
