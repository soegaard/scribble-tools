#lang racket/base

(require (prefix-in api: "code.rkt"))

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

(define-syntax-rule (css-code . rest) (api:css-code . rest))
(define-syntax-rule (html-code . rest) (api:html-code . rest))
(define-syntax-rule (js-code . rest) (api:js-code . rest))
(define-syntax-rule (wasm-code . rest) (api:wasm-code . rest))
(define-syntax-rule (scribble-code . rest) (api:scribble-code . rest))
(define-syntax-rule (cssblock . rest) (api:cssblock . rest))
(define-syntax-rule (htmlblock . rest) (api:htmlblock . rest))
(define-syntax-rule (jsblock . rest) (api:jsblock . rest))
(define-syntax-rule (wasmblock . rest) (api:wasmblock . rest))
(define-syntax-rule (scribbleblock . rest) (api:scribbleblock . rest))
(define-syntax-rule (cssblock0 . rest) (api:cssblock0 . rest))
(define-syntax-rule (htmlblock0 . rest) (api:htmlblock0 . rest))
(define-syntax-rule (jsblock0 . rest) (api:jsblock0 . rest))
(define-syntax-rule (wasmblock0 . rest) (api:wasmblock0 . rest))
(define-syntax-rule (scribbleblock0 . rest) (api:scribbleblock0 . rest))

(define (mdn-map-path) (api:mdn-map-path))
(define mdn-default-map-entries api:mdn-default-map-entries)
(define (mdn-entry? v) (api:mdn-entry? v))
(define (mdn-install-map! entries-or-path) (api:mdn-install-map! entries-or-path))
(define (mdn-reset-map!) (api:mdn-reset-map!))
(define (mdn-export-default-map! dest) (api:mdn-export-default-map! dest))
