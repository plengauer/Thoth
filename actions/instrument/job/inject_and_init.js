const process = require('process')
const { spawn } = require('child_process');

function run(executable, args = []) {
  console.log(process.platform);
  if (process.platform != 'linux') return;
  return new Promise((resolve, reject) => {
    const process = spawn(executable, args, { cwd: __dirname, stdio: 'inherit' });
    process.on('close', code => code == 0 ? resolve(code) : reject(code));
    process.on('error', error => reject(new Error(error)));
  });
}

run('/bin/bash', [ '-e', __dirname + '/inject_and_init.sh' ])
