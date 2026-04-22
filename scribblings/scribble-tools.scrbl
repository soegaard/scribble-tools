#lang scribble/manual

@(require scribble-tools
          (for-label racket/base
                     (except-in scribble/manual racketblock racketblock0)
                     scribble-tools))

@title{scribble-tools}
@author+email["Jens Axel Søgaard" "jensaxel@soegaard.net"]
@defmodule[scribble-tools]

This library provides Scribble forms for typesetting CSS, C, C++, CSV, HTML,
Java, JavaScript, JSON, Go, Haskell, LaTeX, Makefile, Markdown, Objective-C, plist, Python, Racket, Rhombus, Rust, shell scripts
(Bash/Zsh/PowerShell), Swift, TeX, TSV, WebAssembly (WAT), YAML, and Scribble
snippets with syntax coloring.

The inline forms (@racket[css-code], @racket[c-code], @racket[cpp-code], @racket[csv-code],
@racket[go-code], @racket[html-code], @racket[java-code], @racket[js-code], @racket[json-code],
@racket[haskell-code], @racket[latex-code], @racket[makefile-code], @racket[markdown-code], @racket[objc-code], @racket[pascal-code], @racket[plist-code], @racket[python-code], @racket[racket-code],
@racket[rhombus-code], @racket[rust-code], @racket[shell-code], @racket[swift-code], @racket[tex-code], @racket[tsv-code],
@racket[wasm-code], @racket[yaml-code], and @racket[scribble-code])
produce content.

The block forms
(@racket[cssblock], @racket[cblock], @racket[cppblock], @racket[csvblock], @racket[htmlblock],
        @racket[goblock], @racket[javablock], @racket[jsblock], @racket[jsonblock], @racket[markdownblock],
        @racket[haskellblock], @racket[latexblock], @racket[makefileblock], @racket[objcblock], @racket[pascalblock], @racket[plistblock], @racket[pythonblock], @racket[racketblock], @racket[rhombusblock],
        @racket[rustblock], @racket[shellblock], @racket[swiftblock], @racket[texblock], @racket[tsvblock], @racket[wasmblock],
        @racket[yamlblock], and @racket[scribbleblock]) produce code
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
  (list "C"           @scribble-code["@c-code{int answer = 42;}"])
  (list "C++"         @scribble-code["@cpp-code{std::vector<int> xs = {1, 2, 3};}"])
  (list "CSV"         @scribble-code["@csv-code[\"name,age\"]"])
  (list "Go"          @scribble-code["@go-code{func add(x int, y int) int { return x + y }}"])
  (list "HTML"        @scribble-code["@html-code{<button class=\"primary\">Save</button>}"])
  (list "Java"        @scribble-code["@java-code{class Example { void run() { System.out.println(\"hi\"); } }}"])
  (list "JavaScript"  @scribble-code["@js-code{const total = items.reduce((a, b) => a + b, 0);}"])
  (list "JSON"        @scribble-code["@json-code[\"{\\\"name\\\": \\\"Ada\\\"}\"]"])
  (list "Haskell"     @scribble-code["@haskell-code{sumSquares xs = sum (map (^ (2 :: Int)) xs)}"])
  (list "LaTeX"       @scribble-code["@latex-code{\\section{Intro}}"])
  (list "Makefile"    @scribble-code["@makefile-code{all: build test}"])
  (list "Markdown"    @scribble-code["@markdown-code[\"# Hello\"]"])
  (list "Objective-C" @scribble-code["@objc-code{@\"Hello\"}"])
  (list "Pascal"      @scribble-code["@pascal-code{function Add(x, y: Integer): Integer; begin Add := x + y; end;}"])
  (list "plist"       @scribble-code["@plist-code{<plist/>}"])
  (list "Python"      @scribble-code["@python-code{def total(xs): return sum(xs)}"])
  (list "Racket"      @scribble-code["@racket-code{(define (add x y) (+ x y))}"])
  (list "Rhombus"     @scribble-code["@rhombus-code{fun add(x, y): x + y}"])
  (list "Shell"       @scribble-code["@shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi}"])
  (list "Rust"        @scribble-code["@rust-code{let xs: Vec<i32> = vec![1, 2, 3];}"])
  (list "Swift"       @scribble-code["@swift-code{let answer = 42}"])
  (list "TeX"         @scribble-code["@tex-code{\\hbox{Hello}}"])
  (list "TSV"         @scribble-code["@tsv-code[\"name\\tage\"]"])
  (list "WebAssembly" @scribble-code["@wasm-code{(module (func (result i32) (i32.const 42)))}"])
  (list "YAML"        @scribble-code["@yaml-code[\"name: Ada\"]"])
  (list "Scribble"    @scribble-code["@scribble-code{\"@bold{Hello} world.\"}"]))]

@tabular[
 #:sep @hspace[2]
 (list
  (list @bold{Language} @bold{Result})
  (list "CSS"           @css-code{.card { color: #c33; }})
  (list "C"             @c-code{int answer = 42;})
  (list "C++"           @cpp-code{std::vector<int> xs = {1, 2, 3};})
  (list "CSV"           @csv-code["name,age"])
  (list "Go"            @go-code{func add(x int, y int) int { return x + y }})
  (list "HTML"          @html-code{<button class="primary">Save</button>})
  (list "Java"          @java-code{class Example { void run() { System.out.println("hi"); } }})
  (list "JavaScript"    @js-code{const total = items.reduce((a, b) => a + b, 0);})
  (list "JSON"          @json-code["{\"name\": \"Ada\"}"])
  (list "Haskell"       @haskell-code{sumSquares xs = sum (map (^ (2 :: Int)) xs)})
  (list "LaTeX"         @latex-code{\section{Intro}})
  (list "Makefile"      @makefile-code{all: build test})
  (list "Markdown"      @markdown-code["# Hello"])
  (list "Objective-C"   @objc-code[@"Hello"])
  (list "Pascal"        @pascal-code{function Add(x, y: Integer): Integer; begin Add := x + y; end;})
  (list "plist"         @plist-code{<plist/>})
  (list "Python"        @python-code{def total(xs): return sum(xs)})
  (list "Racket"        @racket-code{(define (add x y) (+ x y))})
  (list "Rhombus"       @rhombus-code{fun add(x, y): x + y})
  (list "Shell"         @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi})
  (list "Rust"          @rust-code{let xs: Vec<i32> = vec![1, 2, 3];})
  (list "Swift"         @swift-code{let answer = 42})
  (list "TeX"           @tex-code{\hbox{Hello}})
  (list "TSV"           @tsv-code["name\tage"])
  (list "WebAssembly"   @wasm-code{(module (func (result i32) (i32.const 42)))})
  (list "YAML"          @yaml-code["name: Ada"])
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
   @nested{@bold{Python form}

           @italic{Scribble source}
           @scribbleblock[
             "@pythonblock{\n"
             "# normalize one name\n"
             "def normalize_name(name):\n"
             "    cleaned = name.strip().title()\n"
             "    return cleaned or \"Anonymous\"\n"
             "}\n"]}
   @nested{@italic{Rendered result}
           @pythonblock{
           # normalize one name
           def normalize_name(name):
               cleaned = name.strip().title()
               return cleaned or "Anonymous"
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
 @item{Common LaTeX commands and environments (for example @latex-code{\section}, @latex-code{\label}, @latex-code{\begin{itemize}}) are linked to the LaTeX2e reference manual at @hyperlink["https://latexref.xyz/Index.html"]{latexref.xyz}, while TikZ commands used inside LaTeX snippets (for example @latex-code{\draw}) are linked to @hyperlink["https://tikz.dev/"]{tikz.dev}.}
 @item{Common shell keywords and builtins (for example @shell-code[#:shell 'bash]{if}, @shell-code[#:shell 'zsh]{setopt}, @shell-code[#:shell 'powershell]{Get-ChildItem}), linked to GNU Bash, Zsh, or PowerShell documentation.}
 @item{Common WebAssembly instructions and declarations (for example @wasm-code{module}, @wasm-code{func}, @wasm-code{local.get}, @wasm-code{i32.add}), linked to the WebAssembly Core Spec site by default.}
]

@section{Reference}

This section documents each form and procedure in detail.

@subsection{Inline Forms}

@subsubsection[#:tag "reference-inline-web-languages"]{Web Languages}

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

@subsubsection[#:tag "reference-inline-programming-languages"]{Programming Languages}

@defform/subs[(c-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline C code.

Common C keywords and standard library identifiers are linked to
@hyperlink["https://en.cppreference.com/w/c"]{cppreference}. The bundled
identifier map was generated in 2026.

Example: @c-code{int answer = 42;}
}

@defform/subs[(cpp-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline C++ code.

Common C++ keywords and standard library identifiers are linked to
@hyperlink["https://en.cppreference.com/w/cpp"]{cppreference}. The bundled
identifier map was generated in 2026.

Example: @cpp-code{std::vector<int> xs = {1, 2, 3};}
}

@defform/subs[(makefile-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Makefile code.

Example: @makefile-code{all: build test}
}

@defform/subs[(objc-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Objective-C code.

Example: @objc-code[@"Hello"]
}

@defform/subs[(haskell-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Haskell code.

Example: @haskell-code{sumSquares xs = sum (map (^ (2 :: Int)) xs)}
}

@defform/subs[(java-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Java code.

Example: @java-code{class Example { void run() { System.out.println("hi"); } }}
}

@defform/subs[(pascal-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Pascal code.

Pascal snippets link language-reference entries and bundled Free Pascal API
identifiers from the official Free Pascal documentation.

Example: @pascal-code{function Add(x, y: Integer): Integer; begin Add := x + y; end;}
}

@defform/subs[(python-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Python code.
Newlines and surrounding whitespace are collapsed to single spaces.

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @python-code{def answer(): return 42}
}

@defform/subs[(racket-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Racket code.

Example: @racket-code{(define (add x y) (+ x y))}
}

@defform/subs[(rhombus-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Rhombus code.

Example: @rhombus-code{fun add(x, y): x + y}
}

@defform/subs[(shell-code maybe-options str-expr ...+)
              ([maybe-options code:blank
                              (code:line #:shell shell-expr)
                              (code:line #:docs-source docs-source-expr)
                              (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline shell code.
Newlines and surrounding whitespace are collapsed to single spaces.

@racket[#:shell] selects shell flavor: @racket['bash], @racket['zsh], @racket['powershell], or @racket['pwsh].
Default: @racket[(current-scribble-shell)].

@racket[#:docs-source] selects where shell documentation links point:
@racket['auto], @racket['bash], @racket['zsh], @racket['powershell], @racket['posix], or @racket['none].
Default: @racket[(current-shell-docs-source)].
When the effective value is @racket['auto], links follow the effective shell:
@racket['bash] when @racket[#:shell] (or @racket[current-scribble-shell]) is
@racket['bash], @racket['zsh] when it is @racket['zsh], and
@racket['powershell] when it is @racket['powershell] or @racket['pwsh].

An optional @racket[#:escape] identifier configures escapes of the
form @racket[(escape-id expr)] to splice @racket[expr]-produced
elements into the typeset output.

Example: @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi}
}

@defform/subs[(swift-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Swift code.

Example: @swift-code{let answer = 42}
}

@defform/subs[(rust-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Rust code.

Common Rust keywords, standard library types and traits, and common
macros such as @rust-code{vec!} and @rust-code{println!} are linked to the
official Rust documentation site at
@hyperlink["https://doc.rust-lang.org/"]{doc.rust-lang.org}.

Example: @rust-code{let xs: Vec<i32> = vec![1, 2, 3];}
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

@subsubsection[#:tag "reference-inline-document-languages"]{Document Languages}

@defform/subs[(latex-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline LaTeX code.
Common LaTeX commands and environments are linked to the LaTeX2e
reference manual at @hyperlink["https://latexref.xyz/Index.html"]{latexref.xyz},
and TikZ commands used inside LaTeX snippets are linked to
@hyperlink["https://tikz.dev/"]{tikz.dev}.

Example: @latex-code{\section{Intro}}
}

@defform/subs[(markdown-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Markdown.

Example: @markdown-code["# Hello"]
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

@defform/subs[(tex-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline TeX code.

Example: @tex-code{\hbox{Hello}}
}

@subsubsection[#:tag "reference-inline-data-formats"]{Data Formats}

@defform/subs[(csv-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline CSV text.

Example: @csv-code["name,age"]
}

@defform/subs[(go-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline Go code.

Example: @go-code{func add(x int, y int) int { return x + y }}
}

@defform/subs[(json-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline JSON.

Example: @json-code["{\"name\": \"Ada\"}"]
}

@defform/subs[(plist-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline plist XML.

Example: @plist-code{<plist/>}
}

@defform/subs[(tsv-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline TSV text.

Example: @tsv-code["name\tage"]
}

@defform/subs[(yaml-code maybe-escape str-expr ...+)
              ([maybe-escape code:blank
                             (code:line #:escape escape-id)])]{
Typesets the concatenated strings as inline YAML.

Example: @yaml-code["name: Ada"]
}

@subsection{Block Forms}

@subsubsection[#:tag "reference-block-web-languages"]{Web Languages}

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
}

@subsubsection[#:tag "reference-block-programming-languages"]{Programming Languages}

@defform[(cblock option ... str-expr ...+)]{
Typesets C as a block inset.

Example:

@cblock[#:file "demo.c"]{
int main(void) {
  return 0;
}
}
}

@defform[(cblock0 option ... str-expr ...+)]{
Like @racket[cblock], but without the inset wrapper.
}

@defform[(cppblock option ... str-expr ...+)]{
Typesets C++ as a block inset.
}

@defform[(cppblock0 option ... str-expr ...+)]{
Like @racket[cppblock], but without the inset wrapper.
}

@defform[(goblock option ... str-expr ...+)]{
Typesets Go code as a block inset.
}

@defform[(goblock0 option ... str-expr ...+)]{
Like @racket[goblock], but without the inset wrapper.
}

@defform[(javablock option ... str-expr ...+)]{
Typesets Java code as a block inset.
}

@defform[(javablock0 option ... str-expr ...+)]{
Like @racket[javablock], but without the inset wrapper.
}

@defform[(makefileblock option ... str-expr ...+)]{
Typesets Makefile code as a block inset.
}

@defform[(makefileblock0 option ... str-expr ...+)]{
Like @racket[makefileblock], but without the inset wrapper.
}

@defform[(objcblock option ... str-expr ...+)]{
Typesets Objective-C as a block inset.
}

@defform[(objcblock0 option ... str-expr ...+)]{
Like @racket[objcblock], but without the inset wrapper.
}

@defform[(haskellblock option ... str-expr ...+)]{
Typesets Haskell as a block inset.
}

@defform[(haskellblock0 option ... str-expr ...+)]{
Like @racket[haskellblock], but without the inset wrapper.
}

@defform[(pascalblock option ... str-expr ...+)]{
Typesets Pascal as a block inset.
}

@defform[(pascalblock0 option ... str-expr ...+)]{
Like @racket[pascalblock], but without the inset wrapper.
}

@defform/subs[(pythonblock option ... str-expr ...+)
              ([option (code:line #:indent indent-expr)
                       (code:line #:line-numbers line-number-expr)
                       (code:line #:line-number-sep line-number-sep-expr)
                       (code:line #:copy-button? copy-button?-expr)
                       (code:line #:file filename-expr)
                       (code:line #:escape escape-id)])
              #:contracts ([indent-expr exact-nonnegative-integer?]
                           [line-number-expr (or/c #f exact-nonnegative-integer?)]
                           [line-number-sep-expr exact-nonnegative-integer?])]{
Typesets Python as a block inset using @racket['code-inset].
Options:

@itemlist[
 @item{@racket[#:indent] controls left indentation in spaces (default: @racket[0]).}
 @item{@racket[#:line-numbers] enables line numbers when not @racket[#f], using the given start number (default: @racket[#f]).}
 @item{@racket[#:line-number-sep] controls the spacing between the line number and code (default: @racket[1]).}
 @item{@racket[#:copy-button?] controls whether a copy icon appears on hover/focus to copy the block text to the clipboard (default: @racket[#t]).}
 @item{@racket[#:file] wraps the result in @racket[filebox] with @racket[filename-expr] as label (default: @racket[#f], i.e. no file label).}
 @item{@racket[#:escape] changes the escape identifier; subforms of the shape @racket[(escape-id expr)] splice @racket[expr] as content (default escape id: @racket[unsyntax]).}
]

Example:

@pythonblock[#:line-numbers 1]{
def double(n):
    return n * 2
}
}

@defform[(pythonblock0 option ... str-expr ...+)]{
Like @racket[pythonblock], but without the inset wrapper.

Example:

@pythonblock0[#:indent 2]{
def greet(name):
    return f"Hello, {name}"
}
}
}

@defform[(racketblock option ... str-expr ...+)]{
Typesets Racket code as a block inset.
}

@defform[(racketblock0 option ... str-expr ...+)]{
Like @racket[racketblock], but without the inset wrapper.
}

@defform[(rhombusblock option ... str-expr ...+)]{
Typesets Rhombus code as a block inset.
}

@defform[(rhombusblock0 option ... str-expr ...+)]{
Like @racket[rhombusblock], but without the inset wrapper.
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
 @item{@racket[#:shell] selects shell flavor: @racket['bash], @racket['zsh], @racket['powershell], or @racket['pwsh]. Default: @racket[(current-scribble-shell)].}
 @item{@racket[#:docs-source] selects link targets: @racket['auto], @racket['bash], @racket['zsh], @racket['powershell], @racket['posix], or @racket['none]. Default: @racket[(current-shell-docs-source)]. With @racket['auto], links follow the effective shell selected by @racket[#:shell] (or @racket[current-scribble-shell]).}
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

@defform[(swiftblock option ... str-expr ...+)]{
Typesets Swift code as a block inset.
}

@defform[(swiftblock0 option ... str-expr ...+)]{
Like @racket[swiftblock], but without the inset wrapper.
}

@defform[(rustblock option ... str-expr ...+)]{
Typesets Rust code as a block inset.
}

@defform[(rustblock0 option ... str-expr ...+)]{
Like @racket[rustblock], but without the inset wrapper.
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
}

@subsubsection[#:tag "reference-block-document-languages"]{Document Languages}

@defform[(latexblock option ... str-expr ...+)]{
Typesets LaTeX as a block inset.
}

@defform[(latexblock0 option ... str-expr ...+)]{
Like @racket[latexblock], but without the inset wrapper.
}

@defform[(markdownblock option ... str-expr ...+)]{
Typesets Markdown as a block inset.
}

@defform[(markdownblock0 option ... str-expr ...+)]{
Like @racket[markdownblock], but without the inset wrapper.
}

@defform[(texblock option ... str-expr ...+)]{
Typesets TeX as a block inset.
}

@defform[(texblock0 option ... str-expr ...+)]{
Like @racket[texblock], but without the inset wrapper.
}

@subsubsection[#:tag "reference-block-data-formats"]{Data Formats}

@defform[(csvblock option ... str-expr ...+)]{
Typesets CSV as a block inset.
}

@defform[(csvblock0 option ... str-expr ...+)]{
Like @racket[csvblock], but without the inset wrapper.
}

@defform[(jsonblock option ... str-expr ...+)]{
Typesets JSON as a block inset.

Example:

@jsonblock[#:line-numbers 1]{
{
  "name": "Ada",
  "active": true
}
}
}

@defform[(jsonblock0 option ... str-expr ...+)]{
Like @racket[jsonblock], but without the inset wrapper.
}

@defform[(plistblock option ... str-expr ...+)]{
Typesets plist XML as a block inset.
}

@defform[(plistblock0 option ... str-expr ...+)]{
Like @racket[plistblock], but without the inset wrapper.
}

@defform[(tsvblock option ... str-expr ...+)]{
Typesets TSV as a block inset.
}

@defform[(tsvblock0 option ... str-expr ...+)]{
Like @racket[tsvblock], but without the inset wrapper.
}

@defform[(yamlblock option ... str-expr ...+)]{
Typesets YAML as a block inset.
}

@defform[(yamlblock0 option ... str-expr ...+)]{
Like @racket[yamlblock], but without the inset wrapper.

Example:

@yamlblock0[#:indent 2]{
name: Ada
active: true
}
}

@defparam[current-wasm-docs-source src (or/c 'wasm-spec-3.0 'mdn 'none)]{
Controls the default documentation source used by @racket[wasm-code],
@racket[wasmblock], and @racket[wasmblock0] when @racket[#:docs-source]
is not provided.
The default value is @racket['wasm-spec-3.0].
}

@defparam[current-scribble-shell sh (or/c 'bash 'zsh 'powershell 'pwsh)]{
Controls the default shell flavor used by @racket[shell-code],
@racket[shellblock], and @racket[shellblock0] when @racket[#:shell]
is not provided.
The default value is @racket['bash].
}

@defparam[current-shell-docs-source src (or/c 'auto 'bash 'zsh 'powershell 'pwsh 'posix 'none)]{
Controls the default shell documentation source used by @racket[shell-code],
@racket[shellblock], and @racket[shellblock0] when @racket[#:docs-source]
is not provided.
The default value is @racket['auto], which means: use Bash docs when the
effective shell is @racket['bash], Zsh docs when the effective shell is
@racket['zsh], and PowerShell docs when the effective shell is
@racket['powershell] (or @racket['pwsh]). To force one source regardless of
shell selection, use @racket['bash], @racket['zsh], @racket['powershell],
@racket['posix], or @racket['none].
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

@subsection{Python}

@pythonblock[#:line-numbers 1
             #:file "extended/report.py"
             "from dataclasses import dataclass\n"
             "\n"
             "\n"
             "@dataclass\n"
             "class Entry:\n"
             "    title: str\n"
             "    score: int\n"
             "\n"
             "\n"
             "def top_entries(rows, limit=3):\n"
             "    ranked = sorted(rows, key=lambda row: row.score, reverse=True)\n"
             "    return [entry.title for entry in ranked[:limit] if entry.score >= 0]\n"
             "\n"
             "\n"
             "def format_report(rows):\n"
             "    titles = top_entries(rows)\n"
             "    if not titles:\n"
             "        return \"no entries\"\n"
             "    return \", \".join(titles)\n"]

@subsection{C}

@cblock[#:line-numbers 1
        #:file "extended/cache.c"]{
typedef struct {
  const char *key;
  int value;
} entry_t;

static int lookup(const entry_t *entries, int count, const char *key) {
  for (int i = 0; i < count; ++i) {
    if (strcmp(entries[i].key, key) == 0) {
      return entries[i].value;
    }
  }
  return -1;
}
}

@subsection{C++}

@cppblock[#:line-numbers 1
          #:file "extended/cache.cpp"]{
#include <algorithm>
#include <string>
#include <vector>

struct Entry {
  std::string title;
  int score;
};

std::vector<std::string> top_titles(std::vector<Entry> entries) {
  std::sort(entries.begin(), entries.end(),
            [](const Entry &a, const Entry &b) { return a.score > b.score; });
  std::vector<std::string> out;
  for (const auto &entry : entries) out.push_back(entry.title);
  return out;
}
}

@subsection{JSON}

@jsonblock[#:line-numbers 1
           #:file "extended/config.json"]{
{
  "name": "scribble-tools",
  "features": {
    "copyButton": true,
    "lineNumbers": true,
    "links": ["mdn", "shell-docs", "wasm-spec"]
  },
  "targets": ["html", "manual"]
}
}

@subsection{LaTeX}

@latexblock[#:line-numbers 1
            #:file "extended/doc.tex"]{
\section{Overview}

\usepackage{tikz}

\begin{tikzpicture}
  \draw (0,0) -- (2,1);
  \node[right] at (2,1) {Endpoint};
\end{tikzpicture}
}

@subsection{Makefile}

@makefileblock[#:line-numbers 1
               #:file "extended/Makefile"]{
APP = scribble-tools

.PHONY: docs test

docs:
	raco scribble +m --html --dest html scribblings/scribble-tools.scrbl

test:
	raco test private/lang-code.rkt
}

@subsection{Markdown}

@markdownblock[#:line-numbers 1
               #:file "extended/notes.md"]{
# Release Notes

## Highlights

- Added Python support
- Migrated lexers to the `lexers` package
- Expanded rendered examples

```bash
raco test private/lang-code.rkt
```

```racket
(define (build-docs)
  (displayln "scribblings/scribble-tools.scrbl"))
```
}

@subsection{Go}

@goblock[#:line-numbers 1
         #:file "extended/server.go"]{
package main

import "fmt"

func greet(name string) string {
	return fmt.Sprintf("Hello, %s", name)
}
}

@subsection{Java}

@javablock[#:line-numbers 1
           #:file "extended/Example.java"]{
class Example {
    static void run() {
        var name = "Ada";
        System.out.println("Hello, " + name);
    }
}
}

@subsection{Objective-C}

@objcblock[#:line-numbers 1
           #:file "extended/view.m"
           "#import <Foundation/Foundation.h>\n"
           "\n"
           "@interface Greeter : NSObject\n"
           "- (NSString *)messageFor:(NSString *)name;\n"
           "@end\n"
           "\n"
           "@implementation Greeter\n"
           "- (NSString *)messageFor:(NSString *)name {\n"
           "  return [NSString stringWithFormat:@\"Hello, %@\", name];\n"
           "}\n"
           "@end\n"]

@subsection{Haskell}

@haskellblock[#:line-numbers 1
              #:file "extended/Stats.hs"]{
module Stats where

sumSquares :: [Int] -> Int
sumSquares xs = sum (map square xs)
  where
    square n = n * n

describe :: [Int] -> String
describe xs =
  "count=" ++ show (length xs) ++ ", total=" ++ show (sum xs)
}

@subsection{Pascal}

@pascalblock[#:line-numbers 1
             #:file "extended/helpers.pas"]{
function Factorial(n: Integer): Integer;
begin
  if n <= 1 then
    Factorial := 1
  else
    Factorial := n * Factorial(n - 1);
end;
}

@subsection{plist}

@plistblock[#:line-numbers 1
            #:file "extended/Info.plist"]{
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
  <dict>
    <key>CFBundleName</key>
    <string>scribble-tools</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
  </dict>
</plist>
}

@subsection{Racket}

@racketblock[#:line-numbers 1
             #:file "extended/helpers.rkt"]{
(define (group-by-length words)
  (for/fold ([ht (hash)])
            ([word (in-list words)])
    (define len (string-length word))
    (hash-update ht len (lambda (xs) (cons word xs)) '())))

(group-by-length '("css" "html" "scribble"))
}

@subsection{Rhombus}

@rhombusblock[#:line-numbers 1
              #:file "extended/helpers.rhm"]{
fun summarize(name, count):
  if count == 1:
    "$name has 1 item"
  else:
    "$name has $(count) items"
}

@subsection{Swift}

@swiftblock[#:line-numbers 1
            #:file "extended/helpers.swift"]{
struct Entry {
  let title: String
  let score: Int
}

func topTitles(_ entries: [Entry], limit: Int = 3) -> [String] {
  entries
    .sorted { $0.score > $1.score }
    .prefix(limit)
    .map(\.title)
}
}

@subsection{Rust}

@rustblock[#:line-numbers 1
           #:file "extended/helpers.rs"]{
use std::collections::HashMap;

fn histogram(words: &[&str]) -> HashMap<String, usize> {
    let mut counts = HashMap::new();
    for word in words {
        *counts.entry((*word).to_string()).or_insert(0) += 1;
    }
    counts
}
}

@subsection{TeX}

@texblock[#:line-numbers 1
          #:file "extended/doc.tex"]{
\hbox{Hello}
\vskip 1em
\centerline{Sample}
}

@subsection{CSV and TSV}

@csvblock[#:line-numbers 1
          #:file "extended/people.csv"]{
name,role,active
Ada,author,true
Grace,editor,false
Linus,reviewer,true
}

@tsvblock[#:line-numbers 1
          #:file "extended/people.tsv"]{
name	role	active
Ada	author	true
Grace	editor	false
Linus	reviewer	true
}

@subsection{YAML}

@yamlblock[#:line-numbers 1
           #:file "extended/config.yaml"]{
name: scribble-tools
features:
  copy_button: true
  line_numbers: true
  docs_links:
    - mdn
    - shell-docs
    - wasm-spec
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
  (func $sum_to_acc (param $i i32) (param $n i32) (param $acc i32) (result i32)
    (if (result i32) (i32.le_s (local.get $i) (local.get $n))
      (then
        (call $sum_to_acc
          (i32.add (local.get $i) (i32.const 1))
          (local.get $n)
          (i32.add (local.get $acc) (local.get $i))))
      (else
        (local.get $acc))))
  (func (export "sum_to") (param $n i32) (result i32)
    (call $sum_to_acc (i32.const 0) (local.get $n) (i32.const 0))))
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
