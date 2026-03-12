(module
  ;; folded and non-folded in one snippet
  (func $mix (param $n i32) (result i32)
    (; nested (; block ;) comment ;)
    local.get $n
    (i32.add (i32.const 1) (local.get $n))
    i32.add)
)
