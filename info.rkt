#lang setup/infotab

(define collection 'multi)
(define pkg-desc "Scribble helpers for CSS and HTML code blocks")
(define version "0.1.0")
(define deps '("base" "scribble-lib"))
(define build-deps '("scribble-doc" "racket-doc"))
(define scribblings '(("scribblings/scribble-tools.scrbl" () (library))))
