#lang racket/base

(require racket/cmdline
         racket/file
         racket/list
         racket/pretty
         racket/string
         "private/mdn-map.rkt")

(provide build-map-entries
         write-map!
         merge-maps
         print-stats
         main)

(define (entry-key e)
  (list (first e) (second e) (string-downcase (string-trim (third e)))))

(define (dedupe entries)
  (define h
    (for/fold ([acc (hash)])
              ([e (in-list entries)])
      (if (mdn-entry? e)
          (hash-set acc (entry-key e) e)
          acc)))
  (sort (hash-values h)
        (lambda (a b)
          (cond
            [(symbol<? (first a) (first b)) #t]
            [(eq? (first a) (first b))
             (cond
               [(symbol<? (second a) (second b)) #t]
               [(eq? (second a) (second b))
                (string<? (string-downcase (third a)) (string-downcase (third b)))]
               [else #f])]
            [else #f]))))

(define (build-map-entries)
  (dedupe mdn-default-map-entries))

(define (read-map path)
  (define v (call-with-input-file path read))
  (unless (and (list? v) (andmap mdn-entry? v))
    (raise-argument-error 'read-map "(listof mdn-entry?)" v))
  v)

(define (merge-maps base extra)
  (dedupe (append base extra)))

(define (write-map! out-path entries)
  (call-with-output-file out-path
    (lambda (out)
      ;; Use write for compact rktd representation.
      (write (dedupe entries) out))
    #:exists 'truncate/replace)
  out-path)

(define (print-stats entries)
  (define total (length entries))
  (define by-lang
    (for/fold ([h (hash)])
              ([e (in-list entries)])
      (hash-update h (first e) add1 0)))
  (printf "total: ~a\n" total)
  (for ([k (in-list '(css html js wasm))])
    (printf "  ~a: ~a\n" k (hash-ref by-lang k 0))))

(define (main)
  (define out #f)
  (define merge-file #f)
  (define install? #f)
  (define stats? #f)
  (command-line
   #:program "racket -l scribble-tools/mdn-map-build"
   #:once-each
   ["--out" p "Write generated map to P"
            (set! out p)]
   ["--merge" p "Merge generated map with entries from P (.rktd)"
              (set! merge-file p)]
   ["--install" "Install generated/merged map as user override"
                (set! install? #t)]
   ["--stats" "Print language stats"
              (set! stats? #t)])
  (define base (build-map-entries))
  (define merged
    (if merge-file
        (merge-maps base (read-map merge-file))
        base))
  (when stats? (print-stats merged))
  (when out
    (write-map! out merged)
    (printf "wrote: ~a\n" out))
  (when install?
    (mdn-install-map! merged)
    (printf "installed: ~a\n" (path->string (mdn-map-path))))
  (when (and (not out) (not install?) (not stats?))
    (printf "No action given. Try --stats, --out FILE, --merge FILE, and/or --install\n")))

(module+ main (main))

(module+ test
  (require rackunit)
  (define built (build-map-entries))
  (check-true (pair? built))
  (check-true (andmap mdn-entry? built))
  (check-true (> (length built) 200))
  (check-equal? (length built)
                (length (remove-duplicates (map entry-key built))))
  (define merged
    (merge-maps built
                (list (list 'css 'name "color" "Web/CSS/color")
                      (list 'css 'name "color" "Web/CSS/color"))))
  (check-equal? (length merged) (length built)))
