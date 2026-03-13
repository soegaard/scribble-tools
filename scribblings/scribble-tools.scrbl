#lang scribble/manual

@(require scribble-tools
          (for-label racket/base
                     scribble/manual
                     scribble-tools))

@title{scribble-tools}
@author+email["Jens Axel Søgaard" "jensaxel@soegaard.net"]
@defmodule[scribble-tools]

This library provides Scribble forms for typesetting CSS, HTML,
JavaScript, shell scripts (Bash/Zsh), WebAssembly (WAT), and Scribble snippets with syntax
coloring.

The inline forms (@racket[css-code], @racket[html-code],
@racket[js-code], @racket[shell-code], @racket[wasm-code], and @racket[scribble-code])
produce content.

The block forms
(@racket[cssblock], @racket[htmlblock], @racket[jsblock],
        @racket[shellblock], @racket[wasmblock], and @racket[scribbleblock]) produce code
blocks with optional line numbers, file labels, and escapes.

@section{Guide}

This section gives a practical introduction to the forms and the most
useful options.

@subsection[#:tag "reference-inline-forms"]{Inline Forms}

Use inline forms when you want code inside running text:

@tabular[
 #:sep @hspace[2]
  (list
  (list @bold{Language} @bold{Scribble Form})
  (list "CSS"         @scribble-code["@css-code{.card { color: #c33; }}"])
  (list "HTML"        @scribble-code["@html-code{<button class=\"primary\">Save</button>}"])
  (list "JavaScript"  @scribble-code["@js-code{const total = items.reduce((a, b) => a + b, 0);}"])
  (list "Shell"       @scribble-code["@shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi}"])
  (list "WebAssembly" @scribble-code["@wasm-code{(module (func (result i32) (i32.const 42)))}"])
  (list "Scribble"    @scribble-code["@scribble-code{\"@bold{Hello} world.\"}"]))]

@tabular[
 #:sep @hspace[2]
 (list
  (list @bold{Language} @bold{Result})
  (list "CSS"           @css-code{.card { color: #c33; }})
  (list "HTML"          @html-code{<button class="primary">Save</button>})
  (list "JavaScript"    @js-code{const total = items.reduce((a, b) => a + b, 0);})
  (list "Shell"         @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi})
  (list "WebAssembly"   @wasm-code{(module (func (result i32) (i32.const 42)))})
  (list "Scribble"      @scribble-code["@bold{Hello} world."]))]

If you want @racket[scribble-code] to link identifiers to their documentation,
you need to provide a context. Either add @racket{#:context #'here} when
calling @racket[scribble-code], or set the context using a parameter:

@scribbleblock[
"@current-scribble-context[#'here]\n"
"@scribble-code[\"@bold{Hello} world.\"]"]
@current-scribble-context[#'here]
@scribble-code["@bold{Hello} world."]


@subsection[#:tag "reference-block-forms"]{Block Forms}

Use block forms for larger snippets:

@tabular[
 #:sep @hspace[3]
 (list
  (list
   @nested{@bold{CSS form}

           @italic{Scribble source}
           @scribbleblock[
             "@cssblock{\n"
             "/* Accent color */\n"
             ".card {\n"
             "  color: #c33;\n"
             "  border-radius: 12px;\n"
             "}\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @cssblock{
           /* Accent color */
           .card {
             color: #c33;
             border-radius: 12px;
           }
           }})
  (list
   @nested{@bold{HTML form}

           @italic{Scribble source}
           @scribbleblock[
             "@htmlblock{\n"
             "<!-- Hero title -->\n"
             "<main>\n"
             "  <h1>Hello</h1>\n"
             "  <p>Welcome</p>\n"
             "</main>\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @htmlblock{
           <!-- Hero title -->
           <main>
             <h1>Hello</h1>
             <p>Welcome</p>
           </main>
           }})
  (list
   @nested{@bold{JavaScript form}

           @italic{Scribble source}
           @scribbleblock[
             "@jsblock{\n"
             "/* loadData :: () => Promise<any> */\n"
             "async function loadData() {\n"
             "  const r = await fetch(\"/api/data\");\n"
             "  return r.json();\n"
             "}\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @jsblock{
           /* loadData :: () => Promise<any> */
           async function loadData() {
             const r = await fetch("/api/data");
             return r.json();
           }
           }})
  (list
   @nested{@bold{WebAssembly form}

           @italic{Scribble source}
           @scribbleblock[
             "@wasmblock{\n"
             ";; A simple module\n"
             "(module\n"
             "  (func $fortytwo (result i32)\n"
             "    i32.const 42))\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @wasmblock{
           ;; A simple module
           (module
             (func $fortytwo (result i32)
               i32.const 42))
           }})
  (list
   @nested{@bold{Shell form}

           @italic{Scribble source}
           @scribbleblock[
             "@shellblock[#:shell 'zsh]{\n"
             "# zsh bootstrap\n"
             "setopt prompt_subst\n"
             "autoload -Uz compinit\n"
             "compinit\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @shellblock[#:shell 'zsh]{
           # zsh bootstrap
           setopt prompt_subst
           autoload -Uz compinit
           compinit
           }})
  (list
   @nested{@bold{Scribble form}

           @italic{Scribble source}
           @scribbleblock[
             "@scribbleblock[#:context #'here]{\n"
             "  @@section{Greeting}\n"
             "  @@bold{Hello}, Scribble!\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @scribbleblock[#:context #'here
                          "@section{Greeting}\n"
                          "@bold{Hello}, Scribble!\n"]}))]

@subsection{Block Form Decorations}

Use these options to add decorations to block output:

@tabular[
 #:sep @hspace[3]
 (list
  (list @italic{Scribble source} @italic{Rendered result})
  (list
   @nested{@bold{Line numbers}

           @scribbleblock[
             "@cssblock[#:line-numbers 1]{\n"
             ".card {\n"
             "  color: #c33;\n"
             "}\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @cssblock[#:line-numbers 1]{
           .card {
             color: #c33;
           }
           }})
  (list
   @nested{@bold{File name}

           @scribbleblock[
             "@cssblock[#:file \"styles.css\"]{\n"
             ".card {\n"
             "  color: #c33;\n"
             "}\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @cssblock[#:file "styles.css"]{
           .card {
             color: #c33;
           }
           }})
  (list
   @nested{@bold{Line numbers + file name}

           @scribbleblock[
             "@cssblock[#:line-numbers 1 #:file \"styles.css\"]{\n"
             ".card {\n"
             "  color: #c33;\n"
             "}\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @cssblock[#:line-numbers 1 #:file "styles.css"]{
           .card {
             color: #c33;
           }
           }}))]

@subsection{Preview Visualizations}

@racket[css-code] and @racket[cssblock] can show visual helpers:

@cssblock[
  #:color-swatch? #t
  #:font-preview? #t
  #:dimension-preview? #t
  #:preview-mode 'always]{
.badge {
  color: #0a7;
  background: linear-gradient(90deg, #0a7, #5cf);
  font-family: "Fira Code", monospace;
  margin: 16px;
  border-radius: 4px;
  border-radius: 8px;
}
}

@subsection{Escapes}

All forms support escapes to splice Scribble content:

@italic{Scribble source}
@scribbleblock[
  "@cssblock[#:escape unq\n"
  "          \".notice { color: \"\n"
  "          (unq (bold \"tomato\"))\n"
  "          \"; }\"]\n"]

@italic{Rendered result}
@cssblock[#:escape unq
          ".notice { color: "
          (unq (bold "tomato"))
          "; }"]

@subsection{Documentation Links}

By default, code output includes documentation links for common identifiers:

@itemlist[
 @item{CSS properties (for example @css-code{display}, @css-code{grid}, @css-code{border-radius}).}
 @item{HTML elements (for example @html-code{<section>}, @html-code{<button>}, @html-code{<script>}).}
 @item{Common JavaScript classes, methods, and language keywords (for example @js-code{Array}, @js-code{querySelector}, @js-code{map}, @js-code{const}).}
 @item{Common shell keywords and builtins (for example @shell-code[#:shell 'bash]{if}, @shell-code[#:shell 'bash]{for}, @shell-code[#:shell 'zsh]{setopt}), linked to GNU Bash or Zsh documentation.}
 @item{Common WebAssembly instructions and declarations (for example @wasm-code{module}, @wasm-code{func}, @wasm-code{local.get}, @wasm-code{i32.add}), linked to the WebAssembly Core Spec site by default.}
]

@section{Reference}

This section documents each form and procedure in detail.

@subsection{Inline Forms}

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
@racket[#t]).

@racket[#:mdn-links?] controls whether common CSS tokens are
wrapped as hyperlinks to MDN documentation (default: @racket[#t]).

@racket[#:preview-mode] controls when previews are shown:
@racket['always], @racket['hover], or @racket['none]
(default: @racket['always]).

@racket[#:preview-tooltips?] controls whether preview decorations expose
tooltips (hover/focus) and related runtime tooltip behavior (default:
@racket[#t]).

@racket[#:preview-css-url] optionally points to an external stylesheet
for preview UI classes. When provided, the runtime loads that stylesheet
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

@racket[#:mdn-links?] controls whether common HTML tokens are wrapped
as hyperlinks to MDN documentation, including CSS and JavaScript
tokens that appear inside @tt{<style>} and @tt{<script>} sections
(default: @racket[#t]).

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

@racket[#:mdn-links?] controls whether common JavaScript tokens are
wrapped as hyperlinks to MDN documentation (default: @racket[#t]).

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @js-code{const n = 42;}
}

@defform/subs[(shell-code maybe-options str-expr ...+)
              ([maybe-options code:blank
                              (code:line #:shell shell-expr)
                              (code:line #:docs-source docs-source-expr)
                              (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline shell code.
Newlines and surrounding whitespace are collapsed to single spaces.

@racket[#:shell] selects shell flavor: @racket['bash] or @racket['zsh].
Default: @racket[(current-scribble-shell)].

@racket[#:docs-source] selects where shell documentation links point:
@racket['auto], @racket['bash], @racket['zsh], @racket['posix], or @racket['none].
Default: @racket[(current-shell-docs-source)].
When the effective value is @racket['auto], links follow the effective shell:
@racket['bash] when @racket[#:shell] (or @racket[current-scribble-shell]) is
@racket['bash], and @racket['zsh] when it is @racket['zsh].

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi}
}

@defform/subs[(wasm-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:docs-source docs-source-expr)
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline WebAssembly text (WAT) code.
Newlines and surrounding whitespace are collapsed to single spaces.

@racket[#:docs-source] selects where WebAssembly documentation links point:
@racket['wasm-spec-3.0], @racket['mdn], or @racket['none].
The default comes from @racket[current-wasm-docs-source], which defaults
to @racket['wasm-spec-3.0].

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @wasm-code{(module (func (result i32) (i32.const 42)))}
}

@defform/subs[(scribble-code maybe-options str-expr ...+)
              ([maybe-options code:blank
                             (code:line #:context context-expr)
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Scribble source code.
Newlines and surrounding whitespace are collapsed to single spaces.

@racket[#:context] supplies syntax context for identifier link resolution
(default: @racket[(current-scribble-context)]). Recommended: use @racket[#'here] when you want
identifiers in a snippet to resolve against the current manual's
@racket[for-label] imports.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @scribble-code["@bold{Hi} there."]
}

@subsection{Block Forms}

@defform/subs[(cssblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:copy-button? copy-button?-expr)
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
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:color-swatch?] controls whether detected CSS color literals are followed by a small swatch; gradient literals are shown as a small bar (default: @racket[#t]).}
 @item{@racket[#:font-preview?] controls whether @racket[font-family] declarations are followed by a small @tt{Aa} preview (default: @racket[#t]).}
 @item{@racket[#:dimension-preview?] controls whether spacing and radius declarations (for example @racket[margin], @racket[padding], @racket[gap], @racket[letter-spacing], @racket[text-indent], @racket[filter: blur(...)], and @racket[border-radius]) are followed by small visualizer decorations (default: @racket[#t]).}
 @item{@racket[#:mdn-links?] controls whether common CSS tokens are wrapped as hyperlinks to MDN documentation (default: @racket[#t]).}
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
                       (code:line #:copy-button? copy-button?-expr)
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
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:mdn-links?] controls whether common HTML tokens are wrapped as hyperlinks to MDN documentation, including CSS and JavaScript tokens that appear inside @tt{<style>} and @tt{<script>} sections (default: @racket[#t]).}
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
                       (code:line #:copy-button? copy-button?-expr)
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
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:jsx?] enables JSX-aware tokenization for snippets containing embedded tags (default: @racket[#f]).}
 @item{@racket[#:mdn-links?] controls whether common JavaScript tokens are wrapped as hyperlinks to MDN documentation (default: @racket[#t]).}
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

@defform/subs[(shellblock option ... str-expr ...+)
              ([option (code:line #:shell shell-expr)
                       (code:line #:docs-source docs-source-expr)
                       (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:copy-button? copy-button?-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?])]{
Typesets shell source as a block inset using @racket['code-inset].
Options:

@itemlist[
 @item{@racket[#:shell] selects shell flavor: @racket['bash] or @racket['zsh]. Default: @racket[(current-scribble-shell)].}
 @item{@racket[#:docs-source] selects link targets: @racket['auto], @racket['bash], @racket['zsh], @racket['posix], or @racket['none]. Default: @racket[(current-shell-docs-source)]. With @racket['auto], links follow the effective shell selected by @racket[#:shell] (or @racket[current-scribble-shell]).}
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content (default escape id: @racket[unsyntax]).}
]

Example:

@shellblock[#:shell 'bash #:line-numbers 1]{
# build step
if [ -f ./configure ]; then
  ./configure && make
fi
}
}

@defform[(shellblock0 option ... str-expr ...+)]{
Like @racket[shellblock], but without the inset wrapper.

Example:

@shellblock0[#:shell 'zsh #:indent 2]{
setopt prompt_subst
autoload -Uz compinit
compinit
}
}

@defform/subs[(wasmblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:copy-button? copy-button?-expr)
                       (code:line #:docs-source docs-source-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?])]{
Typesets WebAssembly text (WAT) as a block inset using @racket['code-inset].
Options:

@itemlist[
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:docs-source] selects WebAssembly link targets: @racket['wasm-spec-3.0], @racket['mdn], or @racket['none]. Default: @racket[(current-wasm-docs-source)].}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content (default escape id: @racket[unsyntax]).}
]

Example:

@wasmblock[#:line-numbers 1]{
(module
  (func (result i32)
    i32.const 42))
}
}

@defform[(wasmblock0 option ... str-expr ...+)]{
Like @racket[wasmblock], but without the inset wrapper.

Example:

@wasmblock0[#:indent 2]{
(module
  (func (result i32)
    i32.const 7))
}

@defparam[current-wasm-docs-source src (or/c 'wasm-spec-3.0 'mdn 'none)]{
Controls the default documentation source used by @racket[wasm-code],
@racket[wasmblock], and @racket[wasmblock0] when @racket[#:docs-source]
is not provided.
The default value is @racket['wasm-spec-3.0].
}

@defparam[current-scribble-shell sh (or/c 'bash 'zsh)]{
Controls the default shell flavor used by @racket[shell-code],
@racket[shellblock], and @racket[shellblock0] when @racket[#:shell]
is not provided.
The default value is @racket['bash].
}

@defparam[current-shell-docs-source src (or/c 'auto 'bash 'zsh 'posix 'none)]{
Controls the default shell documentation source used by @racket[shell-code],
@racket[shellblock], and @racket[shellblock0] when @racket[#:docs-source]
is not provided.
The default value is @racket['auto], which means: use Bash docs when the
effective shell is @racket['bash], and Zsh docs when the effective shell is
@racket['zsh]. To force one source regardless of shell selection, use
@racket['bash], @racket['zsh], @racket['posix], or @racket['none].
}

@defparam[current-scribble-context ctx (or/c #f syntax?)]{
Controls the default syntax context used by @racket[scribble-code],
@racket[scribbleblock], and @racket[scribbleblock0] when @racket[#:context]
is not provided.
The default value is @racket[#f].
}
}

@defform/subs[(scribbleblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:lang lang-expr)
                       (code:line #:context context-expr)
                       (code:line #:copy-button? copy-button?-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?]
                           [lang-expr string?]
                           [context-expr (or/c #f syntax?)])]{
Typesets Scribble source as a block inset using @racket['code-inset].

The most important option is @racket[#:context]. If provided identifiers
will be linked to their documentation entries. If you are using the same
context several times, it can be convenient to set the parameter
@racket[current-scribble-context] instead of using @racket[#:context]
repeatedly.
                                                              
Options:

@itemlist[
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:lang] chooses the language line used for parsing/linking when the snippet itself does not start with @tt{#lang}
       (default: @racket["scribble/manual"]).}
 @item{@racket[#:context] supplies syntax context for identifier link resolution (default: @racket[(current-scribble-context)]).
       Recommended: use @racket[#'here] when you want identifiers in a snippet to resolve against the current manual's @racket[for-label] imports.}
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content
       (default escape id: @racket[unsyntax]).}
]

Example:

@scribbleblock[#:line-numbers 1
               #:context #'here
               "@title{Small Example}\n"
               "This is @bold{Scribble} source.\n"]
}

@defform[(scribbleblock0 option ... str-expr ...+)]{
Like @racket[scribbleblock], but without the inset wrapper.

Example:

@scribbleblock0[#:indent 2
                #:context #'here
                "@itemlist[\n"
                " @item{Alpha}\n"
                " @item{Beta}\n"
                "]\n"]
}
}

@subsection{Preview Legend}

Rendered legend example:

@cssblock[
  #:color-swatch? #t
  #:font-preview? #t
  #:dimension-preview? #t
  #:preview-mode 'always]{
.legend {
  color: #c33;
  background: linear-gradient(90deg, red, blue);
  margin: 4px;
  margin: 12px;
  margin: 28px;
  filter: blur(2px);
  filter: blur(8px);
  filter: blur(18px);
  border-radius: 2px;
  border-radius: 6px;
  border-radius: 9px;
  font-family: "Fira Code", monospace;
  font-family: "Georgia", serif;
  font-family: "Helvetica Neue", Arial, sans-serif;
}
}

@itemlist[
 @item{Color square: a detected color literal such as @tt{#c33} or @racket[red].}
 @item{Gradient bar: a detected gradient literal such as @racket[linear-gradient(...)].}
 @item{Spacing bar: detected spacing-sized values (for example @racket[margin], @racket[gap], @racket[letter-spacing], or @racket[filter: blur(...)]) scaled to a compact width.}
 @item{Radius chip: detected @racket[border-radius] values, where the chip corner radius mirrors the declaration.}
 @item{Font @tt{Aa}: preview of @racket[font-family], including fallback resolution tooltip and missing-font warning.}
]

@subsection{MDN Maps}

MDN maps control which CSS/HTML/JavaScript/WebAssembly identifiers
become links to the MDN documentation site.
The procedures below let you inspect the active map, install overrides,
reset to defaults, and export the bundled entries.
Most users will not need these tools, but they are useful when you want
to add links that are not covered by the default maps.

@defproc[(mdn-map-path) path?]{
Returns the user override map path used by @racket[#:mdn-links?]
in CSS/HTML/JavaScript forms.
If the file exists, entries in it override bundled defaults.
}

@defproc[(mdn-default-map-entries) (listof (list/c symbol? symbol? string? string?))]{
Returns bundled compact default entries as
@racket[(list lang class token url-or-path)] records.
In addition to explicit entries, the resolver also supports implicit
coverage for all CSS property names (@tt{Web/CSS/<property>}), all
known HTML element tags (@tt{Web/HTML/Element/<tag>}), and common
WebAssembly instruction families (@tt{WebAssembly/Reference/...}).
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

@section{Extended Examples}

This chapter provides longer rendered examples for each supported language.
Each block uses line numbers and a file label to make lexer behavior and
documentation links easier to inspect.

@subsection{CSS}

@cssblock[#:line-numbers 1
          #:file "extended/styles.css"
          #:dimension-preview? #t]{
:root {
  --brand: #0b62a3;
  --accent: oklch(66% 0.18 28);
}

.layout {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: clamp(0.75rem, 2vw, 1.5rem);
  margin: 16px;
  border-radius: 9px;
  background: linear-gradient(90deg, #f6f8fb, #eef3ff);
}

.button {
  color: white;
  background: color-mix(in srgb, var(--brand) 80%, black);
  border: 1px solid #0a4f83;
  padding: 0.5rem 0.8rem;
  font-family: "Fira Code", "JetBrains Mono", monospace;
}
}

@subsection{HTML}

@htmlblock[#:line-numbers 1
           #:file "extended/index.html"]{
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Extended Example</title>
    <style>
      .hero { color: #c33; margin: 12px; }
      .hero em { font-family: "Georgia", serif; }
    </style>
  </head>
  <body>
    <main id="app">
      <h1 class="hero">Hello <em>world</em></h1>
      <button type="button" data-role="save">Save</button>
    </main>
    <script>
      const root = document.querySelector("#app");
      if (root) root.setAttribute("data-ready", "yes");
    </script>
  </body>
</html>
}

@subsection{JavaScript}

@jsblock[#:line-numbers 1
         #:file "extended/app.js"]{
function quickSort(xs, cmp = (a, b) => a - b) {
  if (xs.length <= 1) return xs.slice();
  const [pivot, ...rest] = xs;
  const left = [];
  const right = [];
  for (const x of rest) {
    if (cmp(x, pivot) < 0) left.push(x); else right.push(x);
  }
  return [...quickSort(left, cmp), pivot, ...quickSort(right, cmp)];
}

function renderNumbers(listEl, numbers) {
  listEl.textContent = "";
  for (const n of numbers) {
    const li = document.createElement("li");
    li.textContent = String(n);
    listEl.append(li);
  }
}

function parseInput(inputEl) {
  return inputEl.value
    .split(/[\\s,]+/)
    .map((s) => s.trim())
    .filter(Boolean)
    .map(Number)
    .filter((n) => Number.isFinite(n));
}

function boot() {
  const inputEl = document.querySelector("#numbers");
  const buttonEl = document.querySelector("#sort");
  const listEl = document.querySelector("#result");
  if (!inputEl || !buttonEl || !listEl) return;

  buttonEl.addEventListener("click", () => {
    const data = parseInput(inputEl);
    const sorted = quickSort(data);
    renderNumbers(listEl, sorted);
  });
}

boot();
}

@subsection{Shell}

This utility copies one directory tree to another and validates arguments
before running the copy operation.

@shellblock[#:line-numbers 1
            #:file "extended/copy-tree.sh"
            #:shell 'bash
            "#!/usr/bin/env bash\n"
            "set -euo pipefail\n"
            "\n"
            "usage() {\n"
            "  echo \"usage: $0 <source-dir> [dest-dir]\"\n"
            "}\n"
            "\n"
            "copy_tree() {\n"
            "  local src=\"$1\"\n"
            "  local dst=\"$2\"\n"
            "  mkdir -p \"$dst\"\n"
            "  cp -R \"$src\"/. \"$dst\"/\n"
            "}\n"
            "\n"
            "main() {\n"
            "  if [ \"$#\" -lt 1 ] || [ \"$#\" -gt 2 ]; then\n"
            "    usage\n"
            "    return 2\n"
            "  fi\n"
            "  local src=\"$1\"\n"
            "  local dst=\"${2:-./out}\"\n"
            "  if [ ! -d \"$src\" ]; then\n"
            "    echo \"error: source directory not found: $src\" >&2\n"
            "    return 1\n"
            "  fi\n"
            "  copy_tree \"$src\" \"$dst\"\n"
            "  echo \"copied $src -> $dst\"\n"
            "}\n"
            "\n"
            "main \"$@\"\n"]

@subsection{WebAssembly}

@wasmblock[#:line-numbers 1
           #:file "extended/module.wat"]{
(module
  (memory (export "mem") 1)
  (func $add (param $x i32) (param $y i32) (result i32)
    (i32.add
      (local.get $x)
      (local.get $y)))
  (func (export "sum_to") (param $n i32) (result i32)
    (local $i i32)
    (local $acc i32)
    (loop $loop
      (if (i32.gt_s (local.get $i) (local.get $n))
        (then (br 1)))
      (local.set $acc
        (i32.add (local.get $acc) (local.get $i)))
      (local.set $i
        (i32.add (local.get $i) (i32.const 1)))
      (br $loop))
    (local.get $acc)))
}

@subsection{Scribble}

@scribbleblock[#:line-numbers 1
               #:file "extended/guide.scrbl"
               #:context #'here
               "@title{Extended Scribble Example}\n"
               "@section{Overview}\n"
               "This paragraph includes @bold{inline formatting},\n"
               "@italic{emphasis}, and @racket[code] references.\n"
               "@itemlist[\n"
               "  @item{First point}\n"
               "  @item{Second point}\n"
               "  @item{Third point}\n"
               "]\n"
               "@subsection{Details}\n"
               "See @secref[\"reference-inline-forms\"] for inline forms.\n"]
