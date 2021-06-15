const fs = require("fs");
const bytes = fs.readFileSync(__dirname + "/strings.wasm");

let memory = new WebAssembly.Memory({ initial: 1 });

let importObject = {
  env: {
    buffer: memory,
    str_pos_len: function (str_pos, str_len) {
      const bytes = new Uint8Array(memory.buffer, str_pos, str_len);

      const log_string = new TextDecoder("utf8").decode(bytes);
      console.log(log_string);
    },
  },
};

(async () => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);

  let main = obj.instance.exports.main;

  main();
})();
