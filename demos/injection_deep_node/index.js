const http = require('http');
const options = {
  hostname: 'example.com',
  port: 80,
  path: '/',
  method: 'GET'
};
http.request(options, response => {
  response.on('data', function (chunk) {});
  response.on('end', function () {});  
}).end();
