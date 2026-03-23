#lang racket/base

;; css-highlight.rkt — View a CSS file with ANSI colours in the terminal.
;;
;; Usage:
;;   racket css-highlight.rkt <file.css>
;;   racket css-highlight.rkt              (reads from stdin)
;;
;; The tokenizer is extracted directly from lang-code.rkt; no Scribble
;; dependencies are needed here.

(require racket/string
         racket/port
         racket/set
         racket/match
         racket/list)

;; ─── ANSI helpers ────────────────────────────────────────────────────────────

(define (ansi . codes)
  (string-append "\033[" (string-join (map number->string codes) ";") "m"))

(define RESET (ansi 0))

;; Build a 24-bit truecolor foreground escape from a hex string like "#07A"
;; or "#262680".  3-digit shorthand is expanded to 6 digits first.
(define (rgb-fg hex)
  (define s (string-trim hex "#"))
  (define s6
    (if (= (string-length s) 3)
        (string-append (substring s 0 1) (substring s 0 1)
                       (substring s 1 2) (substring s 1 2)
                       (substring s 2 3) (substring s 2 3))
        s))
  (define r (string->number (substring s6 0 2) 16))
  (define g (string->number (substring s6 2 4) 16))
  (define b (string->number (substring s6 4 6) 16))
  (ansi 38 2 r g b))

;; Colours chosen to match the hex values used in lang-code.rkt.
(define COLOR-COMMENT (rgb-fg "#6A9955"))  ; green  — easy on the eyes for comments
(define COLOR-KEYWORD (rgb-fg "#07AACC"))  ; blue   — @-rules and selectors
(define COLOR-VALUE   (rgb-fg "#CE9178"))  ; amber  — values, numbers, strings, hex colours
(define COLOR-NAME    (rgb-fg "#9CDCFE"))  ; light blue — property names
(define COLOR-PUNCT   (rgb-fg "#808080"))  ; grey   — { } : ; ( ) , …
(define COLOR-PLAIN   "")                  ; use the terminal's default colour

(define (colorize code text)
  ;; Re-apply the colour escape after every newline so that multi-line tokens
  ;; (e.g. block comments) stay fully coloured even on terminals that reset
  ;; attributes at end-of-line.
  (if (or (string=? text "") (string=? code ""))
      text
      (let* ([lines  (string-split text "\n" #:trim? #f)]
             [joined (string-join lines (string-append RESET "\n" code))])
        (string-append code joined RESET))))

;; ─── CSS tokenizer (verbatim from lang-code.rkt) ─────────────────────────────

(define (read-while s start pred?)
  (let loop ([i start])
    (if (and (< i (string-length s)) (pred? (string-ref s i)))
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
         [escaped?        (loop (add1 k) #f)]
         [(char=? c #\\)  (loop (add1 k) #t)]
         [(char=? c q)    (add1 k)]
         [else            (loop (add1 k) #f)])])))

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
      (read-while s j2 (lambda (c) (or (char-alphabetic? c) (char=? c #\-))))))

(define (tokenize-css s)
  ;; Returns a list of (class . text) pairs where class is one of:
  ;;   'comment  'keyword  'value  'name  'punct  'plain
  (define len (string-length s))
  (let loop ([i 0]
             [mode 'selector]          ; 'selector or 'declaration
             [expect-property? #f]     ; #t right after { or ;
             [paren-depth 0]
             [acc null])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j
                     [new-mode mode]
                     [new-expect? expect-property?]
                     [new-depth paren-depth])
         (loop j new-mode new-expect? new-depth
               (cons (cons cls (substring s i j)) acc)))
       (cond
         ;; Block comment  /* … */
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\*))
          (emit 'comment (read-until s (+ i 2) "*/"))]
         ;; Quoted string
         [(or (char=? ch #\") (char=? ch #\'))
          (emit 'value (read-string-literal s i))]
         ;; Whitespace (preserve as-is)
         [(char-whitespace? ch)
          (emit 'plain (add1 i))]
         ;; @-rule keyword  (@media, @keyframes, …)
         [(char=? ch #\@)
          (emit 'keyword (read-while s (add1 i) css-ident-char?))]
         ;; Opening brace — enter declaration block
         [(char=? ch #\{)
          (emit 'punct (add1 i) 'declaration #t 0)]
         ;; Closing brace — back to selector context
         [(char=? ch #\})
          (emit 'punct (add1 i) 'selector #f 0)]
         ;; Colon — separator after a property name
         [(char=? ch #\:)
          (if (and (eq? mode 'declaration) expect-property?)
              (emit 'punct (add1 i) mode #f paren-depth)
              (emit 'punct (add1 i)))]
         ;; Semicolon — end of declaration
         [(char=? ch #\;)
          (if (and (eq? mode 'declaration) (zero? paren-depth))
              (emit 'punct (add1 i) mode #t paren-depth)
              (emit 'value (add1 i)))]
         ;; Opening paren — function call inside value
         [(char=? ch #\()
          (if (and (eq? mode 'declaration) (not expect-property?))
              (emit 'punct (add1 i) mode #f (add1 paren-depth))
              (emit 'punct (add1 i)))]
         ;; Closing paren
         [(char=? ch #\))
          (if (and (eq? mode 'declaration) (not expect-property?) (positive? paren-depth))
              (emit 'punct (add1 i) mode #f (sub1 paren-depth))
              (emit 'punct (add1 i)))]
         ;; Other punctuation / combinators
         [(member ch '(#\[ #\] #\, #\> #\+ #\~ #\* #\= #\|))
          (emit 'punct (add1 i))]
         ;; Hex colour literal  #rgb / #rrggbb / #rrggbbaa
         [(char=? ch #\#)
          (define j (read-while s (add1 i) hex-digit?))
          (if (and (> j (add1 i)) (<= 3 (- j (add1 i)) 8))
              (emit 'value j)
              (emit 'punct (add1 i)))]
         ;; Numeric literal (length, percentage, …)
         [(or (char-numeric? ch)
              (and (member ch '(#\+ #\-))
                   (< (add1 i) len)
                   (let ([c2 (string-ref s (add1 i))])
                     (or (char-numeric? c2) (char=? c2 #\.)))))
          (emit 'value (read-css-number s i))]
         ;; Identifier — class depends on position
         [(css-ident-start? ch)
          (define j (read-while s i css-ident-char?))
          (define cls
            (cond
              [(eq? mode 'selector) 'keyword]   ; tag / class / pseudo selector
              [expect-property?     'name]       ; property name
              [else                 'value]))    ; property value keyword
          (emit cls j)]
         ;; Anything else — pass through unstyled
         [else (emit 'plain (add1 i))])])))

;; ─── Colour swatch — detection (ported from lang-code.rkt) ──────────────────

(define css-color-keywords
  (list->set
   '("transparent" "currentcolor"
     "black" "white" "gray" "grey" "silver"
     "red" "green" "blue"
     "yellow" "orange" "purple" "pink" "brown"
     "cyan" "magenta" "lime" "teal" "navy" "olive" "maroon"
     "aqua" "fuchsia")))

(define css-color-functions
  (list->set
   '("rgb" "rgba" "hsl" "hsla" "hwb" "lab" "lch" "oklab" "oklch"
     "color" "color-mix" "device-cmyk" "light-dark")))

(define css-gradient-functions
  (list->set
   '("linear-gradient" "radial-gradient" "conic-gradient"
     "repeating-linear-gradient" "repeating-radial-gradient"
     "repeating-conic-gradient")))

(define (safe-css-color-literal? s)
  (and (regexp-match? #px"^[#(),.%+\\-/_a-zA-Z0-9\\s]+$" s)
       (not (regexp-match? #px";" s))))

(define (css-color-literal? s)
  (define down (string-downcase s))
  (or (set-member? css-color-keywords down)
      (regexp-match?
       #px"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$"
       s)))

;; Consume a colour/gradient function token group, returning the grouped tokens,
;; the remaining token list, the full function-call text, and the function name.
(define (consume-css-color-function tokens)
  (define first  (and (pair? tokens) (car tokens)))
  (define second (and (pair? (cdr tokens)) (cadr tokens)))
  (cond
    [(and first second
          (eq? (car first) 'value)
          (or (set-member? css-color-functions   (string-downcase (cdr first)))
              (set-member? css-gradient-functions (string-downcase (cdr first))))
          (eq? (car second) 'punct)
          (string=? (cdr second) "("))
     (define fn-name (string-downcase (cdr first)))
     (let loop ([rest (cddr tokens)]
                [depth 1]
                [taken-rev (list second first)])
       (cond
         [(null? rest) (values #f tokens #f #f)]
         [else
          (define t   (car rest))
          (define cls (car t))
          (define txt (cdr t))
          (define new-depth
            (cond
              [(and (eq? cls 'punct) (string=? txt "(")) (add1 depth)]
              [(and (eq? cls 'punct) (string=? txt ")")) (sub1 depth)]
              [else depth]))
          (define new-taken-rev (cons t taken-rev))
          (if (zero? new-depth)
              (let ([taken (reverse new-taken-rev)])
                (values taken
                        (cdr rest)
                        (apply string-append (map cdr taken))
                        fn-name))
              (loop (cdr rest) new-depth new-taken-rev))]))]
    [else (values #f tokens #f #f)]))

;; ─── Design-token colour table ───────────────────────────────────────────────

;; First pass: scan tokens for  --foo: <color-value> ;  declarations and return
;; a hash mapping custom-property name (string) → CSS colour text (string).
;; We look for the pattern:  name("--…")  punct(":")  …value tokens…  punct(";")
(define (build-token-color-table tokens)
  (let loop ([rest tokens] [table (hash)])
    (cond
      [(null? rest) table]
      [else
       (define t (car rest))
       (if (and (eq? (car t) 'name)
                (string-prefix? (cdr t) "--"))
           (let skip-to-value ([tail (cdr rest)])
             (cond
               [(null? tail)
                (loop tail table)]
               [(eq? (car (car tail)) 'plain)
                (skip-to-value (cdr tail))]
               [(and (eq? (car (car tail)) 'punct)
                     (string=? (cdr (car tail)) ":"))
                (let collect ([tail2 (cdr tail)] [values-rev null])
                  (cond
                    [(null? tail2)
                     (loop tail2 table)]
                    [(and (eq? (car (car tail2)) 'punct)
                          (member (cdr (car tail2)) '(";" "}")))
                     (let* ([value-text (string-trim
                                         (apply string-append
                                                (map cdr (reverse values-rev))))]
                            [new-table  (if (and (not (string=? value-text ""))
                                                (css-color->rgb value-text))
                                            (hash-set table (cdr t) value-text)
                                            table)])
                       (loop tail2 new-table))]
                    [else
                     (collect (cdr tail2) (cons (car tail2) values-rev))]))]
               [else
                (loop (cdr rest) table)]))
           (loop (cdr rest) table))])))


;; Walk the token list and insert a synthetic 'swatch token after every colour
;; literal, colour-function group, or var(--foo) reference whose token resolves
;; to a colour.  The cdr of a swatch token is the CSS colour text.
(define (insert-swatch-tokens tokens token-color-table)
  (let loop ([rest tokens] [acc null])
    (cond
      [(null? rest) (reverse acc)]
      [else
       (define-values (taken tail color-fn fn-name)
         (consume-css-color-function rest))
       (cond
         ;; Colour function like rgb(...) or hsl(...)
         [taken
          (define acc2 (append (reverse taken) acc))
          (if (and color-fn (safe-css-color-literal? color-fn))
              (loop tail (cons (cons 'swatch color-fn) acc2))
              (loop tail acc2))]
         [else
          (define t   (car rest))
          (define cls (car t))
          (define txt (cdr t))
          (cond
            ;; Bare colour literal like #0a66c2 or "red"
            [(and (eq? cls 'value)
                  (css-color-literal? txt)
                  (safe-css-color-literal? txt))
             (loop (cdr rest) (cons (cons 'swatch txt) (cons t acc)))]
            ;; var(--foo) — check if --foo resolves to a colour.
            ;; We skip over 'plain whitespace tokens when peeking ahead.
            [(and (eq? cls 'value)
                  (string=? (string-downcase txt) "var"))
             ;; Returns (values token remaining-list) skipping plain tokens.
             (define (next-nonplain lst)
               (let skip ([xs lst])
                 (cond
                   [(null? xs)          (values #f '())]
                   [(eq? (car (car xs)) 'plain) (skip (cdr xs))]
                   [else                (values (car xs) xs)])))
             (define-values (tok-open   rest-open)   (next-nonplain (cdr rest)))
             (define-values (tok-name   rest-name)   (next-nonplain (if (null? rest-open) '() (cdr rest-open))))
             (define-values (tok-close  rest-close)  (next-nonplain (if (null? rest-name) '() (cdr rest-name))))
             (define var-name
               (and tok-open tok-name
                    (eq? (car tok-open) 'punct) (string=? (cdr tok-open) "(")
                    (string-prefix? (cdr tok-name) "--")
                    (cdr tok-name)))
             (define color-text
               (and var-name (hash-ref token-color-table var-name #f)))
             (if color-text
                 ;; Consume everything up to and including the closing ")",
                 ;; keeping all tokens (including plain ones) in the output.
                 (let* ([close? (and tok-close
                                     (eq? (car tok-close) 'punct)
                                     (string=? (cdr tok-close) ")"))]
                        [consumed (if close?
                                      ;; tokens between (cdr rest) and rest-close inclusive
                                      (let eat ([xs (cdr rest)] [rev (list t)])
                                        (if (eq? xs rest-close)
                                            (reverse (cons (car xs) rev))
                                            (eat (cdr xs) (cons (car xs) rev))))
                                      ;; no closing paren found — just emit var as-is
                                      (list t))]
                        [tail*   (if close? (cdr rest-close) (cdr rest))])
                   (loop tail*
                         (cons (cons 'swatch color-text)
                               (append (reverse consumed) acc))))
                 (loop (cdr rest) (cons t acc)))]
            [else
             (loop (cdr rest) (cons t acc))])])])))

;; ─── Colour swatch — rendering ───────────────────────────────────────────────

;; Parse a CSS colour string into an (r g b) triplet (0-255), or #f on failure.

(define (clamp-byte x) (max 0 (min 255 (inexact->exact (round x)))))

;; Expand 3/4-digit hex to 6/8 digits, then extract r g b (ignore alpha).
(define (hex-color->rgb s)
  (define raw (string-trim s "#"))
  (define s6
    (case (string-length raw)
      [(3 4) (string-append
              (substring raw 0 1) (substring raw 0 1)
              (substring raw 1 2) (substring raw 1 2)
              (substring raw 2 3) (substring raw 2 3))]
      [(6 8) (substring raw 0 6)]
      [else  #f]))
  (and s6
       (let ([r (string->number (substring s6 0 2) 16)]
             [g (string->number (substring s6 2 4) 16)]
             [b (string->number (substring s6 4 6) 16)])
         (and r g b (list r g b)))))

;; Hue-to-RGB helper used by hsl->rgb.
(define (hue->channel p q t)
  (define t* (cond [(< t 0) (+ t 1)] [(> t 1) (- t 1)] [else t]))
  (cond
    [(< t* 1/6) (+ p (* (- q p) 6 t*))]
    [(< t* 1/2) q]
    [(< t* 2/3) (+ p (* (- q p) (- 2/3 t*) 6))]
    [else        p]))

(define (hsl->rgb h-deg s-pct l-pct)
  (define h (/ h-deg 360.0))
  (define s (/ s-pct 100.0))
  (define l (/ l-pct 100.0))
  (if (zero? s)
      (let ([v (clamp-byte (* l 255))])
        (list v v v))
      (let* ([q (if (< l 0.5) (* l (+ 1 s)) (- (+ l s) (* l s)))]
             [p (- (* 2 l) q)])
        (list (clamp-byte (* 255 (hue->channel p q (+ h 1/3))))
              (clamp-byte (* 255 (hue->channel p q h)))
              (clamp-byte (* 255 (hue->channel p q (- h 1/3))))))))

;; Parse numbers out of a function argument string like "10, 20%, 30".
(define (parse-css-numbers s)
  (map string->number
       (regexp-match* #px"[+-]?[0-9]*\\.?[0-9]+" s)))

;; Named colour table (subset matching css-color-keywords above).
(define named-colors
  (hash "black"        '(0   0   0)
        "white"        '(255 255 255)
        "red"          '(255 0   0)
        "green"        '(0   128 0)
        "blue"         '(0   0   255)
        "yellow"       '(255 255 0)
        "orange"       '(255 165 0)
        "purple"       '(128 0   128)
        "pink"         '(255 192 203)
        "brown"        '(165 42  42)
        "cyan"         '(0   255 255)
        "magenta"      '(255 0   255)
        "lime"         '(0   255 0)
        "teal"         '(0   128 128)
        "navy"         '(0   0   128)
        "olive"        '(128 128 0)
        "maroon"       '(128 0   0)
        "aqua"         '(0   255 255)
        "fuchsia"      '(255 0   255)
        "gray"         '(128 128 128)
        "grey"         '(128 128 128)
        "silver"       '(192 192 192)))

;; Top-level: try to resolve any CSS colour string to (r g b), else #f.
(define (css-color->rgb text)
  (define s (string-trim text))
  (define down (string-downcase s))
  (cond
    ;; Named colour
    [(hash-ref named-colors down #f)]
    ;; Transparent / currentcolor — skip swatch
    [(member down '("transparent" "currentcolor")) #f]
    ;; Hex literal
    [(regexp-match? #px"^#" s) (hex-color->rgb s)]
    ;; rgb() / rgba()
    [(regexp-match? #px"(?i:^rgba?\\()" s)
     (define nums (parse-css-numbers s))
     (and (>= (length nums) 3)
          (map clamp-byte (take nums 3)))]
    ;; hsl() / hsla()
    [(regexp-match? #px"(?i:^hsla?\\()" s)
     (define nums (parse-css-numbers s))
     (and (>= (length nums) 3)
          (apply hsl->rgb (take nums 3)))]
    [else #f]))

;; Render a colour swatch: a space with the colour as background,
;; flanked by thin grey brackets so it is visible against any background.
(define (swatch-string r g b)
  (define fg (ansi 38 2 r g b))
  (string-append " " fg "█" RESET))

;; ─── Renderer ────────────────────────────────────────────────────────────────

(define (color-for cls)
  (case cls
    [(comment) COLOR-COMMENT]
    [(keyword) COLOR-KEYWORD]
    [(value)   COLOR-VALUE]
    [(name)    COLOR-NAME]
    [(punct)   COLOR-PUNCT]
    [else      COLOR-PLAIN]))

;; ─── Value alignment ─────────────────────────────────────────────────────────

;; Within each { ... } block, find the column position of each property value
;; (i.e. the width of "  property-name: ") and pad the shorter ones so all
;; values start at the same column.
;;
;; Strategy: work on the flat token list.  We locate each declaration block
;; (tokens between matching { and }) and within it find every
;;   name  plain*  punct(":")  plain*  <value starts here>
;; sequence.  We measure "name + plain before colon + colon + plain after colon"
;; as the prefix width, find the max, then insert extra plain padding after the
;; colon of the shorter ones.

(define (align-tokens tokens)
  ;; Split the token list into segments separated by block boundaries.
  ;; Each block is processed independently; non-block tokens pass through.
  (let loop ([rest tokens] [acc '()])
    (cond
      [(null? rest)
       (reverse acc)]
      ;; Opening brace — collect the block and align it
      [(and (eq? (car (car rest)) 'punct)
            (string=? (cdr (car rest)) "{"))
       (define open-tok (car rest))
       ;; Collect tokens up to and including the matching "}"
       (let gather ([tail (cdr rest)] [block-rev '()] [depth 1])
         (cond
           [(null? tail)
            ;; Unmatched brace — emit as-is
            (loop tail (append (reverse block-rev) (cons open-tok acc)))]
           [(and (eq? (car (car tail)) 'punct) (string=? (cdr (car tail)) "{"))
            (gather (cdr tail) (cons (car tail) block-rev) (add1 depth))]
           [(and (eq? (car (car tail)) 'punct) (string=? (cdr (car tail)) "}"))
            (if (= depth 1)
                ;; Found the matching close — align the block contents
                (let* ([close-tok  (car tail)]
                       [block      (reverse block-rev)]
                       [aligned    (align-block block)])
                  (loop (cdr tail)
                        (append (list close-tok)
                                (reverse aligned)
                                (cons open-tok acc))))
                (gather (cdr tail) (cons (car tail) block-rev) (sub1 depth)))]
           [else
            (gather (cdr tail) (cons (car tail) block-rev) depth)]))]
      [else
       (loop (cdr rest) (cons (car rest) acc))])))

;; Given the tokens inside one { } block (not including the braces),
;; return a new token list with values aligned.
;; Declarations are aligned independently within each comment-separated group.
(define (align-block block)

  ;; Split block into declarations (separated by ";").
  (define (split-decls tokens)
    (let split ([rest tokens] [cur '()] [acc '()])
      (cond
        [(null? rest)
         (reverse (if (null? cur) acc (cons (reverse cur) acc)))]
        [(and (eq? (car (car rest)) 'punct)
              (string=? (cdr (car rest)) ";"))
         (split (cdr rest)
                '()
                (cons (list (car rest))
                      (cons (reverse cur) acc)))]
        [else
         (split (cdr rest) (cons (car rest) cur) acc)])))

  ;; For each declaration, find the property name and measure prefix width.
  ;; Returns #f if the declaration has no alignable colon.
  (define (decl-info decl)
    (let scan ([rest decl] [pre-width 0])
      (match rest
        ['() #f]
        [(cons (cons 'plain s) tail)
         (define new-pre
           (let ([m (regexp-match-positions #rx"(?s:.*)\n" s)])
             (if m
                 (- (string-length s) (cdar m))
                 (+ pre-width (string-length s)))))
         (scan tail new-pre)]
        [(cons (cons 'comment _) tail)
         (scan tail 0)]
        [(cons (cons 'name name-str) tail)
         ;; Only measure name-width + colon + post-colon space.
         ;; pre-width (indentation) is the same for all decls and excluded.
         (let scan2 ([rest2 tail] [name-w (string-length name-str)])
           (match rest2
             ['() #f]
             [(cons (cons 'plain s) tail2)
              (scan2 tail2 (+ name-w (string-length s)))]
             [(cons (cons 'punct ":") tail2)
              (let scan3 ([rest3 tail2] [post-w 0])
                (match rest3
                  [(cons (cons 'plain s) tail3)
                   (scan3 tail3 (+ post-w (string-length s)))]
                  [_
                   ;; prefix = name-w + 1 (colon) + post-w  (no pre-width)
                   (list (+ name-w 1) post-w rest3)]))]
             [_ #f]))]
        [_ #f])))

  ;; Align a flat list of decl-tokens against each other.
  (define (align-decl-group decls)
    (define infos (map decl-info decls))
    (define max-prefix
      (for/fold ([m 0]) ([info infos])
        (if info (max m (first info)) m)))
    (define (rebuild-decl decl info)
      (if (not info)
          decl
          (let* ([prefix-w (first info)]
                 [extra    (- max-prefix prefix-w)]
                 [new-post (+ 1 extra)])  ; 1 minimum space + alignment padding
            (let rebuild ([rest decl] [pre '()])
              (match rest
                ['() (reverse pre)]
                [(cons (cons 'punct ":") tail)
                 (let drop ([tail2 tail])
                   (match tail2
                     [(cons (cons 'plain _) tail3) (drop tail3)]
                     [_
                      (append (reverse (cons (cons 'punct ":") pre))
                              (list (cons 'plain (make-string new-post #\space)))
                              tail2)]))]
                [(cons t tail)
                 (rebuild tail (cons t pre))])))))
    ;; After colon-alignment, right-align numeric parts within runs of
    ;; adjacent single-number+unit values sharing the same unit.
    (define (right-align-numbers aligned-decls)
      ;; Extract the single value token from a declaration if it is
      ;; exactly one number+unit token (e.g. "2px", "1.5rem"), else #f.
      ;; Returns (num-str . unit-str) or #f.
      (define css-length-rx #rx"^([+-]?[0-9]*\\.?[0-9]+)(px|rem|em|%|vw|vh|vmin|vmax|pt|pc|cm|mm|in|q|ch|ex|s|ms)$")
      (define (decl-single-length decl)
        ;; Find value tokens after the colon; return #f if not exactly one length.
        (let find-colon ([rest decl] [found-colon? #f] [values '()])
          (cond
            [(null? rest)
             (if (and found-colon? (= (length values) 1))
                 (let ([m (regexp-match css-length-rx (cdr (car values)))])
                   (and m (cons (cadr m) (caddr m))))
                 #f)]
            [(not (pair? (car rest)))
             (find-colon (cdr rest) found-colon? values)]
            [else
             (define t   (car rest))
             (define cls (car t))
             (define txt (cdr t))
             (cond
               [(not found-colon?)
                (if (and (eq? cls 'punct) (string=? txt ":"))
                    (find-colon (cdr rest) #t values)
                    (find-colon (cdr rest) #f values))]
               [(eq? cls 'plain)  (find-colon (cdr rest) #t values)]
               [(eq? cls 'punct)  #f]
               [else              (find-colon (cdr rest) #t (cons t values))])])))

      ;; Replace the value token text in a declaration.
      (define (replace-value-text decl old-text new-text)
        (map (lambda (t)
               (if (and (eq? (car t) 'value) (string=? (cdr t) old-text))
                   (cons 'value new-text)
                   t))
             decl))

      ;; Process runs of adjacent decls with same unit.
      ;; Returns a flat token list.
      (define result-decls
        (let run-loop ([rest aligned-decls] [acc '()])
          (cond
            [(null? rest) (reverse acc)]
            [else
             (define first-info (decl-single-length (car rest)))
             (if (not first-info)
                 (run-loop (cdr rest) (cons (car rest) acc))
                 (let* ([unit     (cdr first-info)]
                        [run+tail (let gather ([xs rest] [r '()])
                                    (cond
                                      [(null? xs) (cons (reverse r) xs)]
                                      [(and (= (length (car xs)) 1) (eq? (caar xs) 'punct))
                                       ;; Skip semicolon-only separator decls
                                       (gather (cdr xs) r)]
                                      [else
                                       (define i (decl-single-length (car xs)))
                                       (if (and i (string=? (cdr i) unit))
                                           (gather (cdr xs) (cons (car xs) r))
                                           (cons (reverse r) xs))]))]
                        [run      (car run+tail)]
                        [run-tail (cdr run+tail)])
                   (if (= (length run) 1)
                       (run-loop (cdr rest) (cons (car rest) acc))
                       (let* ([infos  (map decl-single-length run)]
                              [nums   (map car infos)]
                              [max-w  (apply max (map string-length nums))]
                              [padded (map (lambda (decl info)
                                            (define num (car info))
                                            (define unt (cdr info))
                                            (define pad (make-string (- max-w (string-length num)) #\space))
                                            (define old (string-append num unt))
                                            (define new (string-append pad num unt))
                                            (replace-value-text decl old new))
                                          run infos)])
                         (run-loop run-tail (append (reverse padded) acc))))))])))
      (append-map (lambda (x) x) result-decls))
    (define aligned-decls (map rebuild-decl decls infos))
    (right-align-numbers aligned-decls))

  ;; Split block into comment-separated groups, align each independently.
  ;; A "group boundary" is any declaration that contains a comment token.
  (define (contains-comment? decl)
    (ormap (lambda (t) (eq? (car t) 'comment)) decl))

  (let group-loop ([decls (split-decls block)] [cur-group '()] [acc '()])
    (cond
      [(null? decls)
       (append acc (align-decl-group (reverse cur-group)))]
      [(contains-comment? (car decls))
       ;; Flush the current group, then start a new one with this decl
       (define flushed (align-decl-group (reverse cur-group)))
       (group-loop (cdr decls)
                   (list (car decls))
                   (append acc flushed))]
      [else
       (group-loop (cdr decls)
                   (cons (car decls) cur-group)
                   acc)])))

(define (tokens->ansi tokens [align? #f])
  (define table (build-token-color-table tokens))
  (define tokens* (if align? (align-tokens tokens) tokens))
  (apply string-append
         (for/list ([tok (in-list (insert-swatch-tokens tokens* table))])
           (define cls (car tok))
           (define txt (cdr tok))
           (cond
             [(eq? cls 'swatch)
              (define rgb (css-color->rgb txt))
              (if rgb
                  (apply swatch-string rgb)
                  "")]
             [else
              (colorize (color-for cls) txt)]))))

;; ─── Entry point ─────────────────────────────────────────────────────────────

(define (highlight-port port [align? #f])
  (display (tokens->ansi (tokenize-css (port->string port)) align?)))

(module+ test
  (define src
    (string-append
     "html.we-theme-light {\n"
     "  /* Focus ring color. */\n"
     "  --we-focus:      #0a66c2;\n"
     "  /* Focus tint. */\n"
     "  --we-focus-tint: rgba(10, 102, 194, 0.20);\n"
     "  /* Main text. */\n"
     "  --we-fg:         #1a1f2b;\n"
     "}\n"))
  (define tokens (tokenize-css src))
  (displayln "=== tokens ===")
  (for ([t tokens]) (displayln t))
  (displayln "\n=== color table ===")
  (define table (build-token-color-table tokens))
  (displayln table)
  (displayln "\n=== after align ===")
  (for ([t (align-tokens tokens)]) (displayln t)))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  (define align? (member "--align" args))
  (define files  (filter (lambda (a) (not (string=? a "--align"))) args))
  (cond
    [(null? files)
     (highlight-port (current-input-port) align?)]
    [(null? (cdr files))
     (define path (car files))
     (unless (file-exists? path)
       (eprintf "css-highlight: file not found: ~a\n" path)
       (exit 1))
     (call-with-input-file path (lambda (p) (highlight-port p align?)))]
    [else
     (eprintf "Usage: racket css-highlight.rkt [--align] [file.css]\n")
     (exit 1)]))
