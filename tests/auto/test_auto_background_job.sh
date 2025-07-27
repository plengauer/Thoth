if ! type node; then exit 0; fi
. otel.sh
nohup node -e "require('http').createServer(function (req, res) { console.log(req.method, req.url); res.writeHead(200); res.end(); }).listen(8080);" > /tmp/http.log &
\sleep 5
\ps -ef | \grep node | \grep 'createServer'
\ps -ef | \grep node | \grep 'createServer' | \awk '{ print $2 }' | \xargs -I '{}' kill -9 '{}'

