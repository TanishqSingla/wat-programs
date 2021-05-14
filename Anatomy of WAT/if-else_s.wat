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