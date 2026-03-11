# Changelog

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
