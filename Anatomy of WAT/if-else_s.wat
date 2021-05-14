;; S expression
(if (local.get $bool_i32)
    (then
        ;; do something
        nop ;; nop stands for "no operation" op code
    )
    (else
        nop 
    )
)