const fs = require("fs");

const bytes = fs.readFileSync(__dirname + "/func-perform.wasm");

let i = 0;
let importedObject = {
  js: {
    external_call: function () {
      i++;
      return i;
    },
  },
};

(async () => {
  const obj = WebAssembly.instantiate(new Uint8Array(bytes), importedObject);

  // destructive wasm_call and js_call from obj.instance.exports
  ({ wasm_call, js_call } = obj.instantiate.exports);

  let start = Date.now();
  wasm_call();

  let time = Date.now() - start;
  console.log("wasm_call time=" + time);

  start = Date.now();
  js_call();
  time = Date.now() - start;
  console.log("js_call time=" + time);
})();
