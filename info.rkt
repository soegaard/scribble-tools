#lang setup/infotab

(define collection 'multi)
(define pkg-desc "Scribble helpers for CSS, HTML, JavaScript, and Scribble code")
(define version "0.2.0")
(define license 'MIT)
(define deps '("base" "scribble-lib" "syntax-color-lib"))
(define build-deps '("scribble-doc" "racket-doc"))
(define scribblings '(("scribblings/scribble-tools.scrbl" () (library))))
