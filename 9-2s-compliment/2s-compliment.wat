(module
    (func $twos_compliment (export "twos_compliment")
        (param $number i32)
        (result i32)

        local.get $number

        i32.const 0xffffffff
        i32.xor
        i32.const 1
        i32.add 
    )
)