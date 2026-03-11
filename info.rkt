#lang setup/infotab

(define collection "scribble-tools")
(define pkg-desc "Scribble helpers for CSS, HTML, JavaScript, and Scribble code")
(define version "0.2")
(define license 'MIT)
(define deps '("base" "scribble-lib" "syntax-color-lib"))
(define build-deps '("scribble-doc" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribble-tools/scribblings/scribble-tools.scrbl" () (library))))
