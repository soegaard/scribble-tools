#lang racket/base

;; The local cppreference archive used by this tool comes from:
;; https://github.com/PeterFeicht/cppreference-doc/releases

(require racket/cmdline
         racket/list
         racket/match
         racket/path
         racket/port
         racket/string)

(provide cppreference-entry?
         extract-index-entries
         extract-cppreference-entries
         write-map!
         print-stats
         main)

;; Compact tuple: (lang kind token url)
;; lang is one of 'c or 'cpp
;; kind is one of 'function 'typedef 'class 'const 'macro 'enum 'variable 'header

(define cppreference-base-url "https://en.cppreference.com/w/")

(define allowed-kinds
  '(function typedef class const macro enum variable header))

(define (cppreference-entry? v)
  (match v
    [(list lang kind token url)
     (and (memq lang '(c cpp))
          (memq kind allowed-kinds)
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://en\\.cppreference\\.com/w/" url))]
    [_ #f]))

(define (entry-key e)
  (match e
    [(list lang kind token _url)
     (list lang
           kind
           (string-downcase (string-trim token)))]))

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b)))

(define (dedupe entries)
  (define h
    (for/fold ([acc (hash)])
              ([e (in-list entries)]
               #:when (cppreference-entry? e))
      (hash-set acc (entry-key e) e)))
  (sort (hash-values h)
        (lambda (a b)
          (match* (a b)
            [((list lang-a kind-a token-a _)
              (list lang-b kind-b token-b _))
             (cond
               [(symbol<? lang-a lang-b) #t]
               [(eq? lang-a lang-b)
                (cond
                  [(symbol<? kind-a kind-b) #t]
                  [(eq? kind-a kind-b)
                   (string<? (string-downcase token-a)
                             (string-downcase token-b))]
                  [else #f])]
               [else #f])]))))

(define (normalize-url link)
  (string-append cppreference-base-url link))

(define (read-archive-member archive-path member-path)
  (define-values (proc in out err)
    (subprocess #f #f #f "/usr/bin/tar" "-xOf" archive-path member-path))
  (close-output-port out)
  (define data (port->string in))
  (define err-data (port->string err))
  (subprocess-wait proc)
  (define status (subprocess-status proc))
  (unless (zero? status)
    (error 'read-archive-member
           (string-append "failed to read archive member: "
                          member-path
                          (if (string=? "" (string-trim err-data))
                              ""
                              (string-append "\n" err-data)))))
  data)

(define item-rx
  #px"<(function|typedef|class|const|macro|enum|variable)\\s+name=\"([^\"]+)\"\\s+link=\"([^\"]+)\"")

(define header-rx
  #px"<sub\\s+name=\"([A-Za-z0-9_]+)\"\\s+link=\"((?:c|cpp)/header/[^\"]+)\"\\s*/>")

(define (extract-item-entries lang xml)
  (for/list ([m (in-list (regexp-match* item-rx xml #:match-select cdr))])
    (define kind (string->symbol (list-ref m 0)))
    (define token (list-ref m 1))
    (define link (list-ref m 2))
    (list lang kind token (normalize-url link))))

(define (extract-header-entries lang xml)
  (for/list ([m (in-list (regexp-match* header-rx xml #:match-select cdr))])
    (define token (list-ref m 0))
    (define link (list-ref m 1))
    (list lang 'header token (normalize-url link))))

(define (extract-index-entries lang xml)
  (dedupe (append (extract-item-entries lang xml)
                  (extract-header-entries lang xml))))

(define (extract-cppreference-entries archive-path)
  (define archive (path->string (simplify-path archive-path #t)))
  (define prefix "cppreference-doc-20250209/")
  (define c-functions
    (read-archive-member archive (string-append prefix "index-functions-c.xml")))
  (define cpp-functions
    (read-archive-member archive (string-append prefix "index-functions-cpp.xml")))
  (define c-chapters
    (read-archive-member archive (string-append prefix "index-chapters-c.xml")))
  (define cpp-chapters
    (read-archive-member archive (string-append prefix "index-chapters-cpp.xml")))
  (dedupe
   (append (extract-index-entries 'c c-functions)
           (extract-header-entries 'c c-chapters)
           (extract-index-entries 'cpp cpp-functions)
           (extract-header-entries 'cpp cpp-chapters))))

(define (write-map! out-path entries)
  (call-with-output-file out-path
    (lambda (out)
      (write (dedupe entries) out))
    #:exists 'truncate/replace)
  out-path)

(define (print-stats entries)
  (define total (length entries))
  (define by-lang
    (for/fold ([h (hash)])
              ([e (in-list entries)])
      (hash-update h (first e) add1 0)))
  (define by-kind
    (for/fold ([h (hash)])
              ([e (in-list entries)])
      (hash-update h (second e) add1 0)))
  (printf "total: ~a\n" total)
  (printf "  C: ~a\n" (hash-ref by-lang 'c 0))
  (printf "  C++: ~a\n" (hash-ref by-lang 'cpp 0))
  (for ([kind (in-list allowed-kinds)])
    (define n (hash-ref by-kind kind 0))
    (when (positive? n)
      (printf "  ~a: ~a\n" kind n))))

(define (main)
  (define archive #f)
  (define out #f)
  (define stats? #f)
  (define sample-count 0)
  (command-line
   #:program "racket cppreference-map-build.rkt"
   #:once-each
   ["--archive" p "Path to cppreference-doc archive (.tar.xz)"
                (set! archive p)]
   ["--out" p "Write generated map to P (.rktd)"
            (set! out p)]
   ["--stats" "Print summary stats"
              (set! stats? #t)]
   ["--sample" n "Print the first N extracted entries"
               (set! sample-count (string->number n))])
  (unless archive
    (error 'cppreference-map-build "missing required --archive PATH"))
  (define entries (extract-cppreference-entries archive))
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

  (define c-functions-xml
    "<index>
       <typedef name=\"size_t\" link=\"c/types/size_t\"/>
       <const name=\"NULL\" link=\"c/types/NULL\"/>
       <function name=\"printf\" link=\"c/io/fprintf\"/>
     </index>")

  (define cpp-functions-xml
    "<index>
       <class name=\"std::vector\" link=\"cpp/container/vector\"/>
       <typedef name=\"std::size_t\" link=\"cpp/types/size_t\"/>
       <function name=\"std::move\" link=\"cpp/utility/move\"/>
     </index>")

  (define chapters-xml
    "<chapters xmlns=\"http://www.devhelp.net/book\">
       <sub name=\"vector\" link=\"cpp/header/vector\"/>
       <sub name=\"string\" link=\"cpp/header/string\"/>
       <sub name=\"Language\" link=\"cpp/language\"/>
     </chapters>")

  (check-true
   (cppreference-entry?
    (list 'c 'function "printf" "https://en.cppreference.com/w/c/io/fprintf")))
  (check-false
   (cppreference-entry?
    (list 'c 'topic "printf" "https://en.cppreference.com/w/c/io/fprintf")))

  (check-equal?
   (extract-item-entries 'c c-functions-xml)
   (list (list 'c 'typedef "size_t" "https://en.cppreference.com/w/c/types/size_t")
         (list 'c 'const "NULL" "https://en.cppreference.com/w/c/types/NULL")
         (list 'c 'function "printf" "https://en.cppreference.com/w/c/io/fprintf")))

  (check-equal?
   (extract-item-entries 'cpp cpp-functions-xml)
   (list (list 'cpp 'class "std::vector" "https://en.cppreference.com/w/cpp/container/vector")
         (list 'cpp 'typedef "std::size_t" "https://en.cppreference.com/w/cpp/types/size_t")
         (list 'cpp 'function "std::move" "https://en.cppreference.com/w/cpp/utility/move")))

  (check-equal?
   (extract-header-entries 'cpp chapters-xml)
   (list (list 'cpp 'header "vector" "https://en.cppreference.com/w/cpp/header/vector")
         (list 'cpp 'header "string" "https://en.cppreference.com/w/cpp/header/string")))

  (check-equal?
   (extract-index-entries 'cpp (string-append cpp-functions-xml chapters-xml))
   (list (list 'cpp 'class "std::vector" "https://en.cppreference.com/w/cpp/container/vector")
         (list 'cpp 'function "std::move" "https://en.cppreference.com/w/cpp/utility/move")
         (list 'cpp 'header "string" "https://en.cppreference.com/w/cpp/header/string")
         (list 'cpp 'header "vector" "https://en.cppreference.com/w/cpp/header/vector")
         (list 'cpp 'typedef "std::size_t" "https://en.cppreference.com/w/cpp/types/size_t"))))
