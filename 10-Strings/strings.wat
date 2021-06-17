(module
    (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
    (import "env" "null_str" (func $null_str (param i32)))
    ;; len prefix
    (import "env" "len_prefix" (func $len_prefix (param i32)))
    (import "env" "buffer" (memory 1))

    (data (i32.const 0) "null-terminating string\00")
    (data (i32.const 128) "another null-terminating string\00")

    ;; len prefix strings
    (data (i32.const 512) "\16length-prefixed string")
    (data (i32.const 640) "\1eanother length-prefixed string") 

    ;; 30 character long string
    (data (i32.const 256) "know the length of this string")

    ;; 35 character long string
    (data (i32.const 384) "Also know the length of this string")

    (func $byte_copy
        (param $source i32) (param $dest i32) (param $len i32)
        (local $last_source_byte i32)

        local.get $source
        local.get $len
        i32.add

        local.set $last_source_byte

        (loop $copy_loop (block $break
            local.get $dest
            (i32.load8_u (local.get $souce))
            i32.store8

            local.get $dest
            i32.const 1
            i32.add
            local.set $source

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
            local.set $dest

            local.get $source
            i32.const 8
            i32.add
            local.tee $source

            local.get $last_source_byte
            i32.ge_u
            br_if $break
            br $copy_loop
        ))
    )

    (func (export "main")
        (call $null_str (i32.const 0))
        (call $null_str (i32.const 128)) 

        (call $len_prefix (i32.const 512))
        (call $len_prefix (i32.const 640))

        (call $str_pos_len (i32.const 256) (i32.const 30)) 

        (call $str_pos_len (i32.const 384) (i32.const 35)) 
    )    
)