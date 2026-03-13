#lang scribble/manual

@(require scribble-tools
          (for-label racket/base
                     scribble/manual))

@title{Example: CSS, HTML, JavaScript, Shell, WebAssembly, and Scribble Code Forms}

This paragraph includes inline CSS with @css-code{h1 { color: #c33; }} and
inline HTML with @html-code{<em class="highlight">Hi</em>} and
inline JS with @js-code{const n = 42;} and
inline shell with @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi} and
inline WebAssembly with @wasm-code{(module (func (result i32) (i32.const 42)))} and
inline Scribble with @scribble-code["@bold{Hi} there."].

@section{Inline Forms}

Inline CSS: @css-code{h1 { color: #c33; }}

Inline CSS (swatches off): @css-code[#:color-swatch? #f]{h1 { color: #c33; }}

Inline CSS (font preview): @css-code{.code { font-family: "Fira Code"; }}

Inline CSS (dimension preview):
@css-code[#:dimension-preview? #t]{.box { margin: 16px; border-radius: 12px; }}

Inline CSS (hover previews):
@css-code[#:dimension-preview? #t #:preview-mode 'hover]{.hint { letter-spacing: 0.08em; }}

Inline CSS (tooltips off):
@css-code[#:dimension-preview? #t #:preview-tooltips? #f]{.plain { margin: clamp(0.5rem, 2vw, 2rem); }}

Inline CSS (external preview stylesheet):
@css-code[#:dimension-preview? #t #:preview-css-url "../scribblings/css-preview-ui.css"]{.x { text-indent: 2em; }}

Inline HTML: @html-code{<em class="highlight">Hi</em>}

Inline JS: @js-code{const n = 42;}

Inline shell (Bash): @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi}

Inline shell (Zsh): @shell-code[#:shell 'zsh]{setopt prompt_subst}

Inline shell (PowerShell): @shell-code[#:shell 'powershell]{if ($HOME) { Get-ChildItem . }}

Inline WebAssembly: @wasm-code{(module (func (result i32) (i32.const 42)))}

Inline Scribble: @scribble-code["@bold{Hi} there."]

Inline JS (JSX mode): @js-code[#:jsx? #t]{const el = <Badge tone="ok">{label}</Badge>;}

@section{CSS Block}

@cssblock[#:dimension-preview? #t]{
/* Page title */
h1.title {
  color: oklch(62% 0.21 25);
  background: conic-gradient(from 90deg, red, yellow, blue);
  outline-color: color-mix(in srgb, #c33 60%, white);
  border-image: radial-gradient(circle, #ffcc66, #cc3300) 1;
  margin: clamp(1rem, 2vw, 2rem);
  padding: min(1.2rem, 14px);
  gap: max(0.6rem, 1.5em);
  border-radius: 12px;
  filter: blur(3px) saturate(130%);
  letter-spacing: 0.04em;
  font-family: "Fira Code";
  font-size: 2rem;
}
}

@section{CSS Block With Line Numbers}

@cssblock[#:line-numbers 1 #:line-number-sep 2]{
.card {
  border: 1px solid #ddd;
  padding: 1rem;
}
}

@section{CSS Block With File Name}

@cssblock[#:file "styles.css"]{
.card {
  border: 1px solid #ddd;
  padding: 1rem;
}
}

@section{CSS Block With Escape}

@cssblock[
  #:escape unq
  ".notice { border-color: "
  (unq (bold "tomato"))
  "; }"
]

@subsection{CSS Block0}

@cssblock0[#:indent 2 #:color-swatch? #f]{
.compact {
  color: #444;
}
}

@section{HTML Block}

@htmlblock{
<article class="card">
  <h1 class="title">Hello</h1>
  <p>Example paragraph.</p>
</article>
}

@section{HTML Block With Line Numbers}

@htmlblock[#:line-numbers 1 #:line-number-sep 2]{
<ul>
  <li>One</li>
  <li>Two</li>
</ul>
}

@section{HTML Block With File Name}

@htmlblock[#:file "snippet.html"]{
<main>
  <p>With a file label.</p>
</main>
}

@section{HTML Block With Escape}

@htmlblock[
  #:escape unq
  "<p class=\"status\">"
  (unq (italic "running"))
  "</p>"
]

@subsection{HTML Block0}

@htmlblock0[#:indent 2]{
<ul>
  <li>One</li>
  <li>Two</li>
</ul>
}

@section{JavaScript Block}

@jsblock{
const square = (x) => x * x;
console.log(square(5));
}

@section{JavaScript Block (New Lexer Features)}

@jsblock[#:jsx? #t]{
const id = <T>(x) => x;

const config = {
  theme: "solarized",
  retries: 2
};

function render({ title, count }, opts = {}) {
  const label = opts.format?.(title) ?? title;
  return `${label} (${count})`;
}

class Counter {
  #value = 0;
  static {
    console.log("init");
  }
  inc(step = 1) {
    this.#value += step;
    return this.#value;
  }
}

async function load(data) {
  for (;;) /ok+/.test(data);
  const value = await Promise.resolve(data / 2);
  return value;
}
}

@section{JavaScript Block (JSX)}

@jsblock[#:jsx? #t]{
const title = "Hi";
const view = <Card className="x">{title}</Card>;
}

@section{JavaScript Block With Line Numbers}

@jsblock[#:line-numbers 1 #:line-number-sep 2]{
// greet
const name = "Scribble";
if (name) {
  console.log(name);
}
}

@section{JavaScript Block With File Name}

@jsblock[#:file "snippet.js"]{
function hello(name) {
  return `Hello, ${name}`;
}
console.log(hello("Scribble"));
}

@section{JavaScript Block With Escape}

@jsblock[
  #:escape unq
  "console.log("
  (unq (bold "\"escaped\""))
  ");"
]

@subsection{JavaScript Block0}

@jsblock0[#:file "plain.js" #:indent 2]{
let total = 0;
for (const n of [1, 2, 3]) {
  total += n;
}
}

@section{Shell Block}

@shellblock[#:shell 'bash]{
# setup
if [ -f ./configure ]; then
  ./configure && make
fi
}

@section{Shell Block With Line Numbers}

@shellblock[#:shell 'zsh #:line-numbers 1 #:line-number-sep 2]{
# zsh options
setopt prompt_subst
autoload -Uz compinit
compinit
}

@section{Shell Block With File Name}

@shellblock[#:shell 'bash #:file "build.sh"]{
#!/usr/bin/env bash
echo "Building..."
make all
}

@section{Shell Block With Escape}

@shellblock[
  #:shell 'bash
  #:escape unq
  "echo "
  (unq (bold "\"escaped\""))
]

@subsection{Shell Block0}

@shellblock0[#:shell 'zsh #:indent 2]{
typeset -g PROJECT_ROOT=$HOME/src/demo
print -r -- $PROJECT_ROOT
}

@section{Shell Block (PowerShell)}

@shellblock[#:shell 'powershell #:line-numbers 1 #:file "script.ps1"]{
if ($HOME) {
  Get-ChildItem .
}
}

@section{Scribble Block}

@scribbleblock[
  #:lang "at-exp racket"
  #:context #'here
  "(define (triple x) (* x 3))\n"
  "@(+ 1 2)\n"
  "@(triple 4)\n"]

@section{Scribble Block With Line Numbers}

@scribbleblock[#:line-numbers 1
               #:context #'here
               #:line-number-sep 2
               "@section{List}\n"
               "@itemlist[\n"
               "  @item{One}\n"
               "  @item{Two}\n"
               "]\n"]

@section{Scribble Block With File Name}

@scribbleblock[#:file "snippet.scrbl"
               #:context #'here
               "@title{With File Label}\n"
               "@para{A paragraph in Scribble source.}\n"]

@section{Scribble Block With Escape}

@scribbleblock[
  #:escape unq
  "@para{Status: "
  (unq (italic "ok"))
  "}"
]

@subsection{Scribble Block0}

@scribbleblock0[#:indent 2
                #:context #'here
                "@itemlist[\n"
                "  @item{Alpha}\n"
                "  @item{Beta}\n"
                "]\n"]

@section{WebAssembly Block (Folded)}

@wasmblock{
(module
  (func $add (param $x i32) (param $y i32) (result i32)
    local.get $x
    local.get $y
    i32.add))
}

@section{WebAssembly Block (Non-Folded)}

@wasmblock{
(module (func (param i32 i32) (result i32) (i32.add (local.get 0) (local.get 1))))
}

@section{WebAssembly Block With Line Numbers}

@wasmblock[#:line-numbers 1 #:line-number-sep 2]{
(module
  (func (result i32)
    i32.const 7))
}

@section{WebAssembly Block With File Name}

@wasmblock[#:file "snippet.wat"]{
(module
  (memory 1)
  (func (export "answer") (result i32)
    i32.const 42))
}

@section{HTML Document With Inline Style and Script}

@htmlblock{
<!doctype html>
<html>
  <head>
    <style>
      .card {
        color: #c33;
        gap: calc(100% - 2rem);
      }
    </style>
  </head>
  <body>
    <script>
      const ratio = total / 2;
      const re = /ab+c/i;
      const msg = `hello ${name}`;
      console.log(msg, re.test("abbbc"), ratio);
    </script>
    <p>Hello &amp; welcome</p>
  </body>
</html>
}
