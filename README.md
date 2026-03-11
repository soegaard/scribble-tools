# scribble-tools
Tools for writing Scribble documents

Current forms:

- `css-code`
- `html-code`
- `js-code`
- `scribble-code`
- `cssblock` / `cssblock0`
- `htmlblock` / `htmlblock0`
- `jsblock` / `jsblock0`
- `scribbleblock` / `scribbleblock0`

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

## MDN Link Maps

The code forms support MDN links via `#:mdn-links?` (default `#t`).
Resolution includes bundled explicit entries plus implicit coverage for:
- all CSS property names as `Web/CSS/<property>`
- all known HTML elements as `Web/HTML/Element/<tag>`

Map utilities:

```sh
racket -l scribble-tools/mdn-map-tool -- --path
racket -l scribble-tools/mdn-map-tool -- --export-default mdn-map.rktd
racket -l scribble-tools/mdn-map-tool -- --build-default mdn-map-built.rktd
racket -l scribble-tools/mdn-map-tool -- --install mdn-map.rktd
racket -l scribble-tools/mdn-map-tool -- --update-from mdn-map-custom.rktd
racket -l scribble-tools/mdn-map-tool -- --reset
```

Builder pipeline:

```sh
racket -l scribble-tools/mdn-map-build -- --stats
racket -l scribble-tools/mdn-map-build -- --out mdn-map-built.rktd
racket -l scribble-tools/mdn-map-build -- --merge mdn-map-custom.rktd --out mdn-map-merged.rktd
racket -l scribble-tools/mdn-map-build -- --merge mdn-map-custom.rktd --install
```

## Docs Check

Use installed-package mode to validate docs/xrefs and build the example page:

```sh
./check-docs-installed.sh
```
