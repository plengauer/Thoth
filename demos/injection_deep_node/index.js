const https = require('https');
const options = {
  hostname: 'example.com',
  port: 443,
  path: '/',
  method: 'GET'
};
https.request(options, response => {
  response.on('data', function (chunk) {});
  response.on('end', function () {});  
}).on('error', err => {}).end();
