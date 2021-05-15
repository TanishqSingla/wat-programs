;; This command shows br table

(block $block_0
(block $block_1
(block $block_2
(block $block_3
(block $block_4
(block $block_5
(br_table $block_0 $block_1 $block_2 $block_3 $block_4 $block_5
    (local.get $val)
)

) ;; block_5
i32.const 55
return

) ;; block 4
i32.const 44
return

) ;; block 3
i32.const 33
return

) ;; block 2
i32.const 22
return

) ;; block 1
i32.const 11
return

)
i32.const 0
return