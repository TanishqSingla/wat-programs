const fs = require("fs");

const bytes = fs.readFileSync("./globals.wasm");

let global_test = null;

let importObject = {
  js: {
    log_i32: (value) => console.log("i32 ", value),
    log_f32: (value) => console.log("f32 ", value),
    log_f64: (value) => console.log("f64 ", value),
  },

  env: {
    import_i32: 132,
    import_f32: 123.0123456,
    import_f64: 123.0123456789,
  },
};

WebAssembly.instantiate(new Uint8Array(bytes), importObject).then((obj) => {
  ({ globaltest: global_test } = obj.instance.exports);

  global_test();
});
