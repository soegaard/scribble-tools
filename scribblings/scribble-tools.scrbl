#lang scribble/manual

@(require scribble-tools
          (for-label racket/base
                     scribble/manual
                     scribble-tools))

@title{scribble-tools}
@author+email["Jens Axel Søgaard" "jensaxel@soegaard.net"]
@defmodule[scribble-tools]

This library provides Scribble forms for typesetting CSS, HTML, and
JavaScript snippets with syntax coloring. The inline forms
(@racket[css-code], @racket[html-code], and @racket[js-code]) produce
content, while the block forms (@racket[cssblock], @racket[htmlblock],
and @racket[jsblock]) produce code blocks with optional line numbers,
file labels, and escapes.

@defform/subs[(css-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline CSS code.
Newlines and surrounding whitespace are collapsed to single spaces.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @css-code{h1 { color: #c33; }}
}

@defform/subs[(html-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline HTML code.
Newlines and surrounding whitespace are collapsed to single spaces.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @html-code{<em class="note">Hi</em>}
}

@defform/subs[(js-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline JavaScript code.
Newlines and surrounding whitespace are collapsed to single spaces.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @js-code{const n = 42;}
}

@defform/subs[(cssblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?])]{
Typesets CSS as a block inset using @racket['code-inset].
Options:

@itemlist[
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content (default escape id: @racket[unsyntax]).}
]

Example:

@cssblock[#:line-numbers 1]{
.card {
  color: #c33;
}
}
}

@defform[(cssblock0 option ... str-expr ...+)]{
Like @racket[cssblock], but without the inset wrapper.

Example:

@cssblock0[#:indent 2]{
.compact {
  color: #444;
}
}
}

@defform/subs[(htmlblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?])]{
Typesets HTML as a block inset using @racket['code-inset].
Options:

@itemlist[
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content (default escape id: @racket[unsyntax]).}
]

Example:

@htmlblock[#:file "snippet.html"]{
<main>
  <p>Example</p>
</main>
}
}

@defform[(htmlblock0 option ... str-expr ...+)]{
Like @racket[htmlblock], but without the inset wrapper.

Example:

@htmlblock0[#:indent 2]{
<ul>
  <li>One</li>
  <li>Two</li>
</ul>
}
}

@defform/subs[(jsblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?])]{
Typesets JavaScript as a block inset using @racket['code-inset].
Options:

@itemlist[
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content (default escape id: @racket[unsyntax]).}
]

Example:

@jsblock[
  "console.log("
  (unsyntax (bold "\"escaped\""))
  ");"]
}

@defform[(jsblock0 option ... str-expr ...+)]{
Like @racket[jsblock], but without the inset wrapper.

Example:

@jsblock0[#:indent 2]{
let total = 0;
for (const n of [1, 2, 3]) {
  total += n;
}
}
}
