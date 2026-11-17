{ text = text $0 " " }
END {
  n = length(text); i = 1
  while (i <= n) {
    while (i <= n && substr(text, i, 1) ~ /[ \t]/) i++
    name = ""
    while (i <= n && substr(text, i, 1) !~ /[ \t=]/) name = name substr(text, i++, 1)
    while (i <= n && substr(text, i, 1) ~ /[ \t]/) i++
    if (substr(text, i, 1) != "=") break
    i++
    while (i <= n && substr(text, i, 1) ~ /[ \t]/) i++
    v = ""
    if (substr(text, i, 1) == "\047") {
      i++
      while (i <= n && substr(text, i, 1) != "\047") {
        if (substr(text, i, 1) == "\\") i++
        v = v substr(text, i++, 1)
      }
      i++
    } else {
      while (i <= n && substr(text, i, 1) !~ /[ \t]/) {
        if (substr(text, i, 1) == "\\") i++
        v = v substr(text, i++, 1)
      }
    }
    if (name == key) found = v
  }
  print found
}
