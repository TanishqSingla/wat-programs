(module
    (import "env" "mem" (memory 1))
    (global $obj_base_addr (import "env" "obj_base_addr") i32)
    (global $obj_count (import "env" "obj_count") i32)
    (global $obj_stride (import "env" "obj_stride") i32)

    (global $x_offset (import "env" "x_offset") i32)
    (global $y_offset (import "env" "y_offset") i32)
    (global $radius_offset (import "env" "obj_stride") i32)
    (global $collision_offset (import "env" "collision_offset") i32)

    (func $collision_check
        (param $x1 i32) (param $y1 i32) (param $r1 i32)
        (param $x2 i32) (param $y2 i32) (param $r2 i32)
        (result i32)

        (local $x_diff_sq i32)
        (local $y_diff_sq i32)
        (local $r_sum_sq i32)

        local.get $x1
        local.get $x2
        i32.sub
        local.tee $x_diff_sq
        local.get $x_diff_sq
        i32.mul
        local.set $x_diff_sq ;; (x1 - x2) * (x1 - x2)

        local.get $y1
        local.get $y2
        i32.sub
        local.tee $y_diff_sq
        local.get $y_diff_sq
        i32.mul
        local.set $y_diff_sq ;; (y1 - y2) * (y1 - y2)

        local.get $r1
        local.get $r2
        i32.add
        local.tee $r_sum_sq
        local.get $r_sum_sq
        i32.mul
        local.tee $r_sum_sq ;; (r1 + r2) * (r1 * r2)

        local.get $x_diff_sq
        local.get $y_diff_sq
        i32.add

        i32.gt_u
    )
)