#lang racket/base

;; The bundled Ruby docs map was generated in 2026 from a local mirror of:
;; https://docs.ruby-lang.org/en/master/

(require racket/list
         racket/match
         racket/runtime-path
         racket/string)

(provide ruby-entry?
         ruby-default-map-entries
         ruby-doc-url-for-token)

(define-runtime-path ruby-map-path "ruby-docs-map.rktd")

;; Compact tuple: (source owner kind token url)
;; source is one of 'syntax 'core 'stdlib.
;; owner is the documenting class/module symbol, or 'syntax for keywords.
;; kind is one of 'class 'module 'keyword 'instance-method 'class-method.

(define allowed-sources '(syntax core stdlib))
(define allowed-kinds '(class module keyword instance-method class-method))

(define (ruby-entry? v)
  (match v
    [(list source owner kind token url)
     (and (memq source allowed-sources)
          (symbol? owner)
          (memq kind allowed-kinds)
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://docs\\.ruby-lang\\.org/en/master/" url))]
    [_ #f]))

(define (read-default-entries)
  (define v (call-with-input-file ruby-map-path read))
  (unless (and (list? v) (andmap ruby-entry? v))
    (raise-arguments-error 'read-default-entries
                           "invalid Ruby docs map data"
                           "path" (path->string ruby-map-path)
                           "value" v))
  v)

(define ruby-default-map-entries
  (read-default-entries))

(define owner-priority
  '(Kernel Object BasicObject Module Class Array Hash String Enumerable Enumerator
           Integer Float Numeric Symbol Regexp Range Time File Dir IO Exception
           StandardError Math Process Thread Fiber Struct Proc Method))

(define source-priority '(syntax core stdlib))
(define kind-priority '(keyword class module class-method instance-method))

(define (symbol-rank table sym)
  (or (for/or ([v (in-list table)]
               [i (in-naturals)])
        (and (eq? v sym) i))
      (+ 1000 (string-length (symbol->string sym)))))

(define (kind-rank kind)
  (or (for/or ([v (in-list kind-priority)]
               [i (in-naturals)])
        (and (eq? v kind) i))
      1000))

(define (api-entry<? a b)
  (match* (a b)
    [((list source-a owner-a kind-a token-a _)
      (list source-b owner-b kind-b token-b _))
     (cond
       [(< (symbol-rank source-priority source-a)
           (symbol-rank source-priority source-b))
        #t]
       [(> (symbol-rank source-priority source-a)
           (symbol-rank source-priority source-b))
        #f]
       [(< (symbol-rank owner-priority owner-a)
           (symbol-rank owner-priority owner-b))
        #t]
       [(> (symbol-rank owner-priority owner-a)
           (symbol-rank owner-priority owner-b))
        #f]
       [(< (kind-rank kind-a) (kind-rank kind-b)) #t]
       [(> (kind-rank kind-a) (kind-rank kind-b)) #f]
       [else (string<? token-a token-b)])]))

(define keyword-cache
  (for/fold ([h (hash)])
            ([e (in-list ruby-default-map-entries)]
             #:when (eq? (third e) 'keyword))
    (match-define (list _source _owner _kind token url) e)
    (hash-set h token url)))

(define constant-cache
  (for/fold ([h (hash)])
            ([e (in-list ruby-default-map-entries)]
             #:when (memq (third e) '(class module)))
    (match-define (list _source _owner _kind token _url) e)
    (hash-update h token (lambda (es) (cons e es)) null)))

(define method-cache
  (for/fold ([h (hash)])
            ([e (in-list ruby-default-map-entries)]
             #:when (memq (third e) '(class-method instance-method)))
    (match-define (list _source _owner _kind token _url) e)
    (hash-update h token (lambda (es) (cons e es)) null)))

(define method-owner-cache
  (for/fold ([h (hash)])
            ([e (in-list ruby-default-map-entries)]
             #:when (memq (third e) '(class-method instance-method)))
    (match-define (list _source owner _kind token _url) e)
    (hash-update h (list owner token) (lambda (es) (cons e es)) null)))

(define (lookup-api-url cache token)
  (define entries (sort (hash-ref cache (string-trim token) null) api-entry<?))
  (and (pair? entries)
       (fifth (car entries))))

(define (lookup-owner-url owner token)
  (define entries
    (sort (hash-ref method-owner-cache (list owner (string-trim token)) null)
          api-entry<?))
  (and (pair? entries)
       (fifth (car entries))))

(define (lookup-owner-method-url owner token)
  (define entries
    (filter (lambda (e) (eq? owner (second e)))
            (hash-ref method-cache (string-trim token) null)))
  (and (pair? entries)
       (fifth (car (sort entries api-entry<?)))))

(define (token-text v)
  (cond
    [(pair? v) (cdr v)]
    [(string? v) v]
    [else #f]))

(define (token-is? v cls txt)
  (and (pair? v)
       (eq? (car v) cls)
       (string=? (cdr v) txt)))

(define (member-access? prev1)
  (define t (token-text prev1))
  (and t (member t '("." "::" "&."))))

(define (range-dot? token prev1 next1)
  (and (string=? token ".")
       (pair? prev1)
       (eq? (car prev1) 'value)
       (regexp-match? #px"[0-9]\\.$" (cdr prev1))
       (pair? next1)
       (eq? (car next1) 'value)
       (regexp-match? #px"^[0-9]" (cdr next1))))

(define syntax-url
  (hash
   "::" "https://docs.ruby-lang.org/en/master/syntax/modules_and_classes_rdoc.html#nesting"
   "&." "https://docs.ruby-lang.org/en/master/syntax/calling_methods_rdoc.html#safe-navigation-operator"
   ".." "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals"
   "..." "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals"
   "=>" "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#hash-literals"
   "&&" "https://docs.ruby-lang.org/en/master/syntax/operators_rdoc.html#-and"
   "||" "https://docs.ruby-lang.org/en/master/syntax/operators_rdoc.html#-or"
   "?" "https://docs.ruby-lang.org/en/master/syntax/control_expressions_rdoc.html#ternary-if"))

(define kernel-methods
  '("abort" "at_exit" "autoload" "autoload?" "binding" "block_given?"
    "caller" "catch" "eval" "exec" "exit" "exit!" "fail" "fork" "format"
    "gets" "global_variables" "lambda" "load" "loop" "p" "print" "printf"
    "proc" "putc" "puts" "raise" "rand" "readline" "readlines" "require"
    "require_relative" "select" "sleep" "spawn" "sprintf" "system" "throw"
    "trace_var" "trap" "untrace_var" "warn"))

(define generic-unqualified-methods
  '("call" "initialize" "name" "object_id" "class" "new" "to_s" "to_a"
    "to_h" "to_i" "to_f" "hash" "inspect" "send" "public_send"))

(define method-aliases
  (hash "collect" "map"
        "length" "size"
        "detect" "find"
        "inject" "reduce"))

(define (definition-method-name? prev1)
  (and prev1
       (eq? (car prev1) 'keyword)
       (string=? (cdr prev1) "def")))

(define (infer-receiver-owner prev2)
  (define cls (and (pair? prev2) (car prev2)))
  (define txt (token-text prev2))
  (cond
    [(not txt) #f]
    [(eq? cls 'constant-name) (string->symbol txt)]
    [(and (eq? cls 'value) (regexp-match? #px"^['\"]" txt)) 'String]
    [(and (eq? cls 'value) (regexp-match? #px"^:" txt)) 'Symbol]
    [(and (eq? cls 'value) (regexp-match? #px"^/" txt)) 'Regexp]
    [(and (eq? cls 'value) (regexp-match? #px"^[+-]?[0-9]+$" txt)) 'Integer]
    [(and (eq? cls 'value) (regexp-match? #px"^[+-]?(?:[0-9]*\\.[0-9]+|[0-9]+\\.[0-9]*)" txt)) 'Float]
    [(and (eq? cls 'punct) (string=? txt "]")) 'Array]
    [(and (eq? cls 'punct) (string=? txt "}")) 'Hash]
    [else #f]))

(define (lookup-method-with-alias owner token)
  (or (lookup-owner-url owner token)
      (let ([canonical (hash-ref method-aliases token #f)])
        (and canonical (lookup-owner-url owner canonical)))))

(define (lookup-any-method-with-alias token)
  (or (lookup-api-url method-cache token)
      (let ([canonical (hash-ref method-aliases token #f)])
        (and canonical (lookup-api-url method-cache canonical)))))

(define (ruby-keyword-url token prev1 prev2 next1)
  (case (string->symbol token)
    [(in)
     (if (token-is? prev2 'keyword "for")
         "https://docs.ruby-lang.org/en/master/syntax/control_expressions_rdoc.html#for-loop"
         (hash-ref keyword-cache token #f))]
    [else (hash-ref keyword-cache token #f)]))

(define (ruby-doc-url-for-token cls token prev1 prev2 next1)
  (define t (string-trim token))
  (cond
    [(or (string=? t "") (regexp-match? #px"[[:space:]]" t)) #f]
    [(and (eq? cls 'punct) (range-dot? t prev1 next1))
     "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals"]
    [(or (eq? cls 'operator) (eq? cls 'punct))
     (hash-ref syntax-url t #f)]
    [(and (eq? cls 'value) (regexp-match? #px"\\.\\.\\.?" t))
     "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals"]
    [(eq? cls 'keyword)
     (ruby-keyword-url t prev1 prev2 next1)]
    [(eq? cls 'constant-name)
     (lookup-api-url constant-cache t)]
    [(eq? cls 'method-name)
     (cond
       [(definition-method-name? prev1) #f]
       [(member-access? prev1)
        (define owner (infer-receiver-owner prev2))
        (or (and owner (lookup-method-with-alias owner t))
            (lookup-any-method-with-alias t))]
       [(member t generic-unqualified-methods string=?) #f]
       [else (lookup-any-method-with-alias t)])]
    [(eq? cls 'name)
     (or (lookup-api-url constant-cache t)
         (and (member t kernel-methods string=?)
              (lookup-owner-method-url 'Kernel t))
         (and (member-access? prev1)
              (let ([owner (infer-receiver-owner prev2)])
                (or (and owner (lookup-method-with-alias owner t))
                    (lookup-any-method-with-alias t)))))]
    [else #f]))

(module+ test
  (require rackunit)

  (check-true (pair? ruby-default-map-entries))
  (check-true (andmap ruby-entry? ruby-default-map-entries))
  (check-equal? (ruby-doc-url-for-token 'keyword "class" #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/modules_and_classes_rdoc.html#classes")
  (check-equal? (ruby-doc-url-for-token 'keyword "def" #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/methods_rdoc.html#methods")
  (check-equal? (ruby-doc-url-for-token 'keyword "if" #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/control_expressions_rdoc.html#if-expression")
  (check-equal? (ruby-doc-url-for-token 'keyword "rescue" #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/exceptions_rdoc.html#exception-handling")
  (check-equal? (ruby-doc-url-for-token 'keyword "in" '(name . "x") '(keyword . "for") #f)
                "https://docs.ruby-lang.org/en/master/syntax/control_expressions_rdoc.html#for-loop")
  (check-equal? (ruby-doc-url-for-token 'keyword "in" '(keyword . "case") #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html#patterns")
  (check-not-false (ruby-doc-url-for-token 'constant-name "Array" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'constant-name "String" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'method-name "puts" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'method-name "map" #f #f #f))
  (check-false (ruby-doc-url-for-token 'method-name "call" '(keyword . "def") #f #f))
  (check-false (ruby-doc-url-for-token 'method-name "initialize" '(keyword . "def") #f #f))
  (check-false (ruby-doc-url-for-token 'name "name" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'name "puts" #f #f #f))
  (check-false (ruby-doc-url-for-token 'name "object_id" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'name "new" '(punct . ".") '(constant-name . "Object") #f))
  (check-equal? (ruby-doc-url-for-token 'name "split" '(punct . ".") '(value . "\"x\"") #f)
                "https://docs.ruby-lang.org/en/master/String.html#method-i-split")
  (check-equal? (ruby-doc-url-for-token 'name "map" '(punct . ".") '(punct . "]") #f)
                "https://docs.ruby-lang.org/en/master/Array.html#method-i-map")
  (check-equal? (ruby-doc-url-for-token 'name "fetch" '(punct . ".") '(punct . "}") #f)
                "https://docs.ruby-lang.org/en/master/Hash.html#method-i-fetch")
  (check-equal? (ruby-doc-url-for-token 'name "collect" '(punct . ".") '(punct . "]") #f)
                "https://docs.ruby-lang.org/en/master/Array.html#method-i-collect")
  (check-equal? (ruby-doc-url-for-token 'operator "::" #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/modules_and_classes_rdoc.html#nesting")
  (check-equal? (ruby-doc-url-for-token 'operator "&." #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/calling_methods_rdoc.html#safe-navigation-operator")
  (check-equal? (ruby-doc-url-for-token 'operator ".." #f #f #f)
                "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals")
  (check-equal? (ruby-doc-url-for-token 'punct "." '(value . "1.") #f '(value . "3"))
                "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals")
  (check-false (ruby-doc-url-for-token 'name "DefinitelyNotARubyBuiltin" #f #f #f)))
