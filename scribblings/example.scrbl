#lang scribble/manual

@(require scribble-tools
          (for-label racket/base
                     scribble/manual))

@title{Example: CSS, C, C++, CSV, HTML, JavaScript, JSON, LaTeX, Makefile, Markdown, Objective-C, plist, Python, Racket, Rhombus, Shell, Swift, TeX, TSV, WebAssembly, YAML, and Scribble Code Forms}

This paragraph includes inline CSS with @css-code{h1 { color: #c33; }} and
inline HTML with @html-code{<em class="highlight">Hi</em>} and
inline JS with @js-code{const n = 42;} and
inline C with @c-code{int answer = 42;} and
inline C++ with @cpp-code{std::vector<int> xs = {1, 2, 3};} and
inline CSV with @csv-code["name,age"] and
inline JSON with @json-code["{\"name\": \"Ada\"}"] and
inline LaTeX with @latex-code{\section{Intro}} and
inline Makefile with @makefile-code{all: build test} and
inline Markdown with @markdown-code["# Hello"] and
inline Objective-C with @objc-code[@"Hello"] and
inline plist with @plist-code{<plist/>} and
inline Python with @python-code{def answer(): return 42} and
inline Racket with @racket-code{(define (add x y) (+ x y))} and
inline Rhombus with @rhombus-code{fun add(x, y): x + y} and
inline shell with @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi} and
inline Swift with @swift-code{let answer = 42} and
inline TeX with @tex-code{\hbox{Hello}} and
inline TSV with @tsv-code["name\tage"] and
inline WebAssembly with @wasm-code{(module (func (result i32) (i32.const 42)))} and
inline YAML with @yaml-code["name: Ada"] and
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

Inline C: @c-code{int answer = 42;}

Inline C++: @cpp-code{std::vector<int> xs = {1, 2, 3};}

Inline CSV: @csv-code["name,age"]

Inline JSON: @json-code["{\"name\": \"Ada\"}"]

Inline LaTeX: @latex-code{\section{Intro}}

Inline Makefile: @makefile-code{all: build test}

Inline Markdown: @markdown-code["# Hello"]

Inline Objective-C: @objc-code[@"Hello"]

Inline plist: @plist-code{<plist/>}

Inline Python: @python-code{def answer(): return 42}

Inline Racket: @racket-code{(define (add x y) (+ x y))}

Inline Rhombus: @rhombus-code{fun add(x, y): x + y}

Inline shell (Bash): @shell-code[#:shell 'bash]{if [ -f ~/.zshrc ]; then echo ok; fi}

Inline Swift: @swift-code{let answer = 42}

Inline TeX: @tex-code{\hbox{Hello}}

Inline shell (Zsh): @shell-code[#:shell 'zsh]{setopt prompt_subst}

Inline shell (PowerShell): @shell-code[#:shell 'powershell]{if ($HOME) { Get-ChildItem . }}

Inline TSV: @tsv-code["name\tage"]

Inline WebAssembly: @wasm-code{(module (func (result i32) (i32.const 42)))}

Inline YAML: @yaml-code["name: Ada"]

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

@section{Python Block}

@pythonblock{
def normalize_name(name):
    cleaned = name.strip().title()
    return cleaned or "Anonymous"
}

@section{Python Block With Line Numbers}

@pythonblock[#:line-numbers 1 #:line-number-sep 2]{
def classify(total):
    if total > 0:
        return "positive"
    return "zero"
}

@section{Python Block With File Name}

@pythonblock[#:file "snippet.py"]{
def greet(name):
    return f"Hello, {name}"
}

@section{Python Block With Escape}

@pythonblock[
  #:escape unq
  "print("
  (unq (bold "\"escaped\""))
  ")\n"
]

@subsection{Python Block0}

@pythonblock0[#:file "plain.py" #:indent 2]{
def square(x):
    return x * x
}

@section{Additional Language Blocks}

These examples cover the newly added generic language forms. They use file
labels and, where useful, line numbers so it is easier to inspect the
rendered output.

@subsection{C}

This small C example shows a compact function with control flow and a return
value.

@cblock[#:line-numbers 1 #:file "answer.c"]{
int answer(void) {
  return 42;
}
}

@subsection{C++}

This C++ example shows templates, standard-library containers, and a short
algorithmic helper.

@cppblock[#:line-numbers 1 #:file "answer.cpp"]{
#include <vector>

std::vector<int> top_three(std::vector<int> xs) {
  if (xs.size() > 3) {
    xs.resize(3);
  }
  return xs;
}
}

@subsection{CSV}

CSV and TSV are useful for short data samples in manuals and notes.

@csvblock[#:file "people.csv"]{
name,age
Ada,37
Grace,48
}

@subsection{JSON}

This JSON example shows nested objects, arrays, and booleans.

@jsonblock[#:line-numbers 1 #:file "config.json"]{
{
  "name": "Ada",
  "active": true,
  "roles": ["admin", "writer"]
}
}

@subsection{LaTeX}

LaTeX snippets are useful for math-heavy, document-structure, or TikZ drawing examples.

@latexblock[#:line-numbers 1 #:file "doc.tex"]{
\section{Intro}
\usepackage{tikz}

\begin{tikzpicture}
  \draw (0,0) -- (2,1);
  \node[right] at (2,1) {Endpoint};
\end{tikzpicture}
}

@subsection{Makefile}

Makefile snippets are useful for small automation and build examples.

@makefileblock[#:line-numbers 1 #:file "Makefile"]{
all: docs test

docs:
	raco scribble +m --html --dest html scribblings/example.scrbl

test:
	raco test private/lang-code.rkt
}

@subsection{Markdown}

Markdown examples are helpful when documenting generated notes or README-style
content.

@markdownblock[#:file "README.md"]{
# Hello

- one
- two
}

@subsection{Objective-C}

Objective-C is useful for Cocoa- and Foundation-oriented examples.

@objcblock[#:line-numbers 1
           #:file "Greeter.m"
           "#import <Foundation/Foundation.h>\n"
           "\n"
           "@interface Greeter : NSObject\n"
           "- (NSString *)messageFor:(NSString *)name;\n"
           "@end\n"]

@subsection{plist}

plist snippets are useful for Apple configuration files and metadata.

@plistblock[#:line-numbers 1 #:file "Info.plist"]{
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
  <dict>
    <key>CFBundleName</key>
    <string>scribble-tools</string>
  </dict>
</plist>
}

@subsection{Racket}

Racket examples use the same visual style as the other added languages.

@racketblock[#:line-numbers 1 #:file "math.rkt"]{
(define (add x y)
  (+ x y))
}

@subsection{Rhombus}

Rhombus is included too, so manuals can show mixed Racket-family syntax.

@rhombusblock[#:file "math.rhm"]{
fun add(x, y):
  x + y
}

@subsection{Swift}

Swift works well for API- and app-oriented examples with types and concise
control flow.

@swiftblock[#:line-numbers 1 #:file "helpers.swift"]{
struct User {
  let name: String
  let score: Int
}

func topNames(_ users: [User]) -> [String] {
  users.sorted { $0.score > $1.score }.map(\.name)
}
}

@subsection{TeX}

TeX snippets are useful for lower-level typesetting examples.

@texblock[#:line-numbers 1 #:file "doc.tex"]{
\hbox{Hello}
\vskip 1em
\centerline{Sample}
}

@subsection{TSV}

@tsvblock[#:file "people.tsv"]{
name	age
Ada	37
Grace	48
}

@subsection{YAML}

YAML is useful for configuration-shaped examples.

@yamlblock[#:line-numbers 1 #:file "config.yaml"]{
name: Ada
active: true
roles:
  - admin
  - writer
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
