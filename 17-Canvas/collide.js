"use strict";
const cnvs_size = 512;
const no_hit_color = 0xff_00_ff_00;
const hit_color = 0xff_00_00_ff;
const pixel_count = cnvs_size * cnvs_size;
const canvas = document.getElementById("cnvs");
const ctx = canvas.getContext("2d");
ctx.clearRect(0, 0, 512, 512);
const obj_start = pixel_count * 4; // 4 bytes in every pixel
const obj_start_32 = pixel_count; // 32 bit offset to staerting object;
const obj_size = 4;
const obj_cnt = 3000;
const stride_bytes = 16;
const x_offset = 0; // x attribute
const y_offset = 4; // y attribute
const xv_offset = 8; // x velocity attribute
const yv_offset = 12; // y velocity attribute
const memory = new WebAssembly.Memory({ initial: 80 });
const mem_i8 = new Uint8Array(memory.buffer);
const mem_i32 = new Uint32Array(memory.buffer);
const importObject = {
    env: {
        buffer: memory,
        cnvs_size,
        no_hit_color,
        hit_color,
        obj_start,
        obj_cnt,
        obj_size,
        x_offset,
        y_offset,
        xv_offset,
        yv_offset,
    },
};
const image_data = new ImageData(new Uint8ClampedArray(memory.buffer, 0, obj_start), cnvs_size, cnvs_size);
const stride_i32 = stride_bytes / 4;
for (let i = 0; i < obj_cnt * stride_i32; i += stride_i32) {
    // value less than canvas_size
    let temp = Math.floor(Math.random() * cnvs_size);
    // set object x attribute to random value
    mem_i32[obj_start_32 + i] = temp;
    // random value less than canvas_size
    temp = Math.floor(Math.random() * cnvs_size);
    // set object y attribute to random value
    mem_i32[obj_start_32 + i + 1] = temp;
    // random value between -2 and 2
    temp = Math.round(Math.random() * 4) - 2;
    // set x velocity to random value
    mem_i32[obj_start_32 + i + 2] = temp;
    // random value between -2 and 2
    temp = Math.round(Math.random() * 4) - 2;
    // set y velocity to random value
    mem_i32[obj_start_32 + i + 3] = temp;
}
var animation_wasm;
function animate() {
    animation_wasm();
    ctx.putImageData(image_data, 0, 0);
    requestAnimationFrame(animate);
}
(async () => {
    let obj = await WebAssembly.instantiateStreaming(fetch("collide.wasm"), importObject);
    // @ts-expect-error
    animation_wasm = obj.instance.exports.main;
    requestAnimationFrame(animate);
})();
