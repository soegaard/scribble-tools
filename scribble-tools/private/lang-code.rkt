#lang racket/base

(require racket/list
         racket/string
         racket/file
         racket/runtime-path
         scribble/base
         scribble/core
         (only-in scribble/manual filebox)
         scribble/racket
         (for-syntax racket/base
                     syntax/parse))

(provide css-code
         html-code
         js-code
         cssblock
         htmlblock
         jsblock
         cssblock0
         htmlblock0
         jsblock0)

(define omitable (make-style #f '(omitable)))

(define (style-for lang cls)
  (case lang
    [(css)
     (case cls
       [(comment) comment-color]
       [(keyword) keyword-color]
       [(value) value-color]
       [(name) symbol-color]
       [(punct) paren-color]
       [else no-color])]
    [(html)
     (case cls
       [(comment) comment-color]
       [(keyword) keyword-color]
       [(value) value-color]
       [(name) symbol-color]
       [(punct) paren-color]
       [else no-color])]
    [(js)
     (case cls
       [(comment) comment-color]
       [(keyword) keyword-color]
       [(value) value-color]
       [(name) symbol-color]
       [(punct) paren-color]
       [else no-color])]
    [else no-color]))

(define (next-char s i)
  (and (< i (string-length s)) (string-ref s i)))

(define (read-while s start pred?)
  (let loop ([i start])
    (if (and (< i (string-length s))
             (pred? (string-ref s i)))
        (loop (add1 i))
        i)))

(define (read-until s start needle)
  (define n-len (string-length needle))
  (let loop ([i start])
    (cond
      [(> (+ i n-len) (string-length s)) (string-length s)]
      [(string=? needle (substring s i (+ i n-len))) (+ i n-len)]
      [else (loop (add1 i))])))

(define (css-ident-start? c)
  (or (char-alphabetic? c) (char=? c #\_) (char=? c #\-)))

(define (css-ident-char? c)
  (or (css-ident-start? c) (char-numeric? c)))

(define (hex-digit? c)
  (or (char-numeric? c)
      (and (char-ci>=? c #\a) (char-ci<=? c #\f))))

(define (read-string-literal s i)
  (define len (string-length s))
  (define q (string-ref s i))
  (let loop ([k (add1 i)] [escaped? #f])
    (cond
      [(>= k len) len]
      [else
       (define c (string-ref s k))
       (cond
         [escaped? (loop (add1 k) #f)]
         [(char=? c #\\) (loop (add1 k) #t)]
         [(char=? c q) (add1 k)]
         [else (loop (add1 k) #f)])])))

(define (read-css-number s i)
  (define len (string-length s))
  (define j0
    (if (and (< i len) (member (string-ref s i) '(#\+ #\-)))
        (add1 i)
        i))
  (define j1 (read-while s j0 char-numeric?))
  (define j2
    (if (and (< j1 len) (char=? (string-ref s j1) #\.))
        (read-while s (add1 j1) char-numeric?)
        j1))
  (if (and (< j2 len) (char=? (string-ref s j2) #\%))
      (add1 j2)
      (read-while s j2
                  (lambda (c)
                    (or (char-alphabetic? c) (char=? c #\-))))))

(define (tokenize-css s)
  (define len (string-length s))
  (let loop ([i 0]
             [mode 'selector]
             [expect-property? #f]
             [paren-depth 0]
             [acc null])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j [new-mode mode] [new-expect-property? expect-property?] [new-paren-depth paren-depth])
         (loop j
               new-mode
               new-expect-property?
               new-paren-depth
               (cons (cons cls (substring s i j)) acc)))
       (cond
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\*))
          (emit 'comment (read-until s (+ i 2) "*/"))]
         [(or (char=? ch #\") (char=? ch #\'))
          (emit 'value (read-string-literal s i))]
         [(char-whitespace? ch)
          (emit 'plain (add1 i))]
         [(char=? ch #\@)
          (emit 'keyword
                (read-while s (add1 i) css-ident-char?))]
         [(char=? ch #\{)
          (emit 'punct (add1 i) 'declaration #t 0)]
         [(char=? ch #\})
          (emit 'punct (add1 i) 'selector #f 0)]
         [(char=? ch #\:)
          (if (and (eq? mode 'declaration) expect-property?)
              (emit 'punct (add1 i) mode #f paren-depth)
              (emit 'punct (add1 i)))]
         [(char=? ch #\;)
          (if (and (eq? mode 'declaration) (zero? paren-depth))
              (emit 'punct (add1 i) mode #t paren-depth)
              (emit 'value (add1 i)))]
         [(char=? ch #\()
          (if (and (eq? mode 'declaration) (not expect-property?))
              (emit 'punct (add1 i) mode #f (add1 paren-depth))
              (emit 'punct (add1 i)))]
         [(char=? ch #\))
          (if (and (eq? mode 'declaration) (not expect-property?) (positive? paren-depth))
              (emit 'punct (add1 i) mode #f (sub1 paren-depth))
              (emit 'punct (add1 i)))]
         [(member ch '(#\[ #\] #\, #\> #\+ #\~ #\* #\= #\|))
          (emit 'punct (add1 i))]
         [(char=? ch #\#)
          (define j (read-while s (add1 i) hex-digit?))
          (if (and (> j (add1 i))
                   (<= 3 (- j (add1 i)) 8))
              (emit 'value j)
              (emit 'punct (add1 i)))]
         [(or (char-numeric? ch)
              (and (member ch '(#\+ #\-))
                   (< (add1 i) len)
                   (let ([c2 (string-ref s (add1 i))])
                     (or (char-numeric? c2) (char=? c2 #\.)))))
          (emit 'value (read-css-number s i))]
         [(css-ident-start? ch)
          (define j (read-while s i css-ident-char?))
          (define cls
            (cond
              [(eq? mode 'selector) 'keyword]
              [expect-property? 'name]
              [else 'value]))
          (emit cls j)]
         [else
          (emit 'plain (add1 i))])])))

(define js-keywords
  '(break case catch class const continue debugger default delete do else export extends
          false finally for function if import in instanceof let new null of return super
          switch this throw true try typeof var void while with yield await))

(define (js-ident-start? c)
  (or (char-alphabetic? c) (char=? c #\_) (char=? c #\$)))

(define (js-ident-char? c)
  (or (js-ident-start? c) (char-numeric? c)))

(define (read-js-number s i)
  (define len (string-length s))
  (define j0
    (if (and (< i len) (member (string-ref s i) '(#\+ #\-)))
        (add1 i)
        i))
  (define j1 (read-while s j0 char-numeric?))
  (define j2
    (if (and (< j1 len) (char=? (string-ref s j1) #\.))
        (read-while s (add1 j1) char-numeric?)
        j1))
  (if (and (< j2 len) (member (string-ref s j2) '(#\e #\E)))
      (let* ([j3 (if (and (< (add1 j2) len)
                          (member (string-ref s (add1 j2)) '(#\+ #\-)))
                     (+ j2 2)
                     (add1 j2))])
        (read-while s j3 char-numeric?))
      j2))

(define (tokenize-js s)
  (define len (string-length s))
  (let loop ([i 0] [acc null])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j)
         (loop j (cons (cons cls (substring s i j)) acc)))
       (cond
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\*))
          (emit 'comment (read-until s (+ i 2) "*/"))]
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\/))
          (define j (read-until s (+ i 2) "\n"))
          (emit 'comment j)]
         [(or (char=? ch #\") (char=? ch #\') (char=? ch #\`))
          (emit 'value (read-string-literal s i))]
         [(char-whitespace? ch)
          (emit 'plain (add1 i))]
         [(or (char-numeric? ch)
              (and (member ch '(#\+ #\-))
                   (< (add1 i) len)
                   (let ([c2 (string-ref s (add1 i))])
                     (or (char-numeric? c2) (char=? c2 #\.)))))
          (emit 'value (read-js-number s i))]
         [(js-ident-start? ch)
          (define j (read-while s i js-ident-char?))
          (define id (string->symbol (substring s i j)))
          (emit (if (memq id js-keywords) 'keyword 'name) j)]
         [(member ch
                  '(#\{ #\} #\( #\) #\[ #\] #\, #\. #\; #\: #\? #\! #\= #\+ #\- #\* #\/ #\% #\< #\> #\& #\|))
          (emit 'punct (add1 i))]
         [else
          (emit 'plain (add1 i))])])))

(define (string-ci-prefix-at? s i prefix)
  (define n (string-length prefix))
  (and (<= (+ i n) (string-length s))
       (string-ci=? (substring s i (+ i n)) prefix)))

(define (find-ci s start needle)
  (define n (string-length needle))
  (let loop ([i start])
    (cond
      [(> (+ i n) (string-length s)) #f]
      [(string-ci=? (substring s i (+ i n)) needle) i]
      [else (loop (add1 i))])))

(define (html-name-char? c)
  (or (char-alphabetic? c)
      (char-numeric? c)
      (member c '(#\- #\_ #\: #\.))))

(define (parse-html-tag s i)
  (define len (string-length s))
  (define tokens null)
  (define (push cls a b)
    (when (< a b)
      (set! tokens (cons (cons cls (substring s a b)) tokens))))

  (define j (+ i 1))
  (push 'punct i j) ; <
  (define closing?
    (and (< j len) (char=? (string-ref s j) #\/)))
  (when closing?
    (push 'punct j (add1 j))
    (set! j (add1 j)))

  (define name-start j)
  (set! j (read-while s j html-name-char?))
  (define tag-name
    (string-downcase (substring s name-start j)))
  (push 'keyword name-start j)

  (let loop ()
    (if (>= j len)
        (values (reverse tokens) j tag-name closing? #f)
        (let ((ch (string-ref s j)))
          (cond
            ((char-whitespace? ch)
             (let ((k (read-while s j char-whitespace?)))
               (push 'plain j k)
               (set! j k)
               (loop)))
            ((char=? ch #\>)
             (push 'punct j (add1 j))
             (values (reverse tokens) (add1 j) tag-name closing? #f))
            ((and (char=? ch #\/)
                  (< (add1 j) len)
                  (char=? (string-ref s (add1 j)) #\>))
             (push 'punct j (add1 j))
             (push 'punct (add1 j) (+ j 2))
             (values (reverse tokens) (+ j 2) tag-name closing? #t))
            (else
             (let ((attr-start j))
               (set! j (read-while s j html-name-char?))
               (if (= attr-start j)
                   (begin
                     (push 'plain j (add1 j))
                     (set! j (add1 j))
                     (loop))
                   (begin
                     (push 'name attr-start j)
                     (let ((ws-end (read-while s j char-whitespace?)))
                       (push 'plain j ws-end)
                       (set! j ws-end))
                     (when (and (< j len) (char=? (string-ref s j) #\=))
                       (push 'punct j (add1 j))
                       (set! j (add1 j))
                       (let ((ws2-end (read-while s j char-whitespace?)))
                         (push 'plain j ws2-end)
                         (set! j ws2-end))
                       (when (< j len)
                         (let ((q (string-ref s j)))
                           (if (or (char=? q #\") (char=? q #\'))
                               (let ((end (read-string-literal s j)))
                                 (push 'value j end)
                                 (set! j end))
                               (let ((end
                                      (read-while s j
                                                  (lambda (c)
                                                    (not (or (char-whitespace? c)
                                                             (char=? c #\>)
                                                             (char=? c #\/)))))))
                                 (push 'value j end)
                                 (set! j end))))))
                     (loop))))))))))

(define (tokenize-html s)
  (define len (string-length s))
  (let loop ([i 0] [mode 'text] [acc null])
    (define (emit cls a b [new-mode mode])
      (if (< a b)
          (loop b new-mode (cons (cons cls (substring s a b)) acc))
          (loop b new-mode acc)))
    (cond
      [(>= i len) (reverse acc)]
      [(eq? mode 'script)
       (define close-i (or (find-ci s i "</script") len))
       (define acc2
         (if (< i close-i)
             (append (reverse (tokenize-js (substring s i close-i))) acc)
             acc))
       (if (>= close-i len)
           (reverse acc2)
           (let-values ([(tag-tokens j _tag-name _closing? _self-closing?)
                         (parse-html-tag s close-i)])
             (loop j 'text (append (reverse tag-tokens) acc2))))]
      [(eq? mode 'style)
       (define close-i (or (find-ci s i "</style") len))
       (define acc2
         (if (< i close-i)
             (append (reverse (tokenize-css (substring s i close-i))) acc)
             acc))
       (if (>= close-i len)
           (reverse acc2)
           (let-values ([(tag-tokens j _tag-name _closing? _self-closing?)
                         (parse-html-tag s close-i)])
             (loop j 'text (append (reverse tag-tokens) acc2))))]
      [else
       (cond
         [(string-ci-prefix-at? s i "<!--")
          (define j (read-until s (+ i 4) "-->"))
          (emit 'comment i j)]
         [(and (string-ci-prefix-at? s i "<!")
               (not (string-ci-prefix-at? s i "<!--")))
          (define j (or (find-ci s i ">") (sub1 len)))
          (emit 'keyword i (min len (add1 j)))]
         [(char=? (string-ref s i) #\<)
          (let-values ([(tag-tokens j tag-name closing? self-closing?)
                        (parse-html-tag s i)])
            (define next-mode
              (cond
                [closing? 'text]
                [self-closing? 'text]
                [(string=? tag-name "script") 'script]
                [(string=? tag-name "style") 'style]
                [else 'text]))
            (loop j next-mode (append (reverse tag-tokens) acc)))]
         [(char=? (string-ref s i) #\&)
          (define semi (or (find-ci s i ";") (sub1 len)))
          (define end (min len (add1 semi)))
          (if (> end i)
              (emit 'value i end)
              (emit 'plain i (add1 i)))]
         [else
          (define next-special
            (let find ([k i])
              (cond
                [(>= k len) len]
                [(or (char=? (string-ref s k) #\<)
                     (char=? (string-ref s k) #\&))
                 k]
                [else (find (add1 k))])))
          (emit 'plain i next-special)])])))

(define (tokenize lang s)
  (case lang
    [(css) (tokenize-css s)]
    [(html) (tokenize-html s)]
    [(js) (tokenize-js s)]
    [else (list (cons 'plain s))]))

(define (split-lines style s)
  (cond
    [(regexp-match-positions #rx"(?:\r\n|\r|\n)" s)
     => (lambda (m)
          (append (split-lines style (substring s 0 (caar m)))
                  (list 'newline)
                  (split-lines style (substring s (cdar m)))))]
    [(regexp-match-positions #rx" +" s)
     => (lambda (m)
          (append (split-lines style (substring s 0 (caar m)))
                  (list (hspace (- (cdar m) (caar m))))
                  (split-lines style (substring s (cdar m)))))]
    [else
     (define e (if (equal? s "") "" (element style s)))
     (if (equal? e "") null (list e))]))

(define (escape->element v)
  (cond
    [(element? v) v]
    [(list? v) (make-element #f v)]
    [else (make-element #f (list v))]))

(define (tokens->pieces lang tokens)
  (apply append
         (for/list ([t (in-list tokens)])
           (if (eq? (car t) 'escape)
               (list (escape->element (cdr t)))
               (split-lines (style-for lang (car t))
                            (cdr t))))))

(define (break-list lst delim)
  (let loop ([l lst] [n null] [c null])
    (cond
      [(null? l) (reverse (if (null? c) n (cons (reverse c) n)))]
      [(eq? delim (car l)) (loop (cdr l) (cons (reverse c) n) null)]
      [else (loop (cdr l) n (cons (car l) c))])))

(define (list->lines indent-amt l
                     #:line-numbers line-numbers
                     #:line-number-sep line-number-sep
                     #:block? block?)
  (define indent-elem (if (zero? indent-amt) "" (hspace indent-amt)))
  (define lines (break-list l 'newline))
  (define line-cnt (length lines))
  (define line-cntl (string-length (format "~a" (+ line-cnt (or line-numbers 0)))))

  (define (prepend-line-number n r)
    (define ln (format "~a" n))
    (define lnl (string-length ln))
    (define diff (- line-cntl lnl))
    (define l1 (list (tt ln) (hspace line-number-sep)))
    (cons (make-element 'smaller
                        (make-element 'smaller
                                      (if (zero? diff)
                                          l1
                                          (cons (hspace diff) l1))))
          r))

  (define (make-line accum-line line-number)
    (define rest (cons indent-elem accum-line))
    (list ((if block? paragraph (lambda (s e) e))
           omitable
           (if line-numbers
               (prepend-line-number line-number rest)
               rest))))

  (for/list ([one-line (in-list (break-list l 'newline))]
             [i (in-naturals (or line-numbers 1))])
    (make-line one-line i)))

(define (normalize-inline-text s)
  (regexp-replace* #px"(?:\\s*(?:\r|\n|\r\n)\\s*)+" s " "))

(define (tokens-from-chunks lang chunks #:inline? [inline? #f])
  (apply append
         (for/list ([chunk (in-list chunks)])
           (cond
             [(eq? (car chunk) 'escape)
              (list (cons 'escape (cdr chunk)))]
             [else
              (define txt (cdr chunk))
              (unless (string? txt)
                (raise-argument-error 'typeset-lang-code "string?" txt))
              (tokenize lang (if inline? (normalize-inline-text txt) txt))]))))

(define (typeset-lang-block/chunks lang
                                   #:file [filename #f]
                                   #:indent [indent 0]
                                   #:line-numbers [line-numbers #f]
                                   #:line-number-sep [line-number-sep 1]
                                   #:inset? [inset? #t]
                                   chunks)
  (define tokens (tokens-from-chunks lang chunks))
  (define lines (list->lines indent
                             (tokens->pieces lang tokens)
                             #:line-numbers line-numbers
                             #:line-number-sep line-number-sep
                             #:block? #t))
  (define tbl (table block-color lines))
  (define block (if inset?
                    (nested #:style 'code-inset tbl)
                    tbl))
  (if filename
      (filebox filename block)
      block))

(define (typeset-lang-inline/chunks lang chunks)
  (make-element #f (tokens->pieces lang (tokens-from-chunks lang chunks #:inline? #t))))

(define-for-syntax (chunks-template args-stx escape-id-stx)
  (for/list ([arg (in-list (syntax->list args-stx))])
    (syntax-parse arg
      [(esc e:expr)
       #:when (and (identifier? #'esc)
                   (free-identifier=? #'esc escape-id-stx))
       #`(cons 'escape e)]
      [_ #`(cons 'text #,arg)])))

(define-for-syntax (do-block stx lang inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:file filename-expr:expr)
                              #:defaults ([filename-expr #'#f])
                              #:name "#:file keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-block/chunks '#,lang
                                  #:file filename-expr
                                  #:indent indent-expr
                                  #:line-numbers line-numbers-expr
                                  #:line-number-sep line-number-sep-expr
                                  #:inset? #,inset?
                                  (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (css-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-inline/chunks 'css
                                   (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (html-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-inline/chunks 'html
                                   (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (js-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-inline/chunks 'js
                                   (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (cssblock0 stx) (do-block stx 'css #f))
(define-syntax (cssblock stx) (do-block stx 'css #t))
(define-syntax (htmlblock0 stx) (do-block stx 'html #f))
(define-syntax (htmlblock stx) (do-block stx 'html #t))
(define-syntax (jsblock0 stx) (do-block stx 'js #f))
(define-syntax (jsblock stx) (do-block stx 'js #t))

(module+ test
  (require rackunit)
  (define-syntax-rule (unsyntax e) e)
  (define-syntax-rule (UNQ e) e)
  (define-runtime-path fixtures-dir "test-fixtures")
  (define (read-fixture file)
    (file->string (build-path fixtures-dir file)))
  (define (classes lang src)
    (map car (tokenize lang src)))
  (check-true (block? (cssblock "h1 { color: red; }")))
  (check-true (block? (htmlblock "<h1 class=\"x\">Hi</h1>")))
  (check-true (block? (jsblock "const x = 1;")))
  (check-true (element? (css-code "h1 { color: red; }")))
  (check-true (element? (html-code "<h1 class=\"x\">Hi</h1>")))
  (check-true (element? (js-code "const x = 1;")))
  (check-not-false
   (member 'name (classes 'css "h1.title { color: #c33; --gap: 1.5rem; }")))
  (check-not-false
   (member 'value (classes 'css "h1.title { color: #c33; --gap: 1.5rem; }")))
  (check-not-false
   (member 'keyword (classes 'css "@media (min-width: 60rem) { .x { display: grid; } }")))
  (check-not-false
   (member 'keyword (classes 'html "<section id=main class=\"card\">Hi</section>")))
  (check-not-false
   (member 'name (classes 'html "<section id=main class=\"card\">Hi</section>")))
  (check-not-false
   (member 'value (classes 'html "<section id=main class=\"card\">Hi &amp; bye</section>")))
  (check-not-false
   (member 'comment (classes 'html "<!-- note -->")))
  (check-not-false
   (member 'keyword (classes 'js "const x = 1; if (x) { console.log(x); }")))
  (check-not-false
   (member 'comment (classes 'js "// hi\nconst x = 1;")))
  (check-true
   (element? (css-code "a { color: " (unsyntax (bold "red")) "; }")))
  (check-true
   (element? (css-code #:escape UNQ "a { color: " (UNQ (italic "red")) "; }")))
  (check-true
   (block? (htmlblock "<p>" (unsyntax (bold "hi")) "</p>")))
  (check-not-false
   (member 'name (classes 'css (read-fixture "css-basic.css"))))
  (check-not-false
   (member 'keyword (classes 'html (read-fixture "html-basic.html"))))
  (check-not-false
   (member 'keyword (classes 'html (read-fixture "html-script.html"))))
  (check-not-false
   (member 'comment (classes 'html (read-fixture "html-script.html"))))
  (check-true
   (block? (cssblock #:file "demo.css" ".x { color: red; }"))))
