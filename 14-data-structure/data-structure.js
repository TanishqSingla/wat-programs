const colors = require("colors");
const fs = require("fs");

const bytes = fs.readFileSync(__dirname + "/data-structure.wasm");

const memory = new WebAssembly.Memory({ initial: 1 });

const mem_i32 = new Uint32Array(memory.buffer);

const obj_base_addr = 0;
const obj_count = 32;
const obj_stride = 16;

const x_offset = 0;
const y_offset = 4;
const radius_offset = 8;
const collision_offset = 12;

const obj_i32_base_index = obj_base_addr / 4;
const obj_i32_stride = obj_stride / 4;

const x_offset_i32 = x_offset / 4;
const y_offset_i32 = y_offset / 4;
const radius_offset_i32 = radius_offset / 4;
const collision_offset_i32 = collision_offset / 4;
