#lang setup/infotab

(define collection "scribble-tools")
(define pkg-desc "Scribble helpers for CSS, HTML, JavaScript, Python, shell, WebAssembly, and related code")
(define version "0.2")
(define license 'MIT)
(define deps '("base"
               "scribble-lib"
               "syntax-color-lib"
               "lexers"
               "lexers-lib"
               "parser-tools-lib"))
(define build-deps '("scribble-doc" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/scribble-tools.scrbl" () (library))))
