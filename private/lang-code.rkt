#lang racket/base

(require racket/list
         racket/set
         racket/string
         racket/file
         racket/runtime-path
         "lexers-adapter.rkt"
         (only-in lexers/c
                  c-derived-token-has-tag?
                  c-derived-token-text
                  c-derived-token-start
                  c-derived-token-end
                  c-string->tokens
                  c-string->derived-tokens)
         (only-in lexers/cpp
                  cpp-derived-token-has-tag?
                  cpp-derived-token-text
                  cpp-derived-token-start
                  cpp-derived-token-end
                  cpp-string->tokens
                  cpp-string->derived-tokens)
         (only-in lexers/css
                  css-derived-token-has-tag?
                  css-derived-token-text
                  css-string->derived-tokens)
         (only-in lexers/csv csv-string->tokens)
         (only-in lexers/go
                  go-derived-token-has-tag?
                  go-derived-token-text
                  go-derived-token-start
                  go-derived-token-end
                  go-string->tokens
                  go-string->derived-tokens)
         (only-in lexers/haskell
                  haskell-derived-token-has-tag?
                  haskell-derived-token-text
                  haskell-derived-token-start
                  haskell-derived-token-end
                  haskell-string->tokens
                  haskell-string->derived-tokens)
         (only-in lexers/html
                  html-derived-token-has-tag?
                  html-derived-token-text
                  html-string->derived-tokens)
         (only-in lexers/javascript
                  javascript-derived-token-has-tag?
                  javascript-derived-token-text
                  javascript-string->derived-tokens)
         (only-in lexers/json json-string->tokens)
         (only-in lexers/java
                  java-derived-token-has-tag?
                  java-derived-token-text
                  java-derived-token-start
                  java-derived-token-end
                  java-string->tokens
                  java-string->derived-tokens)
         (only-in lexers/makefile
                  makefile-derived-token-has-tag?
                  makefile-derived-token-text
                  makefile-string->derived-tokens)
         (only-in lexers/mathematica
                  mathematica-derived-token-has-tag?
                  mathematica-derived-token-text
                  mathematica-string->tokens
                  mathematica-string->derived-tokens)
         (only-in lexers/markdown
                  markdown-string->tokens
                  markdown-string->derived-tokens
                  markdown-derived-token-has-tag?
                  markdown-derived-token-text
                  markdown-derived-token-start
                  markdown-derived-token-end)
         (only-in lexers/python
                  python-derived-token-has-tag?
                  python-derived-token-text
                  python-derived-token-start
                  python-derived-token-end
                  python-string->derived-tokens)
         (only-in lexers/objc
                  objc-derived-token-has-tag?
                  objc-derived-token-text
                  objc-derived-token-start
                  objc-derived-token-end
                  objc-string->tokens
                  objc-string->derived-tokens)
         (only-in lexers/pascal
                  pascal-derived-token-has-tag?
                  pascal-derived-token-text
                  pascal-derived-token-start
                  pascal-derived-token-end
                  pascal-string->tokens
                  pascal-string->derived-tokens)
         (only-in lexers/plist
                  plist-derived-token-has-tag?
                  plist-derived-token-text
                  plist-derived-token-start
                  plist-derived-token-end
                  plist-string->tokens
                  plist-string->derived-tokens)
         (only-in lexers/scribble
                  scribble-derived-token-has-tag?
                  scribble-derived-token-start
                  scribble-derived-token-end
                  scribble-derived-token-text
                  scribble-string->derived-tokens)
         (only-in lexers/racket racket-string->tokens)
         (only-in lexers/ruby
                  ruby-derived-token-has-tag?
                  ruby-derived-token-text
                  ruby-derived-token-start
                  ruby-derived-token-end
                  ruby-string->derived-tokens)
         (only-in lexers/rhombus rhombus-string->tokens)
         (only-in lexers/rust rust-string->tokens)
         (only-in lexers/sql
                  sql-derived-token-has-tag?
                  sql-derived-token-text
                  sql-derived-token-start
                  sql-derived-token-end
                  sql-string->derived-tokens)
         lexers/shell
         (only-in lexers/swift
                  swift-derived-token-has-tag?
                  swift-derived-token-text
                  swift-derived-token-start
                  swift-derived-token-end
                  swift-string->tokens
                  swift-string->derived-tokens)
         (only-in lexers/tex
                  tex-derived-token-has-tag?
                  tex-derived-token-text
                  tex-derived-token-start
                  tex-derived-token-end
                  tex-string->tokens
                  tex-string->derived-tokens)
         (only-in lexers/latex latex-string->tokens)
         (only-in lexers/latex
                  latex-derived-token-has-tag?
                  latex-derived-token-text
                  latex-derived-token-start
                  latex-derived-token-end
                  latex-string->derived-tokens)
         syntax-color/scribble-lexer
         (only-in lexers/tsv tsv-string->tokens)
         lexers/token
         lexers/wat
         (only-in lexers/yaml
                  yaml-derived-token-has-tag?
                  yaml-derived-token-text
                  yaml-derived-token-start
                  yaml-derived-token-end
                  yaml-string->tokens
                  yaml-string->derived-tokens)
         "mdn-map.rkt"
         "cppreference-docs-map.rkt"
         "latex-docs-map.rkt"
         "go-docs-map.rkt"
         "java-docs-map.rkt"
         "pascal-docs-map.rkt"
         "racket-standard-map.rkt"
         "ruby-docs-map.rkt"
         "rust-docs-map.rkt"
         "rustdoc-docs-map.rkt"
         "wasm-spec-map.rkt"
         "shell-docs-map.rkt"
         scribble/base
         scribble/core
         scribble/html-properties
         (only-in scribble/manual filebox typeset-code)
         scribble/racket
         (for-syntax racket/base
                     syntax/parse))

(provide css-code
         c-code
         cpp-code
         makefile-code
         tex-code
         latex-code
         objc-code
         haskell-code
         pascal-code
         plist-code
         csv-code
         go-code
         html-code
         java-code
         mathematica-code
         js-code
         json-code
         markdown-code
         python-code
         racket-code
         rhombus-code
         rust-code
         ruby-code
         swift-code
         sql-code
         sqlite-code
         mysql-code
         postgres-code
         wasm-code
         shell-code
         scribble-code
         tsv-code
         yaml-code
         cssblock
         cblock
         cppblock
         makefileblock
         texblock
         latexblock
         objcblock
         haskellblock
         pascalblock
         plistblock
         csvblock
         goblock
         htmlblock
         javablock
         mathematicablock
         jsblock
         jsonblock
         markdownblock
         pythonblock
         racketblock
         rhombusblock
         rustblock
         rubyblock
         swiftblock
         sqlblock
         sqliteblock
         mysqlblock
         postgresblock
         wasmblock
         shellblock
         scribbleblock
         tsvblock
         yamlblock
         cssblock0
         cblock0
         cppblock0
         makefileblock0
         texblock0
         latexblock0
         objcblock0
         haskellblock0
         pascalblock0
         plistblock0
         csvblock0
         goblock0
         htmlblock0
         javablock0
         mathematicablock0
         jsblock0
         jsonblock0
         markdownblock0
         pythonblock0
         racketblock0
         rhombusblock0
         rustblock0
         rubyblock0
         swiftblock0
         sqlblock0
         sqliteblock0
         mysqlblock0
         postgresblock0
         wasmblock0
         shellblock0
         scribbleblock0
         tsvblock0
         yamlblock0
         code->sxml
         code-block->sxml
         code->html
         code-block->html
         code->scribble
         code-block->scribble
         code->scribble/legacy
         code-block->scribble/legacy
         code-html-support-sxml
         code-html-support
         raw-sxml
         raw-sxml?
         raw-sxml-value
         raw-html
         raw-html?
         raw-html-value
         current-wasm-docs-source
         current-scribble-context
         current-scribble-shell
         current-shell-docs-source)

(define omitable (make-style #f '(omitable)))
;; Dedicated style for HTML tag names; do not rely on .RktSym/.RktKw theme mappings.
(define html-tag-color
  (make-style #f (list (attributes '((style . "color: #07A;"))))))
(define js-keyword-color
  (make-style #f (list (attributes '((style . "color: #07A;"))))))
(define js-name-color
  (make-style #f (list (attributes '((style . "color: #262680;"))))))
(define js-decl-name-color
  (make-style #f (list (attributes '((style . "color: #795E26;"))))))
(define js-operator-color
  (make-style #f (list (attributes '((style . "color: #8A4F00;"))))))
(define js-object-key-color
  (make-style #f (list (attributes '((style . "color: #1F5F8B;"))))))
(define js-param-name-color
  (make-style #f (list (attributes '((style . "color: #264F78;"))))))
(define js-prop-name-color
  (make-style #f (list (attributes '((style . "color: #5A3E8E;"))))))
(define js-method-name-color
  (make-style #f (list (attributes '((style . "color: #6B2F8A;"))))))
(define js-private-name-color
  (make-style #f (list (attributes '((style . "color: #AF00DB;"))))))
(define js-static-keyword-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #07A;"))))))
(define c-type-name-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #2B5F8A;"))))))
(define racket-builtin-color
  (make-style #f (list (attributes '((style . "color: #795E26;"))))))
(define css-keyword-color
  (make-style #f (list (attributes '((style . "color: #07A;"))))))
(define css-name-color
  (make-style #f (list (attributes '((style . "color: #262680;"))))))
(define markdown-heading-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #7A1F5C;"))))))
(define markdown-heading-1-color
  (make-style #f (list (attributes '((style . "font-weight: 700; color: #8B1E3F;"))))))
(define markdown-heading-2-color
  (make-style #f (list (attributes '((style . "font-weight: 700; color: #7A1F5C;"))))))
(define markdown-heading-3-color
  (make-style #f (list (attributes '((style . "font-weight: 700; color: #5F3B8A;"))))))
(define markdown-heading-4-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #2E5C88;"))))))
(define markdown-heading-5-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #2F6F3E;"))))))
(define markdown-heading-6-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #8A4F00;"))))))
(define makefile-target-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #07A;"))))))
(define makefile-command-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #795E26;"))))))
(define makefile-option-color
  (make-style #f (list (attributes '((style . "color: #098658;"))))))
(define makefile-variable-color
  (make-style #f (list (attributes '((style . "color: #6B2F8A;"))))))
(define makefile-operator-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #A15C00;"))))))
(define makefile-punct-color
  (make-style #f (list (attributes '((style . "color: #7A6A4A;"))))))
(define tex-command-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #7A1F5C;"))))))
(define tex-name-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #0B62A3;"))))))
(define tex-operator-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #A15C00;"))))))
(define tex-value-color
  (make-style #f (list (attributes '((style . "color: #2F6F3E; background-color: rgba(47,111,62,.08); border-radius: .18em;"))))))
(define wasm-form-color
  (make-style #f (list (attributes '((style . "color: #0B62A3;"))))))
(define wasm-type-color
  (make-style #f (list (attributes '((style . "color: #795E26;"))))))
(define wasm-instr-color
  (make-style #f (list (attributes '((style . "color: #6B2F8A;"))))))
(define wasm-id-color
  (make-style #f (list (attributes '((style . "color: #2F6F3E;"))))))
(define mdn-link-style
  (make-style #f (list (attributes '((class . "mdn-code-link")
                                     (style . "color: inherit; text-decoration: none;"))))))
;; Wrapper/source styles for block copy button UI.
(define copy-wrap-style
  (make-style #f (list (attributes '((class . "scribble-copy-wrap")
                                     (data-copy-button . "on"))))))
(define copy-source-style
  (make-style #f (list (attributes '((class . "scribble-copy-source")
                                     (style . "display: none; white-space: pre;"))))))
(define code-inset-tab-style
  (make-style 'code-inset
              (list (attributes '((style . "tab-size: 2; -moz-tab-size: 2;"))))))
(define highlighted-line-style
  (make-style #f
              (list 'omitable
                    (attributes '((class . "stx-line-highlight")
                                  (style . "background-color: rgba(255, 214, 102, .22);"))))))
(define inline-code-font-style
  ;; Ensure inline snippets inherit the same monospace face as Racket docs.
  ;; This keeps tokens with custom color-only styles in Fira Mono, too.
  (make-style #f (list (attributes '((class . "RktBlk"))))))

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
     "repeating-linear-gradient" "repeating-radial-gradient" "repeating-conic-gradient")))

(define c-family-builtin-type-names
  (list->set
   '("void" "char" "short" "int" "long" "float" "double" "signed" "unsigned"
     "_Bool" "_Complex" "_Imaginary" "bool" "wchar_t" "char8_t" "char16_t"
     "char32_t" "auto")))

(define c-family-common-type-names
  (list->set
   '("FILE" "size_t" "ptrdiff_t" "wint_t" "fpos_t" "va_list" "tm" "clock_t"
     "time_t" "max_align_t" "mbstate_t" "div_t" "ldiv_t" "lldiv_t"
     "intptr_t" "uintptr_t" "intmax_t" "uintmax_t"
     "int8_t" "int16_t" "int32_t" "int64_t"
     "uint8_t" "uint16_t" "uint32_t" "uint64_t"
     "int_least8_t" "int_least16_t" "int_least32_t" "int_least64_t"
     "uint_least8_t" "uint_least16_t" "uint_least32_t" "uint_least64_t"
     "int_fast8_t" "int_fast16_t" "int_fast32_t" "int_fast64_t"
     "uint_fast8_t" "uint_fast16_t" "uint_fast32_t" "uint_fast64_t")))

(define cpp-common-type-names
  (list->set
   '("string" "wstring" "u8string" "u16string" "u32string" "string_view"
     "vector" "array" "deque" "list" "forward_list" "map" "multimap"
     "unordered_map" "unordered_multimap" "set" "multiset"
     "unordered_set" "unordered_multiset" "optional" "variant" "tuple"
     "pair" "span" "unique_ptr" "shared_ptr" "weak_ptr" "function"
     "any" "expected" "queue" "stack" "priority_queue")))

(define c-family-type-introducers
  (list->set '("struct" "union" "enum" "class" "typename" "@interface" "@protocol")))

(define go-builtin-type-names
  (list->set
   '("bool" "byte" "complex64" "complex128" "error" "float32" "float64"
     "int" "int8" "int16" "int32" "int64" "rune" "string"
     "uint" "uint8" "uint16" "uint32" "uint64" "uintptr"
     "any" "comparable")))

(define go-common-type-names
  (list->set
   '("Context" "CancelFunc" "Buffer" "Reader" "Writer"
     "Time" "Duration" "Ticker" "Timer"
     "Request" "Response" "Handler" "Client"
     "Decoder" "Encoder" "RawMessage"
     "Regexp" "Template"
     "WaitGroup" "Mutex" "RWMutex"
     "Scanner" "File" "URL")))

(define pascal-builtin-type-names
  (list->set
   '("integer" "boolean" "string" "char" "real" "byte" "word"
     "shortint" "smallint" "longint" "int64"
     "cardinal" "longword" "qword"
     "single" "double" "extended" "comp" "currency"
     "ansistring" "widestring" "unicodestring"
     "pchar" "pointer" "text" "textfile" "file")))

(define swift-builtin-type-names
  (list->set
   '("String" "Substring" "Character"
     "Int" "Int8" "Int16" "Int32" "Int64"
     "UInt" "UInt8" "UInt16" "UInt32" "UInt64"
     "Float" "Double" "CGFloat"
     "Bool" "Void" "Any" "AnyObject" "Never"
     "Array" "Dictionary" "Set" "Optional" "Result"
     "URL" "Data" "Date" "UUID" "Error" "Self")))

(define rust-builtin-type-names
  (list->set
   '("i8" "i16" "i32" "i64" "i128"
     "u8" "u16" "u32" "u64" "u128"
     "isize" "usize"
     "f32" "f64"
     "bool" "char" "str" "String"
     "Vec" "Option" "Result"
     "HashMap" "HashSet" "BTreeMap" "BTreeSet"
     "Box" "Rc" "Arc" "Self")))

(define css-spacing-properties
  (list->set
   '("margin" "margin-top" "margin-right" "margin-bottom" "margin-left"
     "padding" "padding-top" "padding-right" "padding-bottom" "padding-left"
     "gap" "row-gap" "column-gap"
     "letter-spacing" "word-spacing" "outline-offset" "text-indent")))

(define css-blur-properties
  (list->set '("filter" "backdrop-filter")))

(define wasm-form-keywords
  (list->set
   '("module" "func" "param" "result"
     "local" "global" "memory" "table" "type"
     "import" "export" "data" "elem" "start"
     "offset" "align" "mut")))

(define wasm-type-keywords
  (list->set
   '("i32" "i64" "f32" "f64" "v128" "funcref" "externref")))

(define wasm-instruction-keywords
  (list->set
   '("block" "loop" "if" "then" "else" "end"
     "call" "call_indirect" "return" "drop" "select"
     "unreachable" "nop" "br" "br_if" "br_table"
     "local.get" "local.set" "local.tee"
     "global.get" "global.set")))

(define shell-keywords/common
  (list->set
   '("if" "then" "elif" "else" "fi"
     "for" "while" "until" "do" "done"
     "case" "in" "esac" "select"
     "function" "time" "coproc")))

(define shell-builtins/common
  (list->set
   '("cd" "echo" "printf" "read"
     "export" "unset" "readonly"
     "alias" "unalias"
     "set" "shift" "test" "source"
     "." "eval" "exec" "exit" "return")))

(define shell-builtins/zsh
  (list->set
   '("autoload" "setopt" "unsetopt" "emulate" "typeset" "local" "zmodload")))

(define shell-keywords/powershell
  (list->set
   '("if" "elseif" "else" "switch"
     "for" "foreach" "while" "do" "until"
     "break" "continue"
     "function" "filter" "param"
     "begin" "process" "end"
     "return" "throw" "try" "catch" "finally" "trap"
     "class" "enum" "using")))

(define current-preview-css-url (make-parameter #f))
(define current-preview-tooltips? (make-parameter #t))
(define current-jsx? (make-parameter #f))
(define current-js-template-depth (make-parameter 0))
(define current-wasm-docs-source (make-parameter 'wasm-spec-3.0))
(define current-scribble-context (make-parameter #f))
(define current-scribble-shell (make-parameter 'bash))
(define current-shell-docs-source (make-parameter 'auto))
(define current-html-style-color-swatch? (make-parameter #t))
(define current-html-style-font-preview? (make-parameter #t))
(define current-html-style-dimension-preview? (make-parameter #t))
(define current-html-style-preview-mode (make-parameter 'always))
(define current-html-script-preview? (make-parameter #t))

(define (normalize-wasm-docs-source who v)
  (cond
    [(memq v '(wasm-spec-3.0 mdn none)) v]
    [else
     (raise-argument-error who
                           "(or/c 'wasm-spec-3.0 'mdn 'none)"
                           v)]))

(define (normalize-scribble-shell who v)
  (cond
    [(eq? v 'pwsh) 'powershell]
    [(memq v '(bash zsh powershell)) v]
    [else
     (raise-argument-error who
                           "(or/c 'bash 'zsh 'powershell 'pwsh)"
                           v)]))

(define (preview-url-attrs)
  (define u (current-preview-css-url))
  (if (and (string? u) (not (string=? (string-trim u) "")))
      `((data-preview-css-url . ,u))
      null))

(define (preview-tooltip-attrs label)
  (if (current-preview-tooltips?)
      `((data-preview-tooltips . "on")
        (data-preview-title . ,label)
        (title . ,label)
        (role . "img")
        (aria-label . ,label)
        (tabindex . "0"))
      `((data-preview-tooltips . "off")
        (aria-hidden . "true")
        (tabindex . "-1"))))

(define (safe-css-color-literal? s)
  (and (regexp-match? #px"^[#(),.%+\\-/_a-zA-Z0-9\\s]+$" s)
       (not (regexp-match? #px";" s))))

(define (css-color-literal? s)
  (define down (string-downcase s))
  (or (set-member? css-color-keywords down)
      (regexp-match? #px"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$" s)))

(define (safe-css-font-family-literal? s)
  (and (not (string=? (string-trim s) ""))
       (regexp-match? #px"^[a-zA-Z0-9\"' ,._-]+$" s)))

(define (normalize-css-font-family s)
  (string-trim
   (regexp-replace* #px"(?i:!\\s*important\\s*$)" (string-trim s) "")))

(define (normalize-css-decl-value s)
  (string-trim
   (regexp-replace* #px"(?i:!\\s*important\\s*$)" (string-trim s) "")))

(define css-length-rx
  #px"([-+]?[0-9]*\\.?[0-9]+)\\s*(px|rem|em|%|vw|vh|vmin|vmax|svw|svh|lvw|lvh|dvw|dvh|vi|vb|pt|pc|cm|mm|in|q|ch|ex|cap|ic|lh|rlh)")

(define (parse-css-lengths s)
  (let loop ([start 0] [acc null])
    (define m (regexp-match-positions css-length-rx s start))
    (cond
      [(not m) (reverse acc)]
      [else
       (define whole (list-ref m 0))
       (define num-pos (list-ref m 1))
       (define unit-pos (list-ref m 2))
       (define next-start (cdr whole))
       (if (and num-pos unit-pos)
           (let* ([num-str (substring s (car num-pos) (cdr num-pos))]
                  [unit-str (string-downcase (substring s (car unit-pos) (cdr unit-pos)))]
                  [num (string->number num-str)])
             (if num
                 (loop next-start (cons (cons num unit-str) acc))
                 (loop next-start acc)))
           (loop next-start acc))])))

(define (css-length->px amount unit)
  (case (string->symbol unit)
    [(px) amount]
    [(rem em) (* 16.0 amount)]
    [(pt) (* (/ 96.0 72.0) amount)]
    [(pc) (* 16.0 amount)]
    [(in) (* 96.0 amount)]
    [(cm) (* (/ 96.0 2.54) amount)]
    [(mm) (* (/ 96.0 25.4) amount)]
    [(q) (* (/ 96.0 101.6) amount)]
    [(ch ex cap) (* 8.0 amount)]
    [(ic lh rlh) (* 16.0 amount)]
    [(vw vh vmin vmax svw svh lvw lvh dvw dvh vi vb) (* 10.0 amount)]
    [(%) (* 0.5 amount)]
    [else #f]))

(define (clamp lo x hi)
  (min hi (max lo x)))

(define (max-css-length-px value-text)
  (define pxs
    (filter values
            (for/list ([lu (in-list (parse-css-lengths value-text))])
              (css-length->px (car lu) (cdr lu)))))
  (and (pair? pxs) (apply max pxs)))

(define (format-px px)
  (format "~apx" (inexact->exact (round px))))

(define (extract-blur-arg value-text)
  (define m (regexp-match #px"(?i:blur\\(([^)]*)\\))" value-text))
  (and m (string-trim (list-ref m 1))))

(define (spacing-width-px value-text)
  (define px (max-css-length-px value-text))
  (and px
       (let* ([px* (clamp 0.0 px 160.0)])
         (and px*
              (inexact->exact
               (round (clamp 6.0 (+ 6.0 (* 0.28 px*)) 54.0)))))))

(define (radius-size-px value-text)
  (define px (max-css-length-px value-text))
  (and px
       (let* ([px* (clamp 0.0 px 999.0)])
         (and px*
              (inexact->exact
               (round (clamp 0.0 px* 9.0)))))))

(define (spacing-preview-title value-text)
  (define px (max-css-length-px value-text))
  (if px
      (format "Spacing preview: ~a (~a)" value-text (format-px px))
      (format "Spacing preview: ~a" value-text)))

(define (radius-preview-title value-text)
  (define px (max-css-length-px value-text))
  (if px
      (format "Border radius preview: ~a (~a)" value-text (format-px px))
      (format "Border radius preview: ~a" value-text)))

(define (normalize-preview-mode who mode)
  (cond
    [(memq mode '(none always hover)) mode]
    [else (raise-argument-error who "(or/c 'none 'always 'hover)" mode)]))

(define (preview-mode->string mode)
  (case mode
    [(none) "none"]
    [(always) "always"]
    [(hover) "hover"]
    [else "always"]))

(define (css-font-preview-style family-text preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-font-preview-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-font-preview-ui")
        (data-preview-mode . ,mode)
        (data-font-stack . ,family-text)
        (style . ,(format "--css-preview-font: ~a;" family-text)))
      (preview-tooltip-attrs (format "Preview stack: ~a" family-text))
      (preview-url-attrs))))))

(define (css-font-preview-element family-text preview-mode)
  (make-element (css-font-preview-style family-text preview-mode) (list "Aa")))

(define (css-swatch-style color-text preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-swatch-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-color-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-bg: ~a;" color-text)))
      (preview-tooltip-attrs (format "Color preview: ~a" color-text))
      (preview-url-attrs))))))

(define (css-swatch-element color-text preview-mode)
  (make-element (css-swatch-style color-text preview-mode) (list " ")))

(define (css-gradient-swatch-style gradient-text preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-gradient-swatch-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-gradient-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-bg: ~a;" gradient-text)))
      (preview-tooltip-attrs (format "Gradient preview: ~a" gradient-text))
      (preview-url-attrs))))))

(define (css-gradient-swatch-element gradient-text preview-mode)
  (make-element (css-gradient-swatch-style gradient-text preview-mode) (list " ")))

(define (css-spacing-preview-style width-px label preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-spacing-preview-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-spacing-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-width: ~apx;" width-px)))
      (preview-tooltip-attrs (spacing-preview-title label))
      (preview-url-attrs))))))

(define (css-spacing-preview-element width-px label preview-mode)
  (make-element (css-spacing-preview-style width-px label preview-mode) (list " ")))

(define (css-radius-preview-style radius-px label preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-radius-preview-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-radius-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-radius: ~apx;" radius-px)))
      (preview-tooltip-attrs (radius-preview-title label))
      (preview-url-attrs))))))

(define (css-radius-preview-element radius-px label preview-mode)
  (make-element (css-radius-preview-style radius-px label preview-mode) (list " ")))

(define (js-preview-style kind label)
  (make-style
   #f
   (list
    (attributes
     `((class . ,(format "js-preview-ui ~a" kind))
       ,@(preview-tooltip-attrs label))))))

(define (js-regex-preview-element)
  (make-element (js-preview-style "js-regex-preview-ui" "Regex literal") null))

(define (js-template-preview-element)
  (make-element (js-preview-style "js-template-preview-ui" "Template literal") null))

(define (css-token-def-style name value)
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-token-def-preview-ui")
        (style . ,(format "--css-token-name: \"~a\";" name)))
      (preview-tooltip-attrs (format "Design token ~a = ~a" name value))
      (preview-url-attrs))))))

(define (css-token-def-element name value)
  (make-element (css-token-def-style name value) (list name)))

(define (css-token-ref-style name)
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-token-ref-preview-ui")
        (style . ,(format "--css-token-name: \"~a\";" name)))
      (preview-tooltip-attrs (format "Uses design token ~a" name))
      (preview-url-attrs))))))

(define (css-token-ref-element name)
  (make-element (css-token-ref-style name) (list name)))

(define css-font-preview-runtime-script
  #<<JS
(function () {
  if (window.__scribbleCssFontPreviewUiInit) return;
  window.__scribbleCssFontPreviewUiInit = true;

  var styleId = "scribble-css-preview-ui-style";
  function ensureStyles() {
    var first = document.querySelector(".css-preview-ui, .js-preview-ui");
    var external = first && first.getAttribute("data-preview-css-url");
    if (external) {
      var lid = "scribble-css-preview-ui-link";
      if (!document.getElementById(lid)) {
        var lk = document.createElement("link");
        lk.id = lid;
        lk.rel = "stylesheet";
        lk.href = external;
        document.head.appendChild(lk);
      }
      return;
    }
    if (!document.getElementById(styleId)) {
      var st = document.createElement("style");
      st.id = styleId;
      st.textContent =
        ":root{--css-preview-stroke:#999;--css-preview-text:rgba(0,0,0,.72);--css-preview-accent-1:rgba(70,150,245,.70);--css-preview-accent-2:rgba(70,150,245,.22);--css-preview-fill:rgba(70,150,245,.15);}" +
        ".css-preview-ui{display:inline-block;margin-left:.45em;vertical-align:middle;user-select:none;-webkit-user-select:none;pointer-events:auto;}" +
        ".css-preview-ui:focus,.js-preview-ui:focus{outline:1px solid color-mix(in srgb, var(--css-preview-accent-1) 80%, #000 10%);outline-offset:1px;}" +
        ".css-preview-ui[data-preview-mode=none]{display:none!important;}" +
        ".css-preview-ui[data-preview-mode=hover]{display:none;}" +
        ".css-color-preview-ui{width:.75em;height:.75em;border:1px solid var(--css-preview-stroke);background:var(--css-preview-bg);}" +
        ".css-gradient-preview-ui{width:1.4em;height:.75em;border:1px solid var(--css-preview-stroke);background:var(--css-preview-bg);}" +
        ".css-spacing-preview-ui{width:var(--css-preview-width,10px);height:.58em;border:1px solid color-mix(in srgb, var(--css-preview-stroke) 80%, transparent);border-radius:2px;background:linear-gradient(to right, var(--css-preview-accent-1), var(--css-preview-accent-2));}" +
        ".css-radius-preview-ui{width:.95em;height:.95em;border:1px solid color-mix(in srgb, var(--css-preview-stroke) 85%, transparent);border-radius:var(--css-preview-radius,4px);background:var(--css-preview-fill);}" +
        ".css-font-preview-ui{margin-left:.6em;white-space:nowrap;font-family:var(--css-preview-font,inherit);font-size:1em;line-height:1;color:var(--css-preview-text);pointer-events:auto;}" +
        ".css-font-preview-warning{color:#b45;font-weight:600;}" +
        ".css-token-def-preview-ui,.css-token-ref-preview-ui{margin-left:.45em;padding:0 .3em;height:1.1em;line-height:1.05em;border-radius:.35em;border:1px solid color-mix(in srgb, var(--css-preview-stroke) 80%, transparent);font-size:.72em;color:var(--css-preview-text);}" +
        ".css-token-def-preview-ui{background:color-mix(in srgb, var(--css-preview-fill) 75%, transparent);}" +
        ".css-token-ref-preview-ui{background:transparent;border-style:dashed;}" +
        ".js-preview-ui{display:inline-block;margin-left:.35em;vertical-align:middle;user-select:none;-webkit-user-select:none;pointer-events:auto;color:var(--css-preview-text);font-size:.82em;line-height:1;}" +
        ".js-regex-preview-ui::before{content:\"/r/\";}" +
        ".js-template-preview-ui::before{content:\"`...`\";}" +
        ".scribble-copy-wrap{position:relative;}" +
        ".scribble-copy-source{display:none!important;white-space:pre;}" +
        ".scribble-copy-btn{position:absolute;top:.38rem;right:.38rem;display:inline-flex;align-items:center;justify-content:center;width:1.6rem;height:1.6rem;padding:0;border:1px solid rgba(120,120,120,.55);border-radius:.35rem;background:rgba(255,255,255,.92);color:rgba(35,35,35,.9);cursor:pointer;opacity:0;pointer-events:none;transition:opacity .14s ease, background-color .14s ease, border-color .14s ease, transform .12s ease;z-index:5;}" +
        ".scribble-copy-wrap:hover .scribble-copy-btn,.scribble-copy-wrap:focus-within .scribble-copy-btn{opacity:1;pointer-events:auto;}" +
        ".scribble-copy-btn:hover{background:rgba(245,245,245,.98);}" +
        ".scribble-copy-btn:active{transform:scale(.96);}" +
        ".scribble-copy-btn[data-copy-state=done]{background:rgba(46,160,67,.20);border-color:rgba(46,160,67,.65);}" +
        ".scribble-copy-btn[data-copy-state=error]{background:rgba(201,58,58,.20);border-color:rgba(201,58,58,.62);}" +
        ".scribble-copy-btn svg{width:14px;height:14px;display:block;}";
      document.head.appendChild(st);
    }
  }

  var tooltipEl = null;
  function ensureTooltipEl() {
    if (tooltipEl) return tooltipEl;
    tooltipEl = document.createElement("div");
    tooltipEl.id = "scribble-preview-tooltip";
    tooltipEl.style.position = "fixed";
    tooltipEl.style.zIndex = "99999";
    tooltipEl.style.display = "none";
    tooltipEl.style.pointerEvents = "none";
    tooltipEl.style.maxWidth = "32rem";
    tooltipEl.style.padding = "0.28rem 0.45rem";
    tooltipEl.style.borderRadius = "0.32rem";
    tooltipEl.style.background = "rgba(20,20,20,.92)";
    tooltipEl.style.color = "#fff";
    tooltipEl.style.font = "12px/1.25 sans-serif";
    tooltipEl.style.whiteSpace = "pre-wrap";
    tooltipEl.style.boxShadow = "0 3px 10px rgba(0,0,0,.28)";
    document.body.appendChild(tooltipEl);
    return tooltipEl;
  }

  function tooltipText(preview) {
    if (preview.getAttribute("data-preview-tooltips") === "off") return "";
    return preview.getAttribute("data-preview-title") || preview.getAttribute("title") || "";
  }

  function setPreviewLabel(preview, text) {
    preview.setAttribute("data-preview-title", text);
    preview.setAttribute("aria-label", text);
    if (preview.getAttribute("data-preview-tooltips") === "off") {
      preview.removeAttribute("title");
    } else {
      preview.setAttribute("title", text);
    }
  }

  function showTooltip(preview, clientX, clientY) {
    var text = tooltipText(preview);
    if (!text) return;
    var tip = ensureTooltipEl();
    tip.textContent = text;
    tip.style.display = "block";
    moveTooltip(clientX, clientY);
  }

  function moveTooltip(clientX, clientY) {
    if (!tooltipEl || tooltipEl.style.display === "none") return;
    var x = (typeof clientX === "number" ? clientX : 0) + 12;
    var y = (typeof clientY === "number" ? clientY : 0) + 12;
    var vw = window.innerWidth || document.documentElement.clientWidth || 1024;
    var vh = window.innerHeight || document.documentElement.clientHeight || 768;
    var tw = tooltipEl.offsetWidth || 0;
    var th = tooltipEl.offsetHeight || 0;
    if (x + tw + 8 > vw) x = Math.max(8, vw - tw - 8);
    if (y + th + 8 > vh) y = Math.max(8, vh - th - 8);
    tooltipEl.style.left = x + "px";
    tooltipEl.style.top = y + "px";
  }

  function hideTooltip() {
    if (tooltipEl) tooltipEl.style.display = "none";
  }

  function bindTooltip(preview) {
    if (preview.__scribbleTooltipBound) return;
    preview.__scribbleTooltipBound = true;
    if (preview.getAttribute("data-preview-tooltips") === "off") return;
    if (!tooltipText(preview)) return;
    preview.style.cursor = "help";
    preview.addEventListener("mouseenter", function (e) {
      showTooltip(preview, e.clientX, e.clientY);
    });
    preview.addEventListener("mousemove", function (e) {
      moveTooltip(e.clientX, e.clientY);
    });
    preview.addEventListener("mouseleave", hideTooltip);
    preview.addEventListener("focus", function () {
      var r = preview.getBoundingClientRect();
      showTooltip(preview, r.left + r.width / 2, r.bottom);
    });
    preview.addEventListener("blur", hideTooltip);
  }

  var GENERIC = new Set([
    "serif", "sans-serif", "monospace", "cursive", "fantasy",
    "system-ui", "emoji", "math", "fangsong",
    "ui-serif", "ui-sans-serif", "ui-monospace", "ui-rounded"
  ]);

  function splitFontStack(raw) {
    var s = (raw || "").trim();
    var out = [];
    var cur = "";
    var quote = null;
    var esc = false;
    for (var i = 0; i < s.length; i++) {
      var ch = s[i];
      if (esc) {
        cur += ch;
        esc = false;
        continue;
      }
      if (ch === "\\\\") {
        cur += ch;
        esc = true;
        continue;
      }
      if (quote) {
        cur += ch;
        if (ch === quote) quote = null;
        continue;
      }
      if (ch === "'" || ch === "\"") {
        cur += ch;
        quote = ch;
        continue;
      }
      if (ch === ",") {
        out.push(cur.trim());
        cur = "";
        continue;
      }
      cur += ch;
    }
    if (cur.trim() !== "") out.push(cur.trim());
    return out.map(function (part) {
      var p = part.trim();
      if ((p.startsWith("\"") && p.endsWith("\"")) || (p.startsWith("'") && p.endsWith("'"))) {
        p = p.slice(1, -1);
      }
      return p.trim();
    }).filter(Boolean);
  }

  function isGenericFamily(name) {
    return GENERIC.has((name || "").toLowerCase());
  }

  function hasFont(name) {
    if (!name) return false;
    if (isGenericFamily(name)) return true;
    if (!document.fonts || !document.fonts.check) return null;
    try {
      var escaped = String(name).replace(/"/g, "\\\\\"");
      return document.fonts.check('16px "' + escaped + '"');
    } catch (e) {
      return null;
    }
  }

  function addWarning(preview) {
    var warn = preview.querySelector(".css-font-preview-warning");
    if (warn) return;
    warn = document.createElement("span");
    warn.className = "css-font-preview-warning";
    warn.setAttribute("aria-hidden", "true");
    warn.textContent = " \\u26A0";
    preview.appendChild(warn);
  }

  function clearWarning(preview) {
    var warn = preview.querySelector(".css-font-preview-warning");
    if (warn) warn.remove();
  }

  function computeFontState(preview) {
    var stack = preview.getAttribute("data-font-stack") || "";
    var families = splitFontStack(stack);
    var nonGeneric = families.filter(function (f) { return !isGenericFamily(f); });
    var generic = families.filter(function (f) { return isGenericFamily(f); });
    var available = null;
    var availabilityUnknown = false;

    for (var i = 0; i < families.length; i++) {
      var ok = hasFont(families[i]);
      if (ok === null) {
        availabilityUnknown = true;
      } else if (ok) {
        available = families[i];
        break;
      }
    }

    var fallback = generic[0] || "monospace";
    var firstRequested = nonGeneric[0] || generic[0] || "(default)";
    var resolved = available || generic[0] || "(browser default)";
    var usedFallback = available && firstRequested && (available !== firstRequested);
    var missing = (!availabilityUnknown && nonGeneric.length > 0 && !available);

    if (missing) {
      addWarning(preview);
      setPreviewLabel(preview, "Font not found on system\\nUsing fallback: " + fallback);
    } else {
      clearWarning(preview);
      if (usedFallback) {
        setPreviewLabel(preview, "Rendered using: " + resolved + " (fallback)");
      } else {
        setPreviewLabel(preview, "Rendered using: " + resolved);
      }
    }
  }

  function setVisible(preview, on) {
    if (preview.getAttribute("data-preview-mode") !== "hover") return;
    preview.style.display = on ? "inline-block" : "none";
  }

  function bindPreview(preview) {
    if (preview.__scribblePreviewBound) return;
    preview.__scribblePreviewBound = true;
    var mode = preview.getAttribute("data-preview-mode") || "always";
    var isFont = preview.classList.contains("css-font-preview-ui");

    if (isFont) computeFontState(preview);
    bindTooltip(preview);
    if (mode !== "hover") return;

    preview.__scribbleFontPreviewBound = true;
    setVisible(preview, false);

    var host =
      preview.closest("tr") ||
      preview.closest("p") ||
      preview.closest("li") ||
      preview.closest("dd") ||
      preview.closest("dt") ||
      preview.parentElement;
    if (!host) return;

    host.addEventListener("mouseenter", function () {
      if (isFont) computeFontState(preview);
      setVisible(preview, true);
    });
    host.addEventListener("mouseleave", function () {
      setVisible(preview, false);
    });
    host.addEventListener("focusin", function () {
      if (isFont) computeFontState(preview);
      setVisible(preview, true);
    });
    host.addEventListener("focusout", function () {
      setVisible(preview, false);
    });
  }

  var COPY_ICON_SVG =
    '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
    '<rect x="9" y="3" width="11" height="13" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="2"></rect>' +
    '<rect x="4" y="8" width="11" height="13" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="2"></rect>' +
    '</svg>';
  var COPY_DONE_SVG =
    '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
    '<path d="M5 12l5 5L20 7" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path>' +
    '</svg>';

  function setCopyState(btn, state) {
    if (!state) {
      btn.removeAttribute("data-copy-state");
      btn.innerHTML = COPY_ICON_SVG;
      btn.setAttribute("aria-label", "Copy code");
      btn.setAttribute("title", "Copy code");
      return;
    }
    btn.setAttribute("data-copy-state", state);
    if (state === "done") {
      btn.innerHTML = COPY_DONE_SVG;
      btn.setAttribute("aria-label", "Copied");
      btn.setAttribute("title", "Copied");
    } else {
      btn.innerHTML = COPY_ICON_SVG;
      btn.setAttribute("aria-label", "Copy failed");
      btn.setAttribute("title", "Copy failed");
    }
  }

  function copyToClipboard(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      try {
        var ta = document.createElement("textarea");
        ta.value = text;
        ta.setAttribute("readonly", "true");
        ta.style.position = "fixed";
        ta.style.left = "-9999px";
        ta.style.top = "0";
        document.body.appendChild(ta);
        ta.focus();
        ta.select();
        var ok = document.execCommand("copy");
        ta.remove();
        if (ok) resolve();
        else reject(new Error("copy command failed"));
      } catch (e) {
        reject(e);
      }
    });
  }

  function bindCopyButton(wrap) {
    if (wrap.__scribbleCopyBound) return;
    wrap.__scribbleCopyBound = true;
    if (wrap.getAttribute("data-copy-button") === "off") return;

    var src = wrap.querySelector(".scribble-copy-source");
    if (!src) return;

    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "scribble-copy-btn";
    btn.innerHTML = COPY_ICON_SVG;
    btn.setAttribute("aria-label", "Copy code");
    btn.setAttribute("title", "Copy code");
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      var text = src.textContent || "";
      copyToClipboard(text).then(function () {
        setCopyState(btn, "done");
        window.setTimeout(function () { setCopyState(btn, null); }, 1200);
      }).catch(function () {
        setCopyState(btn, "error");
        window.setTimeout(function () { setCopyState(btn, null); }, 1200);
      });
    });
    wrap.appendChild(btn);
  }

  function scan() {
    ensureStyles();
    var previews = document.querySelectorAll(".css-preview-ui");
    for (var i = 0; i < previews.length; i++) bindPreview(previews[i]);
    var copyWraps = document.querySelectorAll(".scribble-copy-wrap");
    for (var j = 0; j < copyWraps.length; j++) bindCopyButton(copyWraps[j]);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", scan, { once: true });
  } else {
    scan();
  }
})();
JS
  )

(define css-font-preview-runtime-element
  (make-element
   (make-style #f (list (script-property "text/javascript"
                                         (list css-font-preview-runtime-script))))
   null))

(define css-preview-runtime-emitted? (box #f))

(define (runtime-prefix-elements)
  (if (unbox css-preview-runtime-emitted?)
      null
      (begin
        (set-box! css-preview-runtime-emitted? #t)
        (list css-font-preview-runtime-element))))

(define (tokens->copy-text tokens)
  (apply string-append
         (for/list ([t (in-list tokens)]
                    #:when (string? (cdr t)))
           (cdr t))))

(define (copy-source-element text)
  (make-element copy-source-style (list text)))

(define (style-for lang cls)
  (case lang
    [(css)
     (case cls
       [(comment) comment-color]
       [(keyword) css-keyword-color]
       [(value) value-color]
       [(name) css-name-color]
       [(punct) paren-color]
       [else no-color])]
    [(html)
     (case cls
       [(comment) comment-color]
       [(keyword) html-tag-color]
       [(value) value-color]
       [(static-keyword) js-static-keyword-color]
       [(object-key) js-object-key-color]
       [(param-name) js-param-name-color]
       [(decl-name) js-decl-name-color]
       [(prop-name) js-prop-name-color]
       [(method-name) js-method-name-color]
       [(private-name) js-private-name-color]
       [(name) symbol-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(js)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(static-keyword) js-static-keyword-color]
       [(object-key) js-object-key-color]
       [(param-name) js-param-name-color]
       [(decl-name) js-decl-name-color]
       [(prop-name) js-prop-name-color]
       [(method-name) js-method-name-color]
       [(private-name) js-private-name-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(python)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(name) js-name-color]
       [(punct) paren-color]
       [else no-color])]
    [(latex tex)
     (case cls
       [(comment) comment-color]
       [(keyword) tex-command-color]
       [(value) tex-value-color]
       [(name) tex-name-color]
       [(operator) tex-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(c cpp objc)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(type-name) c-type-name-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(go)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(type-name) c-type-name-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(pascal)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(type-name) c-type-name-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(swift)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(type-name) c-type-name-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(rust)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(type-name) c-type-name-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(sql sqlite mysql postgres postgresql)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(parameter-name) js-private-name-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(ruby)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(constant-name) c-type-name-color]
       [(method-name) js-method-name-color]
       [(variable-name) js-private-name-color]
       [(label-name) js-object-key-color]
       [(interpolation) js-operator-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(mathematica)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(racket)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(builtin-name) racket-builtin-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(markdown)
     (case cls
       [(comment) comment-color]
       [(heading-1) markdown-heading-1-color]
       [(heading-2) markdown-heading-2-color]
       [(heading-3) markdown-heading-3-color]
       [(heading-4) markdown-heading-4-color]
       [(heading-5) markdown-heading-5-color]
       [(heading-6) markdown-heading-6-color]
       [(heading-marker heading-text keyword) markdown-heading-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(c cpp go haskell java json markdown objc pascal plist racket rhombus ruby rust swift yaml)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(makefile)
     (case cls
       [(comment) comment-color]
       [(keyword make-target) makefile-target-color]
       [(recipe-command) makefile-command-color]
       [(recipe-option) makefile-option-color]
       [(make-variable) makefile-variable-color]
       [(value) value-color]
       [(name) js-name-color]
       [(operator) makefile-operator-color]
       [(punct) makefile-punct-color]
       [else no-color])]
    [(csv tsv)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(name) symbol-color]
       [(punct) paren-color]
       [else no-color])]
    [(wasm)
     (case cls
       [(comment) comment-color]
       [(wasm-form) wasm-form-color]
       [(wasm-type) wasm-type-color]
       [(wasm-instr) wasm-instr-color]
       [(wasm-id) wasm-id-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(name) js-name-color]
       [(punct) paren-color]
       [else no-color])]
    [(bash zsh powershell)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(name) js-name-color]
       [(punct) paren-color]
       [else no-color])]
    [(scribble)
     (case cls
       [(comment) comment-color]
       [(keyword) keyword-color]
       [(name) symbol-color]
       [(value) value-color]
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

(define css-punct-texts
  '("{" "}" ":" ";" "(" ")" "[" "]" "," ">" "+" "~" "*" "=" "|" "#" "/"))

(define (css-whitespace-text? txt)
  (and (not (string=? txt ""))
       (regexp-match? #px"^\\s+$" txt)))

(define (tokenize-css-handwritten s)
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

(define (tokenize-css s)
  (for/list ([token (in-list (css-string->derived-tokens s))])
    (define txt (css-derived-token-text token))
    (define cls
      (cond
        [(css-derived-token-has-tag? token 'comment) 'comment]
        [(css-whitespace-text? txt) 'plain]
        [(or (css-derived-token-has-tag? token 'declaration-value-token)
             (css-derived-token-has-tag? token 'color-literal)
             (css-derived-token-has-tag? token 'color-function)
             (css-derived-token-has-tag? token 'gradient-function)
             (css-derived-token-has-tag? token 'string-literal)
             (css-derived-token-has-tag? token 'numeric-literal)
             (css-derived-token-has-tag? token 'function-name))
         'value]
        [(or (css-derived-token-has-tag? token 'property-name)
             (css-derived-token-has-tag? token 'custom-property-name))
         'name]
        [(or (css-derived-token-has-tag? token 'selector-token)
             (css-derived-token-has-tag? token 'at-rule-name)
             (css-derived-token-has-tag? token 'property-name-candidate))
         'keyword]
        [(member txt css-punct-texts) 'punct]
        [else 'plain]))
    (cons cls txt)))

(define js-keywords
  '(break case catch class const continue debugger default delete do else export extends
          false finally for function if import in instanceof let new null of return super
          switch this throw true try typeof var void while with yield await
          as from static get set enum implements interface package private protected public))

(define js-literal-keywords
  '(true false null this super))

(define js-regex-context-keywords
  '(return throw case delete void typeof new in instanceof do else if while for switch catch await yield))

(define (js-ident-start? c)
  (or (char-alphabetic? c) (char=? c #\_) (char=? c #\$)))

(define (js-ident-char? c)
  (or (js-ident-start? c) (char-numeric? c)))

(define (read-js-digit-seq s i pred?)
  ;; Accept separators but only between digits (reject leading/trailing/consecutive _).
  (define len (string-length s))
  (let loop ([k i] [saw-digit? #f] [prev-us? #f])
    (if (>= k len)
        (if prev-us? (sub1 k) k)
        (let ([c (string-ref s k)])
          (cond
            [(pred? c) (loop (add1 k) #t #f)]
            [(char=? c #\_)
             (if (and saw-digit?
                      (not prev-us?)
                      (< (add1 k) len)
                      (pred? (string-ref s (add1 k))))
                 (loop (add1 k) saw-digit? #t)
                 k)]
            [else k])))))

(define (read-js-number s i)
  (define len (string-length s))
  (define j0
    (if (and (< i len) (member (string-ref s i) '(#\+ #\-)))
        (add1 i)
        i))
  (cond
    [(and (<= (+ j0 2) len)
          (char=? (string-ref s j0) #\0)
          (member (char-downcase (string-ref s (add1 j0))) '(#\x #\o #\b)))
     (define kind (char-downcase (string-ref s (add1 j0))))
     (define pred
       (case kind
         [(#\x) hex-digit?]
         [(#\o) (lambda (c) (member c '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)))]
         [else (lambda (c) (member c '(#\0 #\1)))]))
     (define jx (read-js-digit-seq s (+ j0 2) pred))
     (if (and (< jx len) (char=? (string-ref s jx) #\n))
         (add1 jx)
         jx)]
    [else
     (define has-dot-leading?
       (and (< j0 len)
            (char=? (string-ref s j0) #\.)
            (< (add1 j0) len)
            (char-numeric? (string-ref s (add1 j0)))))
     (define j-int
       (if has-dot-leading?
           j0
           (read-js-digit-seq s j0 char-numeric?)))
     (define-values (j-frac has-dot?)
       (if (and (< j-int len) (char=? (string-ref s j-int) #\.))
           (values (read-js-digit-seq s (add1 j-int) char-numeric?) #t)
           (values j-int #f)))
     (define-values (j-exp has-exp?)
       (if (and (< j-frac len) (member (string-ref s j-frac) '(#\e #\E)))
           (let* ([k0 (add1 j-frac)]
                  [k1 (if (and (< k0 len) (member (string-ref s k0) '(#\+ #\-)))
                          (add1 k0)
                          k0)]
                  [k2 (read-js-digit-seq s k1 char-numeric?)])
             (if (> k2 k1)
                 (values k2 #t)
                 (values j-frac #f)))
           (values j-frac #f)))
     (define j-end
       (if (and (< j-exp len)
                (char=? (string-ref s j-exp) #\n)
                (not has-dot?)
                (not has-exp?))
           (add1 j-exp)
           j-exp))
     (if (> j-end j0) j-end (add1 i))]))

(define (read-js-string-literal s i)
  ;; For recovery, stop at line boundary if the quote is not closed on this line.
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
         [(or (char=? c #\newline) (char=? c #\return)) k]
         [else (loop (add1 k) #f)])])))

(define (read-js-regex s i)
  (define len (string-length s))
  (let loop ([k (add1 i)] [escaped? #f] [in-class? #f])
    (cond
      [(>= k len) #f]
      [else
       (define c (string-ref s k))
       (cond
         [(or (char=? c #\newline) (char=? c #\return)) #f]
         [escaped? (loop (add1 k) #f in-class?)]
         [(char=? c #\\) (loop (add1 k) #t in-class?)]
         [(and (not in-class?) (char=? c #\/))
          (read-while s (add1 k) char-alphabetic?)]
         [(char=? c #\[) (loop (add1 k) #f #t)]
         [(and in-class? (char=? c #\])) (loop (add1 k) #f #f)]
         [else (loop (add1 k) #f in-class?)])])))

(define (prev-nonspace-char s i)
  (let loop ([k (sub1 i)])
    (cond
      [(negative? k) #f]
      [(char-whitespace? (string-ref s k)) (loop (sub1 k))]
      [else (string-ref s k)])))

(define (next-nonspace-index s i)
  (define len (string-length s))
  (let loop ([k i])
    (cond
      [(>= k len) #f]
      [(char-whitespace? (string-ref s k)) (loop (add1 k))]
      [else k])))

(define (next-nonspace-char s i)
  (define k (next-nonspace-index s i))
  (and k (string-ref s k)))

(define js-operators
  '(">>>=" "<<=" ">>=" "&&=" "||=" "??=" "**=" "===" "!=="
    ">>>" "<<" ">>" "==" "!=" "<=" ">=" "&&" "||" "??"
    "++" "--" "+=" "-=" "*=" "/=" "%=" "&=" "|=" "^=" "=>"
    "**" "?." "=" "<" ">" "!" "~" "+" "-" "*" "/" "%" "&"
    "|" "^" "?" ":" "@"))

(define (string-prefix-at? s i prefix)
  (define n (string-length prefix))
  (and (<= (+ i n) (string-length s))
       (string=? (substring s i (+ i n)) prefix)))

(define (read-js-operator s i)
  (for/or ([op (in-list js-operators)])
    (and (string-prefix-at? s i op)
         (+ i (string-length op)))))

(define (js-operator-can-start-regex? txt)
  (and (not (member txt '("++" "--")))
       (member txt
               '("=" "==" "===" "!=" "!==" "+" "-" "*" "/" "%" "+=" "-="
                 "*=" "/=" "%=" "&&" "||" "&&=" "||=" "&" "|" "^" "~"
                 "<" ">" "<=" ">=" "<<" ">>" ">>>" "<<=" ">>=" ">>>="
                 "=>" "??" "??=" "?." "?" ":" "!" "@"))))

(define js-condition-open-keywords
  '(if while for switch catch with))

(define (js-delimiter-char? ch)
  (member ch '(#\{ #\} #\( #\) #\[ #\] #\, #\; #\.)))

(define (js-ident-can-start-regex? id kw?)
  (and kw?
       (not (memq id js-literal-keywords))
       (memq id js-regex-context-keywords)))

(define (tsx-generic-angle-candidate? s i)
  ;; In JSX mode, avoid treating TS-like generic arrows as JSX tags.
  (define len (string-length s))
  (and (< i len)
       (char=? (string-ref s i) #\<)
       (let* ([j0 (next-nonspace-index s (add1 i))])
         (and j0
              (js-ident-start? (string-ref s j0))
              (let* ([j1 (read-while s j0 js-ident-char?)]
                     [j2 (next-nonspace-index s j1)])
                (and j2
                     (< j2 len)
                     (char=? (string-ref s j2) #\>)
                     (let ([j3 (next-nonspace-index s (add1 j2))])
                       (and j3 (< j3 len) (char=? (string-ref s j3) #\()))))))))

(define (jsx-ident-char? c)
  (or (js-ident-char? c) (member c '(#\- #\: #\.))))

(define (jsx-start-candidate? s i)
  (define len (string-length s))
  (and (< (add1 i) len)
       (let ([n (string-ref s (add1 i))])
         (or (char=? n #\/) (char=? n #\>) (char-alphabetic? n)))
       (let ([p (prev-nonspace-char s i)])
         (or (not p)
             (member p
                     '(#\( #\[ #\{ #\= #\, #\: #\? #\; #\! #\> #\| #\&
                       #\+ #\- #\* #\/))))))

(define (read-jsx-brace-expr s i)
  (define len (string-length s))
  (if (or (>= i len) (not (char=? (string-ref s i) #\{)))
      (values null (min len (add1 i)))
      (let* ([expr-start (add1 i)]
             [expr-end (js-template-expr-end s expr-start)]
             [expr-src (if (<= expr-end len) (substring s expr-start expr-end) "")]
             [inner (tokenize-js expr-src)])
        (values (append (list (cons 'punct "{"))
                        inner
                        (if (< expr-end len) (list (cons 'punct "}")) null))
                (if (< expr-end len) (add1 expr-end) len)))))

(define (tokenize-jsx-tag s i)
  (define len (string-length s))
  (define tokens null)
  (define (push cls a b)
    (when (< a b)
      (set! tokens (cons (cons cls (substring s a b)) tokens))))
  (define (skip-ws j)
    (define k (read-while s j char-whitespace?))
    (push 'plain j k)
    k)
  (define (read-attr-value j)
    (cond
      [(>= j len) j]
      [else
       (define q (string-ref s j))
       (cond
         [(or (char=? q #\") (char=? q #\'))
          (define end (read-string-literal s j))
          (push 'value j end)
          end]
         [(char=? q #\{)
          (define-values (expr k) (read-jsx-brace-expr s j))
          (set! tokens (append (reverse expr) tokens))
          k]
         [else
          (define end
            (read-while s j
                        (lambda (x)
                          (not (or (char-whitespace? x)
                                   (char=? x #\>)
                                   (char=? x #\/))))))
          (push 'value j end)
          end])]))
  (define j i)
  (push 'punct j (add1 j)) ; <
  (set! j (add1 j))
  (when (and (< j len) (char=? (string-ref s j) #\/))
    (push 'punct j (add1 j))
    (set! j (add1 j)))
  (cond
    [(and (< j len) (char=? (string-ref s j) #\>))
     (push 'punct j (add1 j))
     (values (reverse tokens) (add1 j))]
    [else
     (define name-start j)
     (set! j (read-while s j jsx-ident-char?))
     (if (> j name-start)
         (push 'keyword name-start j)
         (push 'plain name-start (min len (add1 name-start))))
     (let loop ()
       (cond
         [(>= j len) (values (reverse tokens) j)]
         [else
          (define c (string-ref s j))
          (define c2 (next-char s (add1 j)))
          (cond
            [(char-whitespace? c)
             (set! j (skip-ws j))
             (loop)]
            [(char=? c #\>)
             (push 'punct j (add1 j))
             (values (reverse tokens) (add1 j))]
            [(and c2 (char=? c #\/) (char=? c2 #\>))
             (push 'punct j (add1 j))
             (push 'punct (add1 j) (+ j 2))
             (values (reverse tokens) (+ j 2))]
            [(char=? c #\{)
             (define-values (expr k) (read-jsx-brace-expr s j))
             (set! tokens (append (reverse expr) tokens))
             (set! j k)
             (loop)]
            [else
             (define attr-start j)
             (set! j (read-while s j jsx-ident-char?))
             (if (= attr-start j)
                 (begin
                   (push 'plain j (add1 j))
                   (set! j (add1 j))
                   (loop))
                 (begin
                   (push 'name attr-start j)
                   (set! j (skip-ws j))
                   (when (and (< j len) (char=? (string-ref s j) #\=))
                     (push 'punct j (add1 j))
                     (set! j (add1 j))
                     (set! j (skip-ws j))
                     (set! j (read-attr-value j)))
                   (loop)))])]))]))

(define (js-template-expr-end s start)
  (define len (string-length s))
  (let loop ([k start]
             [depth 1]
             [in-single? #f]
             [in-double? #f]
             [in-backtick? #f]
             [in-line-comment? #f]
             [in-block-comment? #f]
             [escaped? #f])
    (cond
      [(>= k len) len]
      [else
       (define c (string-ref s k))
       (define c2 (next-char s (add1 k)))
       (cond
         [in-line-comment?
          (if (or (char=? c #\newline) (char=? c #\return))
              (loop (add1 k) depth in-single? in-double? in-backtick? #f in-block-comment? #f)
              (loop (add1 k) depth in-single? in-double? in-backtick? in-line-comment? in-block-comment? #f))]
         [in-block-comment?
          (if (and c2 (char=? c #\*) (char=? c2 #\/))
              (loop (+ k 2) depth in-single? in-double? in-backtick? #f #f #f)
              (loop (add1 k) depth in-single? in-double? in-backtick? #f #t #f))]
         [escaped?
          (loop (add1 k) depth in-single? in-double? in-backtick? #f #f #f)]
         [in-single?
          (cond
            [(char=? c #\\) (loop (add1 k) depth #t in-double? in-backtick? #f #f #t)]
            [(char=? c #\') (loop (add1 k) depth #f in-double? in-backtick? #f #f #f)]
            [else (loop (add1 k) depth #t in-double? in-backtick? #f #f #f)])]
         [in-double?
          (cond
            [(char=? c #\\) (loop (add1 k) depth in-single? #t in-backtick? #f #f #t)]
            [(char=? c #\") (loop (add1 k) depth in-single? #f in-backtick? #f #f #f)]
            [else (loop (add1 k) depth in-single? #t in-backtick? #f #f #f)])]
         [in-backtick?
          (cond
            [(char=? c #\\) (loop (add1 k) depth in-single? in-double? #t #f #f #t)]
            [(char=? c #\`) (loop (add1 k) depth in-single? in-double? #f #f #f #f)]
            [else (loop (add1 k) depth in-single? in-double? #t #f #f #f)])]
         [else
          (cond
            [(and c2 (char=? c #\/) (char=? c2 #\/))
             (loop (+ k 2) depth in-single? in-double? in-backtick? #t #f #f)]
            [(and c2 (char=? c #\/) (char=? c2 #\*))
             (loop (+ k 2) depth in-single? in-double? in-backtick? #f #t #f)]
            [(char=? c #\') (loop (add1 k) depth #t in-double? in-backtick? #f #f #f)]
            [(char=? c #\") (loop (add1 k) depth in-single? #t in-backtick? #f #f #f)]
            [(char=? c #\`) (loop (add1 k) depth in-single? in-double? #t #f #f #f)]
            [(char=? c #\{) (loop (add1 k) (add1 depth) in-single? in-double? in-backtick? #f #f #f)]
            [(char=? c #\})
             (if (= depth 1) k
                 (loop (add1 k) (sub1 depth) in-single? in-double? in-backtick? #f #f #f))]
            [else (loop (add1 k) depth in-single? in-double? in-backtick? #f #f #f)])])])))

(define (tokenize-js-template s i)
  (define len (string-length s))
  (define tokens null)
  (define (push cls a b)
    (when (< a b)
      (set! tokens (cons (cons cls (substring s a b)) tokens))))
  (define k (add1 i))
  (define seg-start i)
  (let loop ()
    (cond
      [(>= k len)
       (push 'value seg-start len)
       (values (reverse tokens) len)]
      [else
       (define c (string-ref s k))
       (define c2 (next-char s (add1 k)))
       (cond
         [(char=? c #\\)
          (set! k (if c2 (+ k 2) (add1 k)))
          (loop)]
         [(char=? c #\`)
          (push 'value seg-start (add1 k))
          (values (reverse tokens) (add1 k))]
         [(and c2 (char=? c #\$) (char=? c2 #\{))
          (push 'value seg-start k)
          (push 'punct k (+ k 2))
          (define expr-start (+ k 2))
          (define expr-end (js-template-expr-end s expr-start))
          (define expr-src
            (if (<= expr-end len)
                (substring s expr-start expr-end)
                ""))
          (define expr-tokens
            (if (>= (current-js-template-depth) 8)
                (list (cons 'plain expr-src))
                (parameterize ([current-js-template-depth (add1 (current-js-template-depth))])
                  (tokenize-js expr-src))))
          (set! tokens (append (reverse expr-tokens) tokens))
          (if (< expr-end len)
              (begin
                (push 'punct expr-end (add1 expr-end))
                (set! k (add1 expr-end))
                (set! seg-start k)
                (loop))
              (values (reverse tokens) len))]
         [else
          (set! k (add1 k))
          (loop)])])))

(define (tokenize-js-handwritten s)
  (define len (string-length s))
  (define (has-fn-kind? brace-stack kinds)
    (for/or ([k (in-list brace-stack)])
      (and (symbol? k) (member k kinds))))
  (let loop ([i 0]
             [acc null]
             [can-start-regex? #t]
             [last-keyword #f]
             [paren-stack null]
             [decl-state 'none]
             [brace-stack null]
             [pending-fn-kind #f]
             [expect-params? #f]
             [pending-async? #f])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j
                     [next-can-start-regex? #f]
                     [next-last-keyword #f]
                     [next-paren-stack paren-stack]
                     [next-decl-state decl-state]
                     [next-brace-stack brace-stack]
                     [next-pending-fn-kind pending-fn-kind]
                     [next-expect-params? expect-params?]
                     [next-pending-async? pending-async?])
         (loop j
               (cons (cons cls (substring s i j)) acc)
               next-can-start-regex?
               next-last-keyword
               next-paren-stack
               next-decl-state
               next-brace-stack
               next-pending-fn-kind
               next-expect-params?
               next-pending-async?))
       (cond
         [(and (current-jsx?)
               (char=? ch #\<)
               (jsx-start-candidate? s i)
               (not (tsx-generic-angle-candidate? s i)))
          (define-values (jsx-tokens j) (tokenize-jsx-tag s i))
          (loop j (append (reverse jsx-tokens) acc) #f #f paren-stack decl-state
                brace-stack pending-fn-kind expect-params? pending-async?)]
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\*))
          (emit 'comment (read-until s (+ i 2) "*/") can-start-regex? last-keyword paren-stack decl-state)]
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\/))
          (define j (read-until s (+ i 2) "\n"))
          (emit 'comment j can-start-regex? last-keyword paren-stack decl-state)]
         [(and (char=? ch #\#)
               (< (add1 i) len)
               (js-ident-start? (string-ref s (add1 i))))
          (define j (read-while s (add1 i) js-ident-char?))
          (emit 'private-name j #f #f paren-stack decl-state)]
         [(or (char=? ch #\") (char=? ch #\'))
          (emit 'value (read-js-string-literal s i) #f #f paren-stack decl-state)]
         [(char=? ch #\`)
          (define-values (template-tokens j) (tokenize-js-template s i))
          (loop j (append (reverse template-tokens) acc) #f #f paren-stack decl-state
                brace-stack pending-fn-kind expect-params? pending-async?)]
         [(char-whitespace? ch)
          (emit 'plain (add1 i) can-start-regex? last-keyword paren-stack decl-state)]
         [(or (char-numeric? ch)
              (and (char=? ch #\.)
                   (< (add1 i) len)
                   (char-numeric? (string-ref s (add1 i))))
              (and (member ch '(#\+ #\-))
                   (< (add1 i) len)
                   (let ([c2 (string-ref s (add1 i))])
                     (or (char-numeric? c2)
                         (char=? c2 #\.)))))
          (emit 'value (read-js-number s i) #f #f paren-stack decl-state)]
         [(js-ident-start? ch)
          (define j (read-while s i js-ident-char?))
          (define id (string->symbol (substring s i j)))
          (define in-async?
            (has-fn-kind? brace-stack '(fn-async fn-async-generator)))
          (define in-generator?
            (has-fn-kind? brace-stack '(fn-generator fn-async-generator)))
          (define base-kw? (memq id js-keywords))
          (define kw?
            (cond
              [(eq? id 'await) (and base-kw? in-async?)]
              [(eq? id 'yield) (and base-kw? in-generator?)]
              [else base-kw?]))
          (define prevc (prev-nonspace-char s i))
          (define nextc (next-nonspace-char s j))
          (define decl-name?
            (and (not kw?)
                 (member decl-state '(var-name function-name class-name))))
          (define object-key?
            (and (not kw?)
                 nextc
                 (char=? nextc #\:)
                 (member prevc '(#\{ #\,))))
          (define param-name?
            (and (not kw?)
                 (pair? paren-stack)
                 (eq? (car paren-stack) 'params)
                 (not object-key?)))
          (define prop-name?
            (and (not kw?) prevc (char=? prevc #\.)))
          (define method-name?
            (and prop-name? nextc (string=? (string nextc) "(")))
          (define static-block?
            (and kw? (eq? id 'static) nextc (char=? nextc #\{)))
          (define next-decl
            (cond
              [(and kw? (member id '(const let var))) 'var-name]
              [(and kw? (eq? id 'function)) 'function-name]
              [(and kw? (eq? id 'class)) 'class-name]
              [(and kw? (member id '(in of))) 'none]
              [decl-name? 'none]
              [else decl-state]))
          (define next-fn-kind
            (if (and kw? (eq? id 'function))
                (let* ([k (next-nonspace-index s j)]
                       [gen? (and k (< k len) (char=? (string-ref s k) #\*))])
                  (cond
                    [(and pending-async? gen?) 'fn-async-generator]
                    [pending-async? 'fn-async]
                    [gen? 'fn-generator]
                    [else 'fn-normal]))
                pending-fn-kind))
          (emit (cond [static-block? 'static-keyword]
                      [kw? 'keyword]
                      [object-key? 'object-key]
                      [method-name? 'method-name]
                      [prop-name? 'prop-name]
                      [param-name? 'param-name]
                      [decl-name? 'decl-name]
                      [else 'name])
                j
                (if kw? (js-ident-can-start-regex? id kw?) #f)
                (and kw? id)
                paren-stack
                next-decl
                brace-stack
                next-fn-kind
                (or expect-params? (and kw? (member id '(function catch))))
                (and kw? (eq? id 'async)))]
         [(char=? ch #\/)
          (cond
            [can-start-regex?
             (define j (read-js-regex s i))
             (if j
                 (emit 'value j #f)
                 (emit 'operator (or (read-js-operator s i) (add1 i))
                       (js-operator-can-start-regex? (substring s i (or (read-js-operator s i) (add1 i))))
                       #f paren-stack 'none))]
            [else
             (define j (or (read-js-operator s i) (add1 i)))
             (define op (substring s i j))
             (emit 'operator j (js-operator-can-start-regex? op) #f paren-stack 'none)])]
         [(js-delimiter-char? ch)
          (define j (add1 i))
          (cond
            [(char=? ch #\()
             (define open-kind
               (cond
                 [expect-params? 'params]
                 [(and last-keyword (memq last-keyword js-condition-open-keywords))
                  'condition]
                 [else 'group]))
             (emit 'punct j #t #f (cons open-kind paren-stack) decl-state
                   brace-stack pending-fn-kind #f pending-async?)]
            [(char=? ch #\{)
             (define new-brace
               (if pending-fn-kind
                   (cons pending-fn-kind brace-stack)
                   (cons #f brace-stack)))
             (emit 'punct j #t #f paren-stack decl-state
                   new-brace #f expect-params? pending-async?)]
            [(char=? ch #\))
             (define popped (and (pair? paren-stack) (car paren-stack)))
             (define rest-stack (if (pair? paren-stack) (cdr paren-stack) paren-stack))
             (emit 'punct j (eq? popped 'condition) #f rest-stack
                   (if (eq? decl-state 'var-name) 'none decl-state))]
            [(char=? ch #\})
             (emit 'punct j #f #f paren-stack 'none
                   (if (pair? brace-stack) (cdr brace-stack) brace-stack)
                   pending-fn-kind expect-params? pending-async?)]
            [(char=? ch #\])
             (emit 'punct j #f #f paren-stack 'none)]
            [(char=? ch #\;)
             (emit 'punct j #t #f paren-stack 'none
                   brace-stack pending-fn-kind #f #f)]
            [else
             (emit 'punct j #t #f paren-stack decl-state)])]
         [(read-js-operator s i)
          (define j (read-js-operator s i))
          (define op (substring s i j))
          (define next-decl
            (cond
              [(and (eq? decl-state 'var-name) (string=? op ",")) 'var-name]
              [(eq? decl-state 'var-name) 'none]
              [else decl-state]))
          (emit 'operator j (js-operator-can-start-regex? op) #f paren-stack next-decl)]
         [else
          (emit 'plain (add1 i) can-start-regex? last-keyword paren-stack decl-state)])])))

(define js-delimiter-texts
  '("{" "}" "(" ")" "[" "]" "," ";" "." "${" "}" "<" ">" "</" "/>" "<>" "</>"))

(define (js-whitespace-text? txt)
  (and (not (string=? txt ""))
       (regexp-match? #px"^\\s+$" txt)))

(define (js-operator-text? txt)
  (member txt js-operators))

(define (tokenize-js s)
  ;; Keep JSX on the handwritten path for now. The old lexer has a TSX-like
  ;; generic-angle heuristic (`<T>(x) => x`) that `lexers/javascript` in JSX
  ;; mode does not currently match, and the docs/tests rely on that behavior.
  (if (current-jsx?)
      (tokenize-js-handwritten s)
      (for/list ([token (in-list (javascript-string->derived-tokens s
                                                                   #:jsx? #f))])
        (define txt (javascript-derived-token-text token))
        (define cls
          (cond
            [(javascript-derived-token-has-tag? token 'comment) 'comment]
            [(js-whitespace-text? txt) 'plain]
            [(javascript-derived-token-has-tag? token 'static-keyword-usage) 'static-keyword]
            [(javascript-derived-token-has-tag? token 'object-key) 'object-key]
            [(javascript-derived-token-has-tag? token 'parameter-name) 'param-name]
            [(javascript-derived-token-has-tag? token 'declaration-name) 'decl-name]
            [(javascript-derived-token-has-tag? token 'private-name) 'private-name]
            [(javascript-derived-token-has-tag? token 'method-name) 'method-name]
            [(javascript-derived-token-has-tag? token 'property-name) 'prop-name]
            [(javascript-derived-token-has-tag? token 'keyword) 'keyword]
            [(javascript-derived-token-has-tag? token 'identifier) 'name]
            [(javascript-derived-token-has-tag? token 'template-interpolation-boundary)
             'punct]
            [(or (javascript-derived-token-has-tag? token 'string-literal)
                 (javascript-derived-token-has-tag? token 'numeric-literal)
                 (javascript-derived-token-has-tag? token 'regex-literal)
                 (javascript-derived-token-has-tag? token 'template-literal)
                 (javascript-derived-token-has-tag? token 'template-chunk))
             'value]
            [(member txt js-delimiter-texts)
             'punct]
            [(js-operator-text? txt) 'operator]
            [else 'plain]))
        (cons cls txt))))

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
            [(or (char=? ch #\newline) (char=? ch #\return))
             ;; Recover from malformed tags by stopping at line boundary.
             (values (reverse tokens) j tag-name closing? #f)]
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
                               (let* ([end (read-string-literal s j)]
                                      [closed? (and (< (sub1 end) len)
                                                    (> end j)
                                                    (char=? (string-ref s (sub1 end)) q))])
                                 (if closed?
                                     (push 'value j end)
                                     (push 'plain j end))
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

(define (find-script/style-close s start tag)
  (define len (string-length s))
  (define close-mark (string-append "</" tag))
  (let loop ([i start]
             [in-single? #f]
             [in-double? #f]
             [in-backtick? #f]
             [in-line-comment? #f]
             [in-block-comment? #f]
             [escaped? #f])
    (cond
      [(>= i len) len]
      [else
       (define c (string-ref s i))
       (define c2 (next-char s (add1 i)))
       (define close? (string-ci-prefix-at? s i close-mark))
       (cond
         [(and close?
               (not in-single?) (not in-double?) (not in-backtick?)
               (not in-line-comment?) (not in-block-comment?))
          i]
         [in-line-comment?
          (if (or (char=? c #\newline) (char=? c #\return))
              (loop (add1 i) in-single? in-double? in-backtick? #f in-block-comment? #f)
              (loop (add1 i) in-single? in-double? in-backtick? #t in-block-comment? #f))]
         [in-block-comment?
          (if (and c2 (char=? c #\*) (char=? c2 #\/))
              (loop (+ i 2) in-single? in-double? in-backtick? #f #f #f)
              (loop (add1 i) in-single? in-double? in-backtick? #f #t #f))]
         [escaped?
          (loop (add1 i) in-single? in-double? in-backtick? #f #f #f)]
         [in-single?
          (cond
            [(char=? c #\\) (loop (add1 i) #t in-double? in-backtick? #f #f #t)]
            [(char=? c #\') (loop (add1 i) #f in-double? in-backtick? #f #f #f)]
            [else (loop (add1 i) #t in-double? in-backtick? #f #f #f)])]
         [in-double?
          (cond
            [(char=? c #\\) (loop (add1 i) in-single? #t in-backtick? #f #f #t)]
            [(char=? c #\") (loop (add1 i) in-single? #f in-backtick? #f #f #f)]
            [else (loop (add1 i) in-single? #t in-backtick? #f #f #f)])]
         [in-backtick?
          (cond
            [(char=? c #\\) (loop (add1 i) in-single? in-double? #t #f #f #t)]
            [(char=? c #\`) (loop (add1 i) in-single? in-double? #f #f #f #f)]
            [else (loop (add1 i) in-single? in-double? #t #f #f #f)])]
         [else
          (cond
            [(and c2 (char=? c #\/) (char=? c2 #\/))
             (loop (+ i 2) in-single? in-double? in-backtick? #t #f #f)]
            [(and c2 (char=? c #\/) (char=? c2 #\*))
             (loop (+ i 2) in-single? in-double? in-backtick? #f #t #f)]
            [(char=? c #\') (loop (add1 i) #t in-double? in-backtick? #f #f #f)]
            [(char=? c #\") (loop (add1 i) in-single? #t in-backtick? #f #f #f)]
            [(char=? c #\`) (loop (add1 i) in-single? in-double? #t #f #f #f)]
            [else (loop (add1 i) #f #f #f #f #f #f)])])])))

(define (tokenize-html-handwritten s)
  (define len (string-length s))
  (let loop ([i 0] [mode 'text] [acc null])
    (define (emit cls a b [new-mode mode])
      (if (< a b)
          (loop b new-mode (cons (cons cls (substring s a b)) acc))
          (loop b new-mode acc)))
    (cond
      [(>= i len) (reverse acc)]
      [(eq? mode 'script)
       (define close-i (find-script/style-close s i "script"))
       (define js-body-tokens
         (if (< i close-i)
             (insert-js-preview-tokens
              (tokenize-js (substring s i close-i))
              (current-html-script-preview?))
             null))
       (define acc2
         (if (< i close-i)
             (append (reverse js-body-tokens) acc)
             acc))
       (if (>= close-i len)
           (reverse acc2)
           (let-values ([(tag-tokens j _tag-name _closing? _self-closing?)
                         (parse-html-tag s close-i)])
             (loop j 'text (append (reverse tag-tokens) acc2))))]
      [(eq? mode 'style)
       (define close-i (find-script/style-close s i "style"))
       (define mode-val (current-html-style-preview-mode))
       (define enabled? (not (eq? mode-val 'none)))
       (define css-body-tokens
         (if (< i close-i)
             (let* ([base (tokenize-css (substring s i close-i))]
                    [with-color (insert-css-color-swatch-tokens base (and enabled? (current-html-style-color-swatch?)))]
                    [with-font (insert-css-font-preview-tokens with-color (and enabled? (current-html-style-font-preview?)))]
                    [with-dim (insert-css-dimension-preview-tokens with-font (and enabled? (current-html-style-dimension-preview?)))]
                    [with-token (insert-css-design-token-tokens with-dim enabled?)])
               (move-css-decorations-to-decl-end with-token))
             null))
       (define acc2
         (if (< i close-i)
             (append (reverse css-body-tokens) acc)
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

(define (tokenize-html s)
  (define tokens (html-string->derived-tokens s))
  (define count (length tokens))
  (define mode-val (current-html-style-preview-mode))
  (define style-preview-enabled? (not (eq? mode-val 'none)))
  (define (html-token-class token)
    (cond
      [(html-derived-token-has-tag? token 'comment) 'comment]
      [(html-derived-token-has-tag? token 'html-doctype) 'keyword]
      [(or (html-derived-token-has-tag? token 'html-tag-name)
           (html-derived-token-has-tag? token 'html-closing-tag-name))
       'keyword]
      [(html-derived-token-has-tag? token 'html-attribute-name) 'name]
      [(or (html-derived-token-has-tag? token 'html-attribute-value)
           (html-derived-token-has-tag? token 'html-entity))
       'value]
      [(or (html-derived-token-has-tag? token 'delimiter)
           (html-derived-token-has-tag? token 'operator))
       'punct]
      [else 'plain]))
  (define (collect-embedded-text start tag)
    (let loop ([i start] [pieces null])
      (cond
        [(>= i count)
         (values (apply string-append (reverse pieces)) i)]
        [(html-derived-token-has-tag? (list-ref tokens i) tag)
         (loop (add1 i)
               (cons (html-derived-token-text (list-ref tokens i)) pieces))]
        [else
         (values (apply string-append (reverse pieces)) i)])))
  (let loop ([i 0] [acc null])
    (cond
      [(>= i count) (reverse acc)]
      [else
       (define token (list-ref tokens i))
       (cond
         [(html-derived-token-has-tag? token 'embedded-css)
          (define-values (body next-i) (collect-embedded-text i 'embedded-css))
          (define body-tokens
            (if (string=? body "")
                null
                (let* ([base (tokenize-css body)]
                       [with-color (insert-css-color-swatch-tokens base (and style-preview-enabled? (current-html-style-color-swatch?)))]
                       [with-font (insert-css-font-preview-tokens with-color (and style-preview-enabled? (current-html-style-font-preview?)))]
                       [with-dim (insert-css-dimension-preview-tokens with-font (and style-preview-enabled? (current-html-style-dimension-preview?)))]
                       [with-token (insert-css-design-token-tokens with-dim style-preview-enabled?)])
                  (move-css-decorations-to-decl-end with-token))))
          (loop next-i (append (reverse body-tokens) acc))]
         [(html-derived-token-has-tag? token 'embedded-javascript)
          (define-values (body next-i) (collect-embedded-text i 'embedded-javascript))
          (define body-tokens
            (if (string=? body "")
                null
                (insert-js-preview-tokens
                 (tokenize-js body)
                 (current-html-script-preview?))))
          (loop next-i (append (reverse body-tokens) acc))]
         [else
          (loop (add1 i)
                (cons (cons (html-token-class token)
                            (html-derived-token-text token))
                      acc))])])))

(define (shell-ident-start? c)
  (or (char-alphabetic? c) (char=? c #\_)))

(define (shell-ident-char? c)
  (or (shell-ident-start? c) (char-numeric? c)))

(define (shell-punct-char? c)
  (or (char=? c #\()
      (char=? c #\))
      (char=? c #\{)
      (char=? c #\})
      (char=? c #\[)
      (char=? c #\])
      (char=? c #\")
      (char=? c #\')
      (char=? c #\;)
      (char=? c #\|)
      (char=? c #\&)
      (char=? c #\<)
      (char=? c #\>)
      (char=? c #\`)))

(define (read-shell-braced-var s start)
  (define len (string-length s))
  (let loop ([i (+ start 2)] [depth 1])
    (cond
      [(>= i len) len]
      [else
       (define ch (string-ref s i))
       (cond
         [(char=? ch #\\) (loop (min len (+ i 2)) depth)]
         [(char=? ch #\{) (loop (add1 i) (add1 depth))]
         [(char=? ch #\}) (define d (sub1 depth))
          (if (zero? d) (add1 i) (loop (add1 i) d))]
         [else (loop (add1 i) depth)])])))

(define (read-shell-command-subst s start)
  (define len (string-length s))
  (let loop ([i (+ start 2)] [depth 1])
    (cond
      [(>= i len) len]
      [else
       (define ch (string-ref s i))
       (cond
         [(char=? ch #\\) (loop (min len (+ i 2)) depth)]
         [(or (char=? ch #\") (char=? ch #\'))
          (loop (read-string-literal s i) depth)]
         [(and (char=? ch #\$)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\())
          (loop (+ i 2) (add1 depth))]
         [(char=? ch #\() (loop (add1 i) (add1 depth))]
         [(char=? ch #\)) (define d (sub1 depth))
          (if (zero? d) (add1 i) (loop (add1 i) d))]
         [else (loop (add1 i) depth)])])))

(define (read-shell-backticks s start)
  (define len (string-length s))
  (let loop ([i (add1 start)] [esc? #f])
    (cond
      [(>= i len) len]
      [esc? (loop (add1 i) #f)]
      [else
       (define ch (string-ref s i))
       (cond
         [(char=? ch #\\) (loop (add1 i) #t)]
         [(char=? ch #\`) (add1 i)]
         [else (loop (add1 i) #f)])])))

(define (shell-comment-start? s i)
  (define ch (string-ref s i))
  (and (char=? ch #\#)
       (or (zero? i)
           (let ([p (string-ref s (sub1 i))])
             (or (char-whitespace? p)
                 (shell-punct-char? p)
                 (char=? p #\=))))))

(define (read-shell-word s i)
  (read-while s i
              (lambda (c)
                (and (not (char-whitespace? c))
                     (not (shell-punct-char? c))))))

(define (shell-word-class shell txt)
  (define t (string-downcase txt))
  (cond
    [(string=? t "") 'plain]
    [(or (set-member? shell-keywords/common t)
         (and (eq? shell 'zsh) (set-member? shell-builtins/zsh t)))
     'keyword]
    [(and (eq? shell 'powershell)
          (or (set-member? shell-keywords/powershell t)
              (regexp-match? #px"^[a-z][a-z0-9]*-[a-z][a-z0-9-]*$" t)))
     'keyword]
    [(set-member? shell-builtins/common t) 'keyword]
    [(regexp-match? #px"^\\$\\{?.*" txt) 'value]
    [(regexp-match? #px"^[a-zA-Z_][a-zA-Z0-9_]*=.*" txt) 'name]
    [(regexp-match? #px"^-{1,2}[a-zA-Z0-9][a-zA-Z0-9_-]*$" txt) 'value]
    [(regexp-match? #px"^[0-9]+$" txt) 'value]
    [else 'name]))

(define (tokenize-shell-handwritten shell s)
  (define sh (normalize-scribble-shell 'tokenize-shell shell))
  (define len (string-length s))
  (let loop ([i 0] [acc null])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j)
         (loop j (cons (cons cls (substring s i j)) acc)))
       (cond
         [(char-whitespace? ch)
          (emit 'plain (read-while s i char-whitespace?))]
         [(shell-comment-start? s i)
          (define j
            (let find-line-end ([k (add1 i)])
              (cond
                [(>= k len) len]
                [(char=? (string-ref s k) #\newline) k]
                [else (find-line-end (add1 k))])))
          (emit 'comment j)]
         [(or (char=? ch #\") (char=? ch #\'))
          (emit 'value (read-string-literal s i))]
         [(char=? ch #\`)
          (emit 'value (read-shell-backticks s i))]
         [(and (char=? ch #\$) (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\{))
          (emit 'value (read-shell-braced-var s i))]
         [(and (char=? ch #\$) (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\())
          (emit 'value (read-shell-command-subst s i))]
         [(char=? ch #\$)
          (define j
            (if (and (< (add1 i) len)
                     (or (shell-ident-start? (string-ref s (add1 i)))
                         (char-numeric? (string-ref s (add1 i)))
                         (memv (string-ref s (add1 i)) '(#\* #\@ #\# #\? #\! #\- #\$ #\_))))
                (read-while s (add1 i)
                            (lambda (c)
                              (or (shell-ident-char? c)
                                  (char-numeric? c)
                                  (memv c '(#\* #\@ #\# #\? #\! #\- #\$ #\_)))))
                (add1 i)))
          (emit 'value j)]
         [(shell-punct-char? ch)
          (define two (if (< (add1 i) len) (substring s i (+ i 2)) #f))
          (define j
            (if (and two (member two '("&&" "||" ">>" "<<" ";;" ";&" "|&" ">&" "<&" ">|" "<<-" "<<<")))
                (+ i 2)
                (add1 i)))
          (emit 'punct j)]
         [else
          (define j (read-shell-word s i))
          (emit (shell-word-class sh (substring s i j)) j)])])))

(define (tokenize-shell shell s)
  (define sh (normalize-scribble-shell 'tokenize-shell shell))
  (for/list ([token (in-list (shell-string->derived-tokens s #:shell sh))])
    (define txt (shell-derived-token-text token))
    (define cls
      (cond
        [(shell-derived-token-has-tag? token 'comment) 'comment]
        [(shell-derived-token-has-tag? token 'whitespace) 'plain]
        [(or (shell-derived-token-has-tag? token 'shell-string-literal)
             (shell-derived-token-has-tag? token 'shell-ansi-string-literal)
             (shell-derived-token-has-tag? token 'shell-variable)
             (shell-derived-token-has-tag? token 'shell-command-substitution)
             (shell-derived-token-has-tag? token 'literal))
         'value]
        [(or (shell-derived-token-has-tag? token 'shell-pipeline-operator)
             (shell-derived-token-has-tag? token 'shell-logical-operator)
             (shell-derived-token-has-tag? token 'shell-redirection-operator)
             (shell-derived-token-has-tag? token 'shell-heredoc-operator))
         'operator]
        [(shell-derived-token-has-tag? token 'delimiter) 'punct]
        [(or (shell-derived-token-has-tag? token 'shell-builtin)
             (shell-derived-token-has-tag? token 'shell-keyword)
             (shell-derived-token-has-tag? token 'keyword))
         'keyword]
        [(or (shell-derived-token-has-tag? token 'shell-word)
             (shell-derived-token-has-tag? token 'identifier))
         (shell-word-class sh txt)]
        [else 'plain]))
    (cons cls txt)))

(define (wasm-word-char? ch)
  (or (char-alphabetic? ch)
      (char-numeric? ch)
      (memv ch '(#\$ #\_ #\- #\. #\/ #\! #\? #\= #\+ #\< #\> #\: #\@))))

(define (wasm-number? txt)
  (or (regexp-match? #px"^[+-]?[0-9][0-9_]*$" txt)
      (regexp-match? #px"^[+-]?0x[0-9a-fA-F][0-9a-fA-F_]*$" txt)
      (regexp-match? #px"^[+-]?[0-9][0-9_]*\\.[0-9_]+([eE][+-]?[0-9_]+)?$" txt)
      (regexp-match? #px"^[+-]?[0-9][0-9_]*[eE][+-]?[0-9_]+$" txt)
      (regexp-match? #px"^[+-]?(inf|nan)(:0x[0-9a-fA-F][0-9a-fA-F_]*)?$" (string-downcase txt))))

(define (wasm-word-class txt)
  (cond
    [(set-member? wasm-form-keywords txt) 'wasm-form]
    [(set-member? wasm-type-keywords txt) 'wasm-type]
    [(set-member? wasm-instruction-keywords txt) 'wasm-instr]
    [(or (regexp-match? #px"^[if][0-9]{2}\\.[a-z][a-z0-9_]*$" txt)
         (regexp-match? #px"^v[0-9]+\\.[a-z][a-z0-9_]*$" txt))
     'wasm-instr]
    [(string-prefix? txt "$") 'wasm-id]
    [(wasm-number? txt) 'value]
    [else 'name]))

(define (read-wasm-string s start)
  (let loop ([i (+ start 1)] [esc? #f])
    (cond
      [(>= i (string-length s)) i]
      [esc? (loop (add1 i) #f)]
      [else
       (define ch (string-ref s i))
       (cond
         [(char=? ch #\\) (loop (add1 i) #t)]
         [(char=? ch #\") (add1 i)]
         [else (loop (add1 i) #f)])])))

(define (read-wasm-block-comment s start)
  (let loop ([i (+ start 2)] [depth 1])
    (cond
      [(>= i (string-length s)) i]
      [else
       (define c1 (string-ref s i))
       (define c2 (and (< (add1 i) (string-length s))
                       (string-ref s (add1 i))))
       (cond
         [(and c2 (char=? c1 #\() (char=? c2 #\;))
          (loop (+ i 2) (add1 depth))]
         [(and c2 (char=? c1 #\;) (char=? c2 #\)))
          (define d (sub1 depth))
          (if (zero? d) (+ i 2) (loop (+ i 2) d))]
         [else (loop (add1 i) depth)])])))

(define (tokenize-wasm-handwritten s)
  (define len (string-length s))
  (let loop ([i 0] [acc null])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (cond
         [(char-whitespace? ch)
          (define j (read-while s i char-whitespace?))
          (loop j (cons (cons 'plain (substring s i j)) acc))]
         [(and (< (add1 i) len)
               (char=? ch #\;)
               (char=? (string-ref s (add1 i)) #\;))
          (define j
            (let find-line-end ([k (+ i 2)])
              (cond
                [(>= k len) len]
                [(char=? (string-ref s k) #\newline) k]
                [else (find-line-end (add1 k))])))
          (loop j (cons (cons 'comment (substring s i j)) acc))]
         [(and (< (add1 i) len)
               (char=? ch #\()
               (char=? (string-ref s (add1 i)) #\;))
          (define j (read-wasm-block-comment s i))
          (loop j (cons (cons 'comment (substring s i j)) acc))]
         [(or (char=? ch #\() (char=? ch #\)))
          (loop (add1 i) (cons (cons 'punct (substring s i (add1 i))) acc))]
         [(char=? ch #\")
          (define j (read-wasm-string s i))
          (loop j (cons (cons 'value (substring s i j)) acc))]
         [else
          (define j (read-while s i (lambda (c)
                                      (and (not (char-whitespace? c))
                                           (not (char=? c #\())
                                           (not (char=? c #\)))
                                           (not (char=? c #\;))
                                           (not (char=? c #\"))))))
          (define txt (substring s i j))
          (define cls
            (cond
              [(string=? txt "") 'plain]
              [(wasm-word-char? (string-ref txt 0)) (wasm-word-class txt)]
              [else 'plain]))
          (loop j (cons (cons cls txt) acc))])])))

(define (tokenize-wasm s)
  (define (class-map name txt)
    (case name
      [(comment) 'comment]
      [(delimiter) 'punct]
      [(literal) 'value]
      [(keyword identifier)
       (wasm-word-class txt)]
      [else 'plain]))
  (for/list ([token (in-list (wat-string->tokens s
                                                 #:profile 'coloring
                                                 #:source-positions #t))]
             #:unless (lexer-token-eof? token))
    (wat-projected-token->scribble-token token #:class-map class-map)))

(define (c-family-derived-token->piece token
                                       token-has-tag?
                                       token-text
                                       #:preprocessor-class [preprocessor-class 'name]
                                       #:objc? [objc? #f])
  (define txt (token-text token))
  (cons
   (cond
     [(token-has-tag? token 'comment) 'comment]
     [(token-has-tag? token 'whitespace) 'plain]
     [(token-has-tag? token 'malformed-token) 'plain]
     [(or (token-has-tag? token 'c-preprocessor-directive)
          (token-has-tag? token 'cpp-preprocessor-directive)
          (token-has-tag? token 'objc-preprocessor-directive))
      preprocessor-class]
     [(or (token-has-tag? token 'objc-at-keyword)
          (token-has-tag? token 'keyword))
      'keyword]
     [(token-has-tag? token 'objc-literal-introducer) 'operator]
     [(or (token-has-tag? token 'c-string-literal)
          (token-has-tag? token 'c-char-literal)
          (token-has-tag? token 'c-header-name)
          (token-has-tag? token 'cpp-string-literal)
          (token-has-tag? token 'cpp-char-literal)
          (token-has-tag? token 'cpp-numeric-literal)
          (token-has-tag? token 'cpp-header-name)
          (token-has-tag? token 'objc-string-literal)
          (token-has-tag? token 'objc-char-literal)
          (token-has-tag? token 'literal))
      'value]
     [(or (token-has-tag? token 'c-line-splice)
          (token-has-tag? token 'cpp-line-splice)
          (token-has-tag? token 'operator))
      'operator]
     [(or (token-has-tag? token 'cpp-delimiter)
          (token-has-tag? token 'delimiter))
      'punct]
     [(or (token-has-tag? token 'c-identifier)
          (and objc? (string-prefix? txt "@")))
      'name]
     [(token-has-tag? token 'identifier) 'name]
     [else 'plain])
   txt))

(define (c-family-type-name? lang txt cls prev1 prev2)
  (define t txt)
  (or (set-member? c-family-builtin-type-names t)
      (set-member? c-family-common-type-names t)
      (and (eq? lang 'cpp)
           (set-member? cpp-common-type-names t))
      (and prev1
           (eq? (car prev1) 'keyword)
           (set-member? c-family-type-introducers (cdr prev1))
           (memq cls '(name keyword)))
      (and (eq? lang 'cpp)
           prev1 prev2
           (eq? (car prev1) 'punct)
           (string=? (cdr prev1) "::")
           (memq (car prev2) '(name type-name))
           (or (string=? (cdr prev2) "std")
               (string=? (cdr prev2) "pmr"))
           (set-member? cpp-common-type-names t))))

(define (tokenize-c-family tokens
                           token-has-tag?
                           token-text
                           #:lang lang
                           #:preprocessor-class [preprocessor-class 'name]
                           #:objc? [objc? #f])
  (let loop ([rest tokens] [acc null] [prev1 #f] [prev2 #f])
    (cond
      [(null? rest) (reverse acc)]
      [else
       (define piece0
         (c-family-derived-token->piece (car rest)
                                        token-has-tag?
                                        token-text
                                        #:preprocessor-class preprocessor-class
                                        #:objc? objc?))
       (define piece
         (if (c-family-type-name? lang (cdr piece0) (car piece0) prev1 prev2)
             (cons 'type-name (cdr piece0))
             piece0))
       (define next-prev1 (if (token-nonplain? piece) piece prev1))
       (define next-prev2 (if (token-nonplain? piece) prev1 prev2))
       (loop (cdr rest) (cons piece acc) next-prev1 next-prev2)])))

(define (tokenize-c s)
  (tokenize-c-family (c-string->derived-tokens s)
                     c-derived-token-has-tag?
                     c-derived-token-text
                     #:lang 'c))

(define (tokenize-cpp s)
  (tokenize-c-family (cpp-string->derived-tokens s)
                     cpp-derived-token-has-tag?
                     cpp-derived-token-text
                     #:lang 'cpp))

(define (tokenize-objc s)
  (tokenize-c-family (objc-string->derived-tokens s)
                     objc-derived-token-has-tag?
                     objc-derived-token-text
                     #:lang 'objc
                     #:preprocessor-class 'keyword
                     #:objc? #t))

(define (tex-derived-token->piece token)
  (define txt (tex-derived-token-text token))
  (cons
   (cond
     [(tex-derived-token-has-tag? token 'comment) 'comment]
     [(tex-derived-token-has-tag? token 'whitespace) 'plain]
     [(tex-derived-token-has-tag? token 'malformed-token) 'plain]
     [(tex-derived-token-has-tag? token 'tex-verbatim-literal) 'value]
     [(or (tex-derived-token-has-tag? token 'tex-math-shift)
          (tex-derived-token-has-tag? token 'tex-display-math-shift)
          (tex-derived-token-has-tag? token 'tex-inline-math-shift)
          (tex-derived-token-has-tag? token 'tex-line-break-command)
          (tex-derived-token-has-tag? token 'tex-alignment-tab)
          (tex-derived-token-has-tag? token 'tex-subscript-mark)
          (tex-derived-token-has-tag? token 'tex-superscript-mark)
          (tex-derived-token-has-tag? token 'tex-unbreakable-space)
          (tex-derived-token-has-tag? token 'tex-special-char)
          (tex-derived-token-has-tag? token 'tex-special-character)
          (tex-derived-token-has-tag? token 'tex-parameter-marker)
          (tex-derived-token-has-tag? token 'tex-parameter-reference)
          (tex-derived-token-has-tag? token 'tex-parameter-escape))
      'operator]
     [(or (tex-derived-token-has-tag? token 'tex-open-group-delimiter)
          (tex-derived-token-has-tag? token 'tex-close-group-delimiter)
          (tex-derived-token-has-tag? token 'tex-open-optional-delimiter)
          (tex-derived-token-has-tag? token 'tex-close-optional-delimiter)
          (tex-derived-token-has-tag? token 'tex-group-delimiter)
          (tex-derived-token-has-tag? token 'tex-optional-delimiter)
          (tex-derived-token-has-tag? token 'delimiter))
      'punct]
     [(tex-derived-token-has-tag? token 'tex-environment-name) 'name]
     [(or (tex-derived-token-has-tag? token 'tex-command)
          (tex-derived-token-has-tag? token 'tex-control-word)
          (tex-derived-token-has-tag? token 'tex-control-symbol)
          (tex-derived-token-has-tag? token 'tex-accent-command)
          (tex-derived-token-has-tag? token 'tex-spacing-command)
          (tex-derived-token-has-tag? token 'tex-control-space)
          (tex-derived-token-has-tag? token 'tex-italic-correction)
          (tex-derived-token-has-tag? token 'tex-paragraph-command)
          (tex-derived-token-has-tag? token 'tex-environment-command)
          (tex-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (tex-derived-token-has-tag? token 'literal)
          (tex-derived-token-has-tag? token 'tex-parameter))
      'value]
     [else 'plain])
   txt))

(define (tokenize-tex s)
  (for/list ([token (in-list (tex-string->derived-tokens s))])
    (tex-derived-token->piece token)))

(define (plist-derived-token->piece token)
  (define txt (plist-derived-token-text token))
  (cons
   (cond
     [(plist-derived-token-has-tag? token 'comment) 'comment]
     [(plist-derived-token-has-tag? token 'whitespace) 'plain]
     [(plist-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (plist-derived-token-has-tag? token 'plist-processing-instruction)
          (plist-derived-token-has-tag? token 'plist-doctype))
      'keyword]
     [(or (plist-derived-token-has-tag? token 'plist-tag-name)
          (plist-derived-token-has-tag? token 'plist-closing-tag-name)
          (plist-derived-token-has-tag? token 'plist-attribute-name)
          (plist-derived-token-has-tag? token 'keyword))
      'keyword]
     [(plist-derived-token-has-tag? token 'plist-key-text) 'name]
     [(plist-derived-token-has-tag? token 'plist-entity) 'operator]
     [(or (plist-derived-token-has-tag? token 'plist-string-text)
          (plist-derived-token-has-tag? token 'plist-integer-text)
          (plist-derived-token-has-tag? token 'plist-real-text)
          (plist-derived-token-has-tag? token 'plist-date-text)
          (plist-derived-token-has-tag? token 'plist-data-text)
          (plist-derived-token-has-tag? token 'plist-attribute-value)
          (plist-derived-token-has-tag? token 'literal))
      'value]
     [(plist-derived-token-has-tag? token 'operator) 'operator]
     [(plist-derived-token-has-tag? token 'delimiter) 'punct]
     [else 'plain])
   txt))

(define (tokenize-plist s)
  (for/list ([token (in-list (plist-string->derived-tokens s))])
    (plist-derived-token->piece token)))

(define (python-derived-token->piece token)
  (define txt (python-derived-token-text token))
  (cons
   (cond
     [(python-derived-token-has-tag? token 'comment) 'comment]
     [(python-derived-token-has-tag? token 'whitespace) 'plain]
     [(python-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (python-derived-token-has-tag? token 'python-keyword)
          (python-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (python-derived-token-has-tag? token 'python-string-literal)
          (python-derived-token-has-tag? token 'python-f-string-literal)
          (python-derived-token-has-tag? token 'python-bytes-literal)
          (python-derived-token-has-tag? token 'python-t-string-literal)
          (python-derived-token-has-tag? token 'python-raw-string-literal)
          (python-derived-token-has-tag? token 'python-numeric-literal)
          (python-derived-token-has-tag? token 'literal))
      'value]
     [(or (python-derived-token-has-tag? token 'python-indent)
          (python-derived-token-has-tag? token 'python-dedent)
          (python-derived-token-has-tag? token 'python-line-join))
      'operator]
     [(or (python-derived-token-has-tag? token 'delimiter)
          (python-derived-token-has-tag? token 'python-nl))
      'punct]
     [(or (python-derived-token-has-tag? token 'python-identifier)
          (python-derived-token-has-tag? token 'identifier))
      'name]
     [else 'plain])
   txt))

(define (tokenize-python s)
  (for/list ([token (in-list (python-string->derived-tokens s))])
    (python-derived-token->piece token)))

(define (swift-derived-token->piece token)
  (define txt (swift-derived-token-text token))
  (cons
   (cond
     [(or (swift-derived-token-has-tag? token 'comment)
          (swift-derived-token-has-tag? token 'swift-comment))
      'comment]
     [(swift-derived-token-has-tag? token 'whitespace) 'plain]
     [(swift-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (swift-derived-token-has-tag? token 'swift-keyword)
          (swift-derived-token-has-tag? token 'swift-attribute)
          (swift-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (swift-derived-token-has-tag? token 'swift-string-literal)
          (swift-derived-token-has-tag? token 'swift-raw-string-literal)
          (swift-derived-token-has-tag? token 'literal))
      'value]
     [(or (swift-derived-token-has-tag? token 'swift-operator)
          (swift-derived-token-has-tag? token 'operator))
      'operator]
     [(swift-derived-token-has-tag? token 'delimiter) 'punct]
     [(swift-derived-token-has-tag? token 'identifier) 'name]
     [else 'plain])
   txt))

(define (tokenize-swift s)
  (define (swift-type-name? txt cls prev1 prev2)
    (or (set-member? swift-builtin-type-names txt)
        (and prev1
             (eq? (car prev1) 'keyword)
             (member (cdr prev1) '("struct" "class" "enum" "protocol" "typealias") string=?)
             (eq? cls 'name))
        (and prev1
             (eq? (car prev1) 'punct)
             (or (string=? (cdr prev1) ":")
                 (string=? (cdr prev1) "->"))
             (eq? cls 'name))
        (and prev1 prev2
             (eq? cls 'name)
             (eq? (car prev1) 'punct)
             (string=? (cdr prev1) ".")
             (memq (car prev2) '(name type-name)))))
  (let loop ([rest (swift-string->derived-tokens s)] [acc null] [prev1 #f] [prev2 #f])
    (cond
      [(null? rest) (reverse acc)]
      [else
       (define piece0 (swift-derived-token->piece (car rest)))
       (define piece
         (if (swift-type-name? (cdr piece0) (car piece0) prev1 prev2)
             (cons 'type-name (cdr piece0))
             piece0))
       (define next-prev1 (if (token-nonplain? piece) piece prev1))
       (define next-prev2 (if (token-nonplain? piece) prev1 prev2))
       (loop (cdr rest) (cons piece acc) next-prev1 next-prev2)])))

(define (pascal-derived-token->piece token)
  (define txt (pascal-derived-token-text token))
  (cons
   (cond
     [(or (pascal-derived-token-has-tag? token 'comment)
          (pascal-derived-token-has-tag? token 'pascal-comment))
      'comment]
     [(pascal-derived-token-has-tag? token 'whitespace) 'plain]
     [(pascal-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (pascal-derived-token-has-tag? token 'pascal-keyword)
          (pascal-derived-token-has-tag? token 'pascal-compiler-directive)
          (pascal-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (pascal-derived-token-has-tag? token 'pascal-string-literal)
          (pascal-derived-token-has-tag? token 'pascal-control-string)
          (pascal-derived-token-has-tag? token 'pascal-numeric-literal)
          (pascal-derived-token-has-tag? token 'literal))
      'value]
     [(pascal-derived-token-has-tag? token 'delimiter) 'punct]
     [(or (pascal-derived-token-has-tag? token 'pascal-escaped-identifier)
          (pascal-derived-token-has-tag? token 'identifier))
      'name]
     [else 'plain])
   txt))

(define (tokenize-pascal s)
  (define (pascal-type-name? txt cls prev1 prev2)
    (define t (string-downcase txt))
    (or (set-member? pascal-builtin-type-names t)
        (and prev1
             (eq? (car prev1) 'keyword)
             (member (string-downcase (cdr prev1)) '("type" "of") string=?)
             (eq? cls 'name))
        (and prev1
             (eq? (car prev1) 'punct)
             (or (string=? (cdr prev1) ":")
                 (string=? (cdr prev1) "="))
             (eq? cls 'name))
        (and prev1 prev2
             (eq? cls 'name)
             (eq? (car prev1) 'punct)
             (string=? (cdr prev1) ".")
             (memq (car prev2) '(name type-name)))))
  (let loop ([rest (pascal-string->derived-tokens s)] [acc null] [prev1 #f] [prev2 #f])
    (cond
      [(null? rest) (reverse acc)]
      [else
       (define piece0 (pascal-derived-token->piece (car rest)))
       (define piece
         (if (pascal-type-name? (cdr piece0) (car piece0) prev1 prev2)
             (cons 'type-name (cdr piece0))
             piece0))
       (define next-prev1 (if (token-nonplain? piece) piece prev1))
       (define next-prev2 (if (token-nonplain? piece) prev1 prev2))
       (loop (cdr rest) (cons piece acc) next-prev1 next-prev2)])))

(define (tokenize-racket s)
  (for/list ([piece (in-list
                     (projected-tokens->scribble-tokens
                      (racket-string->tokens s #:profile 'coloring #:source-positions #t)))])
    (cond
      [(and (eq? (car piece) 'name)
            (racket-standard-formish? (cdr piece)))
       (cons 'keyword (cdr piece))]
      [(and (eq? (car piece) 'name)
            (racket-standard-builtin? (cdr piece)))
       (cons 'builtin-name (cdr piece))]
      [else piece])))

(define (tokenize-rust s)
  (define (rust-type-name? txt cls prev1 prev2)
    (or (set-member? rust-builtin-type-names txt)
        (and prev1
             (eq? (car prev1) 'keyword)
             (member (cdr prev1) '("struct" "enum" "trait" "type" "impl") string=?)
             (eq? cls 'name))
        (and prev1
             (eq? (car prev1) 'punct)
             (or (string=? (cdr prev1) ":")
                 (string=? (cdr prev1) "->"))
             (eq? cls 'name))
        (and prev1 prev2
             (eq? cls 'name)
             (eq? (car prev1) 'punct)
             (string=? (cdr prev1) "::")
             (memq (car prev2) '(name type-name)))))
  (let loop ([rest (projected-tokens->scribble-tokens
                    (rust-string->tokens s #:profile 'coloring #:source-positions #t))]
             [acc null]
             [prev1 #f]
             [prev2 #f])
    (cond
      [(null? rest) (reverse acc)]
      [else
       (define piece0 (car rest))
       (define piece
         (if (rust-type-name? (cdr piece0) (car piece0) prev1 prev2)
             (cons 'type-name (cdr piece0))
             piece0))
       (define next-prev1 (if (token-nonplain? piece) piece prev1))
       (define next-prev2 (if (token-nonplain? piece) prev1 prev2))
       (loop (cdr rest) (cons piece acc) next-prev1 next-prev2)])))

(define (ruby-derived-token->piece token)
  (define txt (ruby-derived-token-text token))
  (cons
   (cond
     [(or (ruby-derived-token-has-tag? token 'comment)
          (ruby-derived-token-has-tag? token 'ruby-comment)
          (ruby-derived-token-has-tag? token 'ruby-shebang-comment))
      'comment]
     [(ruby-derived-token-has-tag? token 'whitespace) 'plain]
     [(ruby-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (ruby-derived-token-has-tag? token 'ruby-keyword)
          (ruby-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (ruby-derived-token-has-tag? token 'ruby-constant))
      'constant-name]
     [(or (ruby-derived-token-has-tag? token 'ruby-method-name)
          (ruby-derived-token-has-tag? token 'ruby-operator-method-name)
          (ruby-derived-token-has-tag? token 'ruby-method-reference))
      'method-name]
     [(or (ruby-derived-token-has-tag? token 'ruby-instance-variable)
          (ruby-derived-token-has-tag? token 'ruby-class-variable)
          (ruby-derived-token-has-tag? token 'ruby-global-variable))
      'variable-name]
     [(ruby-derived-token-has-tag? token 'ruby-keyword-argument-label)
      'label-name]
     [(ruby-derived-token-has-tag? token 'ruby-interpolation)
      'interpolation]
     [(or (ruby-derived-token-has-tag? token 'ruby-string-literal)
          (ruby-derived-token-has-tag? token 'ruby-symbol-literal)
          (ruby-derived-token-has-tag? token 'ruby-character-literal)
          (ruby-derived-token-has-tag? token 'ruby-number-literal)
          (ruby-derived-token-has-tag? token 'ruby-regexp-literal)
          (ruby-derived-token-has-tag? token 'ruby-command-literal)
          (ruby-derived-token-has-tag? token 'ruby-percent-literal)
          (ruby-derived-token-has-tag? token 'ruby-word-list-literal)
          (ruby-derived-token-has-tag? token 'ruby-symbol-list-literal)
          (ruby-derived-token-has-tag? token 'ruby-heredoc-introducer)
          (ruby-derived-token-has-tag? token 'ruby-heredoc-body)
          (ruby-derived-token-has-tag? token 'literal))
      'value]
     [(ruby-derived-token-has-tag? token 'operator) 'operator]
     [(ruby-derived-token-has-tag? token 'delimiter) 'punct]
     [(or (ruby-derived-token-has-tag? token 'ruby-identifier)
          (ruby-derived-token-has-tag? token 'identifier))
      'name]
     [else 'plain])
   txt))

(define (tokenize-ruby s)
  (for/list ([token (in-list (ruby-string->derived-tokens s))])
    (ruby-derived-token->piece token)))

(define (sql-derived-token->piece token)
  (define txt (sql-derived-token-text token))
  (cons
   (cond
     [(or (sql-derived-token-has-tag? token 'comment)
          (sql-derived-token-has-tag? token 'sql-comment))
      'comment]
     [(sql-derived-token-has-tag? token 'whitespace) 'plain]
     [(sql-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (sql-derived-token-has-tag? token 'sql-keyword)
          (sql-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (sql-derived-token-has-tag? token 'sql-string-literal)
          (sql-derived-token-has-tag? token 'sql-numeric-literal)
          (sql-derived-token-has-tag? token 'literal))
      'value]
     [(sql-derived-token-has-tag? token 'sql-parameter)
      'parameter-name]
     [(or (sql-derived-token-has-tag? token 'sql-operator)
          (sql-derived-token-has-tag? token 'operator))
      'operator]
     [(or (sql-derived-token-has-tag? token 'sql-delimiter)
          (sql-derived-token-has-tag? token 'delimiter))
      'punct]
     [(or (sql-derived-token-has-tag? token 'sql-identifier)
          (sql-derived-token-has-tag? token 'identifier))
      'name]
     [else 'plain])
   txt))

(define (sql-lang->dialect lang)
  (case lang
    [(sqlite) 'sqlite]
    [(mysql) 'mysql]
    [(postgres postgresql) 'postgres]
    [else 'generic]))

(define (tokenize-sql s dialect)
  (for/list ([token (in-list (sql-string->derived-tokens s #:dialect dialect))])
    (sql-derived-token->piece token)))

(define (yaml-derived-token->piece token)
  (define txt (yaml-derived-token-text token))
  (cons
   (cond
     [(yaml-derived-token-has-tag? token 'comment) 'comment]
     [(yaml-derived-token-has-tag? token 'whitespace) 'plain]
     [(yaml-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (yaml-derived-token-has-tag? token 'yaml-directive)
          (yaml-derived-token-has-tag? token 'yaml-document-marker)
          (yaml-derived-token-has-tag? token 'keyword))
      'keyword]
     [(yaml-derived-token-has-tag? token 'yaml-key-scalar) 'name]
     [(or (yaml-derived-token-has-tag? token 'yaml-string-literal)
          (yaml-derived-token-has-tag? token 'yaml-boolean)
          (yaml-derived-token-has-tag? token 'yaml-block-scalar-content)
          (yaml-derived-token-has-tag? token 'literal))
      'value]
     [(or (yaml-derived-token-has-tag? token 'yaml-sequence-indicator)
          (yaml-derived-token-has-tag? token 'yaml-block-scalar-header)
          (yaml-derived-token-has-tag? token 'operator))
      'operator]
     [(yaml-derived-token-has-tag? token 'delimiter) 'punct]
     [else 'plain])
   txt))

(define (tokenize-yaml s)
  (for/list ([token (in-list (yaml-string->derived-tokens s))])
    (yaml-derived-token->piece token)))

(define (go-derived-token->piece token)
  (define txt (go-derived-token-text token))
  (cons
   (cond
     [(or (go-derived-token-has-tag? token 'comment)
          (go-derived-token-has-tag? token 'go-general-comment)
          (go-derived-token-has-tag? token 'go-line-comment))
      'comment]
     [(go-derived-token-has-tag? token 'whitespace) 'plain]
     [(go-derived-token-has-tag? token 'malformed-token) 'plain]
     [(go-derived-token-has-tag? token 'keyword) 'keyword]
     [(or (go-derived-token-has-tag? token 'go-raw-string-literal)
          (go-derived-token-has-tag? token 'go-rune-literal)
          (go-derived-token-has-tag? token 'go-imaginary-literal)
          (go-derived-token-has-tag? token 'literal))
      'value]
     [(go-derived-token-has-tag? token 'operator) 'operator]
     [(go-derived-token-has-tag? token 'delimiter) 'punct]
     [(go-derived-token-has-tag? token 'identifier) 'name]
     [else 'plain])
   txt))

(define (tokenize-go s)
  (define (go-type-name? txt cls prev1 prev2)
    (or (set-member? go-builtin-type-names txt)
        (set-member? go-common-type-names txt)
        (and prev1
             (eq? (car prev1) 'keyword)
             (string=? (cdr prev1) "type")
             (eq? cls 'name))
        (and prev1 prev2
             (eq? cls 'name)
             (eq? (car prev1) 'punct)
             (string=? (cdr prev1) ".")
             (memq (car prev2) '(name type-name))
             (set-member? go-common-type-names txt))))
  (let loop ([rest (go-string->derived-tokens s)] [acc null] [prev1 #f] [prev2 #f])
    (cond
      [(null? rest) (reverse acc)]
      [else
       (define piece0 (go-derived-token->piece (car rest)))
       (define piece
         (if (go-type-name? (cdr piece0) (car piece0) prev1 prev2)
             (cons 'type-name (cdr piece0))
             piece0))
       (define next-prev1 (if (token-nonplain? piece) piece prev1))
       (define next-prev2 (if (token-nonplain? piece) prev1 prev2))
       (loop (cdr rest) (cons piece acc) next-prev1 next-prev2)])))

(define (haskell-derived-token->piece token)
  (define txt (haskell-derived-token-text token))
  (cons
   (cond
     [(or (haskell-derived-token-has-tag? token 'comment)
          (haskell-derived-token-has-tag? token 'haskell-line-comment))
      'comment]
     [(haskell-derived-token-has-tag? token 'whitespace) 'plain]
     [(haskell-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (haskell-derived-token-has-tag? token 'haskell-keyword)
          (haskell-derived-token-has-tag? token 'haskell-pragma)
          (haskell-derived-token-has-tag? token 'keyword))
      'keyword]
     [(or (haskell-derived-token-has-tag? token 'haskell-string-literal)
          (haskell-derived-token-has-tag? token 'haskell-char-literal)
          (haskell-derived-token-has-tag? token 'haskell-numeric-literal)
          (haskell-derived-token-has-tag? token 'literal))
      'value]
     [(haskell-derived-token-has-tag? token 'operator) 'operator]
     [(haskell-derived-token-has-tag? token 'delimiter) 'punct]
     [(haskell-derived-token-has-tag? token 'identifier) 'name]
     [else 'plain])
   txt))

(define (tokenize-haskell s)
  (for/list ([token (in-list (haskell-string->derived-tokens s))])
    (haskell-derived-token->piece token)))

(define (java-derived-token->piece token)
  (define txt (java-derived-token-text token))
  (cons
   (cond
     [(or (java-derived-token-has-tag? token 'comment)
          (java-derived-token-has-tag? token 'java-line-comment)
          (java-derived-token-has-tag? token 'java-doc-comment))
      'comment]
     [(java-derived-token-has-tag? token 'whitespace) 'plain]
     [(java-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (java-derived-token-has-tag? token 'keyword)
          (java-derived-token-has-tag? token 'java-annotation-name))
      'keyword]
     [(or (java-derived-token-has-tag? token 'java-string-literal)
          (java-derived-token-has-tag? token 'java-char-literal)
          (java-derived-token-has-tag? token 'java-text-block)
          (java-derived-token-has-tag? token 'java-numeric-literal)
          (java-derived-token-has-tag? token 'java-true-literal)
          (java-derived-token-has-tag? token 'java-false-literal)
          (java-derived-token-has-tag? token 'java-null-literal)
          (java-derived-token-has-tag? token 'literal))
      'value]
     [(java-derived-token-has-tag? token 'operator) 'operator]
     [(java-derived-token-has-tag? token 'delimiter) 'punct]
     [(or (java-derived-token-has-tag? token 'java-identifier)
          (java-derived-token-has-tag? token 'identifier))
      'name]
     [else 'plain])
   txt))

(define (tokenize-java s)
  (for/list ([token (in-list (java-string->derived-tokens s))])
    (java-derived-token->piece token)))

(define (tokenize-latex s)
  (for/list ([token (in-list (latex-string->derived-tokens s))])
    (define txt (latex-derived-token-text token))
    (define cls
      (cond
        [(latex-derived-token-has-tag? token 'comment) 'comment]
        [(latex-derived-token-has-tag? token 'whitespace) 'plain]
        [(latex-derived-token-has-tag? token 'latex-verbatim-literal) 'value]
        [(or (latex-derived-token-has-tag? token 'tex-inline-math-shift)
             (latex-derived-token-has-tag? token 'tex-display-math-shift)
             (latex-derived-token-has-tag? token 'latex-line-break-command)
             (latex-derived-token-has-tag? token 'tex-parameter-marker)
             (latex-derived-token-has-tag? token 'tex-parameter-reference)
             (latex-derived-token-has-tag? token 'tex-parameter-escape))
         'operator]
        [(or (latex-derived-token-has-tag? token 'tex-open-group-delimiter)
             (latex-derived-token-has-tag? token 'tex-close-group-delimiter)
             (latex-derived-token-has-tag? token 'tex-open-optional-delimiter)
             (latex-derived-token-has-tag? token 'tex-close-optional-delimiter)
             (latex-derived-token-has-tag? token 'delimiter))
         'punct]
        [(or (latex-derived-token-has-tag? token 'latex-environment-name)
             (latex-derived-token-has-tag? token 'tex-text))
         (if (regexp-match? #px"^[A-Za-z][A-Za-z0-9*_:-]*$" txt)
             'name
             'plain)]
        [(or (latex-derived-token-has-tag? token 'latex-command)
             (latex-derived-token-has-tag? token 'latex-environment-command)
             (latex-derived-token-has-tag? token 'tex-control-word)
             (latex-derived-token-has-tag? token 'tex-control-symbol)
             (latex-derived-token-has-tag? token 'tex-accent-command)
             (latex-derived-token-has-tag? token 'tex-spacing-command)
             (latex-derived-token-has-tag? token 'tex-control-space)
             (latex-derived-token-has-tag? token 'tex-italic-correction)
             (latex-derived-token-has-tag? token 'tex-paragraph-command)
             (latex-derived-token-has-tag? token 'keyword))
         'keyword]
        [(or (latex-derived-token-has-tag? token 'literal)
             (latex-derived-token-has-tag? token 'tex-parameter))
         'value]
        [else 'plain]))
    (cons cls txt)))

(define (scribble-token-type->symbol t)
  (cond
    [(symbol? t) t]
    [(hash? t) (hash-ref t 'type 'text)]
    [else 'text]))

(define (scribble-token-class typ txt)
  (case typ
    [(comment) 'comment]
    [(constant string) 'value]
    [(parenthesis) 'punct]
    [(symbol)
     ;; In Scribble source snippets, symbols most often represent commands
     ;; and embedded expression identifiers.
     'keyword]
    [(text) 'plain]
    [(white-space) 'plain]
    [else
     (if (regexp-match? #px"^[a-zA-Z_][a-zA-Z0-9_?!-]*$" txt)
         'name
         'plain)]))

(define (tokenize-scribble-handwritten s)
  (define lx (make-scribble-inside-lexer))
  (define in (open-input-string s))
  (port-count-lines! in)
  (let loop ([mode #f] [acc null])
    (define-values (_lexeme type _paren start end _backup new-mode)
      (lx in 0 mode))
    (define typ (scribble-token-type->symbol type))
    (if (eq? typ 'eof)
        (reverse acc)
        (let* ([a (max 0 (sub1 start))]
               [b (min (string-length s) (max a (sub1 end)))]
               [txt (substring s a b)]
               [cls (scribble-token-class typ txt)])
          (loop new-mode (cons (cons cls txt) acc))))))

(define (tokenize-scribble s)
  (for/list ([token (in-list (scribble-string->derived-tokens s))])
    (define txt (scribble-derived-token-text token))
    (define cls
      (cond
        [(scribble-derived-token-has-tag? token 'comment) 'comment]
        [(scribble-derived-token-has-tag? token 'scribble-string) 'value]
        [(scribble-derived-token-has-tag? token 'scribble-constant) 'value]
        [(scribble-derived-token-has-tag? token 'scribble-parenthesis) 'punct]
        [(scribble-derived-token-has-tag? token 'scribble-symbol)
         (scribble-token-class 'symbol txt)]
        [(scribble-derived-token-has-tag? token 'whitespace) 'plain]
        [(scribble-derived-token-has-tag? token 'scribble-text) 'plain]
        [else 'plain]))
    (cons cls txt)))

(define (tokenize-makefile s)
  (let loop ([tokens (makefile-string->derived-tokens s)]
             [acc null]
             [expect-recipe-command? #f])
    (cond
      [(null? tokens) (reverse acc)]
      [else
       (define token (car tokens))
    (define txt (makefile-derived-token-text token))
    (define cls
      (cond
        [(makefile-derived-token-has-tag? token 'comment) 'comment]
        [(makefile-derived-token-has-tag? token 'whitespace) 'plain]
        [(makefile-derived-token-has-tag? token 'makefile-recipe-prefix) 'plain]
        [(makefile-derived-token-has-tag? token 'makefile-rule-target) 'make-target]
        [(or (makefile-derived-token-has-tag? token 'makefile-paren-variable-reference)
             (makefile-derived-token-has-tag? token 'makefile-brace-variable-reference)
             (makefile-derived-token-has-tag? token 'makefile-variable-reference))
         'make-variable]
        [(and expect-recipe-command?
              (or (makefile-derived-token-has-tag? token 'shell-word)
                  (makefile-derived-token-has-tag? token 'shell-builtin)))
         'recipe-command]
        [(makefile-derived-token-has-tag? token 'shell-builtin) 'keyword]
        [(makefile-derived-token-has-tag? token 'shell-option) 'recipe-option]
        [(or (makefile-derived-token-has-tag? token 'makefile-order-only-delimiter)
             (makefile-derived-token-has-tag? token 'makefile-rule-delimiter)
             (makefile-derived-token-has-tag? token 'makefile-double-colon-delimiter))
         'operator]
        [(makefile-derived-token-has-tag? token 'makefile-recipe-separator) 'punct]
        [(makefile-derived-token-has-tag? token 'operator) 'operator]
        [(makefile-derived-token-has-tag? token 'delimiter) 'punct]
        [(makefile-derived-token-has-tag? token 'literal) 'value]
        [(makefile-derived-token-has-tag? token 'identifier) 'name]
        [else 'plain]))
       (define next-expect-recipe-command?
         (cond
           [(makefile-derived-token-has-tag? token 'makefile-recipe-prefix) #t]
           [(regexp-match? #px"\n" txt) #f]
           [(and expect-recipe-command?
                 (not (makefile-derived-token-has-tag? token 'whitespace)))
            #f]
           [else expect-recipe-command?]))
       (loop (cdr tokens)
             (cons (cons cls txt) acc)
             next-expect-recipe-command?)])))

(define (markdown-derived-token->piece token)
  (define txt (markdown-derived-token-text token))
  (cons
   (cond
     [(markdown-derived-token-has-tag? token 'comment) 'comment]
     [(markdown-derived-token-has-tag? token 'whitespace) 'plain]
     [(markdown-derived-token-has-tag? token 'markdown-heading-marker) 'heading-marker]
     [(markdown-derived-token-has-tag? token 'markdown-heading-text) 'heading-text]
     [(or (markdown-derived-token-has-tag? token 'markdown-code-span)
          (markdown-derived-token-has-tag? token 'markdown-code-block)
          (markdown-derived-token-has-tag? token 'literal))
      'value]
     [(markdown-derived-token-has-tag? token 'operator) 'operator]
     [(markdown-derived-token-has-tag? token 'delimiter) 'punct]
     [(markdown-derived-token-has-tag? token 'identifier) 'name]
     [else 'plain])
   txt))

(define (markdown-heading-class level)
  (case level
    [(1) 'heading-1]
    [(2) 'heading-2]
    [(3) 'heading-3]
    [(4) 'heading-4]
    [(5) 'heading-5]
    [else 'heading-6]))

(define (tokenize-markdown s)
  (let loop ([tokens (markdown-string->derived-tokens s)]
             [acc null]
             [current-heading-level #f])
    (cond
      [(null? tokens) (reverse acc)]
      [else
       (define token (car tokens))
       (define piece0 (markdown-derived-token->piece token))
       (define txt (cdr piece0))
       (define piece
         (cond
           [(eq? (car piece0) 'heading-marker)
            (cons (markdown-heading-class (min 6 (string-length (string-trim txt))))
                  txt)]
           [(and current-heading-level
                 (eq? (car piece0) 'heading-text))
            (cons (markdown-heading-class current-heading-level) txt)]
           [else piece0]))
       (define next-level
         (cond
           [(eq? (car piece0) 'heading-marker)
            (min 6 (string-length (string-trim txt)))]
           [(and current-heading-level
                 (eq? (car piece0) 'plain)
                 (regexp-match? #px"(?:\r\n|\r|\n)" txt))
            #f]
           [(eq? (car piece0) 'heading-text) current-heading-level]
           [else current-heading-level]))
       (loop (cdr tokens) (cons piece acc) next-level)])))

(define (mathematica-derived-token->piece token)
  (define txt (mathematica-derived-token-text token))
  (cons
   (cond
     [(mathematica-derived-token-has-tag? token 'comment) 'comment]
     [(mathematica-derived-token-has-tag? token 'whitespace) 'plain]
     [(mathematica-derived-token-has-tag? token 'malformed-token) 'plain]
     [(or (mathematica-derived-token-has-tag? token 'mathematica-package-form)
          (mathematica-derived-token-has-tag? token 'mathematica-scoping-form))
      'keyword]
     [(or (mathematica-derived-token-has-tag? token 'mathematica-string-literal)
          (mathematica-derived-token-has-tag? token 'mathematica-number)
          (mathematica-derived-token-has-tag? token 'mathematica-named-character)
          (mathematica-derived-token-has-tag? token 'mathematica-character-escape)
          (mathematica-derived-token-has-tag? token 'literal))
      'value]
     [(or (mathematica-derived-token-has-tag? token 'mathematica-assignment-operator)
          (mathematica-derived-token-has-tag? token 'mathematica-rewrite-operator)
          (mathematica-derived-token-has-tag? token 'mathematica-pattern-condition-operator)
          (mathematica-derived-token-has-tag? token 'mathematica-composition-operator)
          (mathematica-derived-token-has-tag? token 'mathematica-string-pattern-operator)
          (mathematica-derived-token-has-tag? token 'mathematica-function-arrow-operator)
          (mathematica-derived-token-has-tag? token 'operator))
      'operator]
     [(or (mathematica-derived-token-has-tag? token 'mathematica-association-delimiter)
          (mathematica-derived-token-has-tag? token 'mathematica-part-delimiter)
          (mathematica-derived-token-has-tag? token 'delimiter))
      'punct]
     [(or (mathematica-derived-token-has-tag? token 'mathematica-symbol)
          (mathematica-derived-token-has-tag? token 'mathematica-long-name)
          (mathematica-derived-token-has-tag? token 'mathematica-pattern)
          (mathematica-derived-token-has-tag? token 'mathematica-slot)
          (mathematica-derived-token-has-tag? token 'identifier))
      'name]
     [else 'plain])
   txt))

(define (tokenize-mathematica s)
  (for/list ([token (in-list (mathematica-string->derived-tokens s))])
    (mathematica-derived-token->piece token)))

(define (tokenize lang s)
  (case lang
    [(css) (tokenize-css s)]
    [(c) (tokenize-c s)]
    [(cpp) (tokenize-cpp s)]
    [(makefile) (tokenize-makefile s)]
    [(objc) (tokenize-objc s)]
    [(haskell) (tokenize-haskell s)]
    [(pascal) (tokenize-pascal s)]
    [(csv) (projected-tokens->scribble-tokens
            (csv-string->tokens s #:profile 'coloring #:source-positions #t))]
    [(go) (tokenize-go s)]
    [(html) (tokenize-html s)]
    [(java) (tokenize-java s)]
    [(js) (tokenize-js s)]
    [(json) (projected-tokens->scribble-tokens
             (json-string->tokens s #:profile 'coloring #:source-positions #t))]
    [(mathematica) (tokenize-mathematica s)]
    [(latex) (tokenize-latex s)]
    [(markdown) (tokenize-markdown s)]
    [(python) (tokenize-python s)]
    [(plist) (tokenize-plist s)]
    [(racket) (tokenize-racket s)]
    [(rhombus)
     (with-handlers ([exn:fail? (lambda (_e) (list (cons 'plain s)))])
       (projected-tokens->scribble-tokens
        (rhombus-string->tokens s #:profile 'coloring #:source-positions #t)))]
    [(ruby) (tokenize-ruby s)]
    [(rust) (tokenize-rust s)]
    [(sql sqlite mysql postgres postgresql) (tokenize-sql s (sql-lang->dialect lang))]
    [(swift) (tokenize-swift s)]
    [(tex) (tokenize-tex s)]
    [(wasm) (tokenize-wasm s)]
    [(bash) (tokenize-shell 'bash s)]
    [(zsh) (tokenize-shell 'zsh s)]
    [(powershell) (tokenize-shell 'powershell s)]
    [(scribble) (tokenize-scribble s)]
    [(tsv) (projected-tokens->scribble-tokens
            (tsv-string->tokens s #:profile 'coloring #:source-positions #t))]
    [(yaml) (tokenize-yaml s)]
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

(define (token-text-length cell)
  (for/sum ([piece (in-list cell)])
    (string-length (cdr piece))))

(define (normalize-tsv-display-tokens tokens)
  (define (finish-cell row current-cell)
    (append row (list (reverse current-cell))))
  (define (finish-row rows row current-cell)
    (append rows (list (finish-cell row current-cell))))
  (define rows
    (let loop ([rest tokens] [rows null] [row null] [cell null])
      (cond
        [(null? rest)
         (finish-row rows row cell)]
        [else
         (define tok (car rest))
         (define txt (cdr tok))
         (cond
           [(string=? txt "\t")
            (loop (cdr rest) rows (finish-cell row cell) null)]
           [(or (string=? txt "\n")
                (string=? txt "\r")
                (string=? txt "\r\n"))
            (loop (cdr rest) (finish-row rows row cell) null null)]
           [else
            (loop (cdr rest) rows row (cons tok cell))])])))
  (define max-cols (apply max 0 (map length rows)))
  (define widths
    (for/list ([col (in-range max-cols)])
      (for/fold ([w 0]) ([row (in-list rows)])
        (define cell (and (< col (length row)) (list-ref row col)))
        (max w (if cell (token-text-length cell) 0)))))
  (define gutter 2)
  (define display-tokens
    (apply append
           (for/list ([row (in-list rows)]
                      [idx (in-naturals)])
             (define last-col (sub1 (length row)))
             (define row-pieces
               (let loop-cols ([cells row] [col 0] [pieces null])
                 (cond
                   [(null? cells) pieces]
                   [else
                    (define cell (car cells))
                    (define pieces*
                      (append pieces cell))
                    (define pieces**
                      (if (< col last-col)
                          (let* ([pad (- (list-ref widths col) (token-text-length cell))]
                                 [spaces (make-string (+ gutter (max 0 pad)) #\space)])
                            (append pieces* (list (cons 'plain spaces))))
                          pieces*))
                    (loop-cols (cdr cells) (add1 col) pieces**)])))
             (if (= idx (sub1 (length rows)))
                 row-pieces
                 (append row-pieces (list (cons 'plain "\n")))))))
  display-tokens)

(define (escape->element v)
  (cond
    [(element? v) v]
    [(list? v) (make-element #f v)]
    [else (make-element #f (list v))]))

(define (consume-css-color-function tokens)
  (define first (and (pair? tokens) (car tokens)))
  (define second (and (pair? (cdr tokens)) (cadr tokens)))
  (cond
    [(and first second
          (eq? (car first) 'value)
          (or (set-member? css-color-functions (string-downcase (cdr first)))
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
          (define t (car rest))
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

(define (insert-css-color-swatch-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail color-fn fn-name) (consume-css-color-function rest))
           (cond
             [taken
              (define acc2 (append (reverse taken) acc))
              (if (and color-fn (safe-css-color-literal? color-fn))
                  (loop tail (cons (cons (if (set-member? css-gradient-functions fn-name)
                                             'swatch-gradient
                                             'swatch)
                                         color-fn)
                                   acc2))
                  (loop tail acc2))]
             [else
              (define t (car rest))
              (define cls (car t))
              (define txt (cdr t))
              (define add-swatch?
                (and (eq? cls 'value)
                     (css-color-literal? txt)
                     (safe-css-color-literal? txt)))
              (if add-swatch?
                  (loop (cdr rest) (cons (cons 'swatch txt) (cons t acc)))
                  (loop (cdr rest) (cons t acc)))])]))))

(define (consume-css-property-decl tokens property?)
  (define first (and (pair? tokens) (car tokens)))
  (cond
    [(and first
          (eq? (car first) 'name)
          (property? (string-downcase (cdr first))))
     (let loop ([rest (cdr tokens)]
                [seen-colon? #f]
                [taken-rev (list first)]
                [value-rev null])
       (cond
         [(null? rest)
          (if seen-colon?
              (values (reverse taken-rev) null
                      (normalize-css-font-family
                       (apply string-append (map cdr (reverse value-rev)))))
              (values #f tokens #f))]
         [else
          (define t (car rest))
          (define cls (car t))
          (define txt (cdr t))
          (cond
            [(not seen-colon?)
             (cond
               [(and (eq? cls 'punct) (string=? txt ":"))
                (loop (cdr rest) #t (cons t taken-rev) value-rev)]
               [(and (eq? cls 'punct) (or (string=? txt ";") (string=? txt "}")))
                (values #f tokens #f)]
               [else
                (loop (cdr rest) #f (cons t taken-rev) value-rev)])]
            [else
             (cond
               [(and (eq? cls 'punct) (or (string=? txt ";") (string=? txt "}")))
                (values (reverse (cons t taken-rev))
                        (cdr rest)
                        (normalize-css-decl-value
                         (apply string-append (map cdr (reverse value-rev)))))]
               [else
                (loop (cdr rest) #t (cons t taken-rev) (cons t value-rev))])])]))]
    [else (values #f tokens #f)]))

(define (consume-css-font-family-decl tokens)
  (consume-css-property-decl
   tokens
   (lambda (prop) (string=? prop "font-family"))))

(define (consume-css-dimension-decl tokens)
  (consume-css-property-decl
   tokens
   (lambda (prop)
     (or (set-member? css-spacing-properties prop)
         (string=? prop "border-radius")
         (set-member? css-blur-properties prop)))))

(define (insert-css-font-preview-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail family-text) (consume-css-font-family-decl rest))
           (if taken
               (let ([acc2 (append (reverse taken) acc)])
                 (if (safe-css-font-family-literal? family-text)
                     (loop tail (cons (cons 'font-preview family-text) acc2))
                     (loop tail acc2)))
               (loop (cdr rest) (cons (car rest) acc)))]))))

(define (insert-css-dimension-preview-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail value-text) (consume-css-dimension-decl rest))
           (if taken
               (let* ([acc2 (append (reverse taken) acc)]
                      [prop (string-downcase (cdr (car taken)))])
                 (cond
                   [(set-member? css-spacing-properties prop)
                    (define width (spacing-width-px value-text))
                    (if width
                        (loop tail (cons (cons 'spacing-preview (cons width value-text)) acc2))
                        (loop tail acc2))]
                   [(set-member? css-blur-properties prop)
                    (define blur-arg (extract-blur-arg value-text))
                    (define width (and blur-arg (spacing-width-px blur-arg)))
                    (if width
                        (loop tail (cons (cons 'spacing-preview (cons width (format "blur(~a)" blur-arg))) acc2))
                        (loop tail acc2))]
                   [(string=? prop "border-radius")
                    (define radius (radius-size-px value-text))
                    (if radius
                        (loop tail (cons (cons 'radius-preview (cons radius value-text)) acc2))
                        (loop tail acc2))]
                   [else
                   (loop tail acc2)]))
               (loop (cdr rest) (cons (car rest) acc)))]))))

(define (consume-css-custom-token-decl tokens)
  (define-values (taken tail value-text)
    (consume-css-property-decl
     tokens
     (lambda (prop)
       (and (>= (string-length prop) 2)
            (string-prefix? prop "--")))))
  (if taken
      (values taken tail (string-downcase (cdr (car taken))) value-text)
      (values #f tokens #f #f)))

(define (insert-css-design-token-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail token-name value-text) (consume-css-custom-token-decl rest))
           (cond
             [taken
              (define acc2 (append (reverse taken) acc))
              (define maybe-color
                (cond
                  [(css-color-literal? (string-trim value-text)) (string-trim value-text)]
                  [else #f]))
              (if maybe-color
                  (loop tail (cons (cons 'token-def (cons token-name maybe-color)) acc2))
                  (loop tail acc2))]
             [else
              (define t1 (car rest))
              (define t2 (if (>= (length rest) 2) (cadr rest) #f))
              (define t3 (if (>= (length rest) 3) (caddr rest) #f))
              (if (and t1 t2 t3
                       (member (car t1) '(value name keyword))
                       (string-ci=? (cdr t1) "var")
                       (eq? (car t2) 'punct)
                       (string=? (cdr t2) "(")
                       (member (car t3) '(name value))
                       (string-prefix? (string-downcase (cdr t3)) "--"))
                  (loop (cdr rest)
                        (cons (cons 'token-ref (string-downcase (cdr t3)))
                              (cons t1 acc)))
                  (loop (cdr rest) (cons (car rest) acc)))])]))))

(define (insert-js-preview-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define t (car rest))
           (define cls (car t))
           (define txt (cdr t))
           (define is-regex?
             (and (eq? cls 'value)
                  (regexp-match? #px"^/.+/[a-zA-Z]*$" txt)))
           (define is-template?
             (and (eq? cls 'value)
                  (regexp-match? #px"`" txt)))
           (cond
             [is-regex?
              (loop (cdr rest) (cons (cons 'js-regex-preview "") (cons t acc)))]
             [is-template?
              (loop (cdr rest) (cons (cons 'js-template-preview "") (cons t acc)))]
             [else
              (loop (cdr rest) (cons t acc))])]))))

(define css-decoration-classes
  ;; Only color/gradient swatches need relocation to declaration ends.
  (set 'swatch 'swatch-gradient))

(define (move-css-decorations-to-decl-end tokens)
  (let loop ([rest tokens] [pending null] [acc null])
    (cond
      [(null? rest)
       (reverse (append (reverse pending) acc))]
      [else
       (define t (car rest))
       (define cls (car t))
       (cond
         [(set-member? css-decoration-classes cls)
          (loop (cdr rest) (cons t pending) acc)]
         [(and (eq? cls 'punct) (string=? (cdr t) ";"))
          (loop (cdr rest) null (append (reverse pending) (cons t acc)))]
         [(and (eq? cls 'punct) (string=? (cdr t) "}"))
          ;; If final declaration omits ';', show decorations right before '}'.
          (loop (cdr rest) null (cons t (append (reverse pending) acc)))]
         [else
          (loop (cdr rest) pending (cons t acc))])])))

(define js-global-objects
  (list->set
   '("Array" "Object" "String" "Number" "Boolean" "Promise"
     "Map" "Set" "WeakMap" "WeakSet"
     "Date" "RegExp" "Math" "JSON"
     "URL" "URLSearchParams" "Error" "TypeError" "SyntaxError"
     "Symbol" "BigInt" "Intl")))

(define js-webapi-objects
  (list->set
   '("CanvasRenderingContext2D"
     "WebGLRenderingContext"
     "WebGL2RenderingContext"
     "ImageBitmapRenderingContext"
     "console"
     "Document" "Window" "Element" "HTMLElement" "Node" "EventTarget"
     "Navigator" "Location" "History")))

(define js-known-objects
  (set-union js-global-objects js-webapi-objects))

(define js-method-owner-index
  ;; Maps lowercase method name -> possible owning global/API objects.
  (let ([pairs
         '(("map" . "Array") ("filter" . "Array") ("reduce" . "Array")
           ("forEach" . "Array") ("includes" . "Array") ("find" . "Array")
           ("findIndex" . "Array") ("some" . "Array") ("every" . "Array")
           ("flatMap" . "Array") ("join" . "Array") ("slice" . "Array")
           ("push" . "Array") ("pop" . "Array") ("shift" . "Array")
           ("unshift" . "Array") ("sort" . "Array") ("toSorted" . "Array")
           ("toReversed" . "Array") ("toSpliced" . "Array") ("at" . "Array")
           ("entries" . "Array") ("keys" . "Array") ("values" . "Array")
           ("startsWith" . "String") ("endsWith" . "String")
           ("split" . "String") ("match" . "String") ("replace" . "String")
           ("test" . "RegExp") ("exec" . "RegExp")
           ("parse" . "JSON") ("stringify" . "JSON")
           ("max" . "Math") ("min" . "Math") ("round" . "Math")
           ("floor" . "Math") ("ceil" . "Math") ("abs" . "Math")
           ("random" . "Math")
           ("then" . "Promise") ("catch" . "Promise") ("finally" . "Promise")
           ("all" . "Promise") ("allSettled" . "Promise")
           ("race" . "Promise") ("any" . "Promise")
           ("resolve" . "Promise") ("reject" . "Promise")
           ("get" . "Map") ("set" . "Map") ("has" . "Map")
           ("delete" . "Map") ("clear" . "Map")
           ("assign" . "Object") ("fromEntries" . "Object")
           ("querySelector" . "Document")
           ("querySelectorAll" . "Document")
           ("getElementById" . "Document")
           ("getElementsByClassName" . "Document")
           ("getElementsByTagName" . "Document")
           ("createElement" . "Document")
           ("createTextNode" . "Document")
           ("matches" . "Element") ("closest" . "Element")
           ("setAttribute" . "Element") ("getAttribute" . "Element")
           ("hasAttribute" . "Element") ("removeAttribute" . "Element")
           ("appendChild" . "Node") ("removeChild" . "Node")
           ("insertBefore" . "Node") ("replaceChild" . "Node")
           ("cloneNode" . "Node")
           ("addEventListener" . "EventTarget")
           ("removeEventListener" . "EventTarget")
           ("dispatchEvent" . "EventTarget")
           ("requestAnimationFrame" . "Window")
           ("cancelAnimationFrame" . "Window")
           ("setTimeout" . "Window") ("clearTimeout" . "Window")
           ("setInterval" . "Window") ("clearInterval" . "Window")
           ("log" . "console") ("info" . "console") ("warn" . "console")
           ("error" . "console") ("debug" . "console")
           ("dir" . "console") ("table" . "console")
           ("trace" . "console") ("assert" . "console")
           ("group" . "console") ("groupCollapsed" . "console")
           ("groupEnd" . "console")
           ("time" . "console") ("timeLog" . "console") ("timeEnd" . "console")
           ("count" . "console") ("countReset" . "console")
           ("clear" . "console"))])
    (for/fold ([h (hash)])
              ([p (in-list pairs)])
      (hash-update h
                   (string-downcase (car p))
                   (lambda (owners) (cons (cdr p) owners))
                   null))))

(define (js-known-object? s)
  (set-member? js-known-objects s))

(define (js-global-object? s)
  (set-member? js-global-objects s))

(define (js-object-url owner)
  (if (js-global-object? owner)
      (format "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/~a"
              owner)
      (format "https://developer.mozilla.org/en-US/docs/Web/API/~a"
              owner)))

(define (js-object-method-url owner method)
  (if (js-global-object? owner)
      (format "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/~a/~a"
              owner method)
      (let ([canonical-owner
             (cond
               [(string=? owner "console") "console"]
               [(member method '("addEventListener" "removeEventListener" "dispatchEvent"))
                "EventTarget"]
               [(member method '("appendChild" "removeChild" "insertBefore" "replaceChild" "cloneNode"))
                "Node"]
               [else owner])])
        (if (string=? canonical-owner "console")
            (format "https://developer.mozilla.org/en-US/docs/Web/API/console/~a_static"
                    method)
            (format "https://developer.mozilla.org/en-US/docs/Web/API/~a/~a"
                    canonical-owner method)))))

(define (token-nonplain? t)
  (not (eq? (car t) 'plain)))

(define (token-class-in? t classes)
  (and t (memq (car t) classes)))

(define (next-nonplain-token rest)
  (let loop ([xs rest])
    (cond
      [(null? xs) #f]
      [(token-nonplain? (car xs)) (car xs)]
      [else (loop (cdr xs))])))

(define (resolve-js-owner name object-aliases)
  (or (and (js-known-object? name) name)
      (hash-ref object-aliases name #f)))

(define (strip-js-string-quotes s)
  (if (and (>= (string-length s) 2)
           (let ([f (string-ref s 0)]
                 [l (string-ref s (sub1 (string-length s)))])
             (and (or (char=? f #\") (char=? f #\'))
                  (char=? f l))))
      (substring s 1 (sub1 (string-length s)))
      s))

(define (canvas-context-owner-from-token t)
  (and t
       (eq? (car t) 'value)
       (let ([k (string-downcase (strip-js-string-quotes (cdr t)))])
         (cond
           [(member k '("2d")) "CanvasRenderingContext2D"]
           [(member k '("webgl")) "WebGLRenderingContext"]
           [(member k '("webgl2")) "WebGL2RenderingContext"]
           [(member k '("bitmaprenderer")) "ImageBitmapRenderingContext"]
           [else #f]))))

(define (rhs-context-owner np start)
  ;; Heuristic: detect ...getContext("<kind>") on RHS.
  (define max-j (min (length np) (+ start 28)))
  (let loop ([j start])
    (cond
      [(>= j max-j) #f]
      [else
       (define tj (list-ref np j))
       (define t1 (and (< (add1 j) (length np)) (list-ref np (add1 j))))
       (define t2 (and (< (+ j 2) (length np)) (list-ref np (+ j 2))))
       (define t3 (and (< (+ j 3) (length np)) (list-ref np (+ j 3))))
       (cond
         [(and (token-class-in? tj '(method-name prop-name name))
               (string=? (cdr tj) "getContext")
               t1 t2
               (eq? (car t1) 'punct) (string=? (cdr t1) "("))
          (or (canvas-context-owner-from-token t2)
              (and t3 (canvas-context-owner-from-token t3))
              #f)]
         [(and (eq? (car tj) 'punct) (or (string=? (cdr tj) ";") (string=? (cdr tj) ",")))
          #f]
         [else (loop (add1 j))])])))

(define (rhs-dom-owner np start)
  ;; Heuristic: detect common DOM-returning expressions on RHS.
  (define max-j (min (length np) (+ start 28)))
  (let loop ([j start])
    (cond
      [(>= j max-j) #f]
      [else
       (define tj (list-ref np j))
       (define t1 (and (< (add1 j) (length np)) (list-ref np (add1 j))))
       (define t2 (and (< (+ j 2) (length np)) (list-ref np (+ j 2))))
       (define t3 (and (< (+ j 3) (length np)) (list-ref np (+ j 3))))
       (define t4 (and (< (+ j 4) (length np)) (list-ref np (+ j 4))))
       (define t5 (and (< (+ j 5) (length np)) (list-ref np (+ j 5))))
       (cond
         ;; document.querySelector(...), el.querySelector(...)
         [(and (token-class-in? tj '(name decl-name prop-name object-key keyword))
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(method-name prop-name name))
               (member (cdr t2) '("querySelector" "querySelectorAll"
                                  "getElementById" "createElement")))
          "Element"]
         ;; document.body, document.documentElement
         [(and (token-class-in? tj '(name decl-name prop-name object-key keyword))
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(name prop-name method-name))
               (member (cdr t2) '("body" "documentElement")))
          "HTMLElement"]
         ;; document, window, navigator, history, location aliases
         [(and (token-class-in? tj '(name decl-name prop-name keyword))
               (member (cdr tj) '("document" "window" "navigator" "history" "location")))
          (case (string->symbol (cdr tj))
            [(document) "Document"]
            [(window) "Window"]
            [(navigator) "Navigator"]
            [(history) "History"]
            [else "Location"])]
         ;; window.document
         [(and (token-class-in? tj '(name decl-name keyword))
               (string=? (cdr tj) "window")
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(name prop-name))
               (string=? (cdr t2) "document"))
          "Document"]
         ;; event.target / event.currentTarget
         [(and (token-class-in? tj '(name decl-name))
               (member (cdr tj) '("event" "ev" "e"))
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(name prop-name))
               (member (cdr t2) '("target" "currentTarget")))
          "EventTarget"]
         [(and (eq? (car tj) 'punct) (or (string=? (cdr tj) ";") (string=? (cdr tj) ",")))
          #f]
         [else
          (loop (add1 j))])])))

(define (js-token-literal-owner t)
  (and t
       (eq? (car t) 'value)
       (let ([txt (cdr t)])
         (cond
           [(regexp-match? #px"^['\"]" txt) "String"]
           [(regexp-match? #px"^`" txt) "String"]
           [(regexp-match? #px"^/" txt) "RegExp"]
           [(regexp-match? #px"^[+-]?(?:[0-9]|\\.[0-9])" txt) "Number"]
           [else #f]))))

(define (build-js-alias-env tokens)
  ;; Returns two values:
  ;;   object-aliases : alias -> built-in object name (e.g. m -> Math)
  ;;   method-aliases : alias -> fully resolved method URL (e.g. parse -> .../JSON/parse)
  (define np (filter token-nonplain? tokens))
  (define len (length np))
  (define (tok i) (and (<= 0 i) (< i len) (list-ref np i)))
  (define object-aliases0
    (hash "document" "Document"
          "window" "Window"
          "console" "console"
          "navigator" "Navigator"
          "location" "Location"
          "history" "History"))
  (let loop ([i 0] [object-aliases object-aliases0] [method-aliases (hash)])
    (if (>= i len)
        (values object-aliases method-aliases)
        (let* ([t0 (tok i)]
               [t1 (tok (+ i 1))]
               [t2 (tok (+ i 2))]
               [t3 (tok (+ i 3))]
               [t4 (tok (+ i 4))]
               [t5 (tok (+ i 5))]
               [kw? (and t0 (eq? (car t0) 'keyword)
                         (member (cdr t0) '("const" "let" "var")))])
          (cond
            ;; const p = JSON.parse;
            [(and kw?
                  (token-class-in? t1 '(decl-name name))
                  (and t2 (eq? (car t2) 'operator) (string=? (cdr t2) "="))
                  (token-class-in? t3 '(name decl-name))
                  (resolve-js-owner (cdr t3) object-aliases)
                  (and t4 (eq? (car t4) 'punct) (string=? (cdr t4) "."))
                  (token-class-in? t5 '(method-name prop-name name)))
             (define owner (resolve-js-owner (cdr t3) object-aliases))
             (if owner
                 (loop (add1 i)
                       object-aliases
                       (hash-set method-aliases (cdr t1)
                                 (js-object-method-url owner (cdr t5))))
                 (loop (add1 i) object-aliases method-aliases))]
            ;; const m = Math;
            [(and kw?
                  (token-class-in? t1 '(decl-name name))
                  (and t2 (eq? (car t2) 'operator) (string=? (cdr t2) "="))
                  (token-class-in? t3 '(name decl-name prop-name object-key))
                  (resolve-js-owner (cdr t3) object-aliases)
                  (not (and t4 (eq? (car t4) 'punct) (string=? (cdr t4) "."))))
             (loop (add1 i)
                   (hash-set object-aliases (cdr t1) (resolve-js-owner (cdr t3) object-aliases))
                   method-aliases)]
            ;; const ctx = canvas.getContext("2d");
            [(and kw?
                  (token-class-in? t1 '(decl-name name))
                  (and t2 (eq? (car t2) 'operator) (string=? (cdr t2) "=")))
             (define owner (or (rhs-context-owner np (+ i 3))
                               (rhs-dom-owner np (+ i 3))))
             (if owner
                 (loop (add1 i)
                       (hash-set object-aliases (cdr t1) owner)
                       method-aliases)
                 (loop (add1 i) object-aliases method-aliases))]
            ;; const {parse} = JSON;
            [(and kw? t1 (eq? (car t1) 'punct) (string=? (cdr t1) "{"))
             (let parse-destruct ([j (+ i 2)] [names null])
               (define tj (tok j))
               (cond
                 [(or (not tj)
                      (and (eq? (car tj) 'punct) (string=? (cdr tj) "}")))
                  (define close-j j)
                  (define t-op (tok (+ close-j 1)))
                  (define t-rhs (tok (+ close-j 2)))
                  (define owner
                    (and t-op t-rhs
                         (eq? (car t-op) 'operator)
                         (string=? (cdr t-op) "=")
                         (token-class-in? t-rhs '(name decl-name))
                         (resolve-js-owner (cdr t-rhs) object-aliases)))
                  (if owner
                      (let ([method-aliases*
                             (for/fold ([h method-aliases])
                                       ([n (in-list (reverse names))])
                               (hash-set h n (js-object-method-url owner n)))])
                        (loop (add1 i) object-aliases method-aliases*))
                      (loop (add1 i) object-aliases method-aliases))]
                 [(token-class-in? tj '(name decl-name))
                  (define tcolon (tok (+ j 1)))
                  (define talias (tok (+ j 2)))
                  (cond
                    ;; {parse: p}
                    [(and tcolon talias
                          (eq? (car tcolon) 'punct) (string=? (cdr tcolon) ":")
                          (token-class-in? talias '(name decl-name)))
                     (parse-destruct (+ j 3) (cons (cdr talias) names))]
                    [else
                     (parse-destruct (add1 j) (cons (cdr tj) names))])]
                 [else (parse-destruct (add1 j) names)]))]
            [else (loop (add1 i) object-aliases method-aliases)])))))

(define (js-infer-method-owner prev1 prev2 object-aliases)
  (and prev1 prev2
       (eq? (car prev1) 'punct)
       (string=? (cdr prev1) ".")
       (or (and (token-class-in? prev2 '(name decl-name prop-name object-key keyword))
                (resolve-js-owner (cdr prev2) object-aliases))
           (js-token-literal-owner prev2)
           (and (eq? (car prev2) 'punct) (string=? (cdr prev2) "]") "Array")
           (and (eq? (car prev2) 'punct) (string=? (cdr prev2) "}") "Object"))))

(define (js-contextual-mdn-url lang cls txt prev1 prev2 next1 object-aliases method-aliases)
  (define direct (mdn-url-for-token lang cls txt))
  (cond
    [direct direct]
    [(not (memq lang '(js html))) #f]
    [(and (token-class-in? (cons cls txt) '(name decl-name prop-name method-name object-key))
          (hash-ref method-aliases txt #f))
     (hash-ref method-aliases txt #f)]
    [(and (memq cls '(name decl-name prop-name method-name object-key))
          (resolve-js-owner txt object-aliases))
     (js-object-url (resolve-js-owner txt object-aliases))]
    [(eq? cls 'method-name)
     (define owner (js-infer-method-owner prev1 prev2 object-aliases))
     (cond
       [owner (js-object-method-url owner txt)]
       [else
        (define owners (hash-ref js-method-owner-index (string-downcase txt) null))
        (and (= (length owners) 1)
             (js-object-method-url (car owners) txt))])]
    ;; Alias call case: const parse = JSON.parse; parse(...)
    [(and (memq cls '(name decl-name))
          next1
          (eq? (car next1) 'punct)
          (string=? (cdr next1) "("))
     (hash-ref method-aliases txt #f)]
    [else #f]))

(define (mdn-class-for-token lang cls)
  (if (eq? lang 'wasm)
      (case cls
        [(wasm-form wasm-type wasm-instr) 'keyword]
        [(wasm-id) 'name]
        [else cls])
      cls))

(define (tokens->pieces lang tokens
                        #:color-swatch? [color-swatch? #f]
                        #:font-preview? [font-preview? #f]
                        #:dimension-preview? [dimension-preview? #t]
                        #:mdn-links? [mdn-links? #t]
                        #:docs-source [docs-source #f]
                        #:preview-tooltips? [preview-tooltips? #t]
                        #:preview-mode [preview-mode 'always])
  (define mode (normalize-preview-mode 'tokens->pieces preview-mode))
  (define css-preview-enabled? (not (eq? mode 'none)))
  (define tokens*
    (if (eq? lang 'css)
        (insert-css-color-swatch-tokens tokens (and color-swatch? css-preview-enabled?))
        tokens))
  (define tokens**
    (if (eq? lang 'css)
        (insert-css-font-preview-tokens tokens* (and font-preview? css-preview-enabled?))
        tokens*))
  (define tokens***
    (if (eq? lang 'css)
        (insert-css-dimension-preview-tokens tokens** (and dimension-preview? css-preview-enabled?))
        tokens**))
  (define tokens****
    (if (eq? lang 'css)
        (insert-css-design-token-tokens tokens*** css-preview-enabled?)
        tokens***))
  (define tokens*****
    (if (eq? lang 'css)
        (move-css-decorations-to-decl-end tokens****)
        tokens****))
  (define-values (js-object-aliases js-method-aliases)
    (if (memq lang '(js html))
        (build-js-alias-env tokens*****)
        (values (hash) (hash))))
  (let loop ([rest tokens*****] [acc null] [runtime-inserted? #f] [i 0])
    (cond
      [(null? rest) (reverse acc)]
      [else
        (define t (car rest))
        (define cls (car t))
        (define prev1
          (let loop-prev ([k (sub1 i)])
            (cond
              [(negative? k) #f]
              [else
               (define tk (list-ref tokens***** k))
               (if (token-nonplain? tk) tk (loop-prev (sub1 k)))])))
        (define prev2
          (and prev1
               (let ([k1
                      (let loop-prev ([k (sub1 i)])
                        (cond
                          [(negative? k) #f]
                          [else
                           (define tk (list-ref tokens***** k))
                           (if (token-nonplain? tk) k (loop-prev (sub1 k)))]))])
                 (and k1
                      (let loop-prev2 ([k (sub1 k1)])
                        (cond
                          [(negative? k) #f]
                          [else
                           (define tk (list-ref tokens***** k))
                           (if (token-nonplain? tk) tk (loop-prev2 (sub1 k)))]))))))
        (define next1 (next-nonplain-token (cdr rest)))
       (cond
         [(eq? cls 'escape)
         (loop (cdr rest) (append (reverse (list (escape->element (cdr t)))) acc) runtime-inserted? (add1 i))]
         [(eq? cls 'swatch)
          (if runtime-inserted?
              (loop (cdr rest) (append (reverse (list (css-swatch-element (cdr t) mode))) acc) #t (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-swatch-element (cdr t) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'swatch-gradient)
          (if runtime-inserted?
              (loop (cdr rest) (append (reverse (list (css-gradient-swatch-element (cdr t) mode))) acc) #t (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-gradient-swatch-element (cdr t) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'spacing-preview)
          (define p (cdr t))
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-spacing-preview-element (car p) (cdr p) mode))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-spacing-preview-element (car p) (cdr p) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'radius-preview)
          (define p (cdr t))
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-radius-preview-element (car p) (cdr p) mode))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-radius-preview-element (car p) (cdr p) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'token-def)
          (define p (cdr t))
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-token-def-element (car p) (cdr p)))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-token-def-element (car p) (cdr p)))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'token-ref)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-token-ref-element (cdr t)))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-token-ref-element (cdr t)))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'js-regex-preview)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (js-regex-preview-element))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (js-regex-preview-element))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'js-template-preview)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (js-template-preview-element))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (js-template-preview-element))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'font-preview)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-font-preview-element (cdr t) mode))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-font-preview-element (cdr t) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [else
         (define txt (cdr t))
         (define token-style (style-for lang cls))
          (define mdn-cls (mdn-class-for-token lang cls))
          (define maybe-url
            (cond
              [(regexp-match? #px"[[:space:]]" txt) #f]
              [(eq? lang 'wasm)
               (case (normalize-wasm-docs-source 'tokens->pieces
                                                 (or docs-source (current-wasm-docs-source)))
                 [(none) #f]
                 [(mdn)
                  (js-contextual-mdn-url lang mdn-cls txt prev1 prev2 next1
                                         js-object-aliases js-method-aliases)]
                 [(wasm-spec-3.0)
                 (wasm-spec-3.0-url-for-token cls txt)])]
              [(memq lang '(bash zsh powershell))
               (and mdn-links?
                    (shell-doc-url-for-token lang cls txt
                                             #:docs-source (or docs-source
                                                              (current-shell-docs-source))))]
              [(eq? lang 'latex)
               (latex-doc-url-for-token cls txt)]
              [(eq? lang 'go)
               (go-doc-url-for-token cls txt prev1 prev2 next1)]
              [(eq? lang 'java)
               (java-doc-url-for-token cls txt prev1 prev2 next1)]
              [(eq? lang 'pascal)
               (pascal-doc-url-for-token cls txt)]
              [(eq? lang 'ruby)
               (ruby-doc-url-for-token cls txt prev1 prev2 next1)]
              [(eq? lang 'rust)
               (generated-rust-doc-url-for-token cls txt prev1 prev2 next1)]
              [(memq lang '(c cpp))
               (c/cpp-doc-url-for-token lang cls txt prev1 prev2)]
              [else
               (and mdn-links?
                    (js-contextual-mdn-url lang mdn-cls txt prev1 prev2 next1
                                           js-object-aliases js-method-aliases))]))
          (define pieces
            (if maybe-url
                (list (hyperlink maybe-url #:style mdn-link-style #:underline? #f
                                 (element token-style txt)))
                (split-lines token-style txt)))
          (loop (cdr rest)
                (append (reverse pieces) acc)
                runtime-inserted?
                (add1 i))])])))

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
  (define (normalize-text txt)
    (if inline? (normalize-inline-text txt) txt))
  (let loop ([rest chunks] [pending ""] [acc null])
    (cond
      [(null? rest)
       (define acc2
         (if (string=? pending "")
             acc
             (append (reverse (tokenize lang (normalize-text pending))) acc)))
       (reverse acc2)]
      [else
       (define chunk (car rest))
       (cond
         [(eq? (car chunk) 'escape)
          (define acc2
            (if (string=? pending "")
                acc
                (append (reverse (tokenize lang (normalize-text pending))) acc)))
          (loop (cdr rest) "" (cons (cons 'escape (cdr chunk)) acc2))]
         [else
          (define txt (cdr chunk))
          (unless (string? txt)
            (raise-argument-error 'typeset-lang-code "string?" txt))
          (loop (cdr rest) (string-append pending txt) acc)])])))

(struct code-text (class text) #:transparent)
(struct code-link (url parts) #:transparent)
(struct code-space (count) #:transparent)
(struct code-newline () #:transparent)
(struct code-preview (kind attrs text) #:transparent)
(struct code-runtime () #:transparent)
(struct code-escape (value) #:transparent)
(struct code-inline-doc (lang parts) #:transparent)
(struct code-line (number parts highlighted?) #:transparent)
(struct code-block-doc (lang file lines copy-text inset? line-number-sep) #:transparent)
(struct raw-sxml (value) #:transparent)
(struct raw-html (value) #:transparent)

(define (values->chunks who values)
  (for/list ([v (in-list values)])
    (cond
      [(string? v) (cons 'text v)]
      [(or (raw-sxml? v) (raw-html? v)) (cons 'escape v)]
      [else (raise-argument-error who "(or/c string? raw-sxml? raw-html?)" v)])))

(define (values->scribble-chunks values)
  (for/list ([v (in-list values)])
    (if (string? v)
        (cons 'text v)
        (cons 'escape v))))

(define (normalize-html-output-lang who lang)
  (case lang
    [(shell) (normalize-scribble-shell who (current-scribble-shell))]
    [(pwsh) 'powershell]
    [else lang]))

(define (prepare-code-tokens lang chunks
                             #:inline? [inline? #f]
                             #:color-swatch? [color-swatch? #f]
                             #:font-preview? [font-preview? #f]
                             #:dimension-preview? [dimension-preview? #t]
                             #:preview-tooltips? [preview-tooltips? #t]
                             #:preview-mode [preview-mode 'always]
                             #:preview-css-url [preview-css-url #f]
                             #:jsx? [jsx? #f])
  (define html-style-color? (if (eq? lang 'html) #t color-swatch?))
  (define html-style-font? (if (eq? lang 'html) #t font-preview?))
  (define html-style-dim? (if (eq? lang 'html) #t dimension-preview?))
  (define html-style-mode (if (eq? lang 'html) 'always preview-mode))
  (define tokens
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?]
                   [current-jsx? (and (eq? lang 'js) jsx?)]
                   [current-html-style-color-swatch? html-style-color?]
                   [current-html-style-font-preview? html-style-font?]
                   [current-html-style-dimension-preview? html-style-dim?]
                   [current-html-style-preview-mode html-style-mode])
      (tokens-from-chunks lang chunks #:inline? inline?)))
  (if (eq? lang 'tsv)
      (normalize-tsv-display-tokens tokens)
      tokens))

(define (token-doc-url lang cls txt prev1 prev2 next1 object-aliases method-aliases
                       #:mdn-links? mdn-links?
                       #:docs-source docs-source)
  (define mdn-cls (mdn-class-for-token lang cls))
  (cond
    [(regexp-match? #px"[[:space:]]" txt) #f]
    [(eq? lang 'wasm)
     (case (normalize-wasm-docs-source 'tokens->code-parts
                                       (or docs-source (current-wasm-docs-source)))
       [(none) #f]
       [(mdn)
        (js-contextual-mdn-url lang mdn-cls txt prev1 prev2 next1
                               object-aliases method-aliases)]
       [(wasm-spec-3.0)
        (wasm-spec-3.0-url-for-token cls txt)])]
    [(memq lang '(bash zsh powershell))
     (and mdn-links?
          (shell-doc-url-for-token lang cls txt
                                   #:docs-source (or docs-source
                                                    (current-shell-docs-source))))]
    [(eq? lang 'latex)
     (latex-doc-url-for-token cls txt)]
    [(eq? lang 'go)
     (go-doc-url-for-token cls txt prev1 prev2 next1)]
    [(eq? lang 'java)
     (java-doc-url-for-token cls txt prev1 prev2 next1)]
    [(eq? lang 'pascal)
     (pascal-doc-url-for-token cls txt)]
    [(eq? lang 'ruby)
     (ruby-doc-url-for-token cls txt prev1 prev2 next1)]
    [(eq? lang 'rust)
     (generated-rust-doc-url-for-token cls txt prev1 prev2 next1)]
    [(memq lang '(c cpp))
     (c/cpp-doc-url-for-token lang cls txt prev1 prev2)]
    [else
     (and mdn-links?
          (js-contextual-mdn-url lang mdn-cls txt prev1 prev2 next1
                                 object-aliases method-aliases))]))

(define (text->code-parts cls s)
  (cond
    [(string=? s "") null]
    [(regexp-match-positions #rx"(?:\r\n|\r|\n)" s)
     => (lambda (m)
          (append (text->code-parts cls (substring s 0 (caar m)))
                  (list (code-newline))
                  (text->code-parts cls (substring s (cdar m)))))]
    [(regexp-match-positions #rx" +" s)
     => (lambda (m)
          (append (text->code-parts cls (substring s 0 (caar m)))
                  (list (code-space (- (cdar m) (caar m))))
                  (text->code-parts cls (substring s (cdar m)))))]
    [else (list (code-text cls s))]))

(define (preview-attrs class style title)
  (append
   `((class . ,class)
     (style . ,style))
   (preview-tooltip-attrs title)
   (preview-url-attrs)))

(define (preview-token->part cls datum mode)
  (case cls
    [(swatch)
     (code-preview 'swatch
                   (preview-attrs "css-preview-ui css-color-preview-ui"
                                  (format "--css-preview-bg: ~a;" datum)
                                  (format "Color preview: ~a" datum))
                   " ")]
    [(swatch-gradient)
     (code-preview 'swatch-gradient
                   (preview-attrs "css-preview-ui css-gradient-preview-ui"
                                  (format "--css-preview-bg: ~a;" datum)
                                  (format "Gradient preview: ~a" datum))
                   " ")]
    [(spacing-preview)
     (code-preview 'spacing-preview
                   (preview-attrs "css-preview-ui css-spacing-preview-ui"
                                  (format "--css-preview-width: ~apx;" (car datum))
                                  (spacing-preview-title (cdr datum)))
                   " ")]
    [(radius-preview)
     (code-preview 'radius-preview
                   (preview-attrs "css-preview-ui css-radius-preview-ui"
                                  (format "--css-preview-radius: ~apx;" (car datum))
                                  (radius-preview-title (cdr datum)))
                   " ")]
    [(token-def)
     (code-preview 'token-def
                   (preview-attrs "css-preview-ui css-token-def-preview-ui"
                                  (format "--css-token-name: \"~a\";" (car datum))
                                  (format "Design token ~a = ~a" (car datum) (cdr datum)))
                   (car datum))]
    [(token-ref)
     (code-preview 'token-ref
                   (preview-attrs "css-preview-ui css-token-ref-preview-ui"
                                  (format "--css-token-name: \"~a\";" datum)
                                  (format "Uses design token ~a" datum))
                   datum)]
    [(js-regex-preview)
     (code-preview 'js-regex-preview
                   `((class . "js-preview-ui js-regex-preview-ui")
                     ,@(preview-tooltip-attrs "Regex literal"))
                   "")]
    [(js-template-preview)
     (code-preview 'js-template-preview
                   `((class . "js-preview-ui js-template-preview-ui")
                     ,@(preview-tooltip-attrs "Template literal"))
                   "")]
    [(font-preview)
     (code-preview 'font-preview
                   (append
                    `((class . "css-preview-ui css-font-preview-ui")
                      (data-preview-mode . ,(preview-mode->string mode))
                      (data-font-stack . ,datum)
                      (style . ,(format "--css-preview-font: ~a;" datum)))
                    (preview-tooltip-attrs (format "Preview stack: ~a" datum))
                    (preview-url-attrs))
                   "Aa")]
    [else (code-text 'plain "")]))

(define (decorate-code-tokens lang tokens
                              #:color-swatch? [color-swatch? #f]
                              #:font-preview? [font-preview? #f]
                              #:dimension-preview? [dimension-preview? #t]
                              #:preview-mode [preview-mode 'always])
  (define mode (normalize-preview-mode 'decorate-code-tokens preview-mode))
  (define css-preview-enabled? (not (eq? mode 'none)))
  (define tokens*
    (if (eq? lang 'css)
        (insert-css-color-swatch-tokens tokens (and color-swatch? css-preview-enabled?))
        tokens))
  (define tokens**
    (if (eq? lang 'css)
        (insert-css-font-preview-tokens tokens* (and font-preview? css-preview-enabled?))
        tokens*))
  (define tokens***
    (if (eq? lang 'css)
        (insert-css-dimension-preview-tokens tokens** (and dimension-preview? css-preview-enabled?))
        tokens**))
  (define tokens****
    (if (eq? lang 'css)
        (insert-css-design-token-tokens tokens*** css-preview-enabled?)
        tokens***))
  (if (eq? lang 'css)
      (move-css-decorations-to-decl-end tokens****)
      tokens****))

(define (tokens->code-parts lang tokens
                            #:color-swatch? [color-swatch? #f]
                            #:font-preview? [font-preview? #f]
                            #:dimension-preview? [dimension-preview? #t]
                            #:mdn-links? [mdn-links? #t]
                            #:docs-source [docs-source #f]
                            #:preview-tooltips? [preview-tooltips? #t]
                            #:preview-mode [preview-mode 'always]
                            #:preview-css-url [preview-css-url #f])
  (define mode (normalize-preview-mode 'tokens->code-parts preview-mode))
  (define tokens*
    (decorate-code-tokens lang tokens
                          #:color-swatch? color-swatch?
                          #:font-preview? font-preview?
                          #:dimension-preview? dimension-preview?
                          #:preview-mode preview-mode))
  (define-values (js-object-aliases js-method-aliases)
    (if (memq lang '(js html))
        (build-js-alias-env tokens*)
        (values (hash) (hash))))
  (parameterize ([current-preview-css-url preview-css-url]
                 [current-preview-tooltips? preview-tooltips?])
    (let loop ([rest tokens*] [acc null] [i 0])
      (cond
        [(null? rest) (reverse acc)]
        [else
         (define t (car rest))
         (define cls (car t))
         (define prev1
           (let loop-prev ([k (sub1 i)])
             (cond
               [(negative? k) #f]
               [else
                (define tk (list-ref tokens* k))
                (if (token-nonplain? tk) tk (loop-prev (sub1 k)))])))
         (define prev2
           (and prev1
                (let ([k1
                       (let loop-prev ([k (sub1 i)])
                         (cond
                           [(negative? k) #f]
                           [else
                            (define tk (list-ref tokens* k))
                            (if (token-nonplain? tk) k (loop-prev (sub1 k)))]))])
                  (and k1
                       (let loop-prev2 ([k (sub1 k1)])
                         (cond
                           [(negative? k) #f]
                           [else
                            (define tk (list-ref tokens* k))
                            (if (token-nonplain? tk) tk (loop-prev2 (sub1 k)))]))))))
         (define next1 (next-nonplain-token (cdr rest)))
         (define parts
           (cond
             [(eq? cls 'escape) (list (code-escape (cdr t)))]
             [(memq cls '(swatch swatch-gradient spacing-preview radius-preview token-def token-ref
                                  js-regex-preview js-template-preview font-preview))
              (list (preview-token->part cls (cdr t) mode))]
             [else
              (define txt (cdr t))
              (define maybe-url
                (token-doc-url lang cls txt prev1 prev2 next1
                               js-object-aliases js-method-aliases
                               #:mdn-links? mdn-links?
                               #:docs-source docs-source))
              (define text-parts (text->code-parts cls txt))
              (if maybe-url
                  (list (code-link maybe-url text-parts))
                  text-parts)]))
         (loop (cdr rest) (append (reverse parts) acc) (add1 i))]))))

(define (parts->copy-text parts)
  (apply string-append
         (for/list ([p (in-list parts)]
                    #:when (or (code-text? p) (code-space? p) (code-newline? p)
                               (code-link? p)))
           (cond
             [(code-text? p) (code-text-text p)]
             [(code-space? p) (make-string (code-space-count p) #\space)]
             [(code-newline? p) "\n"]
             [(code-link? p) (parts->copy-text (code-link-parts p))]
             [else ""]))))

(define (highlight-line-set who specs)
  (define (positive-line-number? v)
    (and (exact-integer? v) (positive? v)))
  (define (add-range spec start end acc)
    (unless (and (positive-line-number? start)
                 (positive-line-number? end)
                 (<= start end))
      (raise-argument-error
       who
       "(listof (or/c exact-positive-integer? (cons/c exact-positive-integer? exact-positive-integer?) (list/c exact-positive-integer? exact-positive-integer?)))"
       spec))
    (for/fold ([acc acc]) ([i (in-range start (add1 end))])
      (set-add acc i)))
  (cond
    [(or (not specs) (null? specs)) (set)]
    [(not (list? specs))
     (raise-argument-error
      who
      "(or/c #f (listof (or/c exact-positive-integer? (cons/c exact-positive-integer? exact-positive-integer?) (list/c exact-positive-integer? exact-positive-integer?))))"
      specs)]
    [else
     (for/fold ([acc (set)]) ([spec (in-list specs)])
       (cond
         [(positive-line-number? spec) (set-add acc spec)]
         [(and (pair? spec)
               (positive-line-number? (car spec))
               (positive-line-number? (cdr spec)))
          (add-range spec (car spec) (cdr spec) acc)]
         [(and (list? spec)
               (= (length spec) 2)
               (positive-line-number? (first spec))
               (positive-line-number? (second spec)))
          (add-range spec (first spec) (second spec) acc)]
         [else
          (raise-argument-error
           who
           "(or/c exact-positive-integer? (cons/c exact-positive-integer? exact-positive-integer?) (list/c exact-positive-integer? exact-positive-integer?))"
           spec)]))]))

(define (parts->code-lines parts
                           #:line-numbers [line-numbers #f]
                           #:highlight-lines [highlight-lines #f])
  (define highlighted-lines (highlight-line-set 'highlight-lines highlight-lines))
  (define (trim-final-empty-line lines)
    (cond
      [(and (pair? lines)
            (pair? (cdr lines))
            (null? (last lines)))
       (take lines (sub1 (length lines)))]
      [else lines]))
  (define raw-lines
    (trim-final-empty-line
     (let loop ([rest parts] [lines null] [line null])
       (cond
         [(null? rest) (reverse (cons (reverse line) lines))]
         [(code-newline? (car rest))
          (loop (cdr rest) (cons (reverse line) lines) null)]
         [else (loop (cdr rest) lines (cons (car rest) line))]))))
  (for/list ([line (in-list raw-lines)]
             [source-i (in-naturals 1)]
             [display-i (in-naturals (or line-numbers 1))])
    (code-line (and line-numbers display-i)
               line
               (set-member? highlighted-lines source-i))))

(define (make-code-parts lang chunks
                         #:inline? [inline? #f]
                         #:color-swatch? [color-swatch? #f]
                         #:font-preview? [font-preview? #f]
                         #:dimension-preview? [dimension-preview? #t]
                         #:mdn-links? [mdn-links? #t]
                         #:docs-source [docs-source #f]
                         #:preview-tooltips? [preview-tooltips? #t]
                         #:preview-mode [preview-mode 'always]
                         #:preview-css-url [preview-css-url #f]
                         #:jsx? [jsx? #f])
  (define tokens
    (prepare-code-tokens lang chunks
                         #:inline? inline?
                         #:color-swatch? color-swatch?
                         #:font-preview? font-preview?
                         #:dimension-preview? dimension-preview?
                         #:preview-tooltips? preview-tooltips?
                         #:preview-mode preview-mode
                         #:preview-css-url preview-css-url
                         #:jsx? jsx?))
  (tokens->code-parts lang tokens
                      #:color-swatch? color-swatch?
                      #:font-preview? font-preview?
                      #:dimension-preview? dimension-preview?
                      #:mdn-links? mdn-links?
                      #:docs-source docs-source
                      #:preview-tooltips? preview-tooltips?
                      #:preview-mode preview-mode
                      #:preview-css-url preview-css-url))

(define (code-parts->scribble lang parts)
  (apply append
         (for/list ([p (in-list parts)])
           (cond
             [(code-text? p) (list (element (style-for lang (code-text-class p))
                                            (code-text-text p)))]
             [(code-space? p) (list (hspace (code-space-count p)))]
             [(code-newline? p) (list 'newline)]
             [(code-link? p)
              (list (hyperlink (code-link-url p)
                               #:style mdn-link-style
                               #:underline? #f
                               (code-parts->scribble lang (code-link-parts p))))]
             [(code-preview? p)
              (list (make-element
                     (make-style #f (list (attributes (code-preview-attrs p))))
                     (list (code-preview-text p))))]
             [(code-runtime? p) (runtime-prefix-elements)]
             [(code-escape? p) (list (escape->element (code-escape-value p)))]
             [else null]))))

(define (code-parts-have-runtime? parts)
  (for/or ([p (in-list parts)])
    (cond
      [(code-preview? p) #t]
      [(code-runtime? p) #t]
      [(code-link? p) (code-parts-have-runtime? (code-link-parts p))]
      [else #f])))

(define (code-inline-doc->scribble doc)
  (define parts (code-inline-doc-parts doc))
  (make-element inline-code-font-style
                (append (if (code-parts-have-runtime? parts)
                            (runtime-prefix-elements)
                            null)
                        (code-parts->scribble (code-inline-doc-lang doc) parts))))

(define (line-number-width lines)
  (define numbers (filter values (map code-line-number lines)))
  (if (null? numbers)
      0
      (string-length (format "~a" (apply max numbers)))))

(define (code-line->scribble line lang width sep)
  (define number (code-line-number line))
  (define parts (code-parts->scribble lang (code-line-parts line)))
  (define numbered-parts
    (if number
        (let* ([ln (format "~a" number)]
               [pad (- width (string-length ln))]
               [number-node
                (make-element 'smaller
                              (make-element 'smaller
                                            (append (if (positive? pad)
                                                        (list (hspace pad))
                                                        null)
                                                    (list (tt ln)
                                                          (hspace sep)))))])
          (cons number-node parts))
        parts))
  (list (paragraph (if (code-line-highlighted? line)
                       highlighted-line-style
                       omitable)
                   numbered-parts)))

(define (code-block-doc->scribble doc #:copy-button? [copy-button? #t])
  (define lang (code-block-doc-lang doc))
  (define lines (code-block-doc-lines doc))
  (define width (line-number-width lines))
  (define table-lines
    (for/list ([line (in-list lines)])
      (code-line->scribble line lang width (code-block-doc-line-number-sep doc))))
  (define tbl (table block-color table-lines))
  (define block (if (code-block-doc-inset? doc)
                    (nested #:style code-inset-tab-style tbl)
                    tbl))
  (define payload (if (code-block-doc-file doc)
                      (filebox (code-block-doc-file doc) block)
                      block))
  (define needs-runtime?
    (or copy-button?
        (for/or ([line (in-list lines)])
          (code-parts-have-runtime? (code-line-parts line)))))
  (if copy-button?
      (apply nested
             #:style copy-wrap-style
             (append (if needs-runtime? (runtime-prefix-elements) null)
                     (list payload
                           (copy-source-element (code-block-doc-copy-text doc)))))
      (if needs-runtime?
          (apply nested (append (runtime-prefix-elements) (list payload)))
          payload)))

(define (html-class-for-token cls)
  (format "stx-~a" cls))

(define (attrs->sxml attrs)
  (for/list ([a (in-list attrs)])
    (list (car a) (cdr a))))

(define (sxml-element name attrs children)
  (if (null? attrs)
      (cons name children)
      (cons name (cons (cons '@ (attrs->sxml attrs)) children))))

(define (code-parts->sxml-list parts)
  (apply append
         (for/list ([p (in-list parts)])
           (cond
             [(code-text? p)
              (define txt (code-text-text p))
              (if (eq? (code-text-class p) 'plain)
                  (list txt)
                  (list (sxml-element 'span
                                      `((class . ,(html-class-for-token (code-text-class p))))
                                      (list txt))))]
             [(code-space? p) (list (make-string (code-space-count p) #\space))]
             [(code-newline? p) (list "\n")]
             [(code-link? p)
              (list (sxml-element 'a
                                  `((class . "stx-link")
                                    (href . ,(code-link-url p)))
                                  (code-parts->sxml-list (code-link-parts p))))]
             [(code-preview? p)
              (list (sxml-element 'span
                                  (code-preview-attrs p)
                                  (list (code-preview-text p))))]
             [(code-escape? p)
              (define v (code-escape-value p))
              (cond
                [(raw-sxml? v) (list (raw-sxml-value v))]
                [(raw-html? v) (list v)]
                [(string? v) (list v)]
                [else
                 (raise-argument-error 'code-parts->sxml-list
                                       "(or/c string? raw-sxml? raw-html?)"
                                       v)])]
             [else null]))))

(define (code-inline-doc->sxml doc)
  (sxml-element 'code
                `((class . ,(format "scribble-tools-code scribble-tools-code-~a"
                                    (code-inline-doc-lang doc))))
                (code-parts->sxml-list (code-inline-doc-parts doc))))

(define (line-number-sxml n)
  (sxml-element 'span
                '((class . "stx-line-number")
                  (aria-hidden . "true"))
                (list (format "~a " n))))

(define (code-line->sxml line sep last?)
  (define line-content
    (append
     (if (code-line-number line)
         (list (line-number-sxml (format "~a~a"
                                          (code-line-number line)
                                          (make-string sep #\space))))
         null)
     (code-parts->sxml-list (code-line-parts line))))
  (append
   (if (code-line-highlighted? line)
       (list (sxml-element 'span
                           '((class . "stx-line-highlight"))
                           line-content))
       line-content)
   (if last? null (list "\n"))))

(define (code-block-doc->sxml doc #:copy-button? [copy-button? #t])
  (define code-node
    (sxml-element 'pre
                  `((class . ,(format "scribble-tools-block scribble-tools-block-~a"
                                      (code-block-doc-lang doc))))
                  (list
                   (sxml-element
                    'code
                    null
                    (apply append
                           (for/list ([line (in-list (code-block-doc-lines doc))]
                                      [i (in-naturals)])
                             (code-line->sxml
                              line
                              (code-block-doc-line-number-sep doc)
                              (= i (sub1 (length (code-block-doc-lines doc)))))))))))
  (define payload
    (if (code-block-doc-file doc)
        (sxml-element 'figure
                      '((class . "scribble-tools-file"))
                      (list (sxml-element 'figcaption
                                          '((class . "scribble-tools-file-label"))
                                          (list (code-block-doc-file doc)))
                            code-node))
        code-node))
  (if copy-button?
      (sxml-element 'div
                    '((class . "scribble-copy-wrap")
                      (data-copy-button . "on"))
                    (list payload
                          (sxml-element 'span
                                        '((class . "scribble-copy-source")
                                          (style . "display: none; white-space: pre;"))
                                        (list (code-block-doc-copy-text doc)))))
      payload))

(define code-html-support-css
  #<<CSS
.scribble-tools-code,.scribble-tools-block{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,"Liberation Mono",monospace;}
.scribble-tools-block{tab-size:2;-moz-tab-size:2;overflow:auto;padding:.75rem .9rem;border:1px solid rgba(120,120,120,.25);background:rgba(248,248,248,.92);}
.stx-comment{color:#6A9955}.stx-keyword,.stx-static-keyword,.stx-wasm-form{color:#07A}.stx-value,.stx-wasm-type{color:#A31515}.stx-name{color:#262680}.stx-decl-name{color:#795E26}.stx-prop-name,.stx-method-name,.stx-private-name{color:#5A3E8E}.stx-object-key,.stx-param-name{color:#1F5F8B}.stx-operator{color:#8A4F00}.stx-punct{color:#7A6A4A}.stx-type-name,.stx-builtin-name{font-weight:600;color:#2B5F8A}.stx-make-target,.stx-recipe-command{font-weight:600;color:#07A}.stx-make-variable{color:#6B2F8A}.stx-line-number{display:inline-block;min-width:2.5em;padding-right:.75em;color:rgba(90,90,90,.72);text-align:right;user-select:none}.stx-line-highlight{background:rgba(255,214,102,.22)}.stx-link{color:inherit;text-decoration:none}.stx-link:hover{text-decoration:underline}
CSS
  )

(define (code-html-support-sxml)
  (list (sxml-element 'style null (list code-html-support-css))
        (sxml-element 'script null (list css-font-preview-runtime-script))))

(define (escape-html s #:attribute? [attribute? #f])
  (define s1 (string-replace s "&" "&amp;"))
  (define s2 (string-replace s1 "<" "&lt;"))
  (define s3 (string-replace s2 ">" "&gt;"))
  (if attribute?
      (string-replace s3 "\"" "&quot;")
      s3))

(define (sxml-attrs? v)
  (and (pair? v) (eq? (car v) '@)))

(define (sxml->html x)
  (cond
    [(raw-html? x) (raw-html-value x)]
    [(raw-sxml? x) (sxml->html (raw-sxml-value x))]
    [(string? x) (escape-html x)]
    [(symbol? x) (escape-html (symbol->string x))]
    [(list? x)
     (cond
       [(null? x) ""]
       [(raw-html? (car x))
        (apply string-append (map sxml->html x))]
       [else
        (define tag (car x))
        (define rest (cdr x))
        (define attrs-node (and (pair? rest) (sxml-attrs? (car rest)) (car rest)))
        (define children (if attrs-node (cdr rest) rest))
        (define attrs
          (if attrs-node
              (apply string-append
                     (for/list ([a (in-list (cdr attrs-node))])
                       (format " ~a=\"~a\""
                               (car a)
                               (escape-html (format "~a" (cadr a)) #:attribute? #t))))
              ""))
        (define children-html
          (if (memq tag '(script style))
              (apply string-append
                     (for/list ([child (in-list children)])
                       (cond
                         [(raw-html? child) (raw-html-value child)]
                         [(string? child) child]
                         [else (sxml->html child)])))
              (apply string-append (map sxml->html children))))
        (format "<~a~a>~a</~a>"
                tag
                attrs
                children-html
                tag)])]
    [else (escape-html (format "~a" x))]))

(define (code-html-support)
  (apply string-append (map sxml->html (code-html-support-sxml))))

(define (code->sxml lang
                    #:color-swatch? [color-swatch? #t]
                    #:font-preview? [font-preview? #t]
                    #:dimension-preview? [dimension-preview? #t]
                    #:mdn-links? [mdn-links? #t]
                    #:docs-source [docs-source #f]
                    #:preview-tooltips? [preview-tooltips? #t]
                    #:preview-mode [preview-mode 'always]
                    #:preview-css-url [preview-css-url #f]
                    #:jsx? [jsx? #f]
                    . values)
  (define lang* (normalize-html-output-lang 'code->sxml lang))
  (define chunks (values->chunks 'code->sxml values))
  (code-inline-doc->sxml
   (code-inline-doc
    lang*
    (make-code-parts lang* chunks
                     #:inline? #t
                     #:color-swatch? color-swatch?
                     #:font-preview? font-preview?
                     #:dimension-preview? dimension-preview?
                     #:mdn-links? mdn-links?
                     #:docs-source docs-source
                     #:preview-tooltips? preview-tooltips?
                     #:preview-mode preview-mode
                     #:preview-css-url preview-css-url
                     #:jsx? jsx?))))

(define (code-block->sxml lang
                          #:file [filename #f]
                          #:indent [indent 0]
                          #:line-numbers [line-numbers #f]
                          #:line-number-sep [line-number-sep 1]
                          #:highlight-lines [highlight-lines #f]
                          #:copy-button? [copy-button? #t]
                          #:color-swatch? [color-swatch? #t]
                          #:font-preview? [font-preview? #t]
                          #:dimension-preview? [dimension-preview? #t]
                          #:mdn-links? [mdn-links? #t]
                          #:docs-source [docs-source #f]
                          #:preview-tooltips? [preview-tooltips? #t]
                          #:preview-mode [preview-mode 'always]
                          #:preview-css-url [preview-css-url #f]
                          #:jsx? [jsx? #f]
                          #:inset? [inset? #t]
                          . values)
  (define lang* (normalize-html-output-lang 'code-block->sxml lang))
  (define chunks (values->chunks 'code-block->sxml values))
  (define parts0
    (make-code-parts lang* chunks
                     #:inline? #f
                     #:color-swatch? color-swatch?
                     #:font-preview? font-preview?
                     #:dimension-preview? dimension-preview?
                     #:mdn-links? mdn-links?
                     #:docs-source docs-source
                     #:preview-tooltips? preview-tooltips?
                     #:preview-mode preview-mode
                     #:preview-css-url preview-css-url
                     #:jsx? jsx?))
  (define parts
    (if (zero? indent)
        parts0
        (cons (code-space indent) parts0)))
  (define doc
    (code-block-doc lang*
                    filename
                    (parts->code-lines parts
                                       #:line-numbers line-numbers
                                       #:highlight-lines highlight-lines)
                    (parts->copy-text parts0)
                    inset?
                    line-number-sep))
  (code-block-doc->sxml doc #:copy-button? copy-button?))

(define (code->scribble lang
                        #:color-swatch? [color-swatch? #t]
                        #:font-preview? [font-preview? #t]
                        #:dimension-preview? [dimension-preview? #t]
                        #:mdn-links? [mdn-links? #t]
                        #:docs-source [docs-source #f]
                        #:preview-tooltips? [preview-tooltips? #t]
                        #:preview-mode [preview-mode 'always]
                        #:preview-css-url [preview-css-url #f]
                        #:jsx? [jsx? #f]
                        . values)
  (define lang* (normalize-html-output-lang 'code->scribble lang))
  (define chunks (values->scribble-chunks values))
  (code-inline-doc->scribble
   (code-inline-doc
    lang*
    (make-code-parts lang* chunks
                     #:inline? #t
                     #:color-swatch? color-swatch?
                     #:font-preview? font-preview?
                     #:dimension-preview? dimension-preview?
                     #:mdn-links? mdn-links?
                     #:docs-source docs-source
                     #:preview-tooltips? preview-tooltips?
                     #:preview-mode preview-mode
                     #:preview-css-url preview-css-url
                     #:jsx? jsx?))))

(define (code-block->scribble lang
                              #:file [filename #f]
                              #:indent [indent 0]
                              #:line-numbers [line-numbers #f]
                              #:line-number-sep [line-number-sep 1]
                              #:highlight-lines [highlight-lines #f]
                              #:copy-button? [copy-button? #t]
                              #:color-swatch? [color-swatch? #t]
                              #:font-preview? [font-preview? #t]
                              #:dimension-preview? [dimension-preview? #t]
                              #:mdn-links? [mdn-links? #t]
                              #:docs-source [docs-source #f]
                              #:preview-tooltips? [preview-tooltips? #t]
                              #:preview-mode [preview-mode 'always]
                              #:preview-css-url [preview-css-url #f]
                              #:jsx? [jsx? #f]
                              #:inset? [inset? #t]
                              . values)
  (define lang* (normalize-html-output-lang 'code-block->scribble lang))
  (define chunks (values->scribble-chunks values))
  (define parts0
    (make-code-parts lang* chunks
                     #:inline? #f
                     #:color-swatch? color-swatch?
                     #:font-preview? font-preview?
                     #:dimension-preview? dimension-preview?
                     #:mdn-links? mdn-links?
                     #:docs-source docs-source
                     #:preview-tooltips? preview-tooltips?
                     #:preview-mode preview-mode
                     #:preview-css-url preview-css-url
                     #:jsx? jsx?))
  (define parts
    (if (zero? indent)
        parts0
        (cons (code-space indent) parts0)))
  (define doc
    (code-block-doc lang*
                    filename
                    (parts->code-lines parts
                                       #:line-numbers line-numbers
                                       #:highlight-lines highlight-lines)
                    (parts->copy-text parts0)
                    inset?
                    line-number-sep))
  (code-block-doc->scribble doc #:copy-button? copy-button?))

(define (code->html lang
                    #:color-swatch? [color-swatch? #t]
                    #:font-preview? [font-preview? #t]
                    #:dimension-preview? [dimension-preview? #t]
                    #:mdn-links? [mdn-links? #t]
                    #:docs-source [docs-source #f]
                    #:preview-tooltips? [preview-tooltips? #t]
                    #:preview-mode [preview-mode 'always]
                    #:preview-css-url [preview-css-url #f]
                    #:jsx? [jsx? #f]
                    . values)
  (sxml->html
   (keyword-apply code->sxml
                  '(#:color-swatch?
                    #:dimension-preview?
                    #:docs-source
                    #:font-preview?
                    #:jsx?
                    #:mdn-links?
                    #:preview-css-url
                    #:preview-mode
                    #:preview-tooltips?)
                  (list color-swatch?
                        dimension-preview?
                        docs-source
                        font-preview?
                        jsx?
                        mdn-links?
                        preview-css-url
                        preview-mode
                        preview-tooltips?)
                  lang
                  values)))

(define (code-block->html lang
                          #:file [filename #f]
                          #:indent [indent 0]
                          #:line-numbers [line-numbers #f]
                          #:line-number-sep [line-number-sep 1]
                          #:highlight-lines [highlight-lines #f]
                          #:copy-button? [copy-button? #t]
                          #:color-swatch? [color-swatch? #t]
                          #:font-preview? [font-preview? #t]
                          #:dimension-preview? [dimension-preview? #t]
                          #:mdn-links? [mdn-links? #t]
                          #:docs-source [docs-source #f]
                          #:preview-tooltips? [preview-tooltips? #t]
                          #:preview-mode [preview-mode 'always]
                          #:preview-css-url [preview-css-url #f]
                          #:jsx? [jsx? #f]
                          #:inset? [inset? #t]
                          . values)
  (sxml->html
   (keyword-apply code-block->sxml
                  '(#:color-swatch?
                    #:copy-button?
                    #:dimension-preview?
                    #:docs-source
                    #:file
                    #:font-preview?
                    #:highlight-lines
                    #:indent
                    #:inset?
                    #:jsx?
                    #:line-number-sep
                    #:line-numbers
                    #:mdn-links?
                    #:preview-css-url
                    #:preview-mode
                    #:preview-tooltips?)
                  (list color-swatch?
                        copy-button?
                        dimension-preview?
                        docs-source
                        filename
                        font-preview?
                        highlight-lines
                        indent
                        inset?
                        jsx?
                        line-number-sep
                        line-numbers
                        mdn-links?
                        preview-css-url
                        preview-mode
                        preview-tooltips?)
                  lang
                  values)))

(define (typeset-lang-block/chunks lang
                                   #:file [filename #f]
                                   #:indent [indent 0]
                                   #:line-numbers [line-numbers #f]
                                   #:line-number-sep [line-number-sep 1]
                                   #:copy-button? [copy-button? #t]
                                   #:color-swatch? [color-swatch? #f]
                                   #:font-preview? [font-preview? #f]
                                   #:dimension-preview? [dimension-preview? #t]
                                   #:mdn-links? [mdn-links? #t]
                                   #:docs-source [docs-source #f]
                                   #:preview-tooltips? [preview-tooltips? #t]
                                   #:preview-mode [preview-mode 'always]
                                   #:preview-css-url [preview-css-url #f]
                                   #:jsx? [jsx? #f]
                                   #:inset? [inset? #t]
                                   chunks)
  (define html-style-color? (if (eq? lang 'html) #t color-swatch?))
  (define html-style-font? (if (eq? lang 'html) #t font-preview?))
  (define html-style-dim? (if (eq? lang 'html) #t dimension-preview?))
  (define html-style-mode (if (eq? lang 'html) 'always preview-mode))
  (define tokens
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?]
                   [current-jsx? (and (eq? lang 'js) jsx?)]
                   [current-html-style-color-swatch? html-style-color?]
                   [current-html-style-font-preview? html-style-font?]
                   [current-html-style-dimension-preview? html-style-dim?]
                   [current-html-style-preview-mode html-style-mode])
      (tokens-from-chunks lang chunks)))
  (define display-tokens
    (if (eq? lang 'tsv)
        (normalize-tsv-display-tokens tokens)
        tokens))
  (define lines (list->lines indent
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?])
      (tokens->pieces lang display-tokens
                                              #:color-swatch? color-swatch?
                                              #:font-preview? font-preview?
                                              #:dimension-preview? dimension-preview?
                                              #:mdn-links? mdn-links?
                                              #:docs-source docs-source
                                              #:preview-tooltips? preview-tooltips?
                                               #:preview-mode preview-mode))
                             #:line-numbers line-numbers
                             #:line-number-sep line-number-sep
                             #:block? #t))
  (define tbl (table block-color lines))
  (define block (if inset?
                    (nested #:style code-inset-tab-style tbl)
                    tbl))
  (define payload (if filename
                      (filebox filename block)
                      block))
  (if copy-button?
      (apply nested
             #:style copy-wrap-style
             (append (runtime-prefix-elements)
                     (list payload
                           (copy-source-element (tokens->copy-text tokens)))))
      payload))

(define (typeset-lang-inline/chunks lang chunks
                                    #:color-swatch? [color-swatch? #f]
                                    #:font-preview? [font-preview? #f]
                                    #:dimension-preview? [dimension-preview? #t]
                                    #:mdn-links? [mdn-links? #t]
                                    #:docs-source [docs-source #f]
                                    #:preview-tooltips? [preview-tooltips? #t]
                                    #:preview-mode [preview-mode 'always]
                                    #:preview-css-url [preview-css-url #f]
                                    #:jsx? [jsx? #f])
  (define html-style-color? (if (eq? lang 'html) #t color-swatch?))
  (define html-style-font? (if (eq? lang 'html) #t font-preview?))
  (define html-style-dim? (if (eq? lang 'html) #t dimension-preview?))
  (define html-style-mode (if (eq? lang 'html) 'always preview-mode))
  (define tokens
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?]
                   [current-jsx? (and (eq? lang 'js) jsx?)]
                   [current-html-style-color-swatch? html-style-color?]
                   [current-html-style-font-preview? html-style-font?]
                   [current-html-style-dimension-preview? html-style-dim?]
                   [current-html-style-preview-mode html-style-mode])
      (tokens-from-chunks lang chunks #:inline? #t)))
  (make-element inline-code-font-style
                (parameterize ([current-preview-css-url preview-css-url]
                               [current-preview-tooltips? preview-tooltips?])
                  (tokens->pieces lang
                                  tokens
                                  #:color-swatch? color-swatch?
                                  #:font-preview? font-preview?
                                  #:dimension-preview? dimension-preview?
                                  #:mdn-links? mdn-links?
                                  #:docs-source docs-source
                                  #:preview-tooltips? preview-tooltips?
                  #:preview-mode preview-mode))))

(define (code->scribble/legacy lang
                               #:color-swatch? [color-swatch? #f]
                               #:font-preview? [font-preview? #f]
                               #:dimension-preview? [dimension-preview? #t]
                               #:mdn-links? [mdn-links? #t]
                               #:docs-source [docs-source #f]
                               #:preview-tooltips? [preview-tooltips? #t]
                               #:preview-mode [preview-mode 'always]
                               #:preview-css-url [preview-css-url #f]
                               #:jsx? [jsx? #f]
                               . values)
  (define lang* (normalize-html-output-lang 'code->scribble/legacy lang))
  (define chunks (values->scribble-chunks values))
  (if (eq? lang* 'scribble)
      (typeset-scribble-inline/chunks chunks)
      (typeset-lang-inline/chunks
       lang*
       chunks
       #:color-swatch? color-swatch?
       #:font-preview? font-preview?
       #:dimension-preview? dimension-preview?
       #:mdn-links? mdn-links?
       #:docs-source docs-source
       #:preview-tooltips? preview-tooltips?
       #:preview-mode preview-mode
       #:preview-css-url preview-css-url
       #:jsx? jsx?)))

(define (code-block->scribble/legacy lang
                                      #:file [filename #f]
                                      #:indent [indent 0]
                                      #:line-numbers [line-numbers #f]
                                      #:line-number-sep [line-number-sep 1]
                                      #:copy-button? [copy-button? #t]
                                      #:color-swatch? [color-swatch? #f]
                                      #:font-preview? [font-preview? #f]
                                      #:dimension-preview? [dimension-preview? #t]
                                      #:mdn-links? [mdn-links? #t]
                                      #:docs-source [docs-source #f]
                                      #:preview-tooltips? [preview-tooltips? #t]
                                      #:preview-mode [preview-mode 'always]
                                      #:preview-css-url [preview-css-url #f]
                                      #:jsx? [jsx? #f]
                                      #:inset? [inset? #t]
                                      . values)
  (define lang* (normalize-html-output-lang 'code-block->scribble/legacy lang))
  (define chunks (values->scribble-chunks values))
  (if (eq? lang* 'scribble)
      (typeset-scribble-block/chunks
       #:file filename
       #:indent indent
       #:line-numbers line-numbers
       #:line-number-sep line-number-sep
       #:copy-button? copy-button?
       #:inset? inset?
       chunks)
      (typeset-lang-block/chunks
       lang*
       #:file filename
       #:indent indent
       #:line-numbers line-numbers
       #:line-number-sep line-number-sep
       #:copy-button? copy-button?
       #:color-swatch? color-swatch?
       #:font-preview? font-preview?
       #:dimension-preview? dimension-preview?
       #:mdn-links? mdn-links?
       #:docs-source docs-source
       #:preview-tooltips? preview-tooltips?
       #:preview-mode preview-mode
       #:preview-css-url preview-css-url
       #:jsx? jsx?
       #:inset? inset?
       chunks)))

(define (typeset-scribble-inline/chunks
         #:lang [lang-line "scribble/manual"]
         #:context [context (current-scribble-context)]
         chunks)
  (define (leading-inline-hspace? v)
    (and (element? v)
         (eq? (element-style v) 'hspace)))
  (define (trim-leading-hspace-lists v)
    (cond
      [(list? v) (map trim-leading-hspace-lists (dropf v leading-inline-hspace?))]
      [else v]))
  (define maybe-src (chunks->string-or-false chunks))
  (define source*
    (and maybe-src
         (if (regexp-match? #px"(?m:^\\s*#lang\\s+)" maybe-src)
             maybe-src
             (string-append "#lang " lang-line "\n" maybe-src))))
  (or (and source*
           (let* ([v (typeset-code #:block? #f
                                   #:keep-lang-line? #f
                                   #:context context
                                   source*)]
                  [trimmed-content
                   (if (element? v)
                       (trim-leading-hspace-lists (element-content v))
                       v)])
             (if (element? v)
                 (make-element (element-style v) trimmed-content)
                 trimmed-content)))
      (typeset-lang-inline/chunks 'scribble
                                  #:mdn-links? #f
                                  chunks)))

(define (chunks->string-or-false chunks)
  (let loop ([rest chunks] [acc null])
    (cond
      [(null? rest) (apply string-append (reverse acc))]
      [else
       (define v (cdr (car rest)))
       (if (string? v)
           (loop (cdr rest) (cons v acc))
           #f)])))

(define (typeset-scribble-block/chunks
         #:file [filename #f]
         #:lang [lang-line "scribble/manual"]
         #:indent [indent 0]
         #:line-numbers [line-numbers #f]
         #:line-number-sep [line-number-sep 1]
         #:copy-button? [copy-button? #t]
         #:inset? [inset? #t]
         #:context [context (current-scribble-context)]
         chunks)
  (define maybe-src (chunks->string-or-false chunks))
  (define synthetic-lang-line?
    (and maybe-src
         (not (regexp-match? #px"(?m:^\\s*#lang\\s+)" maybe-src))))
  (define source*
    (and maybe-src
         (if synthetic-lang-line?
             (string-append "#lang " lang-line "\n" maybe-src)
             maybe-src)))
  (define visible-line-numbers
    (and line-numbers
         (if synthetic-lang-line?
             (max 0 (sub1 line-numbers))
             line-numbers)))
  (define rendered
    (or (and source*
             (let ([v (typeset-code
                       #:keep-lang-line? #f
                       #:context context
                       #:indent indent
                       #:line-numbers visible-line-numbers
                       #:line-number-sep line-number-sep
                       source*)])
               (if inset?
                   (nested #:style code-inset-tab-style v)
                   v)))
        (typeset-lang-block/chunks 'scribble
                                   #:file #f
                                   #:indent indent
                                   #:line-numbers line-numbers
                                   #:line-number-sep line-number-sep
                                   #:copy-button? #f
                                   #:mdn-links? #f
                                   #:inset? inset?
                                   chunks)))
  (define payload (if filename
                      (filebox filename rendered)
                      rendered))
  (define copy-text
    (or maybe-src
        (tokens->copy-text (tokens-from-chunks 'scribble chunks))))
  (if copy-button?
      (apply nested
             #:style copy-wrap-style
             (append (runtime-prefix-elements)
                     (list payload
                           (copy-source-element copy-text))))
      payload))

(define (scribbleblock-proc
         #:file [filename #f]
         #:lang [lang-line "scribble/manual"]
         #:indent [indent 0]
         #:line-numbers [line-numbers #f]
         #:line-number-sep [line-number-sep 1]
         #:copy-button? [copy-button? #t]
         #:context [context (current-scribble-context)]
         chunks)
  (typeset-scribble-block/chunks
   #:file filename
   #:lang lang-line
   #:indent indent
   #:line-numbers line-numbers
   #:line-number-sep line-number-sep
   #:copy-button? copy-button?
   #:inset? #t
   #:context context
   chunks))

(define (scribbleblock0-proc
         #:file [filename #f]
         #:lang [lang-line "scribble/manual"]
         #:indent [indent 0]
         #:line-numbers [line-numbers #f]
         #:line-number-sep [line-number-sep 1]
         #:copy-button? [copy-button? #t]
         #:context [context (current-scribble-context)]
         chunks)
  (typeset-scribble-block/chunks
   #:file filename
   #:lang lang-line
   #:indent indent
   #:line-numbers line-numbers
   #:line-number-sep line-number-sep
   #:copy-button? copy-button?
   #:inset? #f
   #:context context
   chunks))

(define-for-syntax (chunks-template args-stx escape-id-stx)
  (for/list ([arg (in-list (syntax->list args-stx))])
    (syntax-parse arg
      [(esc e:expr)
       #:when (and (identifier? #'esc)
                   (free-identifier=? #'esc escape-id-stx))
       #`(cons 'escape e)]
      [_ #`(cons 'text #,arg)])))

(define-for-syntax (values-template args-stx escape-id-stx)
  (for/list ([arg (in-list (syntax->list args-stx))])
    (syntax-parse arg
      [(esc e:expr)
       #:when (and (identifier? #'esc)
                   (free-identifier=? #'esc escape-id-stx))
       #'e]
      [_ arg])))

(define-for-syntax (do-block stx lang inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:lang lang-expr:expr)
                              #:defaults ([lang-expr #'"scribble/manual"])
                              #:name "#:lang keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
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
     #`(code-block->scribble '#,lang
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:mdn-links? mdn-links-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-scribble-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:lang lang-expr:expr)
                              #:defaults ([lang-expr #'"scribble/manual"])
                              #:name "#:lang keyword")
                   (~optional (~seq #:context ctx-expr:expr)
                              #:name "#:context keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
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
     #`(code-block->scribble 'scribble
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-css-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
                   (~optional (~seq #:color-swatch? color-swatch-expr:expr)
                              #:defaults ([color-swatch-expr #'#t])
                              #:name "#:color-swatch? keyword")
                   (~optional (~seq #:font-preview? font-preview-expr:expr)
                              #:defaults ([font-preview-expr #'#t])
                              #:name "#:font-preview? keyword")
                   (~optional (~seq #:dimension-preview? dimension-preview-expr:expr)
                              #:defaults ([dimension-preview-expr #'#t])
                              #:name "#:dimension-preview? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:preview-mode preview-mode-expr:expr)
                              #:defaults ([preview-mode-expr #''always])
                              #:name "#:preview-mode keyword")
                   (~optional (~seq #:preview-tooltips? preview-tooltips-expr:expr)
                              #:defaults ([preview-tooltips-expr #'#t])
                              #:name "#:preview-tooltips? keyword")
                   (~optional (~seq #:preview-css-url preview-css-url-expr:expr)
                              #:defaults ([preview-css-url-expr #'#f])
                              #:name "#:preview-css-url keyword")
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
     #`(code-block->scribble 'css
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:color-swatch? color-swatch-expr
                              #:font-preview? font-preview-expr
                              #:dimension-preview? dimension-preview-expr
                              #:mdn-links? mdn-links-expr
                              #:preview-tooltips? preview-tooltips-expr
                              #:preview-mode preview-mode-expr
                              #:preview-css-url preview-css-url-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-js-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:jsx? jsx-expr:expr)
                              #:defaults ([jsx-expr #'#f])
                              #:name "#:jsx? keyword")
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
     #`(code-block->scribble 'js
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:mdn-links? mdn-links-expr
                              #:jsx? jsx-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-python-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
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
     #`(code-block->scribble 'python
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-simple-block stx lang inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
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
     #`(code-block->scribble '#,lang
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-wasm-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
                   (~optional (~seq #:docs-source docs-source-expr:expr)
                              #:defaults ([docs-source-expr #'(current-wasm-docs-source)])
                              #:name "#:docs-source keyword")
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
     #`(code-block->scribble 'wasm
                              #:file filename-expr
                              #:indent indent-expr
                              #:line-numbers line-numbers-expr
                              #:highlight-lines highlight-lines-expr
                              #:line-number-sep line-number-sep-expr
                              #:copy-button? copy-button-expr
                              #:docs-source docs-source-expr
                              #:inset? #,inset?
                              #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-shell-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:shell shell-expr:expr)
                              #:defaults ([shell-expr #'(current-scribble-shell)])
                              #:name "#:shell keyword")
                   (~optional (~seq #:docs-source docs-source-expr:expr)
                              #:defaults ([docs-source-expr #'(current-shell-docs-source)])
                              #:name "#:docs-source keyword")
                   (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:highlight-lines highlight-lines-expr:expr)
                              #:defaults ([highlight-lines-expr #'#f])
                              #:name "#:highlight-lines keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:copy-button? copy-button-expr:expr)
                              #:defaults ([copy-button-expr #'#t])
                              #:name "#:copy-button? keyword")
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
     #`(let ([shell* (normalize-scribble-shell 'shellblock shell-expr)])
         (code-block->scribble shell*
                               #:file filename-expr
                               #:indent indent-expr
                               #:line-numbers line-numbers-expr
                               #:highlight-lines highlight-lines-expr
                               #:line-number-sep line-number-sep-expr
                               #:copy-button? copy-button-expr
                               #:docs-source docs-source-expr
                               #:inset? #,inset?
                               #,@(values-template #'(str ...) esc-id)))]))

(define-syntax (css-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:color-swatch? color-swatch-expr:expr)
                              #:defaults ([color-swatch-expr #'#t])
                              #:name "#:color-swatch? keyword")
                   (~optional (~seq #:font-preview? font-preview-expr:expr)
                              #:defaults ([font-preview-expr #'#t])
                              #:name "#:font-preview? keyword")
                   (~optional (~seq #:dimension-preview? dimension-preview-expr:expr)
                              #:defaults ([dimension-preview-expr #'#t])
                              #:name "#:dimension-preview? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:preview-mode preview-mode-expr:expr)
                              #:defaults ([preview-mode-expr #''always])
                              #:name "#:preview-mode keyword")
                   (~optional (~seq #:preview-tooltips? preview-tooltips-expr:expr)
                              #:defaults ([preview-tooltips-expr #'#t])
                              #:name "#:preview-tooltips? keyword")
                   (~optional (~seq #:preview-css-url preview-css-url-expr:expr)
                              #:defaults ([preview-css-url-expr #'#f])
                              #:name "#:preview-css-url keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble 'css
                       #:color-swatch? color-swatch-expr
                       #:font-preview? font-preview-expr
                       #:dimension-preview? dimension-preview-expr
                       #:mdn-links? mdn-links-expr
                       #:preview-tooltips? preview-tooltips-expr
                       #:preview-mode preview-mode-expr
                       #:preview-css-url preview-css-url-expr
                       #,@(values-template #'(str ...) esc-id))]))

(define-syntax (html-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble 'html
                       #:mdn-links? mdn-links-expr
                       #,@(values-template #'(str ...) esc-id))]))

(define-syntax (js-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:jsx? jsx-expr:expr)
                              #:defaults ([jsx-expr #'#f])
                              #:name "#:jsx? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble 'js
                       #:jsx? jsx-expr
                       #:mdn-links? mdn-links-expr
                       #,@(values-template #'(str ...) esc-id))]))

(define-syntax (python-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble 'python
                       #,@(values-template #'(str ...) esc-id))]))

(define-for-syntax (do-simple-inline stx lang)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble '#,lang
                       #,@(values-template #'(str ...) esc-id))]))

(define-syntax (c-code stx) (do-simple-inline stx 'c))
(define-syntax (cpp-code stx) (do-simple-inline stx 'cpp))
(define-syntax (makefile-code stx) (do-simple-inline stx 'makefile))
(define-syntax (tex-code stx) (do-simple-inline stx 'tex))
(define-syntax (latex-code stx) (do-simple-inline stx 'latex))
(define-syntax (objc-code stx) (do-simple-inline stx 'objc))
(define-syntax (haskell-code stx) (do-simple-inline stx 'haskell))
(define-syntax (pascal-code stx) (do-simple-inline stx 'pascal))
(define-syntax (plist-code stx) (do-simple-inline stx 'plist))
(define-syntax (csv-code stx) (do-simple-inline stx 'csv))
(define-syntax (go-code stx) (do-simple-inline stx 'go))
(define-syntax (java-code stx) (do-simple-inline stx 'java))
(define-syntax (mathematica-code stx) (do-simple-inline stx 'mathematica))
(define-syntax (json-code stx) (do-simple-inline stx 'json))
(define-syntax (markdown-code stx) (do-simple-inline stx 'markdown))
(define-syntax (racket-code stx) (do-simple-inline stx 'racket))
(define-syntax (rhombus-code stx) (do-simple-inline stx 'rhombus))
(define-syntax (ruby-code stx) (do-simple-inline stx 'ruby))
(define-syntax (rust-code stx) (do-simple-inline stx 'rust))
(define-syntax (swift-code stx) (do-simple-inline stx 'swift))
(define-syntax (sql-code stx) (do-simple-inline stx 'sql))
(define-syntax (sqlite-code stx) (do-simple-inline stx 'sqlite))
(define-syntax (mysql-code stx) (do-simple-inline stx 'mysql))
(define-syntax (postgres-code stx) (do-simple-inline stx 'postgres))
(define-syntax (tsv-code stx) (do-simple-inline stx 'tsv))
(define-syntax (yaml-code stx) (do-simple-inline stx 'yaml))

(define-syntax (wasm-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:docs-source docs-source-expr:expr)
                              #:defaults ([docs-source-expr #'(current-wasm-docs-source)])
                              #:name "#:docs-source keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble 'wasm
                       #:docs-source docs-source-expr
                       #,@(values-template #'(str ...) esc-id))]))

(define-syntax (shell-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:shell shell-expr:expr)
                              #:defaults ([shell-expr #'(current-scribble-shell)])
                              #:name "#:shell keyword")
                   (~optional (~seq #:docs-source docs-source-expr:expr)
                              #:defaults ([docs-source-expr #'(current-shell-docs-source)])
                              #:name "#:docs-source keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(let ([shell* (normalize-scribble-shell 'shell-code shell-expr)])
         (code->scribble shell*
                         #:docs-source docs-source-expr
                         #,@(values-template #'(str ...) esc-id)))]))

(define-syntax (scribble-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:context ctx-expr:expr)
                              #:name "#:context keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(code->scribble 'scribble
                       #,@(values-template #'(str ...) esc-id))]))

(define-syntax (cssblock0 stx) (do-css-block stx #f))
(define-syntax (cssblock stx) (do-css-block stx #t))
(define-syntax (cblock0 stx) (do-simple-block stx 'c #f))
(define-syntax (cblock stx) (do-simple-block stx 'c #t))
(define-syntax (cppblock0 stx) (do-simple-block stx 'cpp #f))
(define-syntax (cppblock stx) (do-simple-block stx 'cpp #t))
(define-syntax (makefileblock0 stx) (do-simple-block stx 'makefile #f))
(define-syntax (makefileblock stx) (do-simple-block stx 'makefile #t))
(define-syntax (texblock0 stx) (do-simple-block stx 'tex #f))
(define-syntax (texblock stx) (do-simple-block stx 'tex #t))
(define-syntax (latexblock0 stx) (do-simple-block stx 'latex #f))
(define-syntax (latexblock stx) (do-simple-block stx 'latex #t))
(define-syntax (objcblock0 stx) (do-simple-block stx 'objc #f))
(define-syntax (objcblock stx) (do-simple-block stx 'objc #t))
(define-syntax (haskellblock0 stx) (do-simple-block stx 'haskell #f))
(define-syntax (haskellblock stx) (do-simple-block stx 'haskell #t))
(define-syntax (pascalblock0 stx) (do-simple-block stx 'pascal #f))
(define-syntax (pascalblock stx) (do-simple-block stx 'pascal #t))
(define-syntax (plistblock0 stx) (do-simple-block stx 'plist #f))
(define-syntax (plistblock stx) (do-simple-block stx 'plist #t))
(define-syntax (csvblock0 stx) (do-simple-block stx 'csv #f))
(define-syntax (csvblock stx) (do-simple-block stx 'csv #t))
(define-syntax (goblock0 stx) (do-simple-block stx 'go #f))
(define-syntax (goblock stx) (do-simple-block stx 'go #t))
(define-syntax (htmlblock0 stx) (do-block stx 'html #f))
(define-syntax (htmlblock stx) (do-block stx 'html #t))
(define-syntax (javablock0 stx) (do-simple-block stx 'java #f))
(define-syntax (javablock stx) (do-simple-block stx 'java #t))
(define-syntax (mathematicablock0 stx) (do-simple-block stx 'mathematica #f))
(define-syntax (mathematicablock stx) (do-simple-block stx 'mathematica #t))
(define-syntax (jsblock0 stx) (do-js-block stx #f))
(define-syntax (jsblock stx) (do-js-block stx #t))
(define-syntax (jsonblock0 stx) (do-simple-block stx 'json #f))
(define-syntax (jsonblock stx) (do-simple-block stx 'json #t))
(define-syntax (markdownblock0 stx) (do-simple-block stx 'markdown #f))
(define-syntax (markdownblock stx) (do-simple-block stx 'markdown #t))
(define-syntax (pythonblock0 stx) (do-python-block stx #f))
(define-syntax (pythonblock stx) (do-python-block stx #t))
(define-syntax (racketblock0 stx) (do-simple-block stx 'racket #f))
(define-syntax (racketblock stx) (do-simple-block stx 'racket #t))
(define-syntax (rhombusblock0 stx) (do-simple-block stx 'rhombus #f))
(define-syntax (rhombusblock stx) (do-simple-block stx 'rhombus #t))
(define-syntax (rubyblock0 stx) (do-simple-block stx 'ruby #f))
(define-syntax (rubyblock stx) (do-simple-block stx 'ruby #t))
(define-syntax (rustblock0 stx) (do-simple-block stx 'rust #f))
(define-syntax (rustblock stx) (do-simple-block stx 'rust #t))
(define-syntax (swiftblock0 stx) (do-simple-block stx 'swift #f))
(define-syntax (swiftblock stx) (do-simple-block stx 'swift #t))
(define-syntax (sqlblock0 stx) (do-simple-block stx 'sql #f))
(define-syntax (sqlblock stx) (do-simple-block stx 'sql #t))
(define-syntax (sqliteblock0 stx) (do-simple-block stx 'sqlite #f))
(define-syntax (sqliteblock stx) (do-simple-block stx 'sqlite #t))
(define-syntax (mysqlblock0 stx) (do-simple-block stx 'mysql #f))
(define-syntax (mysqlblock stx) (do-simple-block stx 'mysql #t))
(define-syntax (postgresblock0 stx) (do-simple-block stx 'postgres #f))
(define-syntax (postgresblock stx) (do-simple-block stx 'postgres #t))
(define-syntax (wasmblock0 stx) (do-wasm-block stx #f))
(define-syntax (wasmblock stx) (do-wasm-block stx #t))
(define-syntax (shellblock0 stx) (do-shell-block stx #f))
(define-syntax (shellblock stx) (do-shell-block stx #t))
(define-syntax (scribbleblock0 stx) (do-scribble-block stx #f))
(define-syntax (scribbleblock stx) (do-scribble-block stx #t))
(define-syntax (tsvblock0 stx) (do-simple-block stx 'tsv #f))
(define-syntax (tsvblock stx) (do-simple-block stx 'tsv #t))
(define-syntax (yamlblock0 stx) (do-simple-block stx 'yaml #f))
(define-syntax (yamlblock stx) (do-simple-block stx 'yaml #t))

(module+ test
  (require rackunit
           parser-tools/lex)
  (define-syntax-rule (unsyntax e) e)
  (define-syntax-rule (UNQ e) e)
  (define-runtime-path fixtures-dir "test-fixtures")
  (define (read-fixture file)
    (file->string (build-path fixtures-dir file)))
  (define (classes lang src)
    (map car (tokenize lang src)))
  (define (class-count cls l)
    (for/sum ([x (in-list l)])
      (if (eq? x cls) 1 0)))
  (define decoration-classes
    '(swatch swatch-gradient font-preview spacing-preview radius-preview token-def token-use))
  (define (source-bearing-text tokens)
    (apply string-append
           (for/list ([t (in-list tokens)]
                      #:when (and (string? (cdr t))
                                  (not (memq (car t) decoration-classes))))
             (cdr t))))
  (define (compare-class-normalize cls)
    (if (memq cls decoration-classes)
        cls
        (normalize-render-class cls)))
  (define (compare-css-class-normalize cls)
    (case cls
      [(keyword name) 'ident]
      [else (compare-class-normalize cls)]))
  (define (class-runs tokens)
    (let loop ([rest (map (lambda (t) (compare-class-normalize (car t))) tokens)]
               [prev #f]
               [acc null])
      (cond
        [(null? rest) (reverse acc)]
        [(eq? (car rest) prev) (loop (cdr rest) prev acc)]
        [else (loop (cdr rest) (car rest) (cons (car rest) acc))])))
  (define (class-runs/normalize tokens normalize)
    (let loop ([rest (map (lambda (t) (normalize (car t))) tokens)]
               [prev #f]
               [acc null])
      (cond
        [(null? rest) (reverse acc)]
        [(eq? (car rest) prev) (loop (cdr rest) prev acc)]
        [else (loop (cdr rest) (car rest) (cons (car rest) acc))])))
  (define (has-target-url-prop? st)
    (and (style? st)
         (for/or ([p (in-list (style-properties st))])
           (target-url? p))))
  (define (contains-link? v)
    (cond
      [(element? v)
       (or (has-target-url-prop? (element-style v))
           (let ([c (element-content v)])
             (if (list? c)
                 (for/or ([x (in-list c)]) (contains-link? x))
                 (contains-link? c))))]
      [(list? v) (for/or ([c (in-list v)]) (contains-link? c))]
      [else #f]))
  (define (collect-target-urls v)
    (define (style-target st)
      (and (style? st)
           (for/or ([p (in-list (style-properties st))])
             (and (target-url? p)
                  (vector-ref (struct->vector p) 1)))))
    (cond
      [(element? v)
       (append
        (let ([u (style-target (element-style v))])
          (if u (list u) null))
        (let ([c (element-content v)])
          (if (list? c)
              (append-map collect-target-urls c)
              (collect-target-urls c))))]
      [(list? v) (append-map collect-target-urls v)]
      [else null]))
  (define (contains-text? v needle)
    (string-contains? (format "~s" v) needle))
  (define (has-class? v class-name)
    (string-contains? (format "~s" v)
                      (format "(class . \"~a\")" class-name)))
  (define (derived-stream-contiguous? tokens token-start token-end)
    (or (null? tokens)
        (for/and ([left (in-list tokens)]
                  [right (in-list (cdr tokens))])
          (= (position-offset (token-end left))
             (position-offset (token-start right))))))
  (define (shell-derived-stream-contiguous? tokens)
    (derived-stream-contiguous? tokens
                               shell-derived-token-start
                               shell-derived-token-end))
  (define (latex-derived-stream-contiguous? tokens)
    (derived-stream-contiguous? tokens
                               latex-derived-token-start
                               latex-derived-token-end))
  (define (sql-derived-stream-contiguous? tokens)
    (derived-stream-contiguous? tokens
                               sql-derived-token-start
                               sql-derived-token-end))
  (check-true (block? (cssblock "h1 { color: red; }")))
  (check-true (block? (cblock "int main(void) { return 0; }")))
  (check-true (block? (cppblock "int main() { return 0; }")))
  (check-true (block? (makefileblock "all:\n\t@echo ok\n")))
  (check-true (block? (texblock "\\hbox{Hello}")))
  (check-true (block? (latexblock "\\section{Hi}")))
  (check-true (block? (objcblock "@interface Box : NSObject @end")))
  (check-true (block? (haskellblock "add :: Int -> Int -> Int\nadd x y = x + y\n")))
  (check-true (block? (pascalblock "function Add(x, y: Integer): Integer; begin Add := x + y; end;")))
  (check-true (block? (plistblock "<plist><dict><key>Name</key><string>Ada</string></dict></plist>")))
  (check-true (block? (csvblock "name,age\nAda,37\n")))
  (check-true (block? (goblock "package main\n\nfunc add(x int, y int) int {\n    return x + y\n}\n")))
  (check-true (block? (htmlblock "<h1 class=\"x\">Hi</h1>")))
  (check-true (block? (javablock "class Example { void run() { System.out.println(\"hi\"); } }\n")))
  (check-true (block? (mathematicablock "f[x_] := Module[{y = x^2}, y + 1]\n")))
  (check-true (block? (jsblock "const x = 1;")))
  (check-true (block? (jsonblock "{ \"name\": \"Ada\" }")))
  (check-true (block? (markdownblock "# Title\n\n* item\n")))
  (check-true (block? (pythonblock "def f(x):\n    return x\n")))
  (check-true (block? (racketblock "(define (f x) (+ x 1))")))
  (check-true (block? (rhombusblock "fun add(x, y): x + y")))
  (check-true (block? (rubyblock "class Greeter\n  def call(name:) puts name end\nend\n")))
  (check-true (block? (rustblock "fn add(x: i32, y: i32) -> i32 { x + y }")))
  (check-true (block? (swiftblock "func add(_ x: Int, _ y: Int) -> Int { x + y }")))
  (check-true (block? (sqlblock "SELECT name FROM people WHERE active = TRUE;")))
  (check-true (block? (sqliteblock "SELECT [group] FROM `items` WHERE id = ?1;")))
  (check-true (block? (mysqlblock "# note\nSELECT @user FROM `users`;")))
  (check-true (block? (postgresblock "SELECT $1, $$hello$$;")))
  (check-true (block? (wasmblock "(module (func))")))
  (check-true (block? (shellblock "if [ -f ./x ]; then echo ok; fi")))
  (check-true (block? (scribbleblock "@title{Hi}\nText.")))
  (check-true (block? (tsvblock "name\tage\nAda\t37\n")))
  (check-true (block? (yamlblock "name: Ada\nactive: true\n")))
  (check-true (block? (cssblock #:copy-button? #f "h1 { color: red; }")))
  (check-true (block? (htmlblock #:copy-button? #f "<h1 class=\"x\">Hi</h1>")))
  (check-true (block? (jsblock #:copy-button? #f "const x = 1;")))
  (check-true (block? (pythonblock #:copy-button? #f "def f(x):\n    return x\n")))
  (check-true (block? (wasmblock #:copy-button? #f "(module (func))")))
  (check-true (block? (scribbleblock #:copy-button? #f "@title{Hi}\nText.")))
  (check-true (block? (jsblock #:jsx? #t "const el = <A x={1}/>;")))
  (check-true (element? (css-code "h1 { color: red; }")))
  (check-true (element? (c-code "int x = 1;")))
  (let ([cls (classes 'c "#include <stdio.h>\ntypedef struct Node { int value; } Node;\nstatic int count;\nFILE *out;\nsize_t n = 0;\nchar *s = \"ok\";\nchar bad = '\\q';\n")])
    (check-not-false (member 'type-name cls))
    (check-true ((class-count 'type-name cls) . >= . 5))
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'plain cls)))
  (check-true (element? (cpp-code "std::vector<int> xs;")))
  (let ([cls (classes 'cpp "#include <vector>\nstd::vector<int> xs;\nstd::string s = R\"(ok)\";\nauto d = 12_km;\n")])
    (check-not-false (member 'type-name cls))
    (check-true ((class-count 'type-name cls) . >= . 4))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls)))
  (check-true (element? (makefile-code "all: build test")))
  (let ([cls (classes 'makefile ".PHONY: docs\ndocs:\n\traco scribble +m --html --dest html scribblings/scribble-tools.scrbl\n\ttest -f private/lang-code.rkt\nCC = cc\nall:\n\t$(CC) -o $@ $<\n")])
    (check-not-false (member 'make-target cls))
    (check-not-false (member 'recipe-command cls))
    (check-not-false (member 'recipe-option cls))
    (check-not-false (member 'make-variable cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'operator cls)))
  (let ([cls (classes 'makefile "build: input | cache ; @echo ok\n\t${CC} -o $@ $<\n")])
    (check-not-false (member 'operator cls))
    (check-not-false (member 'make-variable cls)))
  (check-true (element? (tex-code "\\hbox{Hello}")))
  (let ([cls (classes 'tex "\\def\\foo#1{$$#1^2$$ \\verb|x+y| \\~n}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'operator cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls)))
  (check-true (element? (latex-code "\\section{Hi}")))
  (let ([cls (classes 'latex "\\begin{itemize}\n\\item One\\\\\n\\verb|x+y|\n\\end{itemize}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'operator cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls)))
  (check-true (element? (objc-code "@\"hello\"")))
  (let ([cls (classes 'objc "@interface Box : NSObject\n@property NSString *name;\n@end\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls)))
  (check-true (element? (haskell-code "map (+1) [1,2,3]")))
  (let ([cls (classes 'haskell "{-# LANGUAGE OverloadedStrings #-}\nmain = do\n  putStrLn \"hi\" -- note\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls)))
  (check-true (element? (pascal-code "var answer: Integer;")))
  (let ([cls (classes 'pascal "type TPoint = record x, y: Integer; end;\nvar p: TPoint;\nfunction Add(x, y: Integer): Integer;\nbegin\n  Add := x + y + $FF;\nend;\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'type-name cls))
    (check-true ((class-count 'type-name cls) . >= . 5))
    (check-not-false (member 'value cls)))
  (check-true (element? (plist-code "<plist/>")))
  (let ([cls (classes 'plist "<?xml version=\"1.0\"?>\n<plist><dict><key>Name</key><string>Ada &amp; Bob</string></dict></plist>\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (check-true (element? (csv-code "a,b")))
  (check-true (element? (go-code "func add(x int, y int) int { return x + y }")))
  (let ([cls (classes 'go "package main\n\ntype Server struct {\n    ctx Context\n    buf Buffer\n}\n\nfunc add(x int, y int) int {\n    var s string = `raw`\n    var r rune = 'x'\n    return x + y\n}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'type-name cls))
    (check-true ((class-count 'type-name cls) . >= . 6))
    (check-not-false (member 'value cls))
    (check-not-false (member 'name cls)))
  (check-true (element? (html-code "<h1 class=\"x\">Hi</h1>")))
  (check-true (element? (java-code "class Example { void run() { System.out.println(\"hi\"); } }")))
  (check-true (element? (mathematica-code "f[x_] := Module[{y = x^2}, y + 1]")))
  (let ([cls (classes 'mathematica "BeginPackage[\"Demo`\"]\nf[x_] := Module[{y = x^2}, x /. a_ :> #name &]\nassoc = <|\"a\" -> 1|>;\nexpr[[1]]\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls))
    (check-not-false (member 'punct cls)))
  (let ([cls (classes 'java "@Override\nclass Example {\n  String s = \"hi\";\n  Object x = null;\n}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'name cls)))
  (check-true (element? (js-code "const x = 1;")))
  (check-true (element? (json-code "{ \"x\": 1 }")))
  (check-true (element? (markdown-code "# Hi")))
  (let ([cls (classes 'markdown "# Title\n\n## Subhead\n\nParagraph.\n")])
    (check-not-false (member 'heading-1 cls))
    (check-not-false (member 'heading-2 cls)))
  (check-true (element? (python-code "def f(x): return x")))
  (let ([cls (classes 'python "def f(x):\n    path = rf\"{x}\\n\"\n    return path\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'name cls)))
  (check-true (element? (racket-code "(+ 1 2)")))
  (let ([cls (classes 'racket "(define (group-by-length words)\n  (for/fold ([ht (hash)])\n            ([word (in-list words)])\n    (define len (string-length word))\n    (hash-update ht len (lambda (xs) (cons word xs)) '())))\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'builtin-name cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls)))
  (let ([cls (classes 'racket "(define-flow x 1)\n(for/custom ([x xs]) x)\n(hash-update ht 'k values)\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'builtin-name cls)))
  (check-true (element? (rhombus-code "fun add(x, y): x + y")))
  (check-true (element? (ruby-code "class Greeter; def call(name:) puts name; end; end")))
  (let ([cls (classes 'ruby "#!/usr/bin/env ruby\nclass Greeter\n  DEFAULT_GREETING = \"Hello\"\n\n  def initialize(name)\n    @name = name\n  end\n\n  def call(greeting: DEFAULT_GREETING)\n    puts \"#{greeting}, #{@name}\"\n    puts %w[one two].join(/,\\s*/)\n  end\nend\n\nGreeter.new(:Ada).call(greeting: \"Hi\")\n")])
    (check-not-false (member 'comment cls))
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'constant-name cls))
    (check-not-false (member 'method-name cls))
    (check-not-false (member 'variable-name cls))
    (check-not-false (member 'label-name cls))
    (check-not-false (member 'interpolation cls))
    (check-not-false (member 'value cls)))
  (check-true (element? (rust-code "let answer: i32 = 42;")))
  (let ([cls (classes 'rust "use std::collections::HashMap;\n\nstruct User {\n    name: String,\n    score: i32,\n}\n\nfn histogram(words: &[&str]) -> HashMap<String, usize> {\n    let mut counts = HashMap::new();\n    counts\n}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'type-name cls))
    (check-true ((class-count 'type-name cls) . >= . 6))
    (check-not-false (member 'name cls)))
  (check-true (element? (swift-code "let answer = 42")))
  (let ([cls (classes 'swift "struct User {\n  let name: String\n  let score: Int\n}\n\nfunc topNames(_ users: [User]) -> [String] {\n  users.sorted { $0.score > $1.score }.map(\\.name)\n}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'type-name cls))
    (check-true ((class-count 'type-name cls) . >= . 5))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'swift "#if DEBUG\n@MainActor func show() { let s = ##\"raw\"## }\n#endif\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (check-true (element? (sql-code "SELECT name FROM people WHERE id = 1;")))
  (check-true (element? (sqlite-code "SELECT [group] FROM `items` WHERE id = ?1;")))
  (check-true (element? (mysql-code "SELECT @user FROM `users`;")))
  (check-true (element? (postgres-code "SELECT $1, $$hello$$;")))
  (let ([cls (classes 'sql "SELECT name FROM people WHERE active = TRUE AND score >= 10;")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls))
    (check-not-false (member 'punct cls)))
  (let ([cls (classes 'sqlite "SELECT x'ABCD', [group], `name` FROM \"items\" WHERE id = ?1;\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'parameter-name cls)))
  (let ([cls (classes 'mysql "# comment\nSELECT _utf8'hej', `name`, @user, @@global.time_zone FROM users;\n")])
    (check-not-false (member 'comment cls))
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'parameter-name cls)))
  (let ([cls (classes 'postgres "SELECT $1, $$hello$$, E'line\\n', \"user\" FROM accounts WHERE note ILIKE '%ok%';\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'parameter-name cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'postgresql "SELECT $1::int;")])
    (check-not-false (member 'parameter-name cls))
    (check-not-false (member 'punct cls)))
  (check-true (element? (wasm-code "(module (func))")))
  (check-true (element? (shell-code "echo $HOME")))
  (let ([cls (classes 'bash "cat <<EOF | grep hi && echo $'ok\\n' >out\n")])
    (check-not-false (member 'operator cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'name cls)))
  (check-true (element? (scribble-code "@bold{Hi}")))
  (check-true (element? (tsv-code "a\tb")))
  (check-true (element? (yaml-code "x: 1")))
  (let ([cls (classes 'yaml "---\nname: Ada\nactive: true\nitems:\n  - one\nnote: |\n  line\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (check-true (parameter? current-scribble-shell))
  (check-true (parameter? current-shell-docs-source))
  (check-true (parameter? current-scribble-context))
  (check-false (contains-link? (scribble-code "@bold{Hi}")))
  (check-true (element? (scribble-code #:context #'here "@bold{Hi}")))
  (check-true
   (element?
    (parameterize ([current-scribble-context 42])
      (scribble-code "@bold{Hi}"))))
  (check-true
   (block?
    (parameterize ([current-scribble-context 42])
      (scribbleblock "@title{Hi}\nText."))))
  (check-true (element? (js-code #:jsx? #t "const el = <A/>;")))
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
  (let ([cls (classes 'js "const x = 1; function f() { return x; } class C {}")])
    (check-not-false (member 'decl-name cls))
    (check-not-false (member 'operator cls)))
  (check-not-false
   (member 'comment (classes 'js "// hi\nconst x = 1;")))
  (let ([cls (classes 'python (read-fixture "python-basic.py"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls)))
  (let ([cls (classes 'python "def render(rows):\n    if rows:\n        return rows[0]\n    return None\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'python (read-fixture "python-edge.py"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'plain cls)))
  (let ([cls (classes 'bash "if [ -f \"$HOME/.zshrc\" ]; then echo ok # note\nfi\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls)))
  (let ([cls (classes 'zsh "setopt prompt_subst\nautoload -Uz compinit\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'powershell "if ($x) { Get-ChildItem $HOME # note\n}\n")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls)))
  (let ([cls (classes 'wasm (read-fixture "wasm-folded.wat"))])
    (check-not-false (member 'wasm-form cls))
    (check-not-false (member 'wasm-type cls))
    (check-not-false (member 'wasm-instr cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'wasm-id cls)))
  (let ([cls (classes 'wasm (read-fixture "wasm-non-folded.wat"))])
    (check-not-false (member 'wasm-form cls))
    (check-not-false (member 'wasm-instr cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'wasm-id cls)))
  (let ([cls (classes 'wasm (read-fixture "wasm-mixed.wat"))])
    (check-not-false (member 'comment cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'wasm-instr cls)))
  (check-true
   (element? (css-code "a { color: " (unsyntax (bold "red")) "; }")))
  (check-true
   (element? (css-code #:escape UNQ "a { color: " (UNQ (italic "red")) "; }")))
  (check-true
   (block? (htmlblock "<p>" (unsyntax (bold "hi")) "</p>")))
  (check-true
   (block? (scribbleblock "@para{" (unsyntax (bold "Hi")) "}")))
  (check-true
   (element? (python-code "print(" (unsyntax (bold "\"hi\"")) ")")))
  (check-true
   (element? (python-code #:escape UNQ "print(" (UNQ (italic "\"hi\"")) ")")))
  (let ([cls (classes 'scribble (read-fixture "scribble-basic.scrbl"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'plain cls))
    (check-true ((class-count 'keyword cls) . >= . 2)))
  (check-not-false (mdn-url-for-token 'css 'name "color"))
  (check-not-false (mdn-url-for-token 'html 'keyword "div"))
  (check-not-false (mdn-url-for-token 'js 'keyword "const"))
  (check-not-false (mdn-url-for-token 'wasm 'keyword "module"))
  (check-not-false (c/cpp-doc-url-for-token 'c 'keyword "return" #f #f))
  (check-not-false (c/cpp-doc-url-for-token 'cpp 'identifier "vector" "::" "std"))
  (check-not-false (generated-rust-doc-url-for-token 'keyword "fn" #f #f #f))
  (check-not-false (generated-rust-doc-url-for-token 'identifier "Vec" #f #f #f))
  (check-not-false (latex-doc-url-for-token 'keyword "\\section"))
  (check-not-false (latex-doc-url-for-token 'literal "itemize"))
  (check-not-false (latex-doc-url-for-token 'identifier "\\draw"))
  (check-not-false (go-doc-url-for-token 'keyword "func" #f #f #f))
  (check-not-false (go-doc-url-for-token 'name "Println" #f #f #f))
  (check-not-false (java-doc-url-for-token 'keyword "class" #f #f #f))
  (check-not-false (java-doc-url-for-token 'name "String" #f #f #f))
  (check-not-false (java-doc-url-for-token 'keyword "Override" "@" #f #f))
  (check-not-false (pascal-doc-url-for-token 'keyword "function"))
  (check-not-false (pascal-doc-url-for-token 'identifier "WriteLn"))
  (check-not-false (pascal-doc-url-for-token 'identifier "Format"))
  (check-not-false (pascal-doc-url-for-token 'identifier "SysUtils"))
  (check-not-false (ruby-doc-url-for-token 'keyword "class" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'constant-name "Array" #f #f #f))
  (check-not-false (ruby-doc-url-for-token 'method-name "puts" #f #f #f))
  (check-true (contains-link? (c-code "int main(void) { return 0; }")))
  (check-true (contains-link? (cpp-code "std::vector<int> xs;")))
  (check-true (contains-link? (go-code "func main() { fmt.Println(nil) }")))
  (check-true (contains-link? (java-code "@Override class Example { void run() { String s = null; System.out.println(\"hi\"); } }")))
  (check-true (contains-link? (rust-code "fn main() { let xs: Vec<i32> = vec![1, 2, 3]; }")))
  (check-true (contains-link? (ruby-code "class Greeter; def call(name:) puts name; end; end")))
  (check-not-false
   (member "https://docs.ruby-lang.org/en/master/syntax/modules_and_classes_rdoc.html#classes"
           (collect-target-urls (ruby-code "class Greeter; end"))))
  (check-not-false
   (member "https://docs.ruby-lang.org/en/master/String.html#method-i-split"
           (collect-target-urls (ruby-code "\"a,b\".split(\",\")"))))
  (check-not-false
   (member "https://docs.ruby-lang.org/en/master/Array.html#method-i-map"
           (collect-target-urls (ruby-code "[1, 2].map"))))
  (check-not-false
   (member "https://docs.ruby-lang.org/en/master/Hash.html#method-i-fetch"
           (collect-target-urls (ruby-code "{a: 1}.fetch(:a)"))))
  (check-not-false
   (member "https://docs.ruby-lang.org/en/master/syntax/modules_and_classes_rdoc.html#nesting"
           (collect-target-urls (ruby-code "Net::HTTP"))))
  (check-not-false
   (member "https://docs.ruby-lang.org/en/master/syntax/literals_rdoc.html#range-literals"
           (collect-target-urls (ruby-code "1..3"))))
  (check-true (contains-link? (pascal-code "function Add(x, y: Integer): Integer; begin WriteLn(Format('%d', [x])); end;")))
  (check-true (contains-link? (css-code "a{color:red;}")))
  (check-false (contains-link? (css-code #:mdn-links? #f "a{color:red;}")))
  (check-true (contains-link? (html-code "<div class='x'>x</div>")))
  (check-false (contains-link? (js-code #:mdn-links? #f "const x = 1;")))
  (check-true (contains-link? (wasm-code "(module (func (result i32) (i32.const 1)))")))
  (check-false (contains-link? (wasm-code #:docs-source 'none "(module (func (result i32) (i32.const 1)))")))
  (check-true (contains-link? (latex-code "\\section{Intro}\\begin{itemize}\\item x\\end{itemize}")))
  (check-true (contains-link? (latex-code "\\usepackage{tikz}\\draw (0,0)--(1,1);")))
  (check-false (contains-link? (tex-code "\\hbox{Hello}")))
  (check-true (contains-link? (shell-code "if [ -f ./x ]; then echo ok; fi")))
  (check-false (contains-link? (shell-code #:docs-source 'none "if [ -f ./x ]; then echo ok; fi")))
  (for ([cmd (in-list '("cd" "echo" "printf" "read"
                        "export" "unset" "readonly"
                        "alias" "unalias" "set" "shift" "test"
                        "source" "." "eval" "exec" "exit" "return"))])
    (define u (shell-doc-url-for-token 'bash 'name cmd))
    (check-not-false u)
    (check-true (string-contains? u "html_node/"))
    (check-true (string-contains? u "#index-")))
  (check-equal?
   (shell-doc-url-for-token 'bash 'name "echo" #:docs-source 'posix)
   "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/echo.html")
  (check-equal?
   (shell-doc-url-for-token 'bash 'keyword "if" #:docs-source 'posix)
   "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_04")
  (check-not-false
   (shell-doc-url-for-token 'bash 'name "set" #:docs-source 'posix))
  (check-false
   (shell-doc-url-for-token 'bash 'keyword "coproc" #:docs-source 'posix))
  (check-true (contains-link? (shell-code #:shell 'zsh "setopt prompt_subst")))
  (check-false (contains-link? (shell-code #:shell 'zsh "prompt_subst compinit")))
  (check-true (contains-link? (shell-code #:shell 'powershell "if ($x) { Get-ChildItem $HOME }")))
  (check-not-false
   (shell-doc-url-for-token 'powershell 'keyword "Get-ChildItem"))
  (check-true
   (string-contains?
    (shell-doc-url-for-token 'powershell 'keyword "Get-ChildItem")
    "get-childitem"))
  (let ([urls (collect-target-urls (shell-code #:shell 'zsh "setopt prompt_subst"))])
    (check-not-false
     (for/or ([u (in-list urls)])
       (and (string-contains? u "Shell-Builtin-Commands.html#:~:text=")
            (string-contains? u "setopt")
            (string-contains? u "%5B")))))
  (check-true
   (parameterize ([current-scribble-shell 'zsh])
     (contains-link? (shell-code "setopt prompt_subst"))))
  (check-true
   (parameterize ([current-scribble-shell 'pwsh])
     (contains-link? (shell-code "Get-ChildItem $HOME"))))
  (check-exn exn:fail?
             (lambda ()
               (parameterize ([current-scribble-shell 'fish])
                 (shell-code "echo hi"))))
  (check-exn exn:fail?
             (lambda ()
               (parameterize ([current-shell-docs-source 'bogus])
                 (shell-code "if true; then echo ok; fi"))))
  (let ([urls (collect-target-urls (wasm-code "(module (func (result i32) (i32.const 1)))"))])
    (check-not-false
     (member "https://webassembly.github.io/spec/core/syntax/modules.html#syntax-func"
             urls)))
  (let ([urls (collect-target-urls (wasm-code "(func (param i32) (result i32))"))])
    (check-not-false
     (member "https://webassembly.github.io/spec/core/text/types.html#text-param"
             urls))
    (check-not-false
     (member "https://webassembly.github.io/spec/core/text/types.html#text-result"
             urls))
    (check-not-false
     (member "https://webassembly.github.io/spec/core/syntax/types.html#syntax-numtype"
             urls)))
  (let ([urls (collect-target-urls (wasm-code "local.get $x"))])
    (check-not-false
     (member "https://webassembly.github.io/spec/core/syntax/instructions.html#syntax-instr-variable"
             urls)))
  (let ([urls (collect-target-urls (wasm-code "i32.add"))])
    (check-not-false
     (member "https://webassembly.github.io/spec/core/syntax/instructions.html#syntax-binop"
             urls)))
  (let ([urls (collect-target-urls (wasm-code "v128.and"))])
    (check-not-false
     (member "https://webassembly.github.io/spec/core/syntax/instructions.html#syntax-vbinop"
             urls)))
  (let ([urls (collect-target-urls (wasm-code #:docs-source 'mdn "(module (func (result i32) (i32.const 1)))"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Understanding_the_text_format"
             urls)))
  (let ([urls (collect-target-urls (js-code "Math.max(1, 2);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/max"
             urls)))
  (let ([urls (collect-target-urls (js-code "const p = JSON.parse; p(\"{}\");"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse"
             urls)))
  (let ([urls (collect-target-urls (js-code "const {parse} = JSON; parse(\"{}\");"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse"
             urls)))
  (let ([urls (collect-target-urls (js-code "\"x\".startsWith(\"x\"); [1,2].map((n)=>n);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/startsWith"
             urls))
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "const ctx = canvas.getContext(\"2d\"); ctx.fillRect(0, 0, 10, 10);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillRect"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "const gl = canvas.getContext(\"webgl\"); gl.clear();"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext/clear"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "document.querySelector(\"#app\").appendChild(node);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector"
             urls))
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "const el = document.getElementById(\"app\"); el.setAttribute(\"role\", \"main\");"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "window.addEventListener(\"resize\", onResize);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "console.log(msg); console.error(err);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/console/log_static"
             urls))
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/console/error_static"
             urls)))
  (check-not-false
   (member 'name (classes 'css (read-fixture "css-basic.css"))))
  (let ([sw (insert-css-color-swatch-tokens (tokenize 'css ".x { color: #c33; }") #t)])
    (check-not-false (member 'swatch (map car sw))))
  (let ([sw (insert-css-color-swatch-tokens (tokenize 'css ".x { color: #c33; }") #f)])
    (check-false (member 'swatch (map car sw))))
  (let* ([sw (insert-css-color-swatch-tokens
              (tokenize 'css
                        ".x { color: oklch(62% 0.21 25); background: conic-gradient(red, blue); outline-color: color-mix(in srgb, #c33 60%, white); }")
              #t)]
         [classes (map car sw)])
    (check-not-false (member 'swatch classes))
    (check-not-false (member 'swatch-gradient classes)))
  (let* ([dp (insert-css-dimension-preview-tokens
              (tokenize 'css
                        ".x { margin: clamp(1rem, 2vw, 2rem); padding: min(1.2rem, 14px); gap: max(0.6rem, 1.5em); }")
              #t)]
         [classes (map car dp)])
    (check-not-false (member 'spacing-preview classes)))
  (let* ([on-attrs (preview-tooltip-attrs "Color preview: #c33")]
         [off-attrs (parameterize ([current-preview-tooltips? #f])
                      (preview-tooltip-attrs "Color preview: #c33"))])
    (check-equal? (assoc 'data-preview-tooltips on-attrs) '(data-preview-tooltips . "on"))
    (check-equal? (assoc 'title on-attrs) '(title . "Color preview: #c33"))
    (check-equal? (assoc 'data-preview-tooltips off-attrs) '(data-preview-tooltips . "off"))
    (check-false (assoc 'title off-attrs)))
  (let ([sw (insert-css-color-swatch-tokens
             (tokenize 'css ".x { background: linear-gradient(red, blue); }")
             #t)])
    (check-not-false (member 'swatch-gradient (map car sw))))
  (let ([fp (insert-css-font-preview-tokens
             (tokenize 'css ".x { font-family: \"Fira Code\"; }")
             #t)])
    (check-not-false (member 'font-preview (map car fp))))
  (let ([fp (insert-css-font-preview-tokens
             (tokenize 'css ".x { font-family: \"Fira Code\"; }")
             #f)])
    (check-false (member 'font-preview (map car fp))))
  (let ([block (pythonblock #:line-numbers 10
                            #:file "sample.py"
                            "def identity(x):\n    return x\n")])
    (check-true (contains-text? block "sample.py"))
    (check-true (contains-text? block "10"))
    (check-true (has-class? block "scribble-copy-wrap")))
  (let ([block (pythonblock #:copy-button? #f "def identity(x):\n    return x\n")])
    (check-false (has-class? block "scribble-copy-wrap")))
  (for ([sh (in-list '(bash zsh powershell))]
        [src (in-list (list "if [ -f \"$HOME/.zshrc\" ]; then echo ok # note\nfi\n"
                            "setopt prompt_subst\nautoload -Uz compinit\n"
                            "if ($x) { Get-ChildItem $HOME # note\n}\n"))])
    (define comparison
      (compare-token-streams
       src
       (tokenize-shell-handwritten sh src)
       (shell-string->derived-tokens src
                                     #:shell sh)
       #:old-class-normalizer normalize-render-class
       #:new-class-normalizer normalize-render-class
       #:new-token->piece
       (lambda (token)
         (define txt (shell-derived-token-text token))
         (cons
          (cond
            [(shell-derived-token-has-tag? token 'comment) 'comment]
            [(shell-derived-token-has-tag? token 'whitespace) 'plain]
            [(or (shell-derived-token-has-tag? token 'shell-string-literal)
                 (shell-derived-token-has-tag? token 'shell-ansi-string-literal)
                 (shell-derived-token-has-tag? token 'shell-variable)
                 (shell-derived-token-has-tag? token 'shell-command-substitution)
                 (shell-derived-token-has-tag? token 'literal))
             'value]
            [(or (shell-derived-token-has-tag? token 'shell-pipeline-operator)
                 (shell-derived-token-has-tag? token 'shell-logical-operator)
                 (shell-derived-token-has-tag? token 'shell-redirection-operator)
                 (shell-derived-token-has-tag? token 'shell-heredoc-operator))
             'operator]
            [(shell-derived-token-has-tag? token 'delimiter) 'punct]
            [(or (shell-derived-token-has-tag? token 'shell-builtin)
                 (shell-derived-token-has-tag? token 'shell-keyword)
                 (shell-derived-token-has-tag? token 'keyword))
             'keyword]
            [(or (shell-derived-token-has-tag? token 'shell-word)
                 (shell-derived-token-has-tag? token 'identifier))
             (shell-word-class sh txt)]
            [else 'plain])
          txt))
       #:new-contiguous? shell-derived-stream-contiguous?
       #:new-eof? (lambda (_token) #f)))
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?))
    (check-true (hash-ref comparison 'class-match?)))
  (let* ([src "\\section{Hi}\n\\begin{itemize}\n\\item One\n\\verb|x+y|\n\\end{itemize}\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (latex-string->tokens src #:profile 'coloring #:source-positions #t))
           (latex-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece
           (lambda (token)
             (define txt (latex-derived-token-text token))
             (cons
              (cond
                [(latex-derived-token-has-tag? token 'comment) 'comment]
                [(latex-derived-token-has-tag? token 'whitespace) 'plain]
                [(latex-derived-token-has-tag? token 'latex-verbatim-literal) 'value]
                [(or (latex-derived-token-has-tag? token 'tex-inline-math-shift)
                     (latex-derived-token-has-tag? token 'tex-display-math-shift)
                     (latex-derived-token-has-tag? token 'latex-line-break-command)
                     (latex-derived-token-has-tag? token 'tex-parameter-marker)
                     (latex-derived-token-has-tag? token 'tex-parameter-reference)
                     (latex-derived-token-has-tag? token 'tex-parameter-escape))
                 'operator]
                [(or (latex-derived-token-has-tag? token 'tex-open-group-delimiter)
                     (latex-derived-token-has-tag? token 'tex-close-group-delimiter)
                     (latex-derived-token-has-tag? token 'tex-open-optional-delimiter)
                     (latex-derived-token-has-tag? token 'tex-close-optional-delimiter)
                     (latex-derived-token-has-tag? token 'delimiter))
                 'punct]
                [(or (latex-derived-token-has-tag? token 'latex-environment-name)
                     (latex-derived-token-has-tag? token 'tex-text))
                 (if (regexp-match? #px"^[A-Za-z][A-Za-z0-9*_:-]*$" txt)
                     'name
                     'plain)]
                [(or (latex-derived-token-has-tag? token 'latex-command)
                     (latex-derived-token-has-tag? token 'latex-environment-command)
                     (latex-derived-token-has-tag? token 'tex-control-word)
                     (latex-derived-token-has-tag? token 'tex-control-symbol)
                     (latex-derived-token-has-tag? token 'tex-accent-command)
                     (latex-derived-token-has-tag? token 'tex-spacing-command)
                     (latex-derived-token-has-tag? token 'tex-control-space)
                     (latex-derived-token-has-tag? token 'tex-italic-correction)
                     (latex-derived-token-has-tag? token 'tex-paragraph-command)
                     (latex-derived-token-has-tag? token 'keyword))
                 'keyword]
                [(or (latex-derived-token-has-tag? token 'literal)
                     (latex-derived-token-has-tag? token 'tex-parameter))
                 'value]
                [else 'plain])
              txt))
           #:new-contiguous? latex-derived-stream-contiguous?
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "int main(void) { char c = '\\x41'; return 0; }\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (c-string->tokens src #:profile 'coloring #:source-positions #t))
           (c-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece
           (lambda (token)
             (c-family-derived-token->piece token
                                            c-derived-token-has-tag?
                                            c-derived-token-text))
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        c-derived-token-start
                                        c-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?))
    (check-true (hash-ref comparison 'class-match?)))
  (let* ([src "std::string s = R\"(ok)\";\nauto d = 12_km;\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (cpp-string->tokens src #:profile 'coloring #:source-positions #t))
           (cpp-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece
           (lambda (token)
             (c-family-derived-token->piece token
                                            cpp-derived-token-has-tag?
                                            cpp-derived-token-text))
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        cpp-derived-token-start
                                        cpp-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?))
    (check-true (hash-ref comparison 'class-match?)))
  (let* ([src "@interface Box : NSObject\n@property NSString *name;\n@end\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (objc-string->tokens src #:profile 'coloring #:source-positions #t))
           (objc-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece
           (lambda (token)
             (c-family-derived-token->piece token
                                            objc-derived-token-has-tag?
                                            objc-derived-token-text
                                            #:preprocessor-class 'keyword
                                            #:objc? #t))
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        objc-derived-token-start
                                        objc-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?))
    (check-true (hash-ref comparison 'class-match?)))
  (let* ([src "\\def\\foo#1{$$#1^2$$ \\verb|x+y| \\~n}\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (tex-string->tokens src #:profile 'coloring #:source-positions #t))
           (tex-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece tex-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        tex-derived-token-start
                                        tex-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "<?xml version=\"1.0\"?>\n<plist><dict><key>Name</key><string>Ada &amp; Bob</string></dict></plist>\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (plist-string->tokens src #:profile 'coloring #:source-positions #t))
           (plist-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece plist-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        plist-derived-token-start
                                        plist-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "def f(x):\n    path = rf\"{x}\\n\"\n    return path\n"]
         [comparison
          (compare-token-streams
           src
           (python-string->scribble-tokens src)
           (python-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece python-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        python-derived-token-start
                                        python-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "{$mode objfpc}\nfunction Add(x, y: Integer): Integer;\nbegin\n  Add := x + y;\nend;\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (pascal-string->tokens src #:profile 'coloring #:source-positions #t))
           (pascal-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece pascal-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        pascal-derived-token-start
                                        pascal-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "#if DEBUG\n@MainActor func show() { let s = ##\"raw\"## }\n#endif\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (swift-string->tokens src #:profile 'coloring #:source-positions #t))
           (swift-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece swift-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        swift-derived-token-start
                                        swift-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "---\nname: Ada\nactive: true\nitems:\n  - one\nnote: |\n  line\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (yaml-string->tokens src #:profile 'coloring #:source-positions #t))
           (yaml-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece yaml-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        yaml-derived-token-start
                                        yaml-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "package main\n\nfunc main() {\n    var s = `raw`\n    var r = 'x'\n    // note\n}\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (go-string->tokens src #:profile 'coloring #:source-positions #t))
           (go-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece go-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        go-derived-token-start
                                        go-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "# Title\n\n## Subhead\n\n`code`\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
           (markdown-string->tokens src #:profile 'coloring #:source-positions #t))
           (markdown-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer
           normalize-render-class
           #:new-token->piece markdown-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        markdown-derived-token-start
                                        markdown-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "{-# LANGUAGE OverloadedStrings #-}\nmain = putStrLn \"hi\" -- note\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (haskell-string->tokens src #:profile 'coloring #:source-positions #t))
           (haskell-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece haskell-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        haskell-derived-token-start
                                        haskell-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src "@Override\nclass Example {\n  String s = \"hi\";\n  Object x = null;\n}\n"]
         [comparison
          (compare-token-streams
           src
           (projected-tokens->scribble-tokens
            (java-string->tokens src #:profile 'coloring #:source-positions #t))
           (java-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-token->piece java-derived-token->piece
           #:new-contiguous?
           (lambda (tokens)
             (derived-stream-contiguous? tokens
                                        java-derived-token-start
                                        java-derived-token-end))
           #:new-eof? (lambda (_token) #f))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?)))
  (let* ([src (read-fixture "scribble-basic.scrbl")]
         [comparison
          (compare-token-streams
           src
           (tokenize-scribble-handwritten src)
           (scribble-string->derived-tokens src)
           #:old-class-normalizer normalize-render-class
           #:new-class-normalizer normalize-render-class
           #:new-eof? (lambda (_token) #f)
           #:new-contiguous?
           (lambda (tokens)
             (or (null? tokens)
                 (for/and ([left (in-list tokens)]
                           [right (in-list (cdr tokens))])
                   (= (position-offset (scribble-derived-token-end left))
                      (position-offset (scribble-derived-token-start right))))))
           #:new-token->piece
           (lambda (token)
             (let ([text (scribble-derived-token-text token)])
               (cons
                (cond
                  [(scribble-derived-token-has-tag? token 'comment) 'comment]
                  [(scribble-derived-token-has-tag? token 'scribble-string) 'value]
                  [(scribble-derived-token-has-tag? token 'scribble-constant) 'value]
                  [(scribble-derived-token-has-tag? token 'scribble-parenthesis) 'punct]
                  [(scribble-derived-token-has-tag? token 'scribble-symbol)
                   (scribble-token-class 'symbol text)]
                  [(scribble-derived-token-has-tag? token 'whitespace) 'plain]
                  [(scribble-derived-token-has-tag? token 'scribble-text) 'plain]
                  [else 'plain])
                text))))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?))
    (check-true (hash-ref comparison 'class-match?)))
  (let* ([old (tokenize-wasm-handwritten (read-fixture "wasm-folded.wat"))]
         [new (wat-string->tokens (read-fixture "wasm-folded.wat")
                                  #:profile 'coloring
                                  #:source-positions #t)]
         [comparison (compare-token-streams
                      (read-fixture "wasm-folded.wat")
                      old
                      new
                      #:old-class-normalizer normalize-render-class
                      #:new-class-normalizer normalize-render-class
                      #:new-token->piece
                      (lambda (token)
                        (wat-projected-token->scribble-token
                         token
                         #:class-map
                         (lambda (name text)
                           (case name
                             [(comment) 'comment]
                             [(delimiter) 'punct]
                             [(literal) 'value]
                             [(keyword identifier) (wasm-word-class text)]
                             [else 'plain])))))])
    (check-true (hash-ref comparison 'source-match?))
    (check-true (hash-ref comparison 'new-contiguous?))
    (check-true (hash-ref comparison 'class-match?)))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { margin: 16px; gap: 1.5em; }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { border-radius: 12px; }")
             #t)])
    (check-not-false (member 'radius-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { margin: calc(1rem + 8px) 2rem; }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { filter: blur(3px) saturate(130%); }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { letter-spacing: 0.08em; text-indent: 2em; }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([tp (insert-css-design-token-tokens
             (tokenize 'css ":root { --brand: #c33; } .x { color: var(--brand); }")
             #t)])
    (check-not-false (member 'token-def (map car tp)))
    (check-not-false (member 'token-ref (map car tp))))
  (let ([jp (insert-js-preview-tokens
             (tokenize 'js "const re = /ab+c/i; const msg = `hi ${name}`;")
             #t)])
    (check-not-false (member 'js-regex-preview (map car jp)))
    (check-not-false (member 'js-template-preview (map car jp))))
  (check-equal? (normalize-preview-mode 't 'always) 'always)
  (check-equal? (normalize-preview-mode 't 'hover) 'hover)
  (check-equal? (normalize-preview-mode 't 'none) 'none)
  (check-exn exn:fail?
             (lambda () (normalize-preview-mode 't 'auto)))
  (let* ([tok (insert-css-color-swatch-tokens
               (tokenize 'css ".x { color: #c33; }")
               #t)]
         [moved (move-css-decorations-to-decl-end tok)]
         [semi-i (let loop ([xs moved] [i 0])
                   (cond
                     [(null? xs) #f]
                     [(and (eq? (caar xs) 'punct) (string=? (cdar xs) ";")) i]
                     [else (loop (cdr xs) (add1 i))]))]
         [sw-i (index-of (map car moved) 'swatch)])
    (check-not-false semi-i)
    (check-not-false sw-i)
    (check-true (< semi-i sw-i)))
  (let* ([tok (insert-css-color-swatch-tokens
               (tokenize 'css ".x { color: #c33 }")
               #t)]
         [moved (move-css-decorations-to-decl-end tok)]
         [kinds (map car moved)])
    (check-true (< (index-of kinds 'swatch)
                   (let loop ([xs moved] [i 0])
                     (cond
                       [(null? xs) 999]
                       [(and (eq? (caar xs) 'punct) (string=? (cdar xs) "}")) i]
                       [else (loop (cdr xs) (add1 i))])))))
  (for ([src (in-list (list (read-fixture "css-basic.css")
                            (read-fixture "css-nesting.css")
                            ".x { color: #c33; background: linear-gradient(red, blue); font-family: \"Fira Code\"; margin: calc(100% - 2rem); }"))])
    (define old (tokenize-css-handwritten src))
    (define new (tokenize-css src))
    (check-equal? (source-bearing-text old) src)
    (check-equal? (source-bearing-text new) src)
    (check-equal? (class-runs/normalize old compare-css-class-normalize)
                  (class-runs/normalize new compare-css-class-normalize)))
  (for ([src (in-list (list (read-fixture "js-tricky.js")
                            (read-fixture "js-async.js")
                            (read-fixture "js-modern-ops.js")
                            "const re = /ab+c/i; const msg = `hi ${name}`;"))]
        [jsx? (in-list '(#f #f #f #f))])
    (parameterize ([current-jsx? jsx?])
      (define old (tokenize-js-handwritten src))
      (define new (tokenize-js src))
      (check-equal? (source-bearing-text old) src)
      (check-equal? (source-bearing-text new) src)))
  (for ([src (in-list (list (read-fixture "js-jsx.js")
                            (read-fixture "js-real-react.jsx")
                            "const el = <Button kind=\"primary\">Hello {name}</Button>;"))])
    (parameterize ([current-jsx? #t])
      (define old (tokenize-js-handwritten src))
      (define new (tokenize-js src))
      (check-equal? (source-bearing-text old) src)
      (check-equal? (source-bearing-text new) src)))
  (check-not-false
   (member 'keyword (classes 'html (read-fixture "html-basic.html"))))
  (check-not-false
   (member 'keyword (classes 'html (read-fixture "html-script.html"))))
  (check-not-false
   (member 'comment (classes 'html (read-fixture "html-script.html"))))
  (let ([cls (classes 'js (read-fixture "js-tricky.js"))])
    (check-not-false (member 'comment cls))
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls))
    (check-true ((class-count 'punct cls) . >= . 6)))
  (let ([cls (classes 'js (read-fixture "js-async.js"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-true ((class-count 'keyword cls) . >= . 6)))
  (let ([cls (classes 'css (read-fixture "css-nesting.css"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls))
    (check-true ((class-count 'punct cls) . >= . 8)))
  (let ([cls (classes 'html (read-fixture "html-mixed.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls))
    (check-true ((class-count 'keyword cls) . >= . 5)))
  (let ([cls (classes 'html (read-fixture "html-broken.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls)))
  (let ([cls (classes 'js (read-fixture "js-regex-vs-division.js"))])
    (check-not-false (member 'value cls))   ; regex literal
    (check-not-false (member 'operator cls)) ; division/operator
    (check-true ((class-count 'value cls) . >= . 2))
    (check-true ((class-count 'operator cls) . >= . 3)))
  (let ([cls (classes 'js (read-fixture "js-regex-condition.js"))])
    (check-not-false (member 'value cls))    ; /ab+c/
    (check-not-false (member 'operator cls)) ; divisions
    (check-true ((class-count 'value cls) . >= . 1))
    (check-true ((class-count 'operator cls) . >= . 4)))
  (let ([cls (classes 'js "for (;;) /ab+/.test(s); const q = a / b;")])
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (let ([cls (classes 'js (read-fixture "js-numeric-edge.js"))])
    (check-not-false (member 'value cls))
    (check-true ((class-count 'value cls) . >= . 5)))
  (let ([cls (classes 'js (read-fixture "js-recovery-edge.js"))])
    (check-not-false (member 'punct cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'js (read-fixture "js-recovery-string-edge.js"))])
    (check-not-false (member 'value cls))
    (check-not-false (member 'keyword cls))
    (check-true ((class-count 'keyword cls) . >= . 2)))
  (let ([cls (classes 'js "const o = {a: 1, b: 2};")])
    (check-not-false (member 'object-key cls)))
  (let ([cls (classes 'js "function f({a, b: c}, d = 0) { return d + c; }")])
    (check-not-false (member 'param-name cls)))
  (let ([cls (classes 'js "obj.value = obj.run(1);")])
    (check-not-false (member 'prop-name cls))
    (check-not-false (member 'method-name cls)))
  (let ([cls (classes 'js "class C { static { this.#x = 1; } #x = 0; }")])
    (check-not-false (member 'static-keyword cls))
    (check-not-false (member 'private-name cls)))
  (let ([cls (parameterize ([current-jsx? #t])
               (classes 'js "const id = <T>(x) => x;"))])
    (check-not-false (member 'operator cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'js "async function f(){ await x; } function g(){ await x; }")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls)))
  (let ([cls (parameterize ([current-jsx? #t])
               (classes 'js (read-fixture "js-jsx.js")))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'punct cls))
    (check-true ((class-count 'keyword cls) . >= . 5)))
  (let ([cls (parameterize ([current-jsx? #t])
               (classes 'js (read-fixture "js-real-react.jsx")))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'operator cls))
    (check-true ((class-count 'punct cls) . >= . 8)))
  (let ([cls (classes 'js (read-fixture "js-modern-ops.js"))])
    (check-not-false (member 'operator cls))
    (check-not-false (member 'decl-name cls))
    (check-not-false (member 'keyword cls))
    (check-true ((class-count 'operator cls) . >= . 8)))
  (let ([cls (classes 'js (read-fixture "js-real-config.js"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (or (member 'name cls)
                         (member 'prop-name cls)
                         (member 'object-key cls)))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (let ([cls (classes 'js (read-fixture "js-template-interpolation.js"))])
    (check-not-false (member 'value cls))   ; template chunks
    (check-not-false (member 'punct cls))   ; ${ and }
    (check-not-false (member 'name cls))
    (check-not-false (member 'keyword cls)))
  (let ([cls (classes 'js (read-fixture "js-template-nested.js"))])
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'name cls))
    (check-true ((class-count 'punct cls) . >= . 4)))
  (let ([cls (classes 'html (read-fixture "html-inline-style-script-full.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls))
    (check-not-false (member 'swatch cls))
    (check-true ((class-count 'keyword cls) . >= . 6)))
  (let ([cls (classes 'html (read-fixture "html-malformed-recovery-2.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls)))
  (for ([src (in-list (list (read-fixture "html-basic.html")
                            (read-fixture "html-inline-style-script-full.html")
                            (read-fixture "html-malformed-recovery-2.html")))])
    (define old (tokenize-html-handwritten src))
    (define new (tokenize-html src))
    (check-equal? (source-bearing-text old) src)
    (check-equal? (source-bearing-text new) src)
    (check-equal? (class-runs old)
                  (class-runs new)))
  (let ([html (code->html 'js #:mdn-links? #f "const x = 1;")])
    (check-true (string-contains? html "<code"))
    (check-true (string-contains? html "stx-keyword"))
    (check-false (string-contains? html "href=")))
  (let ([html (code->html 'html "<em class=\"x\">&</em>")])
    (check-true (string-contains? html "&lt;"))
    (check-true (string-contains? html "&amp;")))
  (let ([sxml (code->sxml 'html "<p>" (raw-sxml '(strong "hi")) "</p>")])
    (check-true (contains-text? sxml "strong")))
  (let ([html (code-block->html 'css
                                 #:line-numbers 10
                                 ".x { color: #c33; }")])
    (check-true (string-contains? html "scribble-copy-wrap"))
    (check-true (string-contains? html "scribble-copy-source"))
    (check-true (string-contains? html "stx-line-number"))
    (check-true (string-contains? html "css-color-preview-ui"))
    (check-true (string-contains? html "https://developer.mozilla.org/en-US/docs/Web/CSS/color")))
  (let ([html (code-block->html 'csv
                                 #:line-numbers 1
                                 "name,age\nAda,37\nGrace,85\n")])
    (check-equal? (length (regexp-match* #rx"stx-line-number" html)) 3)
    (check-true (string-contains? html "name,age\nAda,37\nGrace,85\n")))
  (let ([html (code-block->html 'txt
                                 #:line-numbers 1
                                 "one\n\n")])
    (check-equal? (length (regexp-match* #rx"stx-line-number" html)) 2))
  (let ([html (code-block->html 'js
                                 #:line-numbers 10
                                 #:highlight-lines '(2 (4 . 5))
                                 "a\nb\nc\nd\ne\n")])
    (check-equal? (length (regexp-match* #rx"stx-line-highlight" html)) 3)
    (check-true (string-contains? html ">11  </span>")))
  (let ([html (sxml->html
               (code-block->sxml 'python
                                 #:highlight-lines '(1 (3 4))
                                 "a\nb\nc\nd\n"))])
    (check-equal? (length (regexp-match* #rx"stx-line-highlight" html)) 3))
  (check-true
   (has-class? (code-block->scribble 'js
                                     #:highlight-lines '(2)
                                     "a\nb\n")
               "stx-line-highlight"))
  (check-true
   (has-class? (cssblock #:highlight-lines '(1) ".x { color: red; }")
               "stx-line-highlight"))
  (check-exn exn:fail?
             (lambda ()
               (code-block->html 'js #:highlight-lines '(0) "x")))
  (check-true (string-contains? (code-html-support) "scribble-copy-btn"))
  (let ([new-inline (code->scribble 'js "const x = 1;")]
        [old-inline (js-code "const x = 1;")])
    (check-true (element? new-inline))
    (check-true (contains-link? new-inline))
    (check-true (contains-link? old-inline))
    (check-true (contains-text? new-inline "const")))
  (let ([new-block (code-block->scribble 'css
                                         #:line-numbers 10
                                         #:file "demo.css"
                                         ".x { color: #c33; }")]
        [old-block (cssblock
                    #:line-numbers 10
                    #:file "demo.css"
                    ".x { color: #c33; }")])
    (check-true (block? new-block))
    (check-true (block? old-block))
    (check-true (contains-text? new-block "https://developer.mozilla.org/en-US/docs/Web/CSS/color"))
    (check-true (has-class? new-block "scribble-copy-wrap"))
    (check-true (contains-text? new-block "css-color-preview-ui"))
    (check-true (contains-text? new-block "demo.css")))
  (check-true
   (element? (code->scribble 'python "print(" (bold "\"hi\"") ")")))
  (check-true
   (block? (cssblock #:file "demo.css" ".x { color: red; }"))))
