const fs = require("fs");

const bytes = fs.readFileSync(__dirnam + "/pointer.wasm");
const memory = new WebAssembly.Memory({ initial: 1, maximum: 4 });

const importObject = {
  env: {
    mem: memory,
  },
};

(async () => {
  const obj = await WebAssembly.instantiate(
    new Uint8Array(bytes),
    importObject
  );

  let pointer_value = obj.instance.exports.get_ptr();
  console.log(`pointer_value=${pointer_value}`);
})();
