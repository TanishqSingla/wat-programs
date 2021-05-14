;; Linear expression
local.get $bool_i32

if
    ;; do something if $bool_i32 is not 0
    nop
else
    ;; do soemthing if $bool_i32 is 0
    nop
end

;; example 2
local.get $x
local.get $y
i32.gt_s

local.get $y
i32.const 6
i32.lt_s

i32.and

if
    nop
end