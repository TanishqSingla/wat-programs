(module
    (import "env" "buffer" (memory 1))

    (global $digit_ptr i32 (i32.const 128))
    (data (i32.const 128) "0123456789ABCDEF")

    (global $dec_string_ptr i32 (i32.const 256))
    (global $dec_string_ptr_len i32 (i32.const 16))
    (data (i32.const 256) "               0")

    (global $hex_string_ptr i32 (i32.const 384))
    (global $hex_string_ptr i32 (i32.const 16))
    (data (i32.const 384) "               0x0")

    (global $bin_string_ptr i32 (i32.const 512))
    (global $bin_string_ptr i32 (i32.const 40))
    (data (i32.const 512) "0000 0000 0000 0000 0000 0000 0000 0000")

    (global $h1_open_ptr i32 (i32.const 640))
    (global $h1_open_len i32 (i32.const 4))
    (data (i32.const 640) "<h1>")

    (global $h1_close_ptr i32 (i32.const 656))
    (global $h1_open_len i32 (i32.const 5))
    (data (i32.const 656) "</h1>")

    (global $h4_open_ptr i32 (i32.const 672))
    (global $h4_open_len i32 (i32.const 4))
    (data (i32.const 672) "<h4>")

    (global $h4_close_ptr i32 (i32.const 688))
    (global $h4_close_len i32 (i32.const 5))
    (data (i32.const 688) "</h4>")

    (global $out_str_ptr i32 (i32.const 1024))
    (global $out_str_len i32 (mut i32) (i32.const 0))

    (func $set_bin_string (param $num i32) (param $string_len i32)
        (local $index i32)
        (local $loops_remaining i32)
        (local $nibble_bits i32)

        global.get $bin_string_len
        local.get $index

        i32.const 8
        local.set $loops_remaining

        (loop $bin_loop (block $outer_break
            local.get $index
            i32.eqz
            br_if $outer_break

            i32.const 4
            local.set $nibble_bits

            (loop $nibble_loop (block $nibble_break
                local.get $index
                i32.const 1
                i32.sub
                local.get $index

                local.get $num
                i32.const 1
                i32.and
                if
                    local.get $index
                    i32.const 49
                    i32.store8 offset=512
                else
                    local.get $index
                    i32.const 48
                    i32.store8 offset=512
                end

                local.get $num
                i32.const 1
                i32.shr_u
                local.set $num

                local.get $nibble_bits
                i32.const 1
                i32.sub 1
                local.tee $nibble_bits
                i32.eqz
                br_if $nibble_break

                br $nibble_loop 
            ))

            local.get $index
            i32.const 1
            i32.sub
            local.tee $index
            i32.const 32
            i32.store8 offset=512

            br $bin_loop 
        ))
    )

    (func $set_hex_string (param $num i32) (param $string_len i32)
        (local $index i32)
        (local $digit_char i32)
        (local $digit_val i32)
        (local $x_pos i32)

        global.get $hex_string_len
        local.set $index

        (loop $digit_loop (block $break
            local.get $index
            i32.eqz
            br_if $break

            local.get $num
            i32.const 0xf
            i32.and

            local.set $digit_val
            local.get $num
            i32.eqz
            if
                local.get $x_pos
                i32.eqz
                if
                    local.get $index
                    local.set $x_pos
                else
                    i32.const 32
                    local.set $digit_char 
                end
            else
                (i32.load8_u offset=128 (local.get $digit_val))
                local.set $digit_char
            end

            local.get $index
            i32.const 1
            i32.sub
            local.tee $index
            local.get $digit_char

            i32.store8 offset=384

            local.get $num
            i32.const 4
            i32.shr_u
            local.set $num

            br $digit_loop
        ))

        local.get $x_pos
        i32.const 1
        i32.sub

        i32.const 120
        i32.store8 offset=384

        local.get $x_pos
        i32.const 2
        i32.sub

        i32.const 48
        i32.store8 offset=384
    )

    (func $set_dec_string (param i32) (param $string_len i32)
        (local $index i32)
        (local $digit_char i32)
        (local $digit_val i32)

        local.get $string_len
        local.set $index

        local.get $num
        i32.eqz
        if
            local.get $index
            i32.const 1
            i32.sub
            local.set $index

            (i32.store8 offset=256 (local.get $index) (i32.const 48))
        end

        (loop $digit_loop (block $break
            local.get $index
            i32.eqz
            br_if $break 

            local.get $num
            i32.const 10
            i32.rem_u

            local.set $digit_val
            local.get $num
            i32.eqz
            if
                i32.const 32
                local.set $digit_char
            else
                (i32.load8_u offset=128 (local.get $digit_val))
                local.set $digit_char
            end

            local.get $index
            i32.const 1
            i32.sub
            local.set $index

            (i32.store8 offset=256
                (local.get $index) (local.get $digit_char) 
            )

            local.get $num
            i32.const 10
            i32.div_u
            local.set $num

            br $digit_loop
        ))
    )

    (func $byte_copy
        (param $source i32) (param $dest i32) (param $len i32)
        (local $last_source_byte i32)

        local.get $source
        local.get $len
        i32.add   ;; $source + $len

        local.set $last_source_byte         ;; $last_source_byte = $source + $len

        (loop $copy_loop (block $break
        local.get $dest    ;; push $dest on stack for use in i32.store8 call
        (i32.load8_u (local.get $source)) ;; load a single byte from $source
        i32.store8                        ;; store a single byte in $dest

        local.get $dest
        i32.const 1
        i32.add
        local.set $dest                   ;; $dest = $dest + 1

        local.get $source
        i32.const 1
        i32.add
        local.tee $source                 ;; $source = $source + 1

        local.get $last_source_byte
        i32.eq
        br_if $break
        br $copy_loop
     ))
    )

    (func $byte_copy_i64
        (param $source i32) (param $dest i32) (param $len i32) 
    )

    (func $string_copy
        (param $source i32) (param $dest i32) (param $len i32) 
    )
)