#lang racket/base

(require racket/cmdline
         racket/file
         racket/list
         racket/match
         racket/path
         racket/string)

(provide tikz-entry?
         extract-file-entries
         extract-tikz-entries
         write-map!
         print-stats
         main)

;; Compact tuple: (kind token url)
;; kind is one of 'command or 'key

(define tikz-base-url "https://tikz.dev/")

(define (tikz-entry? v)
  (match v
    [(list kind token url)
     (and (memq kind '(command key))
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://tikz\\.dev/" url))]
    [_ #f]))

(define (entry-key e)
  (list (first e)
        (string-downcase (string-trim (second e)))))

(define (dedupe entries)
  (define h
    (for/fold ([acc (hash)])
              ([e (in-list entries)]
               #:when (tikz-entry? e))
      (hash-set acc (entry-key e) e)))
  (sort (hash-values h)
        (lambda (a b)
          (cond
            [(symbol<? (first a) (first b)) #t]
            [(eq? (first a) (first b))
             (string<? (string-downcase (second a))
                       (string-downcase (second b)))]
            [else #f]))))

(define (public-command-token? token)
  (and (regexp-match? #px"^\\\\[^[:space:]{}]+$" token)
       (not (regexp-match? #px"@" token))))

(define (public-key-token? token)
  (regexp-match? #px"^/(?:tikz|pgf)/" token))

(define (filter-public entries)
  (filter (lambda (e)
            (match e
              [(list 'command token _url) (public-command-token? token)]
              [(list 'key token _url) (public-key-token? token)]
              [_ #f]))
          entries))

(define (html-unescape s)
  (define replacements
    (list (cons "&amp;" "&")
          (cons "&lt;" "<")
          (cons "&gt;" ">")
          (cons "&quot;" "\"")
          (cons "&#39;" "'")
          (cons "&nbsp;" " ")))
  (for/fold ([out s]) ([p (in-list replacements)])
    (string-replace out (car p) (cdr p))))

(define (relative-url root path)
  (define rel (find-relative-path root path))
  (regexp-replace* #px"\\\\" (path->string rel) "/"))

(define (current-page-url root file)
  (string-append tikz-base-url (relative-url root file)))

(define (url-for-anchor root file anchor)
  (string-append (current-page-url root file) "#" anchor))

(define (normalize-href root file href)
  (cond
    [(regexp-match? #px"^https?://" href) href]
    [(string-prefix? href "#")
     (string-append (current-page-url root file) href)]
    [else
     (define m (regexp-match #px"^([^#]+)(#.*)?$" href))
     (define page-part (list-ref m 1))
     (define anchor-part (or (list-ref m 2) ""))
     (define dir (or (path-only file) (current-directory)))
     (define target (simplify-path (build-path dir page-part) #t))
     (string-append tikz-base-url (relative-url root target) anchor-part)]))

(define command-def-rx
  #px"(?s:<a id=\"(pgf\\.back/[^\"]+)\"></a>.*?<kbd>(\\\\[^<[:space:]]+)</kbd>)")

(define command-link-rx
  #px"<a href=\"([^\"]*#pgf\\.back/[^\"]+)\">(\\\\[^<[:space:]]+)</a>")

(define key-def-rx
  #px"(?s:<a id=\"(pgf\\./(?:tikz|pgf)/[^\"]+)\"></a>.*?<span class=\"keyname\">.*?>(/(?:tikz|pgf)/[^<]+)</span>)")

(define (extract-command-definitions root file html)
  (for/list ([m (in-list (regexp-match* command-def-rx html #:match-select cdr))])
    (define anchor (first m))
    (define token (html-unescape (second m)))
    (list 'command token (url-for-anchor root file anchor))))

(define (extract-command-links root file html)
  (for/list ([m (in-list (regexp-match* command-link-rx html #:match-select cdr))])
    (define href (html-unescape (first m)))
    (define token (html-unescape (second m)))
    (list 'command token (normalize-href root file href))))

(define (extract-key-definitions root file html)
  (for/list ([m (in-list (regexp-match* key-def-rx html #:match-select cdr))])
    (define anchor (first m))
    (define token (string-trim (html-unescape (second m))))
    (list 'key token (url-for-anchor root file anchor))))

(define (extract-file-entries root file #:include-internal? [include-internal? #f])
  (define html (file->string file))
  (define entries
    (dedupe
     (append (extract-command-definitions root file html)
             (extract-command-links root file html)
             (extract-key-definitions root file html))))
  (if include-internal? entries (filter-public entries)))

(define (extract-tikz-entries root #:include-internal? [include-internal? #f])
  (define root-path
    (simplify-path
     (cond
       [(path? root) root]
       [(path-string? root) root]
       [else
        (raise-argument-error 'extract-tikz-entries "path-string?" root)])
     #t))
  (unless (directory-exists? root-path)
    (raise-argument-error 'extract-tikz-entries "existing directory" root))
  (dedupe
   (append*
    (for/list ([p (in-list (sort (find-files (lambda (p) (regexp-match? #px"\\.html?$" (path->string p)))
                                              root-path)
                                 path<?))])
      (extract-file-entries root-path p #:include-internal? include-internal?)))))

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
      (hash-update h (first e) add1 0)))
  (printf "total: ~a\n" total)
  (printf "  commands: ~a\n" (hash-ref by-kind 'command 0))
  (printf "  keys: ~a\n" (hash-ref by-kind 'key 0)))

(define (main)
  (define root #f)
  (define out #f)
  (define stats? #f)
  (define sample-count 0)
  (define include-internal? #f)
  (command-line
   #:program "racket tikz-map-build.rkt"
   #:once-each
   ["--root" p "Path to local tikz.dev mirror"
             (set! root p)]
   ["--out" p "Write generated map to P (.rktd)"
            (set! out p)]
   ["--stats" "Print summary stats"
              (set! stats? #t)]
   ["--include-internal" "Keep internal/private commands such as @-macros"
                         (set! include-internal? #t)]
   ["--sample" n "Print the first N extracted entries"
               (set! sample-count (string->number n))])
  (unless root
    (error 'tikz-map-build "missing required --root PATH"))
  (define entries (extract-tikz-entries root #:include-internal? include-internal?))
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

  (define command-html
    "<a id=\"pgf.back/shade\"></a>
     <span class=\"hl-def\"><span class=\"textcolor\" style=\"color: #bf0000\"><kbd>\\shade</kbd></span></span>
     <a class=\"anchor-link\" data-html-link=\"pgf.back/shade\" href=\"#/shade\" id=\"\\shade\">&para;</a>
     <span class=\"textcolor\" style=\"color: #0000b2\"><a href=\"tikz-actions.html#pgf.back/draw\">\\draw</a></span>")

  (define key-html
    "<a id=\"pgf./tikz/state\"></a><a id=\"pgf.state\"></a>
     <span class=\"hl-def\"><kbd><span class=\"keyname\"><span class=\"textcolor\" style=\"color: #bf0000\">/tikz/state</span></span></kbd></span>
     <a class=\"anchor-link\" data-html-link=\"pgf./tikz/state\" href=\"#tikz/state\" id=\"tikz/state\">&para;</a>")

  (define root (string->path "/tmp/tikz.dev"))
  (define file (string->path "/tmp/tikz.dev/library-automata.html"))

  (check-true (tikz-entry? (list 'command "\\draw" "https://tikz.dev/tikz-actions.html#pgf.back/draw")))
  (check-true (tikz-entry? (list 'key "/tikz/state" "https://tikz.dev/library-automata.html#pgf./tikz/state")))
  (check-false (tikz-entry? (list 'topic "x" "https://tikz.dev/x")))
  (check-true (public-command-token? "\\draw"))
  (check-false (public-command-token? "\\begin{document}"))
  (check-false (public-command-token? "\\c@pgf@counta"))
  (check-true (public-key-token? "/tikz/state"))

  (check-equal?
   (extract-command-definitions root file command-html)
   (list (list 'command "\\shade"
               "https://tikz.dev/library-automata.html#pgf.back/shade")))

  (check-equal?
   (extract-command-links root file command-html)
   (list (list 'command "\\draw"
               "https://tikz.dev/tikz-actions.html#pgf.back/draw")))

  (check-equal?
   (extract-key-definitions root file key-html)
   (list (list 'key "/tikz/state"
               "https://tikz.dev/library-automata.html#pgf./tikz/state"))))
