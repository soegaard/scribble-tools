# scribble-tools

`scribble-tools` provides forms for typesetting CSS, HTML, JavaScript, shell (Bash/Zsh), WebAssembly (WAT), and Scribble code in Scribble documents.

Key features:

- Inline and block forms for all supported languages.
- Syntax coloring for CSS/HTML/JavaScript/shell/WebAssembly/Scribble snippets.
- CSS visualizations such as color swatches, gradient bars, spacing and radius previews, and font previews.
- Optional links from common CSS/HTML/JavaScript identifiers to the MDN documentation site.
- Optional links from shell keywords/builtins to Bash/Zsh/POSIX shell documentation.
- Optional copy button for code blocks.
- Plain HTML/SXML rendering for using the same snippets outside Scribble.

Plain HTML example:

```racket
#lang racket/base
(require scribble-tools/html)

(displayln
 (string-append
  "<!doctype html><html><head>"
  (code-html-support)
  "</head><body>"
  (code-block->html 'js
                    #:line-numbers 1
                    "const n = 42;\nconsole.log(n);\n")
  "</body></html>"))
```

Use `code->sxml` and `code-block->sxml` when you want to compose the output
before serializing it.

For full usage and reference, see `scribblings/scribble-tools.scrbl`.
