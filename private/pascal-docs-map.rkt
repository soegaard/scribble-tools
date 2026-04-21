#lang racket/base

;; The bundled Pascal docs map was generated from a local mirror of the
;; official Free Pascal HTML docs:
;; https://www.freepascal.org/docs-html/current/

(require racket/list
         racket/match
         racket/runtime-path
         racket/string)

(provide pascal-entry?
         pascal-default-map-entries
         pascal-doc-url-for-token)

(define-runtime-path pascal-map-path "pascal-docs-map.rktd")

;; Compact tuple: (source kind token url)
;; source is 'reference for language-reference entries, otherwise the unit name
;; kind is one of 'keyword 'unit 'const 'type 'class 'routine 'variable

(define allowed-kinds '(keyword unit const type class routine variable))

(define (pascal-entry? v)
  (match v
    [(list source kind token url)
     (and (symbol? source)
          (memq kind allowed-kinds)
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://www\\.freepascal\\.org/docs-html/current/"
                         url))]
    [_ #f]))

(define (read-default-entries)
  (define v (call-with-input-file pascal-map-path read))
  (unless (and (list? v) (andmap pascal-entry? v))
    (raise-arguments-error 'read-default-entries
                           "invalid Pascal docs map data"
                           "path" (path->string pascal-map-path)
                           "value" v))
  v)

(define pascal-default-map-entries
  (read-default-entries))

(define api-kind-priority
  '(type class routine const variable unit))

(define unit-priority
  '(system sysutils classes strutils math types objpas))

(define (symbol-rank table sym)
  (or (for/or ([v (in-list table)]
               [i (in-naturals)])
        (and (eq? v sym) i))
      (+ 1000 (string-length (symbol->string sym)))))

(define (api-entry<? a b)
  (match* (a b)
    [((list source-a kind-a token-a _)
      (list source-b kind-b token-b _))
     (cond
       [(< (symbol-rank unit-priority source-a)
           (symbol-rank unit-priority source-b))
        #t]
       [(> (symbol-rank unit-priority source-a)
           (symbol-rank unit-priority source-b))
        #f]
       [(< (symbol-rank api-kind-priority kind-a)
           (symbol-rank api-kind-priority kind-b))
        #t]
       [(> (symbol-rank api-kind-priority kind-a)
           (symbol-rank api-kind-priority kind-b))
        #f]
       [else
        (string-ci<? token-a token-b)])]))

(define keyword-cache
  (for/fold ([h (hash)])
            ([e (in-list pascal-default-map-entries)]
             #:when (eq? (second e) 'keyword))
    (match-define (list _source _kind token url) e)
    (hash-set h (string-downcase (string-trim token)) url)))

(define api-cache
  (for/fold ([h (hash)])
            ([e (in-list pascal-default-map-entries)]
             #:when (not (eq? (second e) 'keyword)))
    (match-define (list _source _kind token _url) e)
    (hash-update h
                 (string-downcase (string-trim token))
                 (lambda (es) (cons e es))
                 null)))

(define (lookup-api-url token)
  (define t (string-downcase (string-trim token)))
  (define entries
    (sort (hash-ref api-cache t null) api-entry<?))
  (and (pair? entries)
       (fourth (car entries))))

(define (pascal-doc-url-for-token cls token)
  (define t (string-downcase (string-trim token)))
  (cond
    [(string=? t "") #f]
    [(eq? cls 'keyword)
     (or (hash-ref keyword-cache t #f)
         (lookup-api-url t))]
    [else
     (lookup-api-url t)]))

(module+ test
  (require rackunit)

  (check-true (pair? pascal-default-map-entries))
  (check-true (andmap pascal-entry? pascal-default-map-entries))
  (check-not-false (pascal-doc-url-for-token 'keyword "function"))
  (check-not-false (pascal-doc-url-for-token 'keyword "begin"))
  (check-not-false (pascal-doc-url-for-token 'identifier "Integer"))
  (check-not-false (pascal-doc-url-for-token 'identifier "WriteLn"))
  (check-not-false (pascal-doc-url-for-token 'identifier "Format"))
  (check-not-false (pascal-doc-url-for-token 'identifier "SysUtils"))
  (check-false (pascal-doc-url-for-token 'identifier "DefinitelyNotAPascalBuiltin")))
