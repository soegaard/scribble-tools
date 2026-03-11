# Changelog

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
