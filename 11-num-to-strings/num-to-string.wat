(module
    (import "env" "print_string" (func $print_string (param i32 i32)))
    (import "env" "buffer" (memory 1))

    (data (i32.const 128) "0123456789ABCDEF")

    (data (i32.const 256) "               0")
    (global $dec_string_len i32 (i32.const 16))

    (func $set_dec_string (param $num i32) (param $string_len i32)
        (local $index i32)
        (local $digit_char i32)
        (local $digit_val i32)

        local.get $string_len
        local.set $index 

        local.get $num
        i32.eqz             ;; is equal to zero
        if
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
    )
)