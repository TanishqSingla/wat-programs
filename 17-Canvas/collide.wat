(module
    (global $cnvs_size (import "env" "cnvs_size") i32)

    (global $no_hit_color (import "env" "no_hit_color") i32)
    (global $hit_color (import "env" "hit_color") i32)
    (global $obj_start (import "env" "obj_start") i32)
    (global $obj_size (import "env" "obj_size") i32)
    (global $obj_cnt (import "env" "obj_cnt") i32)

    (global $x_offset (import "env" "x_offset") i32)
    (global $y_offset (import "env" "y_offset") i32)
    (global $xv_offset (import "env" "xv_offset") i32)
    (global $yv_offset (import "env" "yv_offset") i32)

    (import "env" "buffer" (memory 80))  ;; canvas buffer

    (func $clear_canvas
        (local $i i32)
        (local $pixel_bytes i32)

        global.get $cnvs_size
        global.get $cnvs_size
        i32.mul

        i32.const 4
        i32.mul

        local.set $pixel_bytes

        (loop $pixel_loop
            (i32.store (local.get $i) (i32.const 0xff_00_00_00))

            (i32.add (local.get $i) (i32.const 4))
            local.set $i

            ;; if $i < $pixel_bytes
            (i32.lt_u (local.get $i) (local.get $pixel_bytes))
            br_if $pixel_loop
        ) 
    )

    (func $abs
        (param $value    i32)
        (result         i32)

        (i32.lt_s (local.get $value) (i32.const 0))
        if
            i32.const 0
            local.get $value
            i32.sub

            return
        end
        local.get $value
        ;; Note subtracting from 0 is faster in wasm
    )

    (func $set_pixel
        (param $x i32)  ;; x coordinate
        (param $y i32)  ;; y coordinate
        (param $c i32)  ;; color value

        ;; is $x > cnvs_size
        (i32.ge_u (local.get $x) (global.get $cnvs_size))
        if  ;; if x is outside canvas return
            return
        end

        (i32.ge_u (local.get $y) (global.get $cnvs_size))
        if
            return
        end

        local.get $y
        global.get $cnvs_size
        i32.mul

        local.get $x
        i32.add         ;; x + y * cnvs_size, to get the number of pixels

        i32.const 4
        i32.mul         ;; multiply by 4 because each pixel is 4 bytes

        local.get $c

        i32.store
    )

    (func $draw_obj
        (param $x i32)
        (param $y i32)
        (param $c i32)

        (local $max_x   i32)
        (local $max_y   i32)

        (local $xi      i32)
        (local $yi      i32)

        local.get $x
        local.tee $xi
        global.get $obj_size
        i32.add
        local.set $max_x

        local.get $y
        local.tee $yi
        global.get $obj_size
        i32.add
        local.set $max_y

        (block $break (loop $draw_loop
            local.get $xi
            local.get $yi
            local.get $c
            call $set_pixel

            local.get $xi
            i32.const 1
            i32.add
            local.tee $xi

            local.get $max_x
            i32.ge_u

            if
                local.get $x
                local.set $xi

                local.get $yi
                i32.const 1
                i32.add
                local.tee $yi

                local.get $max_y
                i32.ge_u

                br_if $break
            end
            br $draw_loop
        ))
    )
)