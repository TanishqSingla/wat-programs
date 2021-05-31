(module
    (import "js" (table $tbl 4 anyfunc))

    (import "js" "increment" (func $increment (result i32)))

    (import "js" "decrement" (func $decrement (result i32)))

    (import "js" "wasm_increment" (func $wasm_increment (result i32)))

    (import "js" "wasm_decrement" (func $wasm_decrement (result i32)))

    (type $returns_i32 (func (result i32)))

    (global $inc_ptr i32 (i32.const 0))
    (global $dec_ptr i32 (i32.const 1))
    
    (global $wasm_inc_ptr i32 (i32.const 2))
    (global $wasm_dec_ptr i32 (i32.const 3))
)