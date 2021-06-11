const fs = require("fs");

const export_bytes = fs.readFileSync(__dirname + "/table_export.wasm");
const test_bytes = fs.readFileSync(__dirname + "/table_test.wasm");

let i = 0;

let increment = () => {
  i++;
  return i;
};

let decrement = () => {
  i--;
  return i;
};
