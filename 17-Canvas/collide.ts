const cnvs_size = 512;

const no_hit_color = 0xff_00_ff_00;
const hit_color = 0xff_00_00_ff;

const pixel_count = cnvs_size * cnvs_size;

const canvas = document.getElementById("cnvs") as HTMLCanvasElement;
const ctx = canvas.getContext("2d") as CanvasRenderingContext2D;
ctx.clearRect(0, 0, 512, 512);
