#lang racket/base

;; The local Ruby documentation mirror used by this tool comes from:
;; https://docs.ruby-lang.org/en/master/

(require racket/cmdline
         racket/file
         racket/list
         racket/match
         racket/path
         racket/string)

(provide ruby-entry?
         extract-ruby-keyword-entries
         extract-ruby-page-entries
         extract-ruby-doc-entries
         write-map!
         print-stats
         main)

;; Compact tuple: (source owner kind token url)
;; source is one of 'syntax 'core 'stdlib.
;; owner is the documenting class/module symbol, or 'syntax for keywords.
;; kind is one of 'class 'module 'keyword 'instance-method 'class-method.

(define ruby-docs-base-url "https://docs.ruby-lang.org/en/master/")
(define allowed-sources '(syntax core stdlib))
(define allowed-kinds '(class module keyword instance-method class-method))

(define ruby-keywords
  '("__ENCODING__" "__FILE__" "__LINE__"
    "BEGIN" "END" "alias" "and" "begin" "break" "case" "class"
    "def" "defined?" "do" "else" "elsif" "end" "ensure" "false"
    "for" "if" "in" "module" "next" "nil" "not" "or" "redo"
    "rescue" "retry" "return" "self" "super" "then" "true" "undef"
    "unless" "until" "when" "while" "yield"))

(define default-keyword-target
  (cons "syntax/keywords_rdoc.html" #f))

(define ruby-keyword-targets
  (hash
   "__ENCODING__" default-keyword-target
   "__FILE__" default-keyword-target
   "__LINE__" default-keyword-target
   "BEGIN" (cons "syntax/miscellaneous_rdoc.html" "#begin-and-end")
   "END" (cons "syntax/miscellaneous_rdoc.html" "#begin-and-end")
   "alias" (cons "syntax/miscellaneous_rdoc.html" "#alias")
   "and" (cons "syntax/operators_rdoc.html" "#-and")
   "begin" (cons "syntax/exceptions_rdoc.html" "#exception-handling")
   "break" (cons "syntax/control_expressions_rdoc.html" "#break-statement")
   "case" (cons "syntax/control_expressions_rdoc.html" "#case-expression")
   "class" (cons "syntax/modules_and_classes_rdoc.html" "#classes")
   "def" (cons "syntax/methods_rdoc.html" "#methods")
   "defined?" (cons "syntax/miscellaneous_rdoc.html" "#defined")
   "do" (cons "syntax/calling_methods_rdoc.html" "#block-argument")
   "else" (cons "syntax/control_expressions_rdoc.html" "#if-expression")
   "elsif" (cons "syntax/control_expressions_rdoc.html" "#if-expression")
   "end" default-keyword-target
   "ensure" (cons "syntax/exceptions_rdoc.html" "#exception-handling")
   "false" (cons "syntax/literals_rdoc.html" "#boolean-and-nil-literals")
   "for" (cons "syntax/control_expressions_rdoc.html" "#for-loop")
   "if" (cons "syntax/control_expressions_rdoc.html" "#if-expression")
   "in" (cons "syntax/pattern_matching_rdoc.html" "#patterns")
   "module" (cons "syntax/modules_and_classes_rdoc.html" "#modules")
   "next" (cons "syntax/control_expressions_rdoc.html" "#next-statement")
   "nil" (cons "syntax/literals_rdoc.html" "#boolean-and-nil-literals")
   "not" (cons "syntax/operators_rdoc.html" "#logical-operators")
   "or" (cons "syntax/operators_rdoc.html" "#-or")
   "redo" (cons "syntax/control_expressions_rdoc.html" "#redo-statement")
   "rescue" (cons "syntax/exceptions_rdoc.html" "#exception-handling")
   "retry" (cons "syntax/exceptions_rdoc.html" "#exception-handling")
   "return" (cons "syntax/methods_rdoc.html" "#return-values")
   "self" (cons "syntax/modules_and_classes_rdoc.html" "#self")
   "super" (cons "syntax/modules_and_classes_rdoc.html" "#inheritance")
   "then" (cons "syntax/control_expressions_rdoc.html" "#case-expression")
   "true" (cons "syntax/literals_rdoc.html" "#boolean-and-nil-literals")
   "undef" (cons "syntax/miscellaneous_rdoc.html" "#undef")
   "unless" (cons "syntax/control_expressions_rdoc.html" "#unless-expression")
   "until" (cons "syntax/control_expressions_rdoc.html" "#until-loop")
   "when" (cons "syntax/control_expressions_rdoc.html" "#case-expression")
   "while" (cons "syntax/control_expressions_rdoc.html" "#while-loop")
   "yield" (cons "syntax/methods_rdoc.html" "#block-argument")))

(define core-owners
  '(ARGF Array BasicObject Binding Class Comparable Data Dir Encoding Enumerable
         Enumerator Exception FalseClass Fiber File Float GC Hash Integer IO
         Kernel MatchData Math Method Module NilClass Numeric Object Proc Process
         Random Range Rational Regexp String Struct Symbol Thread Time TracePoint
         TrueClass UnboundMethod))

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b)))

(define (ruby-entry? v)
  (match v
    [(list source owner kind token url)
     (and (memq source allowed-sources)
          (symbol? owner)
          (memq kind allowed-kinds)
          (string? token)
          (not (string=? "" (string-trim token)))
          (string? url)
          (regexp-match? #px"^https://docs\\.ruby-lang\\.org/en/master/" url))]
    [_ #f]))

(define (entry-key e)
  (match e
    [(list source owner kind token _url)
     (list source owner kind token)]))

(define (dedupe entries)
  (define h
    (for/fold ([acc (hash)])
              ([e (in-list entries)]
               #:when (ruby-entry? e))
      (hash-set acc (entry-key e) e)))
  (sort (hash-values h)
        (lambda (a b)
          (match* (a b)
            [((list source-a owner-a kind-a token-a _)
              (list source-b owner-b kind-b token-b _))
             (cond
               [(symbol<? source-a source-b) #t]
               [(not (eq? source-a source-b)) #f]
               [(symbol<? owner-a owner-b) #t]
               [(eq? owner-a owner-b)
                (cond
                  [(symbol<? kind-a kind-b) #t]
                  [(eq? kind-a kind-b)
                   (string<? token-a token-b)]
                  [else #f])]
               [else #f])]))))

(define (html-basic-decode s)
  (define named
    '(("&amp;" . "&")
      ("&lt;" . "<")
      ("&gt;" . ">")
      ("&quot;" . "\"")
      ("&#39;" . "'")
      ("&apos;" . "'")))
  (for/fold ([acc s]) ([p (in-list named)])
    (regexp-replace* (regexp-quote (car p)) acc (cdr p))))

(define (path->url-piece p)
  (regexp-replace* #px"\\\\" (path->string p) "/"))

(define (url-for-relpath rel [anchor #f])
  (string-append ruby-docs-base-url
                 (path->url-piece rel)
                 (or anchor "")))

(define (keyword-url root-path keyword)
  (define target (hash-ref ruby-keyword-targets keyword default-keyword-target))
  (define rel (string->path (car target)))
  (define anchor (cdr target))
  (if (file-exists? (build-path root-path rel))
      (url-for-relpath rel anchor)
      (url-for-relpath (string->path (car default-keyword-target))
                       (cdr default-keyword-target))))

(define (api-source owner)
  (if (memq owner core-owners) 'core 'stdlib))

(define title-rx #px"<title>(class|module) ([^-<]+) - Documentation")
(define method-link-rx #px"<a href=\"[^\"]*#(method-([ic])-[^\"]+)\">([^<]+)</a>")

(define (extract-title-entry html rel)
  (match (regexp-match title-rx html)
    [(list _ kind-s token-s)
     (define kind (string->symbol kind-s))
     (define token (string-trim (html-basic-decode token-s)))
     (and (not (string=? token ""))
          (let ([owner (string->symbol token)])
            (list (api-source owner) owner kind token (url-for-relpath rel))))]
    [_ #f]))

(define (extract-method-entries html rel owner)
  (dedupe
   (for/list ([m (in-list (regexp-match* method-link-rx html #:match-select values))])
     (match-define (list _ anchor sigil token-s) m)
     (define kind (if (string=? sigil "c") 'class-method 'instance-method))
     (define token (string-trim (html-basic-decode token-s)))
     (list (api-source owner) owner kind token (url-for-relpath rel (string-append "#" anchor))))))

(define (extract-ruby-page-entries root p)
  (define root-path (simplify-path root #t))
  (define rel (find-relative-path root-path p))
  (define html (file->string p))
  (define title-entry (extract-title-entry html rel))
  (if title-entry
      (let ([owner (second title-entry)])
        (dedupe (cons title-entry (extract-method-entries html rel owner))))
      null))

(define (extract-ruby-keyword-entries root)
  (define root-path (simplify-path root #t))
  (define default-path (build-path root-path (string->path (car default-keyword-target))))
  (if (file-exists? default-path)
      (for/list ([kw (in-list ruby-keywords)])
        (list 'syntax 'syntax 'keyword kw (keyword-url root-path kw)))
      null))

(define (extract-ruby-doc-entries root)
  (define root-path (simplify-path root #t))
  (define pages
    (find-files (lambda (p)
                  (regexp-match? #px"\\.html$" (path->string p)))
                root-path))
  (dedupe
   (append (extract-ruby-keyword-entries root-path)
           (append-map (lambda (p) (extract-ruby-page-entries root-path p)) pages))))

(define (write-map! out-path entries)
  (call-with-output-file out-path
    (lambda (out) (write (dedupe entries) out))
    #:exists 'truncate/replace)
  out-path)

(define (count-by f entries)
  (for/fold ([h (hash)]) ([e (in-list entries)])
    (hash-update h (f e) add1 0)))

(define (print-stats entries)
  (printf "total: ~a\n" (length entries))
  (define by-source (count-by first entries))
  (for ([source (in-list allowed-sources)])
    (define n (hash-ref by-source source 0))
    (when (positive? n)
      (printf "  ~a: ~a\n" source n)))
  (define by-kind (count-by third entries))
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
   #:program "racket ruby-docs-map-build.rkt"
   #:once-each
   ["--root" p "Path to local docs.ruby-lang.org/en/master mirror"
             (set! root p)]
   ["--out" p "Write generated map to P (.rktd)"
            (set! out p)]
   ["--stats" "Print summary stats"
              (set! stats? #t)]
   ["--sample" n "Print the first N extracted entries"
               (set! sample-count (string->number n))])
  (unless root
    (error 'ruby-docs-map-build "missing required --root PATH"))
  (define entries (extract-ruby-doc-entries root))
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

  (check-true (ruby-entry? '(syntax syntax keyword "class" "https://docs.ruby-lang.org/en/master/syntax/modules_and_classes_rdoc.html#classes")))
  (check-false (ruby-entry? '(syntax syntax keyword "class" "https://example.com/"))))
