#lang racket/base

(require racket/file
         racket/list
         racket/match
         racket/path
         racket/runtime-path
         racket/string)

(provide tikz-entry?
         tikz-default-map-entries
         tikz-doc-url-for-token)

(define-runtime-path tikz-map-path "tikz-docs-map.rktd")

;; Compact tuple: (kind token url)
;; kind is one of 'command or 'key

(define (tikz-entry? v)
  (match v
    [(list kind token url)
     (and (memq kind '(command key))
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://tikz\\.dev/" url))]
    [_ #f]))

(define (read-default-entries)
  (define v (call-with-input-file tikz-map-path read))
  (unless (and (list? v) (andmap tikz-entry? v))
    (raise-arguments-error 'read-default-entries
                           "invalid TikZ docs map data"
                           "path" (path->string tikz-map-path)
                           "value" v))
  v)

(define tikz-default-map-entries
  (read-default-entries))

(define tikz-url-cache
  (for/fold ([h (hash)])
            ([e (in-list tikz-default-map-entries)])
    (hash-set h (string-trim (second e)) (third e))))

(define (tikz-doc-url-for-token token)
  (define t (string-trim token))
  (and (not (string=? t ""))
       (hash-ref tikz-url-cache t #f)))

(module+ test
  (require rackunit)

  (check-true (pair? tikz-default-map-entries))
  (check-true (andmap tikz-entry? tikz-default-map-entries))
  (check-not-false (tikz-doc-url-for-token "\\draw"))
  (check-not-false (tikz-doc-url-for-token "/tikz/state"))
  (check-false (tikz-doc-url-for-token "not-a-real-tikz-identifier")))
