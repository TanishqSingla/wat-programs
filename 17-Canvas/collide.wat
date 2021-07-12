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

    (func $set_obj_attr
        (param $obj_number i32)
        (param $attr_offset i32)
        (param $value i32)

        local.get $obj_number

        i32.const 16
        i32.mul     ;; 16 byte stride multiplied by object number

        global.get $obj_start
        i32.add

        local.get $attr_offset
        i32.add

        local.get $value

        i32.store
    )

    (func $get_obj_attr
        (param $obj_number i32)
        (param $attr_offset i32)
        (result i32)

        local.get $obj_number
        i32.const 16
        i32.mul

        global.get $obj_start
        i32.add

        local.get $attr_offset
        i32.add

        i32.load
    )

    (func $main (export "main")
        (local $i   i32)
        (local $j   i32)
        (local $outer_ptr   i32)
        (local $inner_ptr   i32)

        (local $x1  i32)    ;; outer loop object x coordinate
        (local $x2  i32)    ;; inner loop object y coordinate
        (local $y1  i32)    ;; outer loop object y coordinate
        (local $y2  i32)    ;; inner loop object y coordinate

        (local $xdist   i32)    ;; distance b/w 2 objects on x axis
        (local $ydist   i32)    ;; distance b/w 2 objects on y axis

        (local $i_hit   i32)    ;; i object hit boolean flag
        (local $xv  i32)
        (local $yv  i32)

        (call $clear_canvas)    ;; set canvas to black

        (loop $move_loop
            ;; getting x attribute
            (call $get_obj_attr (local.get $i) (global.get $x_offset))
            local.set $x1

            ;; getting y attribute
            (call $get_obj_attr (local.get $i) (global.get $y_offset))
            local.set $y1

            ;; getting x velocity attribute
            (call $get_obj_attr (local.get $i) (global.get $x_offset))
            local.set $xv

            ;; getting y velocity attribute
            (call $get_obj_attr (local.get $i) (global.get $yv_offset))
            local.set $yv

            ;; add velocity to x and force it to stay in the canvas bounds
            (i32.add (local.get $xv) (local.get $x1))
            i32.const 0x1ff ;; 511 in decimal
            i32.and         ;; clear high order 23 bits
            local.set $x1

            ;; add velocity to y and force it to stay in the canvas bounds
            (i32.add (local.get $yv) (local.get $y1))
            i32.const 0x1ff ;; 511 in decimal
            i32.and         ;; clear high order 23 bits
            local.set $y1

            ;; set the x attribute in linear memory
            (call $set_obj_attr (local.get $i) (global.get $x_offset) (local.get $x1))

            ;; set the y attribute in linear memory
            (call $set_obj_attr (local.get $i) (global.get $y_offset) (local.get $y1))

            local.get $i
            i32.const 1
            i32.add
            local.tee $i    ;; i++

            global.get $obj_cnt
            i32.lt_u        ;; $i < obj_cnt

            if
                br $move_loop
            end
        )
        i32.const 0

        local.set $i

        (loop $outer_loop (block $outer_break
            i32.const 0
            local.tee $j    ;; setting j to 0

            ;; $i_hit is a boolean value. 0 for false, 1 for true
            local.set $i_hit    ;; setting i_hit to 0

            ;; get x attribute for object $i
            (call $get_obj_attr (local.get $i) (global.get $x_offset))
            local.set $x1
            
            ;; get y attribute for object $i
            (call $get_obj_attr (local.get $i) (global.get $y_offset))
            local.set $y1

            (loop $inner_loop (block $inner_break
                local.get $i
                local.get $j
                i32.eq
                if
                    local.get $j
                    i32.const 1
                    i32.add
                    local.set $j
                end

                local.get $j
                global.get $obj_cnt
                i32.ge_u
                if
                    br $inner_break
                end

                ;; get x attribute
                (call $get_obj_attr (local.get $j) (global.get $x_offset))
                local.set $x2   ;; set the x attribute for inner loop object

                ;; distance between $x1 and $x2
                (i32.sub (local.get $x1) (local.get $x2))
                call $abs   ;; getting absolute value
                local.tee $xdist    ;; xdist = the absolute value of ($x1 - $x2)

                global.get $obj_size
                i32.ge_u

                if
                    local.get $j
                    i32.const 1
                    i32.add
                    local.set $j

                    br $inner_loop  ;; increment $j and jump to beginning of inner_loop
                end

                ;; get y attribute
                (call $get_obj_attr (local.get $j) (global.get $y_offset))
                local.set $y2

                (i32.sub (local.get $y1) (local.get $y2))
                call $abs
                local.tee $ydist

                global.get $obj_size
                i32.ge_u

                if
                    local.get $j
                    i32.const 1
                    i32.add
                    local.set $j
                    br $inner_loop
                end

                i32.const 1
                local.set $i_hit
            ))

            local.get $i_hit
            i32.const 0
            i32.eq
            if
                (call $draw_obj (local.get $x1) (local.get $y1) (global.get $no_hit_color))
            else
                (call $draw_obj (local.get $x1) (local.get $y1) (global.get $hit_color))
            end

            local.get $i
            i32.const 1
            i32.add
            local.tee $i

            global.get $obj_cnt
            i32.lt_u
            if
                br $outer_loop
            end
        ))
    )
)