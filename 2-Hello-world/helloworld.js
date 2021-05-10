const fs = require("fs");

const bytes = fs.readFileSync(__dirname + "/hello-world.wasm");

let helloWorld = null;
let startStringIndex = 100;
let memory = new WebAssembly.Memory({ initial: 1 });

let importObject = {
  env: {
    buffer: memory,
    start_string: startStringIndex,
    print_string: function (str_len) {
      const bytes = new Uint8Array(memory.buffer, startStringIndex, str_len);

      const log_string = new TextDecoder("utf8").decode(bytes);
      console.log(log_string);
    },
  },
};
