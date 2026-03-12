#lang racket/base

(require racket/file
         racket/list
         racket/path
         racket/set
         racket/string)

(provide mdn-map-path
         mdn-default-map-entries
         mdn-entry?
         mdn-install-map!
         mdn-reset-map!
         mdn-export-default-map!
         mdn-url-for-token)

(define mdn-base-url "https://developer.mozilla.org/en-US/docs/")

;; Compact tuple: (lang class token path-or-url)
(define mdn-default-map-entries/base
  (list
   ;; CSS properties
   (list 'css 'name "color" "Web/CSS/color")
   (list 'css 'name "background" "Web/CSS/background")
   (list 'css 'name "background-color" "Web/CSS/background-color")
   (list 'css 'name "background-image" "Web/CSS/background-image")
   (list 'css 'name "font-family" "Web/CSS/font-family")
   (list 'css 'name "font-size" "Web/CSS/font-size")
   (list 'css 'name "font-weight" "Web/CSS/font-weight")
   (list 'css 'name "line-height" "Web/CSS/line-height")
   (list 'css 'name "margin" "Web/CSS/margin")
   (list 'css 'name "padding" "Web/CSS/padding")
   (list 'css 'name "gap" "Web/CSS/gap")
   (list 'css 'name "border" "Web/CSS/border")
   (list 'css 'name "border-radius" "Web/CSS/border-radius")
   (list 'css 'name "display" "Web/CSS/display")
   (list 'css 'name "position" "Web/CSS/position")
   (list 'css 'name "top" "Web/CSS/top")
   (list 'css 'name "right" "Web/CSS/right")
   (list 'css 'name "bottom" "Web/CSS/bottom")
   (list 'css 'name "left" "Web/CSS/left")
   (list 'css 'name "width" "Web/CSS/width")
   (list 'css 'name "height" "Web/CSS/height")
   (list 'css 'name "max-width" "Web/CSS/max-width")
   (list 'css 'name "min-width" "Web/CSS/min-width")
   (list 'css 'name "max-height" "Web/CSS/max-height")
   (list 'css 'name "min-height" "Web/CSS/min-height")
   (list 'css 'name "overflow" "Web/CSS/overflow")
   (list 'css 'name "overflow-x" "Web/CSS/overflow-x")
   (list 'css 'name "overflow-y" "Web/CSS/overflow-y")
   (list 'css 'name "filter" "Web/CSS/filter")
   (list 'css 'name "transform" "Web/CSS/transform")
   (list 'css 'name "transition" "Web/CSS/transition")
   (list 'css 'name "animation" "Web/CSS/animation")
   (list 'css 'name "grid" "Web/CSS/grid")
   (list 'css 'name "grid-template-columns" "Web/CSS/grid-template-columns")
   (list 'css 'name "justify-content" "Web/CSS/justify-content")
   (list 'css 'name "align-items" "Web/CSS/align-items")
   (list 'css 'name "flex" "Web/CSS/flex")
   (list 'css 'name "flex-direction" "Web/CSS/flex-direction")
   (list 'css 'name "box-shadow" "Web/CSS/box-shadow")
   ;; CSS at-rules and value/functions
   (list 'css 'keyword "@media" "Web/CSS/@media")
   (list 'css 'keyword "@supports" "Web/CSS/@supports")
   (list 'css 'keyword "@keyframes" "Web/CSS/@keyframes")
   (list 'css 'keyword "@import" "Web/CSS/@import")
   (list 'css 'keyword "@layer" "Web/CSS/@layer")
   (list 'css 'value "linear-gradient" "Web/CSS/gradient/linear-gradient")
   (list 'css 'value "radial-gradient" "Web/CSS/gradient/radial-gradient")
   (list 'css 'value "conic-gradient" "Web/CSS/gradient/conic-gradient")
   (list 'css 'value "rgb" "Web/CSS/color_value/rgb")
   (list 'css 'value "rgba" "Web/CSS/color_value/rgb")
   (list 'css 'value "hsl" "Web/CSS/color_value/hsl")
   (list 'css 'value "hsla" "Web/CSS/color_value/hsl")
   (list 'css 'value "var" "Web/CSS/var")
   (list 'css 'value "calc" "Web/CSS/calc")
   (list 'css 'value "clamp" "Web/CSS/clamp")
   (list 'css 'value "min" "Web/CSS/min")
   (list 'css 'value "max" "Web/CSS/max")
   ;; HTML elements and attributes
   (list 'html 'keyword "html" "Web/HTML/Element/html")
   (list 'html 'keyword "head" "Web/HTML/Element/head")
   (list 'html 'keyword "body" "Web/HTML/Element/body")
   (list 'html 'keyword "title" "Web/HTML/Element/title")
   (list 'html 'keyword "meta" "Web/HTML/Element/meta")
   (list 'html 'keyword "link" "Web/HTML/Element/link")
   (list 'html 'keyword "style" "Web/HTML/Element/style")
   (list 'html 'keyword "script" "Web/HTML/Element/script")
   (list 'html 'keyword "main" "Web/HTML/Element/main")
   (list 'html 'keyword "section" "Web/HTML/Element/section")
   (list 'html 'keyword "article" "Web/HTML/Element/article")
   (list 'html 'keyword "nav" "Web/HTML/Element/nav")
   (list 'html 'keyword "header" "Web/HTML/Element/header")
   (list 'html 'keyword "footer" "Web/HTML/Element/footer")
   (list 'html 'keyword "div" "Web/HTML/Element/div")
   (list 'html 'keyword "span" "Web/HTML/Element/span")
   (list 'html 'keyword "p" "Web/HTML/Element/p")
   (list 'html 'keyword "a" "Web/HTML/Element/a")
   (list 'html 'keyword "img" "Web/HTML/Element/img")
   (list 'html 'keyword "ul" "Web/HTML/Element/ul")
   (list 'html 'keyword "ol" "Web/HTML/Element/ol")
   (list 'html 'keyword "li" "Web/HTML/Element/li")
   (list 'html 'keyword "button" "Web/HTML/Element/button")
   (list 'html 'keyword "input" "Web/HTML/Element/input")
   (list 'html 'keyword "form" "Web/HTML/Element/form")
   (list 'html 'keyword "label" "Web/HTML/Element/label")
   (list 'html 'keyword "textarea" "Web/HTML/Element/textarea")
   (list 'html 'keyword "select" "Web/HTML/Element/select")
   (list 'html 'keyword "option" "Web/HTML/Element/option")
   (list 'html 'keyword "table" "Web/HTML/Element/table")
   (list 'html 'keyword "thead" "Web/HTML/Element/thead")
   (list 'html 'keyword "tbody" "Web/HTML/Element/tbody")
   (list 'html 'keyword "tr" "Web/HTML/Element/tr")
   (list 'html 'keyword "td" "Web/HTML/Element/td")
   (list 'html 'keyword "th" "Web/HTML/Element/th")
   (list 'html 'keyword "code" "Web/HTML/Element/code")
   (list 'html 'keyword "pre" "Web/HTML/Element/pre")
   (list 'html 'name "class" "Web/HTML/Global_attributes/class")
   (list 'html 'name "id" "Web/HTML/Global_attributes/id")
   (list 'html 'name "style" "Web/HTML/Global_attributes/style")
   (list 'html 'name "href" "Web/HTML/Element/a#href")
   (list 'html 'name "src" "Web/HTML/Element/img#src")
   (list 'html 'name "alt" "Web/HTML/Element/img#alt")
   (list 'html 'name "type" "Web/HTML/Element/input#type")
   (list 'html 'name "name" "Web/HTML/Element/input#name")
   (list 'html 'name "value" "Web/HTML/Element/input#value")
   (list 'html 'name "placeholder" "Web/HTML/Element/input#placeholder")
   ;; JS keywords and common globals/APIs
   (list 'js 'keyword "const" "Web/JavaScript/Reference/Statements/const")
   (list 'js 'keyword "let" "Web/JavaScript/Reference/Statements/let")
   (list 'js 'keyword "var" "Web/JavaScript/Reference/Statements/var")
   (list 'js 'keyword "function" "Web/JavaScript/Reference/Statements/function")
   (list 'js 'keyword "class" "Web/JavaScript/Reference/Statements/class")
   (list 'js 'keyword "return" "Web/JavaScript/Reference/Statements/return")
   (list 'js 'keyword "if" "Web/JavaScript/Reference/Statements/if...else")
   (list 'js 'keyword "else" "Web/JavaScript/Reference/Statements/if...else")
   (list 'js 'keyword "for" "Web/JavaScript/Reference/Statements/for")
   (list 'js 'keyword "while" "Web/JavaScript/Reference/Statements/while")
   (list 'js 'keyword "switch" "Web/JavaScript/Reference/Statements/switch")
   (list 'js 'keyword "try" "Web/JavaScript/Reference/Statements/try...catch")
   (list 'js 'keyword "catch" "Web/JavaScript/Reference/Statements/try...catch")
   (list 'js 'keyword "throw" "Web/JavaScript/Reference/Statements/throw")
   (list 'js 'keyword "new" "Web/JavaScript/Reference/Operators/new")
   (list 'js 'keyword "typeof" "Web/JavaScript/Reference/Operators/typeof")
   (list 'js 'keyword "instanceof" "Web/JavaScript/Reference/Operators/instanceof")
   (list 'js 'keyword "await" "Web/JavaScript/Reference/Operators/await")
   (list 'js 'keyword "async" "Web/JavaScript/Reference/Statements/async_function")
   (list 'js 'keyword "yield" "Web/JavaScript/Reference/Operators/yield")
   (list 'js 'name "Array" "Web/JavaScript/Reference/Global_Objects/Array")
   (list 'js 'name "Object" "Web/JavaScript/Reference/Global_Objects/Object")
   (list 'js 'name "String" "Web/JavaScript/Reference/Global_Objects/String")
   (list 'js 'name "Number" "Web/JavaScript/Reference/Global_Objects/Number")
   (list 'js 'name "Boolean" "Web/JavaScript/Reference/Global_Objects/Boolean")
   (list 'js 'name "Promise" "Web/JavaScript/Reference/Global_Objects/Promise")
   (list 'js 'name "Map" "Web/JavaScript/Reference/Global_Objects/Map")
   (list 'js 'name "Set" "Web/JavaScript/Reference/Global_Objects/Set")
   (list 'js 'name "Date" "Web/JavaScript/Reference/Global_Objects/Date")
   (list 'js 'name "RegExp" "Web/JavaScript/Reference/Global_Objects/RegExp")
   (list 'js 'name "Math" "Web/JavaScript/Reference/Global_Objects/Math")
   (list 'js 'name "JSON" "Web/JavaScript/Reference/Global_Objects/JSON")
   (list 'js 'name "console" "Web/API/console")
   (list 'js 'name "fetch" "Web/API/Window/fetch")
   (list 'js 'prop-name "log" "Web/API/console/log_static")
   (list 'js 'prop-name "error" "Web/API/console/error_static")
   (list 'js 'prop-name "warn" "Web/API/console/warn_static")
   (list 'js 'method-name "querySelector" "Web/API/Document/querySelector")
   (list 'js 'method-name "querySelectorAll" "Web/API/Document/querySelectorAll")
   (list 'js 'method-name "getElementById" "Web/API/Document/getElementById")
   (list 'js 'method-name "createElement" "Web/API/Document/createElement")
   (list 'js 'method-name "appendChild" "Web/API/Node/appendChild")
   (list 'js 'method-name "addEventListener" "Web/API/EventTarget/addEventListener")
   (list 'js 'method-name "json" "Web/API/Response/json")
   (list 'js 'method-name "map" "Web/JavaScript/Reference/Global_Objects/Array/map")
   (list 'js 'method-name "filter" "Web/JavaScript/Reference/Global_Objects/Array/filter")
   (list 'js 'method-name "reduce" "Web/JavaScript/Reference/Global_Objects/Array/reduce")
   (list 'js 'method-name "forEach" "Web/JavaScript/Reference/Global_Objects/Array/forEach")
   (list 'js 'method-name "includes" "Web/JavaScript/Reference/Global_Objects/Array/includes")
   (list 'js 'method-name "test" "Web/JavaScript/Reference/Global_Objects/RegExp/test")
   (list 'js 'method-name "match" "Web/JavaScript/Reference/Global_Objects/String/match")
   (list 'js 'method-name "replace" "Web/JavaScript/Reference/Global_Objects/String/replace")
   ;; WebAssembly (WAT) keywords/instructions
   (list 'wasm 'keyword "module" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "func" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "param" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "result" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "type" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "import" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "export" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "memory" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "table" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "data" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "elem" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "start" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "offset" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "align" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "mut" "WebAssembly/Guides/Understanding_the_text_format")
   (list 'wasm 'keyword "block" "WebAssembly/Reference/Control_flow/block")
   (list 'wasm 'keyword "loop" "WebAssembly/Reference/Control_flow/loop")
   (list 'wasm 'keyword "if" "WebAssembly/Reference/Control_flow/if...else")
   (list 'wasm 'keyword "else" "WebAssembly/Reference/Control_flow/if...else")
   (list 'wasm 'keyword "end" "WebAssembly/Reference/Control_flow/end")
   (list 'wasm 'keyword "br" "WebAssembly/Reference/Control_flow/br")
   (list 'wasm 'keyword "br_if" "WebAssembly/Reference/Control_flow/br_if")
   (list 'wasm 'keyword "br_table" "WebAssembly/Reference/Control_flow/br_table")
   (list 'wasm 'keyword "call" "WebAssembly/Reference/Control_flow/call")
   (list 'wasm 'keyword "call_indirect" "WebAssembly/Reference/Control_flow")
   (list 'wasm 'keyword "return" "WebAssembly/Reference/Control_flow/return")
   (list 'wasm 'keyword "drop" "WebAssembly/Reference/Control_flow/drop")
   (list 'wasm 'keyword "select" "WebAssembly/Reference/Control_flow/select")
   (list 'wasm 'keyword "unreachable" "WebAssembly/Reference/Control_flow/unreachable")
   (list 'wasm 'keyword "nop" "WebAssembly/Reference/Control_flow/nop")
   (list 'wasm 'keyword "local" "WebAssembly/Reference/Variables")
   (list 'wasm 'keyword "global" "WebAssembly/Reference/Variables")
   (list 'wasm 'keyword "local.get" "WebAssembly/Reference/Variables/local.get")
   (list 'wasm 'keyword "local.set" "WebAssembly/Reference/Variables/local.set")
   (list 'wasm 'keyword "local.tee" "WebAssembly/Reference/Variables/local.tee")
   (list 'wasm 'keyword "global.get" "WebAssembly/Reference/Variables/global.get")
   (list 'wasm 'keyword "global.set" "WebAssembly/Reference/Variables/global.set")
   (list 'wasm 'keyword "i32" "WebAssembly/Reference/Numeric")
   (list 'wasm 'keyword "i64" "WebAssembly/Reference/Numeric")
   (list 'wasm 'keyword "f32" "WebAssembly/Reference/Numeric")
   (list 'wasm 'keyword "f64" "WebAssembly/Reference/Numeric")
   (list 'wasm 'keyword "v128" "WebAssembly/Reference")
   (list 'wasm 'keyword "funcref" "WebAssembly/Reference")
   (list 'wasm 'keyword "externref" "WebAssembly/Reference")
   ;; Also make key JS keywords available when tokenized through html <script> mode.
   (list 'html 'keyword "const" "Web/JavaScript/Reference/Statements/const")
   (list 'html 'keyword "let" "Web/JavaScript/Reference/Statements/let")
   (list 'html 'keyword "function" "Web/JavaScript/Reference/Statements/function")
   (list 'html 'keyword "class" "Web/JavaScript/Reference/Statements/class")
   (list 'html 'keyword "return" "Web/JavaScript/Reference/Statements/return")
   (list 'html 'keyword "if" "Web/JavaScript/Reference/Statements/if...else")
   (list 'html 'keyword "for" "Web/JavaScript/Reference/Statements/for")
   (list 'html 'keyword "while" "Web/JavaScript/Reference/Statements/while")
   (list 'html 'keyword "await" "Web/JavaScript/Reference/Operators/await")
   (list 'html 'keyword "new" "Web/JavaScript/Reference/Operators/new")
   (list 'html 'name "Array" "Web/JavaScript/Reference/Global_Objects/Array")
   (list 'html 'name "Object" "Web/JavaScript/Reference/Global_Objects/Object")
   (list 'html 'name "Promise" "Web/JavaScript/Reference/Global_Objects/Promise")
   ;; Also make key CSS docs available when tokenized through html <style> mode.
   (list 'html 'name "color" "Web/CSS/color")
   (list 'html 'name "background" "Web/CSS/background")
   (list 'html 'name "font-family" "Web/CSS/font-family")
   (list 'html 'name "margin" "Web/CSS/margin")
   (list 'html 'name "padding" "Web/CSS/padding")
   (list 'html 'name "gap" "Web/CSS/gap")
   (list 'html 'name "border-radius" "Web/CSS/border-radius")
   (list 'html 'value "linear-gradient" "Web/CSS/gradient/linear-gradient")
   (list 'html 'value "radial-gradient" "Web/CSS/gradient/radial-gradient")
   (list 'html 'value "conic-gradient" "Web/CSS/gradient/conic-gradient")
   (list 'html 'value "rgb" "Web/CSS/color_value/rgb")
   (list 'html 'value "hsl" "Web/CSS/color_value/hsl")
   (list 'html 'value "var" "Web/CSS/var")
   (list 'html 'value "calc" "Web/CSS/calc")))

(define (mk-entries lang cls toks mk-path)
  (for/list ([t (in-list toks)])
    (list lang cls t (mk-path t))))

(define js-webapi-objects
  '("CanvasRenderingContext2D"
    "WebGLRenderingContext"
    "WebGL2RenderingContext"
    "ImageBitmapRenderingContext"
    "console"
    "Document" "Window" "Element" "HTMLElement" "Node" "EventTarget"
    "Navigator" "Location" "History"
    "Response" "HTMLCanvasElement"))

(define js-webapi-method-owner-pairs
  ;; Mirrors the API-owner heuristics used in lang-code.rkt.
  '(("querySelector" . "Document")
    ("querySelectorAll" . "Document")
    ("getElementById" . "Document")
    ("getElementsByClassName" . "Document")
    ("getElementsByTagName" . "Document")
    ("createElement" . "Document")
    ("createTextNode" . "Document")
    ("matches" . "Element")
    ("closest" . "Element")
    ("setAttribute" . "Element")
    ("getAttribute" . "Element")
    ("hasAttribute" . "Element")
    ("removeAttribute" . "Element")
    ("appendChild" . "Node")
    ("removeChild" . "Node")
    ("insertBefore" . "Node")
    ("replaceChild" . "Node")
    ("cloneNode" . "Node")
    ("addEventListener" . "EventTarget")
    ("removeEventListener" . "EventTarget")
    ("dispatchEvent" . "EventTarget")
    ("requestAnimationFrame" . "Window")
    ("cancelAnimationFrame" . "Window")
    ("setTimeout" . "Window")
    ("clearTimeout" . "Window")
    ("setInterval" . "Window")
    ("clearInterval" . "Window")
    ("getContext" . "HTMLCanvasElement")
    ("fillRect" . "CanvasRenderingContext2D")
    ("json" . "Response")
    ("log" . "console")
    ("info" . "console")
    ("warn" . "console")
    ("error" . "console")
    ("debug" . "console")
    ("dir" . "console")
    ("table" . "console")
    ("trace" . "console")
    ("assert" . "console")
    ("group" . "console")
    ("groupCollapsed" . "console")
    ("groupEnd" . "console")
    ("time" . "console")
    ("timeLog" . "console")
    ("timeEnd" . "console")
    ("count" . "console")
    ("countReset" . "console")))

(define (webapi-method-path owner method)
  (define canonical-owner
    (cond
      [(string=? owner "console") "console"]
      [(member method '("addEventListener" "removeEventListener" "dispatchEvent"))
       "EventTarget"]
      [(member method '("appendChild" "removeChild" "insertBefore" "replaceChild" "cloneNode"))
       "Node"]
      [else owner]))
  (if (string=? canonical-owner "console")
      (format "Web/API/console/~a_static" method)
      (format "Web/API/~a/~a" canonical-owner method)))

(define mdn-generated-extra-entries
  (append
   (mk-entries
    'css 'name
    '("opacity" "visibility" "cursor" "z-index" "inset"
      "place-items" "place-content" "align-content" "justify-items"
      "justify-self" "grid-template-rows" "grid-template-areas"
      "grid-auto-flow" "grid-auto-columns" "grid-auto-rows"
      "flex-wrap" "flex-grow" "flex-shrink" "order"
      "text-align" "text-decoration" "text-transform" "white-space"
      "word-break" "overflow-wrap" "letter-spacing" "word-spacing"
      "outline" "outline-color" "outline-offset"
      "list-style" "list-style-type" "list-style-position"
      "object-fit" "object-position"
      "backdrop-filter" "mix-blend-mode" "isolation"
      "clip-path" "mask-image"
      "content" "counter-reset" "counter-increment"
      "user-select" "pointer-events" "accent-color")
    (lambda (t) (string-append "Web/CSS/" t)))
   (mk-entries
    'css 'keyword
    '("@font-face" "@container" "@page" "@supports" "@namespace")
    (lambda (t) (string-append "Web/CSS/" t)))
   (list
    (list 'css 'value "repeat" "Web/CSS/repeat")
    (list 'css 'value "fit-content" "Web/CSS/fit-content")
    (list 'css 'value "url" "Web/CSS/url_function")
    (list 'css 'value "blur" "Web/CSS/filter-function/blur")
    (list 'css 'value "rotate" "Web/CSS/transform-function/rotate")
    (list 'css 'value "translate" "Web/CSS/transform-function/translate")
    (list 'css 'value "scale" "Web/CSS/transform-function/scale")
    (list 'css 'value "attr" "Web/CSS/attr"))
   (mk-entries
    'html 'keyword
    '("h1" "h2" "h3" "h4" "h5" "h6" "aside" "figure" "figcaption"
      "small" "strong" "em" "time" "blockquote" "cite" "details"
      "summary" "dialog" "template" "slot" "canvas" "svg" "video"
      "audio" "source" "iframe" "noscript" "dl" "dt" "dd")
    (lambda (t) (string-append "Web/HTML/Element/" t)))
   (mk-entries
    'html 'name
    '("role" "aria-label" "aria-hidden" "aria-expanded"
      "data-*"
      "title" "lang" "dir" "tabindex"
      "rel" "target" "loading" "decoding"
      "autofocus" "disabled" "checked" "selected"
      "readonly" "required" "multiple")
    (lambda (t) (string-append "Web/HTML/Global_attributes/" t)))
   (mk-entries
    'js 'keyword
    '("do" "default" "break" "continue" "finally" "delete"
      "void" "import" "export" "extends" "super" "this"
      "in" "of" "typeof")
    (lambda (t)
       (case (string->symbol t)
        [(do) "Web/JavaScript/Reference/Statements/do...while"]
        [(default) "Web/JavaScript/Reference/Statements/switch"]
        [(break) "Web/JavaScript/Reference/Statements/break"]
        [(continue) "Web/JavaScript/Reference/Statements/continue"]
        [(finally) "Web/JavaScript/Reference/Statements/try...catch"]
        [(delete) "Web/JavaScript/Reference/Operators/delete"]
        [(void) "Web/JavaScript/Reference/Operators/void"]
        [(import) "Web/JavaScript/Reference/Statements/import"]
        [(export) "Web/JavaScript/Reference/Statements/export"]
        [(extends) "Web/JavaScript/Reference/Classes/extends"]
        [(super) "Web/JavaScript/Reference/Operators/super"]
        [(this) "Web/JavaScript/Reference/Operators/this"]
        [(in) "Web/JavaScript/Reference/Operators/in"]
        [(of) "Web/JavaScript/Reference/Statements/for...of"]
        [else "Web/JavaScript/Reference/Operators/typeof"])))
   (mk-entries
    'wasm 'keyword
    '("i32.const" "i64.const" "f32.const" "f64.const")
    (lambda (_) "WebAssembly/Reference/Numeric/const"))
   (mk-entries
    'wasm 'keyword
    '("i32.add" "i64.add" "f32.add" "f64.add")
    (lambda (_) "WebAssembly/Reference/Numeric/add"))
   (mk-entries
    'wasm 'keyword
    '("i32.sub" "i64.sub" "f32.sub" "f64.sub")
    (lambda (_) "WebAssembly/Reference/Numeric/sub"))
   (mk-entries
    'wasm 'keyword
    '("i32.mul" "i64.mul" "f32.mul" "f64.mul")
    (lambda (_) "WebAssembly/Reference/Numeric/mul"))
   (mk-entries
    'js 'name
    '("Error" "TypeError" "SyntaxError" "URL" "URLSearchParams"
      "Intl" "Symbol" "BigInt" "WeakMap" "WeakSet")
    (lambda (t) (string-append "Web/JavaScript/Reference/Global_Objects/" t)))
   (mk-entries
    'js 'method-name
    '("find" "findIndex" "some" "every" "flatMap" "join" "slice"
      "push" "pop" "shift" "unshift" "sort" "toSorted" "toReversed"
      "toSpliced" "at" "startsWith" "endsWith" "split"
      "parse" "stringify")
    (lambda (t)
      (cond
        [(member t '("startsWith" "endsWith" "split"))
         (string-append "Web/JavaScript/Reference/Global_Objects/String/" t)]
        [(member t '("parse" "stringify"))
         (string-append "Web/JavaScript/Reference/Global_Objects/JSON/" t)]
        [else
         (string-append "Web/JavaScript/Reference/Global_Objects/Array/" t)]))
    )
   ;; Mirror key JS/CSS symbols for html mode (inline script/style).
   (mk-entries
    'html 'name
    '("Error" "TypeError" "URL" "Map" "Set" "Date" "Math" "JSON")
    (lambda (t) (string-append "Web/JavaScript/Reference/Global_Objects/" t)))
   (mk-entries
    'html 'name
    '("display" "position" "opacity" "visibility" "text-align")
    (lambda (t) (string-append "Web/CSS/" t)))
   (mk-entries
    'js 'name
    js-webapi-objects
    (lambda (t) (string-append "Web/API/" t)))
   (for/list ([p (in-list js-webapi-method-owner-pairs)])
     (list 'js 'method-name (car p) (webapi-method-path (cdr p) (car p))))))

(define mdn-default-map-entries
  (append mdn-default-map-entries/base mdn-generated-extra-entries))

(define (mdn-entry? v)
  (and (list? v)
       (= (length v) 4)
       (memq (first v) '(css html js wasm))
       (symbol? (second v))
       (string? (third v))
       (string? (fourth v))))

(define (normalize-token s)
  (string-downcase (string-trim s)))

(define (normalize-entry entry)
  (unless (mdn-entry? entry)
    (raise-argument-error 'normalize-entry "mdn-entry?" entry))
  (list (first entry)
        (second entry)
        (normalize-token (third entry))
        (fourth entry)))

(define (path->url path-or-url)
  (if (or (string-prefix? path-or-url "http://")
          (string-prefix? path-or-url "https://"))
      path-or-url
      (string-append mdn-base-url path-or-url)))

(define (entries->hash entries)
  (for/fold ([h (hash)])
            ([e (in-list entries)])
    (define e* (normalize-entry e))
    (hash-set h
              (list (first e*) (second e*) (third e*))
              (path->url (fourth e*)))))

(define (mdn-map-path)
  (build-path (find-system-path 'pref-dir)
              "scribble-tools"
              "mdn-map.rktd"))

(define (ensure-map-dir!)
  (make-directory* (path-only (mdn-map-path))))

(define (read-user-entries)
  (define p (mdn-map-path))
  (if (file-exists? p)
      (let ([v (with-handlers ([exn:fail? (lambda (_) null)])
                 (call-with-input-file p read))])
        (if (and (list? v) (andmap mdn-entry? v))
            v
            null))
      null))

(define mdn-map-cache (box #f))

(define (clear-map-cache!)
  (set-box! mdn-map-cache #f))

(define (effective-map)
  (or (unbox mdn-map-cache)
      (let* ([defaults (entries->hash mdn-default-map-entries)]
             [user (entries->hash (read-user-entries))]
             [merged (for/fold ([h defaults])
                               ([(k v) (in-hash user)])
                       (hash-set h k v))])
        (set-box! mdn-map-cache merged)
        merged)))

;; Comprehensive HTML element coverage for html keyword tokens.
;; Includes modern, deprecated, and obsolete tags documented by MDN.
(define html-element-set
  (list->set
   '("a" "abbr" "acronym" "address" "applet" "area" "article" "aside" "audio"
     "b" "base" "basefont" "bdi" "bdo" "bgsound" "big" "blink" "blockquote"
     "body" "br" "button" "canvas" "caption" "center" "cite" "code" "col"
     "colgroup" "content" "data" "datalist" "dd" "del" "details" "dfn"
     "dialog" "dir" "div" "dl" "dt" "em" "embed" "fencedframe" "fieldset"
     "figcaption" "figure" "font" "footer" "form" "frame" "frameset"
     "h1" "h2" "h3" "h4" "h5" "h6" "head" "header" "hgroup" "hr" "html"
     "i" "iframe" "image" "img" "input" "ins" "kbd" "keygen" "label"
     "legend" "li" "link" "listing" "main" "map" "mark" "marquee" "math"
     "menu" "menuitem" "meta" "meter" "multicol" "nav" "nextid" "nobr"
     "noembed" "noframes" "noscript" "object" "ol" "optgroup" "option"
     "output" "p" "param" "picture" "plaintext" "portal" "pre" "progress"
     "q" "rb" "rp" "rt" "rtc" "ruby" "s" "samp" "script" "search" "section"
     "select" "shadow" "slot" "small" "source" "spacer" "span" "strike"
     "strong" "style" "sub" "summary" "sup" "svg" "table" "tbody" "td"
     "template" "textarea" "tfoot" "th" "thead" "time" "title" "tr" "track"
     "tt" "u" "ul" "var" "video" "wbr" "xmp")))

(define css-prop-rx #px"^-?[a-z][a-z0-9-]*$")

(define (css-property-token? token)
  ;; Custom properties (--name) do not have per-property MDN pages.
  (and (regexp-match? css-prop-rx token)
       (not (string-prefix? token "--"))))

(define (fallback-url-for-token lang cls token)
  (cond
    [(and (eq? lang 'css)
          (eq? cls 'name)
          (css-property-token? token))
     (string-append mdn-base-url "Web/CSS/" token)]
    [(and (eq? lang 'html)
          (eq? cls 'keyword)
          (set-member? html-element-set token))
     (string-append mdn-base-url "Web/HTML/Element/" token)]
    [(and (eq? lang 'wasm)
          (or (eq? cls 'keyword) (eq? cls 'name))
          (regexp-match? #px"^(i32|i64|f32|f64)\\.([a-z][a-z0-9_]*)$" token))
     (define m (regexp-match #px"^(i32|i64|f32|f64)\\.([a-z][a-z0-9_]*)$" token))
     (string-append mdn-base-url "WebAssembly/Reference/Numeric/" (third m))]
    [(and (eq? lang 'wasm)
          (or (eq? cls 'keyword) (eq? cls 'name))
          (regexp-match? #px"^(local|global)\\.(get|set|tee)$" token))
     (string-append mdn-base-url "WebAssembly/Reference/Variables/" token)]
    [(and (eq? lang 'wasm)
          (or (eq? cls 'keyword) (eq? cls 'name))
          (regexp-match? #px"^[a-z][a-z0-9_]*$" token))
     (string-append mdn-base-url "WebAssembly/Reference")]
    [else #f]))

(define (mdn-url-for-token lang cls token)
  (define t (normalize-token token))
  (define key (list lang cls t))
  (define css-name-key (list 'css 'name t))
  (define js-keyword-key (list 'js 'keyword t))
  (define js-method-key (list 'js 'method-name t))
  (define js-prop-key (list 'js 'prop-name t))
  (or (hash-ref (effective-map) key #f)
      ;; CSS snippets without declaration context can classify property-like
      ;; identifiers as keywords. Reuse CSS property docs in that case.
      (and (eq? lang 'css)
           (eq? cls 'keyword)
           (hash-ref (effective-map) css-name-key #f))
      ;; JS snippets can classify standalone API methods as plain names.
      ;; If so, reuse known JS keyword/method/property docs.
      (and (eq? lang 'js)
           (eq? cls 'name)
           (or (hash-ref (effective-map) js-keyword-key #f)
               (hash-ref (effective-map) js-method-key #f)
               (hash-ref (effective-map) js-prop-key #f)))
      (fallback-url-for-token lang cls t)))

(define (mdn-install-map! entries-or-path)
  (define entries
    (cond
      [(path-string? entries-or-path)
       (call-with-input-file entries-or-path read)]
      [else entries-or-path]))
  (unless (and (list? entries) (andmap mdn-entry? entries))
    (raise-argument-error 'mdn-install-map! "(listof mdn-entry?) or path-string? to one" entries-or-path))
  (ensure-map-dir!)
  (call-with-output-file (mdn-map-path)
    (lambda (out) (write (map normalize-entry entries) out))
    #:exists 'truncate/replace)
  (clear-map-cache!)
  (mdn-map-path))

(define (mdn-reset-map!)
  (define p (mdn-map-path))
  (define existed? (file-exists? p))
  (when existed? (delete-file p))
  (clear-map-cache!)
  existed?)

(define (mdn-export-default-map! dest)
  (unless (path-string? dest)
    (raise-argument-error 'mdn-export-default-map! "path-string?" dest))
  (call-with-output-file dest
    (lambda (out) (write (map normalize-entry mdn-default-map-entries) out))
    #:exists 'truncate/replace)
  dest)

(module+ test
  (require rackunit)
  (check-true (pair? mdn-default-map-entries))
  (check-true (andmap mdn-entry? mdn-default-map-entries))
  (check-not-false (mdn-url-for-token 'css 'name "display"))
  (check-not-false (mdn-url-for-token 'css 'name "accent-color"))
  (check-not-false (mdn-url-for-token 'css 'name "mask-border-repeat"))
  (check-not-false (mdn-url-for-token 'css 'keyword "display"))
  (check-not-false (mdn-url-for-token 'css 'keyword "grid"))
  (check-not-false (mdn-url-for-token 'js 'name "querySelector"))
  (check-not-false (mdn-url-for-token 'js 'name "async"))
  (check-not-false (mdn-url-for-token 'js 'name "await"))
  (check-not-false (mdn-url-for-token 'js 'name "fetch"))
  (check-not-false (mdn-url-for-token 'js 'method-name "json"))
  (check-not-false (mdn-url-for-token 'html 'keyword "dialog"))
  (check-not-false (mdn-url-for-token 'html 'keyword "acronym"))
  (check-false (mdn-url-for-token 'html 'keyword "not-a-real-tag"))
  (check-not-false (mdn-url-for-token 'html 'keyword "const")) ; explicit JS mapping wins
  (check-not-false (mdn-url-for-token 'js 'method-name "flatMap"))
  (check-not-false (mdn-url-for-token 'wasm 'keyword "module"))
  (check-not-false (mdn-url-for-token 'wasm 'keyword "local.get"))
  (check-not-false (mdn-url-for-token 'wasm 'keyword "i32.add"))
  (check-not-false (mdn-url-for-token 'wasm 'name "f64.mul")))
