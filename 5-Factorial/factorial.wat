(module
    (func (export "Fact") (param $n i32) 
        (result i32)

        (local $i i32)
        (local $factorial i32)

        (local.set $i (i32.const 1))
        (local.set $factorial (i32.const 1))

        (loop $continue (block $break

            (local.set $i
               (i32.add (local.get $i) (i32.const 1)) 
            )

            (local.set $factorial
                (i32.mul (local.get $factorial) (local.get $i))
            )

            (br_if $break
                (i32.eq (local.get $i) (local.get $n)) 
            )

            br $continue
        ))

        local.get $factorial 
    )
)