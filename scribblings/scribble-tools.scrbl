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

@defform/subs[(css-code maybe-option ... str-expr ...+)
              ([maybe-option code:blank
                             (code:line #:color-swatch? color-swatch?-expr)
                             (code:line #:font-preview? font-preview?-expr)
                             (code:line #:dimension-preview? dimension-preview?-expr)
                             (code:line #:mdn-links? mdn-links?-expr)
                             (code:line #:preview-mode preview-mode-expr)
                             (code:line #:preview-tooltips? preview-tooltips?-expr)
                             (code:line #:preview-css-url preview-css-url-expr)
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline CSS code.
Newlines and surrounding whitespace are collapsed to single spaces.

@racket[#:color-swatch?] controls whether detected CSS color literals
are followed by a small color swatch (default: @racket[#t]).
Gradient literals (for example @racket[linear-gradient(...)]) are shown
as a small bar swatch.

@racket[#:font-preview?] controls whether @racket[font-family]
declarations are followed by a small @tt{Aa} preview in the selected
font (default: @racket[#t]).

@racket[#:dimension-preview?] controls whether spacing and radius
declarations such as @racket[margin], @racket[padding], @racket[gap],
and @racket[border-radius] get tiny inline visualizers (default:
@racket[#f]).

@racket[#:mdn-links?] controls whether common CSS/HTML/JS tokens are
wrapped as hyperlinks to MDN documentation (default: @racket[#t]).

@racket[#:preview-mode] controls when previews are shown:
@racket['always], @racket['hover], or @racket['none]
(default: @racket['always]).

@racket[#:preview-tooltips?] controls whether preview decorations expose
tooltips (hover/focus) and related runtime tooltip behavior (default:
@racket[#t]).

@racket[#:preview-css-url] optionally points to an external stylesheet
for preview UI classes. When provided, runtime loads that stylesheet
instead of injecting inline preview CSS.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @css-code{h1 { color: #c33; }}
}

@defform/subs[(html-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:mdn-links? mdn-links?-expr)
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline HTML code.
Newlines and surrounding whitespace are collapsed to single spaces.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

@racket[#:mdn-links?] controls whether common CSS/HTML/JS tokens are
wrapped as hyperlinks to MDN documentation (default: @racket[#t]).

Example: @html-code{<em class="note">Hi</em>}
}

@defform/subs[(js-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:jsx? jsx?-expr)
                             (code:line #:mdn-links? mdn-links?-expr)
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline JavaScript code.
Newlines and surrounding whitespace are collapsed to single spaces.

@racket[#:jsx?] enables JSX-aware tokenization for snippets that contain
embedded tags (default: @racket[#f]).

@racket[#:mdn-links?] controls whether common CSS/HTML/JS tokens are
wrapped as hyperlinks to MDN documentation (default: @racket[#t]).

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @js-code{const n = 42;}
}

@defform/subs[(cssblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:color-swatch? color-swatch?-expr)
                       (code:line #:font-preview? font-preview?-expr)
                       (code:line #:dimension-preview? dimension-preview?-expr)
                       (code:line #:mdn-links? mdn-links?-expr)
                       (code:line #:preview-mode preview-mode-expr)
                       (code:line #:preview-tooltips? preview-tooltips?-expr)
                       (code:line #:preview-css-url preview-css-url-expr)
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
 @item{@racket[#:color-swatch?] controls whether detected CSS color literals are followed by a small swatch; gradient literals are shown as a small bar (default: @racket[#t]).}
 @item{@racket[#:font-preview?] controls whether @racket[font-family] declarations are followed by a small @tt{Aa} preview (default: @racket[#t]).}
 @item{@racket[#:dimension-preview?] controls whether spacing and radius declarations (for example @racket[margin], @racket[padding], @racket[gap], @racket[letter-spacing], @racket[text-indent], @racket[filter: blur(...)], and @racket[border-radius]) are followed by small visualizer decorations (default: @racket[#f]).}
 @item{@racket[#:mdn-links?] controls whether common CSS/HTML/JS tokens are wrapped as hyperlinks to MDN documentation (default: @racket[#t]).}
 @item{@racket[#:preview-mode] controls when previews are shown: @racket['always], @racket['hover], or @racket['none] (default: @racket['always]).}
 @item{@racket[#:preview-tooltips?] controls whether preview decorations include tooltip text and interactive hover/focus tooltip UI (default: @racket[#t]).}
 @item{@racket[#:preview-css-url] optionally points to an external stylesheet URL/path for preview classes; when set, runtime links that stylesheet instead of injecting inline preview CSS (default: @racket[#f]).}
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

@section{Preview Legend}

@itemlist[
 @item{Color square: a detected color literal such as @tt{#c33} or @racket[red].}
 @item{Gradient bar: a detected gradient literal such as @racket[linear-gradient(...)].}
 @item{Spacing bar: detected spacing-sized values (for example @racket[margin], @racket[gap], @racket[letter-spacing], or @racket[filter: blur(...)]) scaled to a compact width.}
 @item{Radius chip: detected @racket[border-radius] values, where the chip corner radius mirrors the declaration.}
 @item{Font @tt{Aa}: preview of @racket[font-family], including fallback resolution tooltip and missing-font warning.}
 @item{Keyboard accessibility: previews with tooltips are focusable and expose the same tooltip text on focus as on hover.}
]

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
                       (code:line #:mdn-links? mdn-links?-expr)
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
 @item{@racket[#:mdn-links?] controls whether common CSS/HTML/JS tokens are wrapped as hyperlinks to MDN documentation (default: @racket[#t]).}
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
                       (code:line #:jsx? jsx?-expr)
                       (code:line #:mdn-links? mdn-links?-expr)
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
 @item{@racket[#:jsx?] enables JSX-aware tokenization for snippets containing embedded tags (default: @racket[#f]).}
 @item{@racket[#:mdn-links?] controls whether common CSS/HTML/JS tokens are wrapped as hyperlinks to MDN documentation (default: @racket[#t]).}
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

@section{MDN Maps}

@defproc[(mdn-map-path) path?]{
Returns the user override map path used by @racket[#:mdn-links?].
If the file exists, entries in it override bundled defaults.
}

@defproc[(mdn-default-map-entries) (listof (list/c symbol? symbol? string? string?))]{
Returns bundled compact default entries as
@racket[(list lang class token url-or-path)] records.
In addition to explicit entries, the resolver also supports implicit
coverage for all CSS property names (@tt{Web/CSS/<property>}) and all
known HTML element tags (@tt{Web/HTML/Element/<tag>}).
}

@defproc[(mdn-entry? [v any/c]) boolean?]{
Recognizes one map entry record.
}

@defproc[(mdn-install-map! [entries-or-path (or/c path-string?
                                                  (listof (list/c symbol? symbol? string? string?)))])
         path?]{
Installs a user override map. You can pass either a list of entries or
the path to a @tt{.rktd} file containing such a list.
}

@defproc[(mdn-reset-map!) boolean?]{
Deletes the user override map (if present), reverting to bundled defaults.
Returns @racket[#t] when a file was removed.
}

@defproc[(mdn-export-default-map! [dest path-string?]) path-string?]{
Writes bundled defaults to @racket[dest] as a @tt{.rktd} file so it can
be edited and re-installed with @racket[mdn-install-map!].
}

Command-line helper:

@verbatim|{
racket -l scribble-tools/mdn-map-tool -- --path
racket -l scribble-tools/mdn-map-tool -- --export-default mdn-map.rktd
racket -l scribble-tools/mdn-map-tool -- --build-default mdn-map-built.rktd
racket -l scribble-tools/mdn-map-tool -- --install mdn-map.rktd
racket -l scribble-tools/mdn-map-tool -- --update-from mdn-map-custom.rktd
racket -l scribble-tools/mdn-map-tool -- --reset
}|

Map build pipeline (dedupe + optional merge):

@verbatim|{
racket -l scribble-tools/mdn-map-build -- --stats
racket -l scribble-tools/mdn-map-build -- --out mdn-map-built.rktd
racket -l scribble-tools/mdn-map-build -- --merge mdn-map-custom.rktd --out mdn-map-merged.rktd
racket -l scribble-tools/mdn-map-build -- --merge mdn-map-custom.rktd --install
}|
