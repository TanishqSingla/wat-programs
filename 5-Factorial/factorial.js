const fs = require("fs");

const bytes = fs.readFileSync(__dirname + "/factorial.wasm");

const n = process.argv[2];

WebAssembly.instantiate(new Uint8Array(bytes)).then((obj) => {
  let factorial = obj.instance.exports.Fact(n);

  console.log(factorial);
});
