#lang racket/base

;; The local Free Pascal documentation mirror used by this tool comes from:
;; https://www.freepascal.org/docs-html/current/
;;
;; In this workspace we mirrored the relevant subset locally under /tmp using curl.

(require racket/cmdline
         racket/file
         racket/list
         racket/match
         racket/path
         racket/string)

(provide pascal-entry?
         extract-reference-keyword-entries
         extract-rtl-unit-entries
         extract-pascal-entries
         write-map!
         print-stats
         main)

;; Compact tuple: (source kind token url)
;; source is 'reference for language-reference entries, otherwise the unit name
;; kind is one of 'keyword 'unit 'const 'type 'class 'routine 'variable

(define fpc-ref-base-url "https://www.freepascal.org/docs-html/current/ref/")
(define fpc-rtl-base-url "https://www.freepascal.org/docs-html/current/rtl/")

(define allowed-kinds '(keyword unit const type class routine variable))

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b)))

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

(define (normalize-token s)
  (string-trim (regexp-replace* #px"&nbsp;|&#160;" s " ")))

(define (identifier-like? s)
  (regexp-match? #px"^[A-Za-z_][A-Za-z0-9_]*$" s))

(define (entry-key e)
  (match e
    [(list source kind token _url)
     (list (string-downcase (symbol->string source))
           kind
           (string-downcase (string-trim token)))]))

(define (dedupe entries)
  (define h
    (for/fold ([acc (hash)])
              ([e (in-list entries)]
               #:when (pascal-entry? e))
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
                   (string-ci<? token-a token-b)]
                  [else #f])]
               [else #f])]))))

(define keyword-anchor-rx #px"<a name=\"keyword_([^\"]+)\"></a>")
(define unit-title-rx #px"<title>Reference for unit '([^']+)'")
(define item-link-rx
  #px"<span class=\"code\"><a href=\"\\.\\./([^/]+)/([^\"/]+\\.html)\">([^<]+)</a></span>")

(define (path-last-string p)
  (define-values (_base name _dir?) (split-path p))
  (path->string name))

(define (extract-reference-keyword-entries root)
  (define ref-root (build-path (simplify-path root #t) "ref"))
  (define entries null)
  (for ([p (in-list (find-files
                     (lambda (p)
                       (regexp-match? #px"\\.html$" (path->string p)))
                     ref-root))])
    (define filename (path-last-string p))
    (define html (file->string p))
    (for ([kw (in-list (regexp-match* keyword-anchor-rx html #:match-select cadr))])
      (define token (normalize-token kw))
      (when (and (not (string=? token ""))
                 (identifier-like? token))
        (set! entries
              (cons (list 'reference
                          'keyword
                          token
                          (string-append fpc-ref-base-url filename "#keyword_" token))
                    entries)))))
  (dedupe entries))

(define rtl-kind-pages
  '((const . "index-2.html")
    (type . "index-3.html")
    (class . "index-4.html")
    (routine . "index-5.html")
    (variable . "index-6.html")))

(define (extract-unit-name index-html fallback-unit-name)
  (cond
    [(regexp-match unit-title-rx index-html)
     => (lambda (m) (normalize-token (list-ref m 1)))]
    [else fallback-unit-name]))

(define (extract-rtl-links page-html expected-unit kind)
  (for/list ([m (in-list (regexp-match* item-link-rx page-html #:match-select cdr))]
             #:do [(define unit-name (list-ref m 0))
                   (define page-name (list-ref m 1))
                   (define token (normalize-token (list-ref m 2)))]
             #:when (and (string-ci=? unit-name expected-unit)
                         (identifier-like? token)
                         (not (regexp-match? #px"^index(?:-[0-9]+)?\\.html$" page-name))))
    (list (string->symbol (string-downcase unit-name))
          kind
          token
          (string-append fpc-rtl-base-url unit-name "/" page-name))))

(define (extract-rtl-unit-entries root)
  (define rtl-root (build-path (simplify-path root #t) "rtl"))
  (define entries null)
  (for ([unit-dir (in-list (sort (filter directory-exists? (directory-list rtl-root #:build? #t))
                                 (lambda (a b)
                                   (string-ci<? (path-last-string a) (path-last-string b)))))])
    (define unit-name (path-last-string unit-dir))
    (define index-path (build-path unit-dir "index.html"))
    (when (file-exists? index-path)
      (define index-html (file->string index-path))
      (define display-name (extract-unit-name index-html unit-name))
      (set! entries
            (cons (list (string->symbol (string-downcase unit-name))
                        'unit
                        display-name
                        (string-append fpc-rtl-base-url unit-name "/index.html"))
                  entries))
      (for ([kp (in-list rtl-kind-pages)])
        (define kind (car kp))
        (define page-name (cdr kp))
        (define page-path (build-path unit-dir page-name))
        (when (file-exists? page-path)
          (set! entries
                (append (extract-rtl-links (file->string page-path) unit-name kind)
                        entries))))))
  (dedupe entries))

(define (extract-pascal-entries root)
  (dedupe
   (append (extract-reference-keyword-entries root)
           (extract-rtl-unit-entries root))))

(define (write-map! out-path entries)
  (call-with-output-file out-path
    (lambda (out)
      (write (dedupe entries) out))
    #:exists 'truncate/replace)
  out-path)

(define (print-stats entries)
  (define total (length entries))
  (define by-kind
    (for/fold ([h (hash)])
              ([e (in-list entries)])
      (hash-update h (second e) add1 0)))
  (define units
    (remove-duplicates
     (for/list ([e (in-list entries)]
                #:when (not (eq? (first e) 'reference)))
       (first e))))
  (printf "total: ~a\n" total)
  (printf "  units: ~a\n" (length units))
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
   #:program "racket pascal-map-build.rkt"
   #:once-each
   ["--root" p "Path to local Free Pascal docs mirror"
             (set! root p)]
   ["--out" p "Write generated map to P (.rktd)"
            (set! out p)]
   ["--stats" "Print summary stats"
              (set! stats? #t)]
   ["--sample" n "Print the first N extracted entries"
               (set! sample-count (string->number n))])
  (unless root
    (error 'pascal-map-build "missing required --root PATH"))
  (define entries (extract-pascal-entries root))
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

  (define ref-html
    "<html><body><a name=\"keyword_function\"></a><a name=\"keyword_begin\"></a></body></html>")
  (define rtl-index-html
    "<title>Reference for unit 'System'</title>")
  (define rtl-routines-html
    "<tr><td valign=\"top\"><p><tt><span class=\"code\"><a href=\"../system/writeln.html\">WriteLn</a></span></tt></p></td></tr>
     <tr><td valign=\"top\"><p><tt><span class=\"code\"><a href=\"../system/op-add-variant-variant-variant.html\">add(variant,variant):variant</a></span></tt></p></td></tr>")
  (define rtl-types-html
    "<tr><td valign=\"top\"><p><tt><span class=\"code\"><a href=\"../system/integer.html\">Integer</a></span></tt></p></td></tr>")

  (check-true
   (pascal-entry?
    (list 'reference 'keyword "function"
          "https://www.freepascal.org/docs-html/current/ref/refse93.html#keyword_function")))
  (check-false (pascal-entry? (list 'reference 'topic "function" "x")))
  (check-equal?
   (dedupe
    (for/list ([kw (in-list (regexp-match* keyword-anchor-rx ref-html #:match-select cadr))])
      (list 'reference 'keyword kw
            (string-append fpc-ref-base-url "sample.html#keyword_" kw))))
   (list (list 'reference 'keyword "begin"
               "https://www.freepascal.org/docs-html/current/ref/sample.html#keyword_begin")
         (list 'reference 'keyword "function"
               "https://www.freepascal.org/docs-html/current/ref/sample.html#keyword_function")))
  (check-equal? (extract-unit-name rtl-index-html "system") "System")
  (check-equal?
   (extract-rtl-links rtl-routines-html "system" 'routine)
   (list (list 'system 'routine "WriteLn"
               "https://www.freepascal.org/docs-html/current/rtl/system/writeln.html")))
  (check-equal?
   (extract-rtl-links rtl-types-html "system" 'type)
   (list (list 'system 'type "Integer"
               "https://www.freepascal.org/docs-html/current/rtl/system/integer.html"))))
