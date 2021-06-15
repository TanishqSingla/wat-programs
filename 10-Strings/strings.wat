(module
    (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
    (import "env" "buffer" (memory 1))

    ;; 30 character long string
    (data (i32.const 256) "know the length of this string");

    ;; 35 character long string
    (data (i32.const 384) "Also know the length of this string");

    (func (export "main")
        (call $str_pos_len (i32.const 256) (i32.const 30)) 

        (call $str_pos_len (i32.const 256) (i32.const 35)) 
    )    
)