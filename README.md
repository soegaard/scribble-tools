# scribble-tools
Tools for writing Scribble documents

Current forms:

- `css-code`
- `html-code`
- `js-code`
- `cssblock` / `cssblock0`
- `htmlblock` / `htmlblock0`
- `jsblock` / `jsblock0`

## Usage

```racket
#lang scribble/manual
@(require scribble-tools)

Inline CSS: @css-code{h1 { color: #c33; }}

@cssblock[#:file "styles.css" #:line-numbers 1]{
h1 { color: #c33; }
}
```

Escapes are supported in all forms:

```racket
@cssblock[#:escape unq
  ".notice { color: "
  (unq (bold "tomato"))
  "; }"]
```
