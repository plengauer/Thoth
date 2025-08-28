type grep

. /usr/bin/opentelemetry_shell.sh

count_0=$(alias | wc -l)
alias la='ls -a'
count_1=$(alias | wc -l)
unalias la
count_2=$(alias | wc -l)
if [ "$((count_0 + 1))" -ne "$count_1" ] || [ "$((count_1 - 1))" -ne "$count_2" ]; then echo "0: $count_0 $count_1 $count_2"; exit 1; fi

count_0=$(alias | wc -l)
alias grep='grep --color=auto'
count_1=$(alias | wc -l)
unalias grep
count_2=$(alias | wc -l)
if [ "$count_0" -ne "$count_1" ] || [ "$count_1" -ne "$count_2" ]; then echo "1: $count_0 $count_1 $count_2"; exit 1; fi

count_0=$(alias | wc -l)
unalias -a
count_1=$(alias | wc -l)
if ! [ "$count_0" -gt "$count_1" ]; then echo "2: $count_0 $count_1"; exit 1; fi # gt because we expect cache to kick in and reduce even further

exit 0
