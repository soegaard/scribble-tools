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

;; Compact tuple: (owner kind token url)
;; owner is the documenting class/module symbol, or 'syntax for keywords.
;; kind is one of 'class 'module 'keyword 'instance-method 'class-method.

(define allowed-kinds '(class module keyword instance-method class-method))

(define (ruby-entry? v)
  (match v
    [(list owner kind token url)
     (and (symbol? owner)
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
    [((list owner-a kind-a token-a _)
      (list owner-b kind-b token-b _))
     (cond
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
             #:when (eq? (second e) 'keyword))
    (match-define (list _owner _kind token url) e)
    (hash-set h token url)))

(define constant-cache
  (for/fold ([h (hash)])
            ([e (in-list ruby-default-map-entries)]
             #:when (memq (second e) '(class module)))
    (match-define (list _owner _kind token _url) e)
    (hash-update h token (lambda (es) (cons e es)) null)))

(define method-cache
  (for/fold ([h (hash)])
            ([e (in-list ruby-default-map-entries)]
             #:when (memq (second e) '(class-method instance-method)))
    (match-define (list _owner _kind token _url) e)
    (hash-update h token (lambda (es) (cons e es)) null)))

(define (lookup-api-url cache token)
  (define entries (sort (hash-ref cache (string-trim token) null) api-entry<?))
  (and (pair? entries)
       (fourth (car entries))))

(define (lookup-owner-method-url owner token)
  (define entries
    (filter (lambda (e) (eq? owner (first e)))
            (hash-ref method-cache (string-trim token) null)))
  (and (pair? entries)
       (fourth (car (sort entries api-entry<?)))))

(define (token-text v)
  (cond
    [(pair? v) (cdr v)]
    [(string? v) v]
    [else #f]))

(define (member-access? prev1)
  (define t (token-text prev1))
  (and t (member t '("." "::"))))

(define (ruby-doc-url-for-token cls token prev1 prev2 next1)
  (define t (string-trim token))
  (cond
    [(or (string=? t "") (regexp-match? #px"[[:space:]]" t)) #f]
    [(eq? cls 'keyword)
     (hash-ref keyword-cache t #f)]
    [(eq? cls 'constant-name)
     (lookup-api-url constant-cache t)]
    [(eq? cls 'method-name)
     (lookup-api-url method-cache t)]
    [(eq? cls 'name)
     (or (lookup-api-url constant-cache t)
         (lookup-owner-method-url 'Kernel t)
         (and (member-access? prev1)
              (lookup-api-url method-cache t)))]
    [else #f]))

(module+ test
  (require rackunit)

  (check-true (pair? ruby-default-map-entries))
  (check-true (andmap ruby-entry? ruby-default-map-entries))
  (check-not-false (ruby-doc-url-for-token 'keyword "class" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'constant-name "Array" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'constant-name "String" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'method-name "puts" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'method-name "map" #f #f #f))
  (check-false (ruby-doc-url-for-token 'name "name" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'name "puts" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'name "new" '(punct . ".") #f #f))
  (check-false (ruby-doc-url-for-token 'name "DefinitelyNotARubyBuiltin" #f #f #f)))
