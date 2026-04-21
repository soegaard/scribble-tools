#lang racket/base

;; The local Rust documentation mirror used by this tool comes from:
;; https://doc.rust-lang.org/

(require racket/cmdline
         racket/file
         racket/list
         racket/match
         racket/path
         racket/string)

(provide rustdoc-entry?
         extract-rustdoc-item-entries
         extract-reference-keyword-entries
         extract-rustdoc-entries
         write-map!
         print-stats
         main)

;; Compact tuple: (source kind token url)
;; source is one of 'std 'core 'alloc 'reference
;; kind is one of 'struct 'enum 'trait 'macro 'function 'type 'constant 'primitive
;; or 'keyword.

(define rustdoc-base-url "https://doc.rust-lang.org/")
(define allowed-sources '(std core alloc reference))
(define allowed-kinds
  '(struct enum trait macro function type constant primitive keyword))

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b)))

(define (rustdoc-entry? v)
  (match v
    [(list source kind token url)
     (and (memq source allowed-sources)
          (memq kind allowed-kinds)
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://doc\\.rust-lang\\.org/" url))]
    [_ #f]))

(define (entry-key e)
  (match e
    [(list source kind token _url)
     (list source kind (string-downcase (string-trim token)))]))

(define (dedupe entries)
  (define h
    (for/fold ([acc (hash)])
              ([e (in-list entries)]
               #:when (rustdoc-entry? e))
      (hash-set acc (entry-key e) e)))
  (sort (hash-values h)
        (lambda (a b)
          (match* (a b)
            [((list source-a kind-a token-a _)
              (list source-b kind-b token-b _))
             (cond
               [(symbol<? source-a source-b) #t]
               [(eq? source-a source-b)
                (cond
                  [(symbol<? kind-a kind-b) #t]
                  [(eq? kind-a kind-b)
                   (string<? (string-downcase token-a)
                             (string-downcase token-b))]
                  [else #f])]
               [else #f])]))))

(define (canonical-relpath rel)
  (define s (path->string rel))
  (cond
    [(regexp-match #px"^(?:stable|beta|nightly)/(.*)$" s)
     => cadr]
    [else s]))

(define (url-for-relpath rel)
  (string-append rustdoc-base-url
                 (regexp-replace* #px"\\\\" (canonical-relpath rel) "/")))

(define item-path-rx
  #px"^(std|core|alloc)/(?:([^/].*)/)?(struct|enum|trait|macro|fn|type|constant|primitive)\\.([^/]+)\\.html$")

(define (kind-name->symbol s)
  (case (string->symbol s)
    [(fn) 'function]
    [else (string->symbol s)]))

(define (available-rustdoc-roots root source-name)
  (define direct (build-path root source-name))
  (define stable (build-path root "stable" source-name))
  (filter values
          (list (and (directory-exists? direct) direct)
                (and (directory-exists? stable) stable))))

(define (extract-rustdoc-item-entries root)
  (define root-path (simplify-path root #t))
  (define entries null)
  (for ([source-name (in-list '("std" "core" "alloc"))])
    (for ([source-root (in-list (available-rustdoc-roots root-path source-name))])
      (for ([p (in-list (find-files
                         (lambda (p)
                           (regexp-match? #px"\\.(?:html)$" (path->string p)))
                         source-root))])
        (define rel (find-relative-path root-path p))
        (define rel-s (regexp-replace* #px"\\\\" (canonical-relpath rel) "/"))
        (define m (regexp-match item-path-rx rel-s))
        (when m
          (define source (string->symbol (list-ref m 1)))
          (define kind (kind-name->symbol (list-ref m 3)))
          (define token (list-ref m 4))
          (set! entries (cons (list source kind token (url-for-relpath rel)) entries))
          (when (eq? kind 'macro)
            (set! entries (cons (list source kind (string-append token "!") (url-for-relpath rel))
                                entries)))))))
  (dedupe entries))

(define strict-anchor "#strict-keywords")
(define reserved-anchor "#reserved-keywords")
(define weak-anchor "#weak-keywords")

(define (extract-code-items html start-pat end-pat)
  (define start (regexp-match-positions start-pat html))
  (define end (regexp-match-positions end-pat html))
  (if (and start end)
      (for/list ([m (in-list (regexp-match* #px"<li><code>([^<]+)</code></li>"
                                            (substring html (cdar start) (caar end))
                                            #:match-select cadr))])
        m)
      null))

(define (extract-reference-keyword-entries root)
  (define root-path (simplify-path root #t))
  (define ref-root
    (or (let ([p (build-path root-path "reference")]) (and (directory-exists? p) p))
        (let ([p (build-path root-path "stable" "reference")]) (and (directory-exists? p) p))
        #f))
  (if (not ref-root)
      null
      (let* ([keywords-path (build-path ref-root "keywords.html")]
             [html (file->string keywords-path)]
             [strict (extract-code-items html #px"id=\"strict-keywords\"" #px"id=\"reserved-keywords\"")]
             [reserved (extract-code-items html #px"id=\"reserved-keywords\"" #px"id=\"weak-keywords\"")]
             [weak (extract-code-items html #px"id=\"weak-keywords\"" #px"</main>")]
             [base-url (url-for-relpath (find-relative-path root-path keywords-path))])
        (dedupe
         (append
          (for/list ([kw (in-list strict)]) (list 'reference 'keyword kw (string-append base-url strict-anchor)))
          (for/list ([kw (in-list reserved)]) (list 'reference 'keyword kw (string-append base-url reserved-anchor)))
          (for/list ([kw (in-list weak)]) (list 'reference 'keyword kw (string-append base-url weak-anchor))))))))

(define (extract-rustdoc-entries root)
  (dedupe
   (append (extract-rustdoc-item-entries root)
           (extract-reference-keyword-entries root))))

(define (write-map! out-path entries)
  (call-with-output-file out-path
    (lambda (out) (write (dedupe entries) out))
    #:exists 'truncate/replace)
  out-path)

(define (print-stats entries)
  (define total (length entries))
  (define by-source
    (for/fold ([h (hash)])
              ([e (in-list entries)])
      (hash-update h (first e) add1 0)))
  (define by-kind
    (for/fold ([h (hash)])
              ([e (in-list entries)])
      (hash-update h (second e) add1 0)))
  (printf "total: ~a\n" total)
  (for ([source (in-list allowed-sources)])
    (define n (hash-ref by-source source 0))
    (when (positive? n)
      (printf "  ~a: ~a\n" source n)))
  (for ([kind (in-list allowed-kinds)])
    (define n (hash-ref by-kind kind 0))
    (when (positive? n)
      (printf "  ~a: ~a\n" kind n))))

(define (main)
  (define root #f)
  (define out #f)
  (define stats? #f)
  (define sample-count 0)
  (command-line
   #:program "racket rustdoc-map-build.rkt"
   #:once-each
   ["--root" p "Path to local doc.rust-lang.org mirror"
             (set! root p)]
   ["--out" p "Write generated map to P (.rktd)"
            (set! out p)]
   ["--stats" "Print summary stats"
              (set! stats? #t)]
   ["--sample" n "Print the first N extracted entries"
               (set! sample-count (string->number n))])
  (unless root
    (error 'rustdoc-map-build "missing required --root PATH"))
  (define entries (extract-rustdoc-entries root))
  (when stats? (print-stats entries))
  (when (and sample-count (positive? sample-count))
    (for ([e (in-list (take entries (min sample-count (length entries))))])
      (write e)
      (newline)))
  (when out
    (write-map! out entries)
    (printf "wrote: ~a\n" out))
  (when (and (not out) (not stats?) (zero? sample-count))
    (printf "No action given. Try --stats, --sample N, and/or --out FILE\n")))

(module+ main
  (main))

(module+ test
  (require rackunit)

  (define keywords-html
    "<h2 id=\"strict-keywords\">Strict keywords</h2>
     <ul><li><code>fn</code></li><li><code>let</code></li></ul>
     <h2 id=\"reserved-keywords\">Reserved keywords</h2>
     <ul><li><code>yield</code></li></ul>
     <h2 id=\"weak-keywords\">Weak keywords</h2>
     <ul><li><code>union</code></li></ul></main>")

  (check-true
   (rustdoc-entry? (list 'std 'struct "Vec" "https://doc.rust-lang.org/std/vec/struct.Vec.html")))
  (check-false
   (rustdoc-entry? (list 'std 'module "vec" "https://doc.rust-lang.org/std/vec/index.html")))

  (check-equal?
   (extract-code-items keywords-html #px"id=\"strict-keywords\"" #px"id=\"reserved-keywords\"")
   '("fn" "let"))

  (check-equal?
   (extract-code-items keywords-html #px"id=\"reserved-keywords\"" #px"id=\"weak-keywords\"")
   '("yield"))

  (check-equal?
   (extract-code-items keywords-html #px"id=\"weak-keywords\"" #px"</main>")
   '("union"))

  (check-equal?
   (kind-name->symbol "fn")
   'function)

  (check-equal?
   (kind-name->symbol "struct")
   'struct)

  (check-equal?
   (canonical-relpath (string->path "stable/std/vec/struct.Vec.html"))
   "std/vec/struct.Vec.html")

  (check-equal?
   (url-for-relpath (string->path "stable/std/vec/struct.Vec.html"))
   "https://doc.rust-lang.org/std/vec/struct.Vec.html"))
