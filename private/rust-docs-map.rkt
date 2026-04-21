#lang racket/base

(require racket/match
         racket/set
         racket/string)

(provide rust-doc-url-for-token)

(define rust-reference-base-url "https://doc.rust-lang.org/reference/")
(define rust-std-base-url "https://doc.rust-lang.org/std/")

(define rust-keywords
  (seteq 'as 'async 'await 'break 'const 'continue 'crate 'dyn 'else 'enum
         'extern 'false 'fn 'for 'if 'impl 'in 'let 'loop 'match 'mod 'move
         'mut 'pub 'ref 'return 'self 'Self 'static 'struct 'super 'trait
         'true 'type 'unsafe 'use 'where 'while))

(define rust-item-url
  (hash
   "Vec"          (string-append rust-std-base-url "vec/struct.Vec.html")
   "String"       (string-append rust-std-base-url "string/struct.String.html")
   "Option"       (string-append rust-std-base-url "option/enum.Option.html")
   "Result"       (string-append rust-std-base-url "result/enum.Result.html")
   "HashMap"      (string-append rust-std-base-url "collections/struct.HashMap.html")
   "HashSet"      (string-append rust-std-base-url "collections/struct.HashSet.html")
   "BTreeMap"     (string-append rust-std-base-url "collections/struct.BTreeMap.html")
   "BTreeSet"     (string-append rust-std-base-url "collections/struct.BTreeSet.html")
   "Box"          (string-append rust-std-base-url "boxed/struct.Box.html")
   "Rc"           (string-append rust-std-base-url "rc/struct.Rc.html")
   "Arc"          (string-append rust-std-base-url "sync/struct.Arc.html")
   "Iterator"     (string-append rust-std-base-url "iter/trait.Iterator.html")
   "IntoIterator" (string-append rust-std-base-url "iter/trait.IntoIterator.html")
   "Clone"        (string-append rust-std-base-url "clone/trait.Clone.html")
   "Copy"         (string-append rust-std-base-url "marker/trait.Copy.html")
   "Debug"        (string-append rust-std-base-url "fmt/trait.Debug.html")
   "Default"      (string-append rust-std-base-url "default/trait.Default.html")
   "Display"      (string-append rust-std-base-url "fmt/trait.Display.html")
   "From"         (string-append rust-std-base-url "convert/trait.From.html")
   "Into"         (string-append rust-std-base-url "convert/trait.Into.html")
   "println"      (string-append rust-std-base-url "macro.println.html")
   "print"        (string-append rust-std-base-url "macro.print.html")
   "eprintln"     (string-append rust-std-base-url "macro.eprintln.html")
   "format"       (string-append rust-std-base-url "macro.format.html")
   "vec"          (string-append rust-std-base-url "macro.vec.html")
   "panic"        (string-append rust-std-base-url "macro.panic.html")
   "dbg"          (string-append rust-std-base-url "macro.dbg.html")))

(define rust-macros
  (list->set (list "println" "print" "eprintln" "format" "vec" "panic" "dbg")))

(define (rust-keyword-url token)
  (and (set-member? rust-keywords (string->symbol token))
       (string-append rust-reference-base-url "keywords.html")))

(define (rust-doc-url-for-token cls token prev1 prev2 next1)
  (define t (string-trim token))
  (cond
    [(or (string=? t "") (regexp-match? #px"[[:space:]]" t)) #f]
    [(eq? cls 'keyword)
     (rust-keyword-url t)]
    [(and (set-member? rust-macros t)
          (equal? next1 "!"))
     (hash-ref rust-item-url t #f)]
    [(and (hash-has-key? rust-item-url t)
          (not (set-member? rust-macros t)))
     (hash-ref rust-item-url t)]
    [(and (equal? prev1 "::") (equal? prev2 "std"))
     (or (hash-ref rust-item-url t #f) #f)]
    [else #f]))

(module+ test
  (require rackunit)

  (check-equal? (rust-doc-url-for-token 'keyword "fn" #f #f #f)
                "https://doc.rust-lang.org/reference/keywords.html")
  (check-equal? (rust-doc-url-for-token 'identifier "Vec" #f #f #f)
                "https://doc.rust-lang.org/std/vec/struct.Vec.html")
  (check-equal? (rust-doc-url-for-token 'identifier "println" #f #f "!")
                "https://doc.rust-lang.org/std/macro.println.html")
  (check-false (rust-doc-url-for-token 'identifier "println" #f #f #f))
  (check-equal? (rust-doc-url-for-token 'identifier "HashMap" "::" "collections" #f)
                "https://doc.rust-lang.org/std/collections/struct.HashMap.html"))
