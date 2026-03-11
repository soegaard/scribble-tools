#lang scribble/manual

@(require scribble-tools)

@title{Example: CSS, HTML, and JavaScript Code Forms}

This paragraph includes inline CSS with @css-code{h1 { color: #c33; }} and
inline HTML with @html-code{<em class="highlight">Hi</em>} and
inline JS with @js-code{const n = 42;}.

@section{Inline Forms}

Inline CSS: @css-code{h1 { color: #c33; }}

Inline HTML: @html-code{<em class="highlight">Hi</em>}

Inline JS: @js-code{const n = 42;}

@section{CSS Block}

@cssblock{
/* Page title */
h1.title {
  color: #c33;
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

@cssblock0[#:indent 2]{
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
