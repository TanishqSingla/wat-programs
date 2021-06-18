(module
    (import "env" "print_string" (func $print_string (param i32 i32)))
    (import "env" "buffer" (memory 1))

    (data (i32.const 128) "0123456789ABCDEF")

    (data (i32.const 256) "               0")
    (global $dec_string_len i32 (i32.const 16))

    (global $hex_string_len i32 (i32.const 16))
    (data (i32.const 384) "             0x0")

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
            i32.shr_u       ;; shifts 1 hexadecimal digit off $num
            local.set $num

            br $digit_loop
        ))

        local.get $x_pos
        i32.const 1
        i32.sub

        i32.const 120       ;; ascii x
        i32.store8 offset=384

        local.get $x_pos
        i32.const 2
        i32.sub

        i32.const 48
        i32.store8 offset=384
    )

    (func $set_dec_string (param $num i32) (param $string_len i32)
        (local $index i32)
        (local $digit_char i32)
        (local $digit_val i32)

        local.get $string_len
        local.set $index

        local.get $num
        i32.eqz             ;; is equal to zero
        if                      ;; if the number is 0 remove the spaces
            local.get $index
            i32.const 1
            i32.sub
            local.set $index

            ;; store ascii '0' to memory location 256 + $index
            (i32.store offset=256 (local.get $index) (i32.const 48))
        end

        (loop $digit_loop (block $break ;; loop converts number to string
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
                (local.set $digit_char)
            end

            local.get $index
            i32.const 1
            i32.sub
            local.set $index

            (i32.store8 offset=256 (local.get $index) (local.get $digit_char))

            local.get $num
            i32.const 10
            i32.div_u
            local.set $num

            br $digit_loop
        ))
    )

    (func (export "to_string") (param $num i32)
        (call $set_dec_string (local.get $num) (global.get $dec_string_len))

        (call $print_string (i32.const 256) (global.get $dec_string_len)) 

        (call $set_hex_string (local.get $num) (global.get $hex_string_len))

        (call $print_string (i32.const 384) (global.get $hex_string_len))
    )
)