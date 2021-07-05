const cnvs_size = 512;

const no_hit_color = 0xff_00_ff_00;
const hit_color = 0xff_00_00_ff;

const pixel_count = cnvs_size * cnvs_size;

const canvas = document.getElementById("cnvs") as HTMLCanvasElement;
const ctx = canvas.getContext("2d") as CanvasRenderingContext2D;
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

const memory = new WebAssembly.Memory({ initial: 1 });
const mem_18 = new Uint8Array(memory.buffer);
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

const image_data = new ImageData(
  new Uint8ClampedArray(memory.buffer, 0, obj_start),
  cnvs_size,
  cnvs_size
);
