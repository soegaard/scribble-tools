#lang racket/base

;; The local cppreference archive used to generate this map came from:
;; https://github.com/PeterFeicht/cppreference-doc/releases

(require racket/list
         racket/match
         racket/runtime-path
         racket/string)

(provide cppreference-entry?
         cppreference-default-map-entries
         cppreference-doc-url-for-token
         c/cpp-doc-url-for-token)

(define-runtime-path cppreference-map-path "cppreference-docs-map.rktd")

;; Compact tuple: (lang kind token url)
;; lang is one of 'c or 'cpp
;; kind is one of 'function 'typedef 'class 'const 'macro 'enum 'variable 'header

(define (cppreference-entry? v)
  (match v
    [(list lang kind token url)
     (and (memq lang '(c cpp))
          (memq kind '(function typedef class const macro enum variable header))
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://en\\.cppreference\\.com/w/" url))]
    [_ #f]))

(define (read-default-entries)
  (define v (call-with-input-file cppreference-map-path read))
  (unless (and (list? v) (andmap cppreference-entry? v))
    (raise-arguments-error 'read-default-entries
                           "invalid cppreference docs map data"
                           "path" (path->string cppreference-map-path)
                           "value" v))
  v)

(define cppreference-default-map-entries
  (read-default-entries))

(define cppreference-url-cache
  (for/fold ([h (hash)])
            ([e (in-list cppreference-default-map-entries)])
    (match-define (list lang _kind token url) e)
    (hash-set h (list lang (string-trim token)) url)))

(define (cppreference-doc-url-for-token lang token)
  (define t (string-trim token))
  (and (memq lang '(c cpp))
       (not (string=? t ""))
       (hash-ref cppreference-url-cache (list lang t) #f)))

(define (keyword-url lang token)
  (define t (string-trim token))
  (and (memq lang '(c cpp))
       (not (string=? t ""))
       (string-append "https://en.cppreference.com/w/"
                      (case lang
                        [(c) "c/keyword/"]
                        [(cpp) "cpp/keyword/"])
                      t)))

(define (c/cpp-doc-url-for-token lang cls token prev1 prev2)
  (define t (string-trim token))
  (cond
    [(or (not (memq lang '(c cpp)))
         (string=? t "")
         (regexp-match? #px"[[:space:]]" t))
     #f]
    [(eq? cls 'keyword)
     (keyword-url lang t)]
    [(and (eq? lang 'cpp)
          (equal? prev1 "::")
          (equal? prev2 "std"))
     (or (cppreference-doc-url-for-token 'cpp (string-append "std::" t))
         (cppreference-doc-url-for-token 'cpp t))]
    [else
     (cppreference-doc-url-for-token lang t)]))

(module+ test
  (require rackunit)

  (check-true (pair? cppreference-default-map-entries))
  (check-true (andmap cppreference-entry? cppreference-default-map-entries))
  (check-not-false (cppreference-doc-url-for-token 'c "printf"))
  (check-not-false (cppreference-doc-url-for-token 'c "size_t"))
  (check-not-false (cppreference-doc-url-for-token 'cpp "std::vector"))
  (check-not-false (cppreference-doc-url-for-token 'cpp "std::size_t"))
  (check-not-false (cppreference-doc-url-for-token 'cpp "vector"))
  (check-false (cppreference-doc-url-for-token 'c "not-a-real-c-identifier"))
  (check-equal? (c/cpp-doc-url-for-token 'c 'keyword "return" #f #f)
                "https://en.cppreference.com/w/c/keyword/return")
  (check-equal? (c/cpp-doc-url-for-token 'cpp 'keyword "if" #f #f)
                "https://en.cppreference.com/w/cpp/keyword/if")
  (check-equal? (c/cpp-doc-url-for-token 'cpp 'identifier "vector" "::" "std")
                "https://en.cppreference.com/w/cpp/container/vector")
  (check-equal? (c/cpp-doc-url-for-token 'cpp 'identifier "vector" #f #f)
                "https://en.cppreference.com/w/cpp/header/vector"))
