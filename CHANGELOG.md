# Changelog

## Unreleased

- Future languages/formats to add:
  - SVG

- Added `scribble-tools/youtube` with a `youtube` form for embedding
  YouTube videos in Scribble documents.
- Added Python support:
  - `python-code`
  - `pythonblock`, `pythonblock0`
- Added new `lexers`-backed forms for:
  - C: `c-code`, `cblock`, `cblock0`
  - C++: `cpp-code`, `cppblock`, `cppblock0`
  - CSV: `csv-code`, `csvblock`, `csvblock0`
  - Go: `go-code`, `goblock`, `goblock0`
  - Haskell: `haskell-code`, `haskellblock`, `haskellblock0`
  - Java: `java-code`, `javablock`, `javablock0`
  - JSON: `json-code`, `jsonblock`, `jsonblock0`
  - LaTeX: `latex-code`, `latexblock`, `latexblock0`
  - Makefile: `makefile-code`, `makefileblock`, `makefileblock0`
  - Markdown: `markdown-code`, `markdownblock`, `markdownblock0`
  - Mathematica: `mathematica-code`, `mathematicablock`, `mathematicablock0`
  - Objective-C: `objc-code`, `objcblock`, `objcblock0`
  - Pascal: `pascal-code`, `pascalblock`, `pascalblock0`
  - plist: `plist-code`, `plistblock`, `plistblock0`
  - Racket: `racket-code`, `racketblock`, `racketblock0`
  - Rhombus: `rhombus-code`, `rhombusblock`, `rhombusblock0`
  - Ruby: `ruby-code`, `rubyblock`, `rubyblock0`
  - Rust: `rust-code`, `rustblock`, `rustblock0`
  - Swift: `swift-code`, `swiftblock`, `swiftblock0`
  - TeX: `tex-code`, `texblock`, `texblock0`
  - TSV: `tsv-code`, `tsvblock`, `tsvblock0`
  - YAML: `yaml-code`, `yamlblock`, `yamlblock0`
- Added the `lexers` package as the lexer backend dependency.
- Added Java docs links for common language keywords and selected
  standard-library identifiers using the official Oracle Java Language
  Specification and Java SE API docs.
- Added Go docs links for common language keywords, predeclared
  identifiers, and selected standard-library identifiers using the
  official Go spec and package docs.
- Migrated language tokenization to `lexers` incrementally:
  - Python via `lexers/python`
  - WebAssembly via `lexers/wat`
  - Shell via `lexers/shell`
  - Scribble via `lexers/scribble`
  - HTML via `lexers/html`
  - CSS via `lexers/css`
  - JavaScript via `lexers/javascript`
- Added internal old-vs-new lexer comparison coverage to support one-language-at-a-time migration checks.
- Kept JSX mode on the handwritten JavaScript lexer path for compatibility with the existing TSX-style generic-angle heuristic.
- Added LaTeX identifier links via `latexref.xyz` for common LaTeX commands and environments.
- Switched the main renderer to derived-token integration for the practical language set, improving visible structure for shell, Makefile, TeX/LaTeX, C-family languages, plist, Python, Swift, Pascal, YAML, Go, and Haskell.
- Added Ruby rendering through `lexers/ruby`, including derived-token styling
  for constants, method names, variables, keyword argument labels,
  interpolation, regular expressions, symbols, percent literals, and heredocs.
- Added Ruby documentation links for keywords, classes/modules, and API
  methods using a generated map from a 2026 local mirror of
  `https://docs.ruby-lang.org/en/master/`.
- Refined Ruby keyword links so constructs such as `class`, `def`, `if`, and
  `rescue` point to their explanatory syntax pages instead of the keyword index.
- Improved Ruby identifier links with source metadata, safer generic-method
  guards, receiver-aware method links for common literals, selected operator
  syntax links, and alias-aware method lookup.

## 0.2.0 - 2026-03-11

- Added block copy-button support across `cssblock/htmlblock/jsblock/scribbleblock` (and `0` variants):
  - new option `#:copy-button?` (default `#t`)
  - copy icon shown on hover/focus
  - click-to-copy with visual success/error feedback
- Enabled CSS dimension previews by default (`#:dimension-preview? #t`) for inline and block CSS rendering.
- Expanded and refined JavaScript lexer behavior and fixtures (regex/template/modern syntax coverage improvements).
- Expanded bundled MDN link maps and JS/Web API contextual linking coverage.
- Added and refined preview visualizations (color, gradient, spacing, radius, font) and runtime tooltip behavior.
- Extended documentation with a Guide + Reference layout, richer examples, and clearer option coverage.
- Added package metadata updates for release:
  - version `0.2.0`
  - dependency on `syntax-color-lib`
  - updated package description to include CSS/HTML/JavaScript/Scribble.

## 0.1.0 - 2026-03-11

- Added new Scribble forms:
  - `css-code`, `html-code`
  - `cssblock`, `cssblock0`
  - `htmlblock`, `htmlblock0`
- Added JavaScript forms:
  - `js-code`
  - `jsblock`, `jsblock0`
- Added `#:escape` support for inline and block forms.
- Added `#:file` support for block forms (`cssblock`, `cssblock0`, `htmlblock`, `htmlblock0`).
- Improved CSS and HTML tokenizers, including HTML `<style>` (CSS) and `<script>` (JavaScript-like) body highlighting.
- Added fixture-based lexer regression tests.
- Added package docs and example document.
