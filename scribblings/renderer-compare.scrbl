#lang scribble/manual

@(require scribble-tools
          racket/list
          (file "../html-demo.rkt"))

@title{Renderer Comparison}

This document renders the same block example for each language twice:
first with the original language-specific Scribble renderer, then with
the new intermediate-representation renderer exposed by
@racket[code-block->scribble].

@(define (old-block lang source)
   (code-block->scribble/legacy lang
                                #:line-numbers 1
                                #:color-swatch? #t
                                #:font-preview? #t
                                source))

@(define (new-block lang source)
   (code-block->scribble lang #:line-numbers 1 source))

@(define (example-label example) (first example))
@(define (example-lang example) (second example))
@(define (example-source example) (fourth example))

@(define (render-comparison example)
   (define label (example-label example))
   (define lang (example-lang example))
   (define source (example-source example))
   (list
    (para (bold label))
    (tabular
     #:sep (hspace 2)
     #:column-properties '(left left)
     (list
      (list (bold "Original renderer") (bold "IR renderer"))
      (list (old-block lang source)
            (new-block lang source))))))

@(apply append (map render-comparison demo-examples))
