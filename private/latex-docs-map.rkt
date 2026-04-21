#lang racket/base

(require racket/string)

(provide latex-doc-url-for-token)

(define latexref-base-url "https://latexref.xyz/")

(define latex-command-url
  (hash "documentclass" "Document-classes.html"
        "usepackage" "_005cusepackage.html"
        "title" "_005cmaketitle.html"
        "author" "_005cmaketitle.html"
        "date" "_005cmaketitle.html"
        "maketitle" "_005cmaketitle.html"
        "section" "_005csection.html"
        "subsection" "_005csubsection.html"
        "subsubsection" "_005csubsubsection.html"
        "paragraph" "_005cparagraph.html"
        "subparagraph" "_005csubparagraph.html"
        "part" "_005cpart.html"
        "chapter" "_005cchapter.html"
        "appendix" "_005cappendix.html"
        "begin" "Environments.html"
        "end" "Environments.html"
        "item" "itemize.html"
        "label" "_005clabel.html"
        "ref" "_005cref.html"
        "pageref" "_005cpageref.html"
        "textbf" "Font-styles.html"
        "textit" "Font-styles.html"
        "emph" "_005cemph-_0026-_005ctextit.html"
        "texttt" "Font-styles.html"
        "textsc" "Font-styles.html"
        "textsf" "Font-styles.html"
        "mathrm" "Font-styles.html"
        "mathbf" "Font-styles.html"
        "itemsep" "list.html"))

(define latex-environment-url
  (hash "document" "document.html"
        "itemize" "itemize.html"
        "enumerate" "enumerate.html"
        "description" "description.html"
        "equation" "equation.html"
        "center" "center.html"
        "flushleft" "flushleft.html"
        "flushright" "flushright.html"
        "quote" "quote.html"
        "quotation" "quotation.html"
        "verbatim" "verbatim.html"
        "tabular" "tabular.html"
        "table" "table.html"
        "figure" "figure.html"
        "thebibliography" "thebibliography.html"
        "abstract" "abstract.html"
        "titlepage" "titlepage.html"
        "minipage" "minipage.html"))

(define (normalize-token token)
  (define t (string-trim token))
  (cond
    [(string=? t "") #f]
    [(string-prefix? t "\\") (substring t 1)]
    [else t]))

(define (latex-doc-url-for-token cls token)
  (define t0 (normalize-token token))
  (define t (and t0 (string-downcase t0)))
  (cond
    [(not t) #f]
    [(hash-has-key? latex-command-url t)
     (string-append latexref-base-url (hash-ref latex-command-url t))]
    [(and (memq cls '(literal value plain name keyword punct))
          (hash-has-key? latex-environment-url t))
     (string-append latexref-base-url (hash-ref latex-environment-url t))]
    [else #f]))
