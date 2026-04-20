#lang racket/base

(require (prefix-in lang: "private/lang-code.rkt")
         (prefix-in mdn: "private/mdn-map.rkt"))

(provide css-code
         c-code
         cpp-code
         csv-code
         html-code
         js-code
         json-code
         markdown-code
         python-code
         racket-code
         rhombus-code
         swift-code
         wasm-code
         shell-code
         scribble-code
         tsv-code
         yaml-code
         cssblock
         cblock
         cppblock
         csvblock
         htmlblock
         jsblock
         jsonblock
         markdownblock
         pythonblock
         racketblock
         rhombusblock
         swiftblock
         wasmblock
         shellblock
         scribbleblock
         tsvblock
         yamlblock
         cssblock0
         cblock0
         cppblock0
         csvblock0
         htmlblock0
         jsblock0
         jsonblock0
         markdownblock0
         pythonblock0
         racketblock0
         rhombusblock0
         swiftblock0
         wasmblock0
         shellblock0
         scribbleblock0
         tsvblock0
         yamlblock0
         current-wasm-docs-source
         current-scribble-shell
         current-shell-docs-source
         current-scribble-context
         mdn-map-path
         mdn-default-map-entries
         mdn-entry?
         mdn-install-map!
         mdn-reset-map!
         mdn-export-default-map!)

(define-syntax-rule (css-code . rest) (lang:css-code . rest))
(define-syntax-rule (c-code . rest) (lang:c-code . rest))
(define-syntax-rule (cpp-code . rest) (lang:cpp-code . rest))
(define-syntax-rule (csv-code . rest) (lang:csv-code . rest))
(define-syntax-rule (html-code . rest) (lang:html-code . rest))
(define-syntax-rule (js-code . rest) (lang:js-code . rest))
(define-syntax-rule (json-code . rest) (lang:json-code . rest))
(define-syntax-rule (markdown-code . rest) (lang:markdown-code . rest))
(define-syntax-rule (python-code . rest) (lang:python-code . rest))
(define-syntax-rule (racket-code . rest) (lang:racket-code . rest))
(define-syntax-rule (rhombus-code . rest) (lang:rhombus-code . rest))
(define-syntax-rule (swift-code . rest) (lang:swift-code . rest))
(define-syntax-rule (wasm-code . rest) (lang:wasm-code . rest))
(define-syntax-rule (shell-code . rest) (lang:shell-code . rest))
(define-syntax-rule (scribble-code . rest) (lang:scribble-code . rest))
(define-syntax-rule (tsv-code . rest) (lang:tsv-code . rest))
(define-syntax-rule (yaml-code . rest) (lang:yaml-code . rest))
(define-syntax-rule (cssblock . rest) (lang:cssblock . rest))
(define-syntax-rule (cblock . rest) (lang:cblock . rest))
(define-syntax-rule (cppblock . rest) (lang:cppblock . rest))
(define-syntax-rule (csvblock . rest) (lang:csvblock . rest))
(define-syntax-rule (htmlblock . rest) (lang:htmlblock . rest))
(define-syntax-rule (jsblock . rest) (lang:jsblock . rest))
(define-syntax-rule (jsonblock . rest) (lang:jsonblock . rest))
(define-syntax-rule (markdownblock . rest) (lang:markdownblock . rest))
(define-syntax-rule (pythonblock . rest) (lang:pythonblock . rest))
(define-syntax-rule (racketblock . rest) (lang:racketblock . rest))
(define-syntax-rule (rhombusblock . rest) (lang:rhombusblock . rest))
(define-syntax-rule (swiftblock . rest) (lang:swiftblock . rest))
(define-syntax-rule (wasmblock . rest) (lang:wasmblock . rest))
(define-syntax-rule (shellblock . rest) (lang:shellblock . rest))
(define-syntax-rule (scribbleblock . rest) (lang:scribbleblock . rest))
(define-syntax-rule (tsvblock . rest) (lang:tsvblock . rest))
(define-syntax-rule (yamlblock . rest) (lang:yamlblock . rest))
(define-syntax-rule (cssblock0 . rest) (lang:cssblock0 . rest))
(define-syntax-rule (cblock0 . rest) (lang:cblock0 . rest))
(define-syntax-rule (cppblock0 . rest) (lang:cppblock0 . rest))
(define-syntax-rule (csvblock0 . rest) (lang:csvblock0 . rest))
(define-syntax-rule (htmlblock0 . rest) (lang:htmlblock0 . rest))
(define-syntax-rule (jsblock0 . rest) (lang:jsblock0 . rest))
(define-syntax-rule (jsonblock0 . rest) (lang:jsonblock0 . rest))
(define-syntax-rule (markdownblock0 . rest) (lang:markdownblock0 . rest))
(define-syntax-rule (pythonblock0 . rest) (lang:pythonblock0 . rest))
(define-syntax-rule (racketblock0 . rest) (lang:racketblock0 . rest))
(define-syntax-rule (rhombusblock0 . rest) (lang:rhombusblock0 . rest))
(define-syntax-rule (swiftblock0 . rest) (lang:swiftblock0 . rest))
(define-syntax-rule (wasmblock0 . rest) (lang:wasmblock0 . rest))
(define-syntax-rule (shellblock0 . rest) (lang:shellblock0 . rest))
(define-syntax-rule (scribbleblock0 . rest) (lang:scribbleblock0 . rest))
(define-syntax-rule (tsvblock0 . rest) (lang:tsvblock0 . rest))
(define-syntax-rule (yamlblock0 . rest) (lang:yamlblock0 . rest))

(define current-wasm-docs-source lang:current-wasm-docs-source)
(define current-scribble-shell lang:current-scribble-shell)
(define current-shell-docs-source lang:current-shell-docs-source)
(define current-scribble-context lang:current-scribble-context)
(define (mdn-map-path) (mdn:mdn-map-path))
(define mdn-default-map-entries mdn:mdn-default-map-entries)
(define (mdn-entry? v) (mdn:mdn-entry? v))
(define (mdn-install-map! entries-or-path) (mdn:mdn-install-map! entries-or-path))
(define (mdn-reset-map!) (mdn:mdn-reset-map!))
(define (mdn-export-default-map! dest) (mdn:mdn-export-default-map! dest))
