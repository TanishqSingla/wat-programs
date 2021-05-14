;; This program is written to show the usage of local variables

(module
    (func (export "SumSquared")
        (param i32) (param i32)
        (result i32)

        (local $sum i32)

        (i32.add (local.get 0) (local.get 1))
        local.set $sum

        (i32.mul (local.get $sum) (local.get $sum)) 
    )
)