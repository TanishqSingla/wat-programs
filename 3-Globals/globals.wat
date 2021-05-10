;;This program imports 3 numbers from js

(module
    ;; Importing different types of number from `env` object passed from js
    (global $import_integer_32 (import "env" "import_i32") i32)
    (global $import_float_32 (import "env" "import_f32") f32)
    (global $import_float_64 (import "env" "import_f64") f64)

    ;; Importing log functions from js
)