;; S expression
(if (local.get $bool_i32)
    (then
        ;; do something if bool_i32 is not 0
        nop ;; nop stands for "no operation" op code
    )
    (else
        nop 
    )
)

;; example 2
(if
    (i32.and
        (i32.gt_s (local.get $x) (local.get $y)) ;; signed greater than 
        (i32.lt_s (local.get $y) (i32.const  $6)) ;; signed less than
    )
    (then
        nop 
    )
)