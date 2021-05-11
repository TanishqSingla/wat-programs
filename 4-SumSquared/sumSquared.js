const fs = require("fs");

const bytes = fs.readFileSync(__dirname + "/sumSquared.wasm");

const firstValue = parseInt(process.argv[2]);
const secondValue = parseInt(process.argv[3]);

WebAssembly.instantiate(new Uint8Array(bytes)).then((obj) => {
  let squaredValue = obj.instance.exports.SumSquared(firstValue, secondValue);

  console.log(
    `(${firstValue} + ${secondValue}) * (${firstValue} + ${secondValue}) = ${squaredValue}`
  );
});
