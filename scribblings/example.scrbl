#lang scribble/manual

@(require scribble-tools)

@title{Example: CSS, HTML, and JavaScript Code Forms}

This paragraph includes inline CSS with @css-code{h1 { color: #c33; }} and
inline HTML with @html-code{<em class="highlight">Hi</em>} and
inline JS with @js-code{const n = 42;}.

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
