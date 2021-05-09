const fs = require("fs");

const bytes = fs.readFileSync(__dirname + "/AddInt.wasm");

const firstValue = process.argv[2];
const secondValue = process.argv[3];

WebAssembly.instantiate(new Uint8Array(bytes)).then((obj) => {
  let addValue = obj.instance.exports.AddInt(firstValue, secondValue);

  console.log(`${firstValue} + ${secondValue} = ${addValue}`);
});
