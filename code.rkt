#lang racket/base

(require (prefix-in lang: "private/lang-code.rkt")
         (prefix-in mdn: "private/mdn-map.rkt"))

(provide css-code
         html-code
         js-code
         wasm-code
         scribble-code
         cssblock
         htmlblock
         jsblock
         wasmblock
         scribbleblock
         cssblock0
         htmlblock0
         jsblock0
         wasmblock0
         scribbleblock0
         mdn-map-path
         mdn-default-map-entries
         mdn-entry?
         mdn-install-map!
         mdn-reset-map!
         mdn-export-default-map!)

(define-syntax-rule (css-code . rest) (lang:css-code . rest))
(define-syntax-rule (html-code . rest) (lang:html-code . rest))
(define-syntax-rule (js-code . rest) (lang:js-code . rest))
(define-syntax-rule (wasm-code . rest) (lang:wasm-code . rest))
(define-syntax-rule (scribble-code . rest) (lang:scribble-code . rest))
(define-syntax-rule (cssblock . rest) (lang:cssblock . rest))
(define-syntax-rule (htmlblock . rest) (lang:htmlblock . rest))
(define-syntax-rule (jsblock . rest) (lang:jsblock . rest))
(define-syntax-rule (wasmblock . rest) (lang:wasmblock . rest))
(define-syntax-rule (scribbleblock . rest) (lang:scribbleblock . rest))
(define-syntax-rule (cssblock0 . rest) (lang:cssblock0 . rest))
(define-syntax-rule (htmlblock0 . rest) (lang:htmlblock0 . rest))
(define-syntax-rule (jsblock0 . rest) (lang:jsblock0 . rest))
(define-syntax-rule (wasmblock0 . rest) (lang:wasmblock0 . rest))
(define-syntax-rule (scribbleblock0 . rest) (lang:scribbleblock0 . rest))

(define (mdn-map-path) (mdn:mdn-map-path))
(define mdn-default-map-entries mdn:mdn-default-map-entries)
(define (mdn-entry? v) (mdn:mdn-entry? v))
(define (mdn-install-map! entries-or-path) (mdn:mdn-install-map! entries-or-path))
(define (mdn-reset-map!) (mdn:mdn-reset-map!))
(define (mdn-export-default-map! dest) (mdn:mdn-export-default-map! dest))
