(module
    (import "env" "buffer" (memory 1))

    (global $digit_ptr i32 (i32.const 128))
    (data (i32.const 128) "0123456789ABCDEF")

    (global $dec_string_ptr i32 (i32.const 256))
    (global $dec_string_ptr_len i32 (i32.const 16))
    (data (i32.const 256) "               0")

    (global $hex_string_ptr i32 (i32.const 384))
    (global $hex_string_len i32 (i32.const 16))
    (data (i32.const 384) "               0x0")

    (global $bin_string_ptr i32 (i32.const 512))
    (global $bin_string_len i32 (i32.const 40))
    (data (i32.const 512) "0000 0000 0000 0000 0000 0000 0000 0000")

    (global $h1_open_ptr i32 (i32.const 640))
    (global $h1_open_len i32 (i32.const 4))
    (data (i32.const 640) "<h1>")

    (global $h1_close_ptr i32 (i32.const 656))
    (global $h1_close_len i32 (i32.const 5))
    (data (i32.const 656) "</h1>")

    (global $h4_open_ptr i32 (i32.const 672))
    (global $h4_open_len i32 (i32.const 4))
    (data (i32.const 672) "<h4>")

    (global $h4_close_ptr i32 (i32.const 688))
    (global $h4_close_len i32 (i32.const 5))
    (data (i32.const 688) "</h4>")

    (global $out_str_ptr i32 (i32.const 1024))
    (global $out_str_len (mut i32) (i32.const 0))

    (func $set_bin_string (param $num i32) (param $string_len i32)
        (local $index i32)
        (local $loops_remaining i32)
        (local $nibble_bits i32)

        global.get $bin_string_len
        local.set $index

        i32.const 8  ;; there are 8 nibbles in 32 bits (32/4 = 8)
        local.set $loops_remaining  ;; outer loop separates nibbles

        (loop $bin_loop (block $outer_break  ;; outer loop for spaces
            local.get $index  
            i32.eqz
            br_if $outer_break        ;; stop looping when $index is 0

            i32.const 4
            local.set $nibble_bits    ;; 4 bits in each nibble

            (loop $nibble_loop (block $nibble_break ;; inner loop for digits
                local.get $index  
                i32.const 1
                i32.sub
                local.set $index        ;; decrement $index

                local.get $num
                i32.const 1
                i32.and   ;; i32.and 1 results in 1 if last bit is 1 else 0
                if        ;; if the last bit is a 1
                    local.get $index
                    i32.const 49           ;; ascii '1' is 49
                    i32.store8 offset=512  ;; store '1' at 512 + $index
                else                     ;; else executes if last bit was 0
                    local.get $index
                    i32.const 48           ;; ascii '0' is 48
                    i32.store8 offset=512  ;; store '0' at 512 + $index
                end

                local.get $num
                i32.const 1
                i32.shr_u                ;; $num shifted right 1 bit
                local.set $num           ;; shift off the last bit of $num

                local.get $nibble_bits
                i32.const 1
                i32.sub
                local.tee $nibble_bits   ;; decrement $nibble_bits
                i32.eqz                  ;; $nibble_bits == 0
                br_if $nibble_break      ;; break when $nibble_bits == 0

                br $nibble_loop
            )) ;; end $nibble_loop

        local.get $index  
        i32.const 1
        i32.sub
        local.tee $index           ;; decrement $index
        i32.const 32               ;; ascii space
        i32.store8 offset=512      ;; store ascii space at 512+$index

        br $bin_loop
        )) ;; end $bin_loop
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

    (func $set_dec_string (param $num i32) (param $string_len i32)
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

        (local $last_source_byte i32)

        local.get $source
        local.get $len
        i32.add

        local.set $last_source_byte

        (loop $copy_loop (block $break
        (i64.store (local.get $dest) (i64.load (local.get $source)))

        local.get $dest
        i32.const 8
        i32.add
        local.set $dest             ;; $dest = $dest + 8

        local.get $source
        i32.const 8
        i32.add
        local.tee $source           ;; $source = $source + 8

        local.get $last_source_byte
        i32.ge_u
        br_if $break
        br $copy_loop
        ))
    )

    (func $string_copy
        (param $source i32) (param $dest i32) (param $len i32)
        (local $start_source_byte i32)
        (local $start_dest_byte   i32)
        (local $singles           i32)
        (local $len_less_singles  i32)

        local.get $len
        local.set $len_less_singles  ;; value without singles

        local.get $len
        i32.const 7                
        i32.and
        local.tee $singles          

        if                           
            local.get $len
            local.get $singles
            i32.sub
            local.tee $len_less_singles 

            local.get $source
            i32.add
   
            local.set $start_source_byte

            local.get $len_less_singles
            local.get $dest
            i32.add
            local.set $start_dest_byte  

            (call $byte_copy (local.get $start_source_byte)
            (local.get $start_dest_byte)(local.get $singles))
        end

        local.get $len
        i32.const 0xff_ff_ff_f8 ;; all bits are 1 except the last three which are 0
        i32.and                 ;; set the last three bits of the length to 0
        local.set $len
        (call $byte_copy_i64 (local.get $source) (local.get $dest) (local.get $len))
    )
    
    (func $append_out (param $source i32) (param $len i32)
        (call $string_copy
            (local.get $source)
            (i32.add
                (global.get $out_str_ptr)
                (global.get $out_str_len) 
            )
            (local.get $len)
        )

        global.get $out_str_len
        local.get $len
        i32.add
        global.set $out_str_len
    )

    (func (export "setOutput") (param $num i32) (result i32)
        (call $set_dec_string
            (local.get $num) (global.get $dec_string_len) 
        )

        (call $set_hex_string
            (local.get $num) (global.get $hex_string_len) 
        )

        i32.const 0
        global.set $out_str_len

        (call $append_out
            (global.get $h1_open_ptr) (global.get $h1_open_len)
        )
        (call $append_out
            (global.get $dec_string_ptr) (global.get $dec_string_len)
        )
        (call $append_out
            (global.get $h1_close_ptr) (global.get $h1_close_len) 
        )

        (call $append_out
            (global.get $h4_open_ptr) (global.get $h4_open_len) 
        )
        (call $append_out
            (global.get $hex_string_ptr) (global.get $hex_string_len)
        )
        (call $append_out
            (global.get $h4_close_ptr) (global.get $h4_close_len) 
        )

        global.get $out_str_len
    )
)