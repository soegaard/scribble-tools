#lang racket/base

(require racket/set
         racket/string)

(provide wasm-spec-3.0-url-for-token)

(define wasm-spec-base-url "https://webassembly.github.io/spec/core/")

(define wasm-forms
  (list->set
   '("module" "func" "param" "result"
     "local" "global" "memory" "table" "type"
     "import" "export" "data" "elem" "start"
     "offset" "align" "mut")))

(define wasm-types
  (list->set
   '("i32" "i64" "f32" "f64" "v128" "funcref" "externref")))

(define wasm-instructions
  (list->set
   '("block" "loop" "if" "then" "else" "end"
     "call" "call_indirect" "return" "drop" "select"
     "unreachable" "nop" "br" "br_if" "br_table"
     "local.get" "local.set" "local.tee"
     "global.get" "global.set")))

(define (wasm-numeric-instruction? t)
  (or (regexp-match? #px"^[if][0-9]{2}\\.[a-z][a-z0-9_]*$" t)
      (regexp-match? #px"^v[0-9]+\\.[a-z][a-z0-9_]*$" t)))

(define (numeric-instr-suffix t)
  (define m (regexp-match #px"^[if][0-9]{2}\\.([a-z][a-z0-9_]*)$" t))
  (and m (list-ref m 1)))

(define (numeric-instr-anchor t)
  (define suf (numeric-instr-suffix t))
  (cond
    [(not suf) #f]
    [(string=? suf "const") "syntax/instructions.html#syntax-const"]
    [(member suf '("eqz")) "syntax/instructions.html#syntax-testop"]
    [(member suf '("eq" "ne" "lt_s" "lt_u" "lt"
                   "gt_s" "gt_u" "gt" "le_s" "le_u" "le"
                   "ge_s" "ge_u" "ge"))
     "syntax/instructions.html#syntax-relop"]
    [(member suf '("clz" "ctz" "popcnt" "abs" "neg" "sqrt"
                   "ceil" "floor" "trunc" "nearest"))
     "syntax/instructions.html#syntax-unop"]
    [(member suf '("add" "sub" "mul" "div_s" "div_u" "div"
                   "rem_s" "rem_u" "and" "or" "xor" "shl"
                   "shr_s" "shr_u" "rotl" "rotr" "min" "max" "copysign"))
     "syntax/instructions.html#syntax-binop"]
    [(regexp-match? #px"(extend|trunc|convert|demote|promote|reinterpret|wrap)" suf)
     "syntax/instructions.html#syntax-cvtop"]
    [else "syntax/instructions.html#syntax-instr-numeric"]))

(define wasm-form-anchor-map
  (hash "module" "syntax/modules.html#syntax-module"
        "func" "syntax/modules.html#syntax-func"
        "param" "text/types.html#text-param"
        "result" "text/types.html#text-result"
        "local" "syntax/modules.html#syntax-local"
        "global" "syntax/modules.html#syntax-global"
        "memory" "syntax/modules.html#syntax-mem"
        "table" "syntax/modules.html#syntax-table"
        "type" "syntax/modules.html#syntax-type"
        "import" "syntax/modules.html#syntax-import"
        "export" "syntax/modules.html#syntax-export"
        "data" "syntax/modules.html#syntax-data"
        "elem" "syntax/modules.html#syntax-elem"
        "start" "syntax/modules.html#syntax-start"
        "offset" "syntax/modules.html#syntax-data"
        "align" "syntax/instructions.html#syntax-memarg"
        "mut" "text/types.html#text-globaltype"))

(define wasm-instruction-anchor-map
  (hash "block" "syntax/instructions.html#syntax-block"
        "loop" "syntax/instructions.html#syntax-loop"
        "if" "syntax/instructions.html#syntax-if"
        "then" "syntax/instructions.html#syntax-instr-control"
        "else" "syntax/instructions.html#syntax-instr-control"
        "end" "syntax/instructions.html#syntax-instr-control"
        "call" "syntax/instructions.html#syntax-call"
        "call_indirect" "syntax/instructions.html#syntax-call_indirect"
        "return" "syntax/instructions.html#syntax-return"
        "drop" "syntax/instructions.html#syntax-instr-parametric"
        "select" "syntax/instructions.html#syntax-instr-parametric"
        "unreachable" "syntax/instructions.html#syntax-unreachable"
        "nop" "syntax/instructions.html#syntax-nop"
        "br" "syntax/instructions.html#syntax-br"
        "br_if" "syntax/instructions.html#syntax-br_if"
        "br_table" "syntax/instructions.html#syntax-br_table"
        "local.get" "syntax/instructions.html#syntax-instr-variable"
        "local.set" "syntax/instructions.html#syntax-instr-variable"
        "local.tee" "syntax/instructions.html#syntax-instr-variable"
        "global.get" "syntax/instructions.html#syntax-instr-variable"
        "global.set" "syntax/instructions.html#syntax-instr-variable"))

(define (vector-instr-suffix t)
  (define m (regexp-match #px"^v128\\.([a-z][a-z0-9_]*)$" t))
  (and m (list-ref m 1)))

(define (vector-instr-anchor t)
  (define suf (vector-instr-suffix t))
  (cond
    [(not suf) #f]
    [(member suf '("not" "abs" "neg" "sqrt" "ceil" "floor" "trunc" "nearest"))
     "syntax/instructions.html#syntax-vunop"]
    [(member suf '("add" "sub" "mul" "div" "min" "max" "and" "or" "xor"
                   "andnot" "shl" "shr"))
     "syntax/instructions.html#syntax-vbinop"]
    [(regexp-match? #px"(convert|demote|promote|reinterpret|trunc|extend)" suf)
     "syntax/instructions.html#syntax-vcvtop"]
    [else "syntax/instructions.html#syntax-instr-vec"]))

(define wasm-type-anchor-map
  (hash "i32" "syntax/types.html#syntax-numtype"
        "i64" "syntax/types.html#syntax-numtype"
        "f32" "syntax/types.html#syntax-numtype"
        "f64" "syntax/types.html#syntax-numtype"
        "v128" "syntax/types.html#syntax-vectype"
        "funcref" "syntax/types.html#syntax-reftype"
        "externref" "syntax/types.html#syntax-reftype"))

(define (wasm-spec-3.0-url-for-token cls token)
  (define t (string-downcase (string-trim token)))
  (cond
    [(string=? t "") #f]
    [(string-prefix? t "$") #f]
    [(or (eq? cls 'wasm-form)
         (set-member? wasm-forms t))
     (string-append wasm-spec-base-url
                    (hash-ref wasm-form-anchor-map t "syntax/modules.html"))]
    [(or (eq? cls 'wasm-type)
         (set-member? wasm-types t))
     (string-append wasm-spec-base-url
                    (hash-ref wasm-type-anchor-map t "syntax/types.html"))]
    [(or (eq? cls 'wasm-instr)
         (set-member? wasm-instructions t)
         (wasm-numeric-instruction? t))
     (string-append wasm-spec-base-url
                    (or (hash-ref wasm-instruction-anchor-map t #f)
                        (numeric-instr-anchor t)
                        (vector-instr-anchor t)
                        "syntax/instructions.html"))]
    [else #f]))
