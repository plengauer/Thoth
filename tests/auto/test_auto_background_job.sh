if ! type node || cat /etc/os-release | grep Alpine; then exit 0; fi
. otel.sh
nohup node -e "require('http').createServer(function (req, res) { console.log(req.method, req.url); res.writeHead(200); res.end(); }).listen(8080);" > /tmp/http.log &
\sleep 5
\ps -o 'pid,command' | \grep node | \grep 'createServer'
\ps -o 'pid,command' | \grep node | \grep 'createServer' | \cut -d ' ' -f 1 | \xargs -I '{}' kill -9 '{}'

