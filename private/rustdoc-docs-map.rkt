#lang racket/base

;; The local Rust documentation mirror used to generate this map came from:
;; https://doc.rust-lang.org/

(require racket/list
         racket/match
         racket/runtime-path
         racket/string)

(provide rustdoc-entry?
         rustdoc-default-map-entries
         rustdoc-doc-url-for-token
         generated-rust-doc-url-for-token)

(define-runtime-path rustdoc-map-path "rustdoc-docs-map.rktd")

;; Compact tuple: (source kind token url)
;; source is one of 'std 'core 'alloc 'reference
;; kind is one of 'struct 'enum 'trait 'macro 'function 'type 'constant
;; 'primitive or 'keyword

(define (rustdoc-entry? v)
  (match v
    [(list source kind token url)
     (and (memq source '(std core alloc reference))
          (memq kind '(struct enum trait macro function type constant primitive keyword))
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://doc\\.rust-lang\\.org/" url))]
    [_ #f]))

(define (read-default-entries)
  (define v (call-with-input-file rustdoc-map-path read))
  (unless (and (list? v) (andmap rustdoc-entry? v))
    (raise-arguments-error 'read-default-entries
                           "invalid rustdoc docs map data"
                           "path" (path->string rustdoc-map-path)
                           "value" v))
  v)

(define rustdoc-default-map-entries
  (read-default-entries))

(define rustdoc-url-cache
  (for/fold ([h (hash)])
            ([e (in-list rustdoc-default-map-entries)])
    (match-define (list source kind token url) e)
    (hash-set h (list source kind (string-trim token)) url)))

(define (rustdoc-doc-url-for-token source kind token)
  (define t (string-trim token))
  (define normalized-token
    (if (and (eq? kind 'macro)
             (string-suffix? t "!"))
        (substring t 0 (sub1 (string-length t)))
        t))
  (and (memq source '(std core alloc reference))
       (memq kind '(struct enum trait macro function type constant primitive keyword))
       (not (string=? normalized-token ""))
       (or (hash-ref rustdoc-url-cache (list source kind t) #f)
           (hash-ref rustdoc-url-cache (list source kind normalized-token) #f))))

(define rust-macro-bases
  (hash "println" 'std
        "print" 'std
        "eprintln" 'std
        "format" 'std
        "panic" 'std
        "dbg" 'std
        "vec" 'alloc))

(define (generated-rust-doc-url-for-token cls token prev1 prev2 next1)
  (define t (string-trim token))
  (cond
    [(or (string=? t "") (regexp-match? #px"[[:space:]]" t)) #f]
    [(eq? cls 'keyword)
     (rustdoc-doc-url-for-token 'reference 'keyword t)]
    [(and (hash-has-key? rust-macro-bases t)
          (equal? next1 "!"))
     (rustdoc-doc-url-for-token (hash-ref rust-macro-bases t) 'macro t)]
    [else
     (or (rustdoc-doc-url-for-token 'std 'struct t)
         (rustdoc-doc-url-for-token 'std 'enum t)
         (rustdoc-doc-url-for-token 'std 'trait t)
         (rustdoc-doc-url-for-token 'std 'function t)
         (rustdoc-doc-url-for-token 'std 'type t)
         (rustdoc-doc-url-for-token 'std 'constant t)
         (rustdoc-doc-url-for-token 'std 'primitive t)
         (rustdoc-doc-url-for-token 'core 'struct t)
         (rustdoc-doc-url-for-token 'core 'enum t)
         (rustdoc-doc-url-for-token 'core 'trait t)
         (rustdoc-doc-url-for-token 'core 'function t)
         (rustdoc-doc-url-for-token 'core 'type t)
         (rustdoc-doc-url-for-token 'core 'constant t)
         (rustdoc-doc-url-for-token 'core 'primitive t)
         (rustdoc-doc-url-for-token 'alloc 'struct t)
         (rustdoc-doc-url-for-token 'alloc 'enum t)
         (rustdoc-doc-url-for-token 'alloc 'trait t)
         (rustdoc-doc-url-for-token 'alloc 'function t)
         (rustdoc-doc-url-for-token 'alloc 'type t)
         (rustdoc-doc-url-for-token 'alloc 'constant t)
         (rustdoc-doc-url-for-token 'alloc 'primitive t))]))

(module+ test
  (require rackunit)

  (check-true (pair? rustdoc-default-map-entries))
  (check-true (andmap rustdoc-entry? rustdoc-default-map-entries))
  (check-not-false (rustdoc-doc-url-for-token 'reference 'keyword "fn"))
  (check-not-false (rustdoc-doc-url-for-token 'std 'struct "Vec"))
  (check-not-false (rustdoc-doc-url-for-token 'std 'trait "Iterator"))
  (check-not-false (rustdoc-doc-url-for-token 'alloc 'macro "vec!"))
  (check-equal? (generated-rust-doc-url-for-token 'keyword "fn" #f #f #f)
                (rustdoc-doc-url-for-token 'reference 'keyword "fn"))
  (check-equal? (generated-rust-doc-url-for-token 'identifier "Vec" #f #f #f)
                (rustdoc-doc-url-for-token 'std 'struct "Vec"))
  (check-equal? (generated-rust-doc-url-for-token 'identifier "println" #f #f "!")
                (rustdoc-doc-url-for-token 'std 'macro "println!"))
  (check-false (generated-rust-doc-url-for-token 'identifier "println" #f #f #f)))
