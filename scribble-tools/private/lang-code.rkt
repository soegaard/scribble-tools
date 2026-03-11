#lang racket/base

(require racket/list
         racket/set
         racket/string
         racket/file
         racket/runtime-path
         "mdn-map.rkt"
         scribble/base
         scribble/core
         scribble/html-properties
         (only-in scribble/manual filebox)
         scribble/racket
         (for-syntax racket/base
                     syntax/parse))

(provide css-code
         html-code
         js-code
         cssblock
         htmlblock
         jsblock
         cssblock0
         htmlblock0
         jsblock0)

(define omitable (make-style #f '(omitable)))
;; Dedicated style for HTML tag names; do not rely on .RktSym/.RktKw theme mappings.
(define html-tag-color
  (make-style #f (list (attributes '((style . "color: #07A;"))))))
(define js-keyword-color
  (make-style #f (list (attributes '((style . "color: #07A;"))))))
(define js-name-color
  (make-style #f (list (attributes '((style . "color: #262680;"))))))
(define js-decl-name-color
  (make-style #f (list (attributes '((style . "color: #795E26;"))))))
(define js-operator-color
  (make-style #f (list (attributes '((style . "color: #8A4F00;"))))))
(define js-object-key-color
  (make-style #f (list (attributes '((style . "color: #1F5F8B;"))))))
(define js-param-name-color
  (make-style #f (list (attributes '((style . "color: #264F78;"))))))
(define js-prop-name-color
  (make-style #f (list (attributes '((style . "color: #5A3E8E;"))))))
(define js-method-name-color
  (make-style #f (list (attributes '((style . "color: #6B2F8A;"))))))
(define js-private-name-color
  (make-style #f (list (attributes '((style . "color: #AF00DB;"))))))
(define js-static-keyword-color
  (make-style #f (list (attributes '((style . "font-weight: 600; color: #07A;"))))))
(define css-keyword-color
  (make-style #f (list (attributes '((style . "color: #07A;"))))))
(define css-name-color
  (make-style #f (list (attributes '((style . "color: #262680;"))))))
(define mdn-link-style
  (make-style #f (list (attributes '((class . "mdn-code-link")
                                     (style . "color: inherit; text-decoration: none;"))))))

(define css-color-keywords
  (list->set
   '("transparent" "currentcolor"
     "black" "white" "gray" "grey" "silver"
     "red" "green" "blue"
     "yellow" "orange" "purple" "pink" "brown"
     "cyan" "magenta" "lime" "teal" "navy" "olive" "maroon"
     "aqua" "fuchsia")))

(define css-color-functions
  (list->set
   '("rgb" "rgba" "hsl" "hsla" "hwb" "lab" "lch" "oklab" "oklch"
     "color" "color-mix" "device-cmyk" "light-dark")))

(define css-gradient-functions
  (list->set
   '("linear-gradient" "radial-gradient" "conic-gradient"
     "repeating-linear-gradient" "repeating-radial-gradient" "repeating-conic-gradient")))

(define css-spacing-properties
  (list->set
   '("margin" "margin-top" "margin-right" "margin-bottom" "margin-left"
     "padding" "padding-top" "padding-right" "padding-bottom" "padding-left"
     "gap" "row-gap" "column-gap"
     "letter-spacing" "word-spacing" "outline-offset" "text-indent")))

(define css-blur-properties
  (list->set '("filter" "backdrop-filter")))

(define current-preview-css-url (make-parameter #f))
(define current-preview-tooltips? (make-parameter #t))
(define current-jsx? (make-parameter #f))
(define current-js-template-depth (make-parameter 0))
(define current-html-style-color-swatch? (make-parameter #t))
(define current-html-style-font-preview? (make-parameter #t))
(define current-html-style-dimension-preview? (make-parameter #t))
(define current-html-style-preview-mode (make-parameter 'always))
(define current-html-script-preview? (make-parameter #t))

(define (preview-url-attrs)
  (define u (current-preview-css-url))
  (if (and (string? u) (not (string=? (string-trim u) "")))
      `((data-preview-css-url . ,u))
      null))

(define (preview-tooltip-attrs label)
  (if (current-preview-tooltips?)
      `((data-preview-tooltips . "on")
        (data-preview-title . ,label)
        (title . ,label)
        (role . "img")
        (aria-label . ,label)
        (tabindex . "0"))
      `((data-preview-tooltips . "off")
        (aria-hidden . "true")
        (tabindex . "-1"))))

(define (safe-css-color-literal? s)
  (and (regexp-match? #px"^[#(),.%+\\-/_a-zA-Z0-9\\s]+$" s)
       (not (regexp-match? #px";" s))))

(define (css-color-literal? s)
  (define down (string-downcase s))
  (or (set-member? css-color-keywords down)
      (regexp-match? #px"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$" s)))

(define (safe-css-font-family-literal? s)
  (and (not (string=? (string-trim s) ""))
       (regexp-match? #px"^[a-zA-Z0-9\"' ,._-]+$" s)))

(define (normalize-css-font-family s)
  (string-trim
   (regexp-replace* #px"(?i:!\\s*important\\s*$)" (string-trim s) "")))

(define (normalize-css-decl-value s)
  (string-trim
   (regexp-replace* #px"(?i:!\\s*important\\s*$)" (string-trim s) "")))

(define css-length-rx
  #px"([-+]?[0-9]*\\.?[0-9]+)\\s*(px|rem|em|%|vw|vh|vmin|vmax|svw|svh|lvw|lvh|dvw|dvh|vi|vb|pt|pc|cm|mm|in|q|ch|ex|cap|ic|lh|rlh)")

(define (parse-css-lengths s)
  (let loop ([start 0] [acc null])
    (define m (regexp-match-positions css-length-rx s start))
    (cond
      [(not m) (reverse acc)]
      [else
       (define whole (list-ref m 0))
       (define num-pos (list-ref m 1))
       (define unit-pos (list-ref m 2))
       (define next-start (cdr whole))
       (if (and num-pos unit-pos)
           (let* ([num-str (substring s (car num-pos) (cdr num-pos))]
                  [unit-str (string-downcase (substring s (car unit-pos) (cdr unit-pos)))]
                  [num (string->number num-str)])
             (if num
                 (loop next-start (cons (cons num unit-str) acc))
                 (loop next-start acc)))
           (loop next-start acc))])))

(define (css-length->px amount unit)
  (case (string->symbol unit)
    [(px) amount]
    [(rem em) (* 16.0 amount)]
    [(pt) (* (/ 96.0 72.0) amount)]
    [(pc) (* 16.0 amount)]
    [(in) (* 96.0 amount)]
    [(cm) (* (/ 96.0 2.54) amount)]
    [(mm) (* (/ 96.0 25.4) amount)]
    [(q) (* (/ 96.0 101.6) amount)]
    [(ch ex cap) (* 8.0 amount)]
    [(ic lh rlh) (* 16.0 amount)]
    [(vw vh vmin vmax svw svh lvw lvh dvw dvh vi vb) (* 10.0 amount)]
    [(%) (* 0.5 amount)]
    [else #f]))

(define (clamp lo x hi)
  (min hi (max lo x)))

(define (max-css-length-px value-text)
  (define pxs
    (filter values
            (for/list ([lu (in-list (parse-css-lengths value-text))])
              (css-length->px (car lu) (cdr lu)))))
  (and (pair? pxs) (apply max pxs)))

(define (format-px px)
  (format "~apx" (inexact->exact (round px))))

(define (extract-blur-arg value-text)
  (define m (regexp-match #px"(?i:blur\\(([^)]*)\\))" value-text))
  (and m (string-trim (list-ref m 1))))

(define (spacing-width-px value-text)
  (define px (max-css-length-px value-text))
  (and px
       (let* ([px* (clamp 0.0 px 160.0)])
         (and px*
              (inexact->exact
               (round (clamp 6.0 (+ 6.0 (* 0.28 px*)) 54.0)))))))

(define (radius-size-px value-text)
  (define px (max-css-length-px value-text))
  (and px
       (let* ([px* (clamp 0.0 px 999.0)])
         (and px*
              (inexact->exact
               (round (clamp 0.0 px* 9.0)))))))

(define (spacing-preview-title value-text)
  (define px (max-css-length-px value-text))
  (if px
      (format "Spacing preview: ~a (~a)" value-text (format-px px))
      (format "Spacing preview: ~a" value-text)))

(define (radius-preview-title value-text)
  (define px (max-css-length-px value-text))
  (if px
      (format "Border radius preview: ~a (~a)" value-text (format-px px))
      (format "Border radius preview: ~a" value-text)))

(define (normalize-preview-mode who mode)
  (cond
    [(memq mode '(none always hover)) mode]
    [else (raise-argument-error who "(or/c 'none 'always 'hover)" mode)]))

(define (preview-mode->string mode)
  (case mode
    [(none) "none"]
    [(always) "always"]
    [(hover) "hover"]
    [else "always"]))

(define (css-font-preview-style family-text preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-font-preview-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-font-preview-ui")
        (data-preview-mode . ,mode)
        (data-font-stack . ,family-text)
        (style . ,(format "--css-preview-font: ~a;" family-text)))
      (preview-tooltip-attrs (format "Preview stack: ~a" family-text))
      (preview-url-attrs))))))

(define (css-font-preview-element family-text preview-mode)
  (make-element (css-font-preview-style family-text preview-mode) (list "Aa")))

(define (css-swatch-style color-text preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-swatch-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-color-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-bg: ~a;" color-text)))
      (preview-tooltip-attrs (format "Color preview: ~a" color-text))
      (preview-url-attrs))))))

(define (css-swatch-element color-text preview-mode)
  (make-element (css-swatch-style color-text preview-mode) (list " ")))

(define (css-gradient-swatch-style gradient-text preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-gradient-swatch-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-gradient-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-bg: ~a;" gradient-text)))
      (preview-tooltip-attrs (format "Gradient preview: ~a" gradient-text))
      (preview-url-attrs))))))

(define (css-gradient-swatch-element gradient-text preview-mode)
  (make-element (css-gradient-swatch-style gradient-text preview-mode) (list " ")))

(define (css-spacing-preview-style width-px label preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-spacing-preview-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-spacing-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-width: ~apx;" width-px)))
      (preview-tooltip-attrs (spacing-preview-title label))
      (preview-url-attrs))))))

(define (css-spacing-preview-element width-px label preview-mode)
  (make-element (css-spacing-preview-style width-px label preview-mode) (list " ")))

(define (css-radius-preview-style radius-px label preview-mode)
  (define mode (preview-mode->string (normalize-preview-mode 'css-radius-preview-style preview-mode)))
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-radius-preview-ui")
        (data-preview-mode . ,mode)
        (style . ,(format "--css-preview-radius: ~apx;" radius-px)))
      (preview-tooltip-attrs (radius-preview-title label))
      (preview-url-attrs))))))

(define (css-radius-preview-element radius-px label preview-mode)
  (make-element (css-radius-preview-style radius-px label preview-mode) (list " ")))

(define (js-preview-style kind label)
  (make-style
   #f
   (list
    (attributes
     `((class . ,(format "js-preview-ui ~a" kind))
       ,@(preview-tooltip-attrs label))))))

(define (js-regex-preview-element)
  (make-element (js-preview-style "js-regex-preview-ui" "Regex literal") null))

(define (js-template-preview-element)
  (make-element (js-preview-style "js-template-preview-ui" "Template literal") null))

(define (css-token-def-style name value)
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-token-def-preview-ui")
        (style . ,(format "--css-token-name: \"~a\";" name)))
      (preview-tooltip-attrs (format "Design token ~a = ~a" name value))
      (preview-url-attrs))))))

(define (css-token-def-element name value)
  (make-element (css-token-def-style name value) (list name)))

(define (css-token-ref-style name)
  (make-style
   #f
   (list
    (attributes
     (append
      `((class . "css-preview-ui css-token-ref-preview-ui")
        (style . ,(format "--css-token-name: \"~a\";" name)))
      (preview-tooltip-attrs (format "Uses design token ~a" name))
      (preview-url-attrs))))))

(define (css-token-ref-element name)
  (make-element (css-token-ref-style name) (list name)))

(define css-font-preview-runtime-script
  #<<JS
(function () {
  if (window.__scribbleCssFontPreviewUiInit) return;
  window.__scribbleCssFontPreviewUiInit = true;

  var styleId = "scribble-css-preview-ui-style";
  function ensureStyles() {
    var first = document.querySelector(".css-preview-ui, .js-preview-ui");
    var external = first && first.getAttribute("data-preview-css-url");
    if (external) {
      var lid = "scribble-css-preview-ui-link";
      if (!document.getElementById(lid)) {
        var lk = document.createElement("link");
        lk.id = lid;
        lk.rel = "stylesheet";
        lk.href = external;
        document.head.appendChild(lk);
      }
      return;
    }
    if (!document.getElementById(styleId)) {
      var st = document.createElement("style");
      st.id = styleId;
      st.textContent =
        ":root{--css-preview-stroke:#999;--css-preview-text:rgba(0,0,0,.72);--css-preview-accent-1:rgba(70,150,245,.70);--css-preview-accent-2:rgba(70,150,245,.22);--css-preview-fill:rgba(70,150,245,.15);}" +
        ".css-preview-ui{display:inline-block;margin-left:.45em;vertical-align:middle;user-select:none;-webkit-user-select:none;pointer-events:auto;}" +
        ".css-preview-ui:focus,.js-preview-ui:focus{outline:1px solid color-mix(in srgb, var(--css-preview-accent-1) 80%, #000 10%);outline-offset:1px;}" +
        ".css-preview-ui[data-preview-mode=none]{display:none!important;}" +
        ".css-preview-ui[data-preview-mode=hover]{display:none;}" +
        ".css-color-preview-ui{width:.75em;height:.75em;border:1px solid var(--css-preview-stroke);background:var(--css-preview-bg);}" +
        ".css-gradient-preview-ui{width:1.4em;height:.75em;border:1px solid var(--css-preview-stroke);background:var(--css-preview-bg);}" +
        ".css-spacing-preview-ui{width:var(--css-preview-width,10px);height:.58em;border:1px solid color-mix(in srgb, var(--css-preview-stroke) 80%, transparent);border-radius:2px;background:linear-gradient(to right, var(--css-preview-accent-1), var(--css-preview-accent-2));}" +
        ".css-radius-preview-ui{width:.95em;height:.95em;border:1px solid color-mix(in srgb, var(--css-preview-stroke) 85%, transparent);border-radius:var(--css-preview-radius,4px);background:var(--css-preview-fill);}" +
        ".css-font-preview-ui{margin-left:.6em;white-space:nowrap;font-family:var(--css-preview-font,inherit);font-size:1em;line-height:1;color:var(--css-preview-text);pointer-events:auto;}" +
        ".css-font-preview-warning{color:#b45;font-weight:600;}" +
        ".css-token-def-preview-ui,.css-token-ref-preview-ui{margin-left:.45em;padding:0 .3em;height:1.1em;line-height:1.05em;border-radius:.35em;border:1px solid color-mix(in srgb, var(--css-preview-stroke) 80%, transparent);font-size:.72em;color:var(--css-preview-text);}" +
        ".css-token-def-preview-ui{background:color-mix(in srgb, var(--css-preview-fill) 75%, transparent);}" +
        ".css-token-ref-preview-ui{background:transparent;border-style:dashed;}" +
        ".js-preview-ui{display:inline-block;margin-left:.35em;vertical-align:middle;user-select:none;-webkit-user-select:none;pointer-events:auto;color:var(--css-preview-text);font-size:.82em;line-height:1;}" +
        ".js-regex-preview-ui::before{content:\"/r/\";}" +
        ".js-template-preview-ui::before{content:\"`...`\";}";
      document.head.appendChild(st);
    }
  }

  var tooltipEl = null;
  function ensureTooltipEl() {
    if (tooltipEl) return tooltipEl;
    tooltipEl = document.createElement("div");
    tooltipEl.id = "scribble-preview-tooltip";
    tooltipEl.style.position = "fixed";
    tooltipEl.style.zIndex = "99999";
    tooltipEl.style.display = "none";
    tooltipEl.style.pointerEvents = "none";
    tooltipEl.style.maxWidth = "32rem";
    tooltipEl.style.padding = "0.28rem 0.45rem";
    tooltipEl.style.borderRadius = "0.32rem";
    tooltipEl.style.background = "rgba(20,20,20,.92)";
    tooltipEl.style.color = "#fff";
    tooltipEl.style.font = "12px/1.25 sans-serif";
    tooltipEl.style.whiteSpace = "pre-wrap";
    tooltipEl.style.boxShadow = "0 3px 10px rgba(0,0,0,.28)";
    document.body.appendChild(tooltipEl);
    return tooltipEl;
  }

  function tooltipText(preview) {
    if (preview.getAttribute("data-preview-tooltips") === "off") return "";
    return preview.getAttribute("data-preview-title") || preview.getAttribute("title") || "";
  }

  function setPreviewLabel(preview, text) {
    preview.setAttribute("data-preview-title", text);
    preview.setAttribute("aria-label", text);
    if (preview.getAttribute("data-preview-tooltips") === "off") {
      preview.removeAttribute("title");
    } else {
      preview.setAttribute("title", text);
    }
  }

  function showTooltip(preview, clientX, clientY) {
    var text = tooltipText(preview);
    if (!text) return;
    var tip = ensureTooltipEl();
    tip.textContent = text;
    tip.style.display = "block";
    moveTooltip(clientX, clientY);
  }

  function moveTooltip(clientX, clientY) {
    if (!tooltipEl || tooltipEl.style.display === "none") return;
    var x = (typeof clientX === "number" ? clientX : 0) + 12;
    var y = (typeof clientY === "number" ? clientY : 0) + 12;
    var vw = window.innerWidth || document.documentElement.clientWidth || 1024;
    var vh = window.innerHeight || document.documentElement.clientHeight || 768;
    var tw = tooltipEl.offsetWidth || 0;
    var th = tooltipEl.offsetHeight || 0;
    if (x + tw + 8 > vw) x = Math.max(8, vw - tw - 8);
    if (y + th + 8 > vh) y = Math.max(8, vh - th - 8);
    tooltipEl.style.left = x + "px";
    tooltipEl.style.top = y + "px";
  }

  function hideTooltip() {
    if (tooltipEl) tooltipEl.style.display = "none";
  }

  function bindTooltip(preview) {
    if (preview.__scribbleTooltipBound) return;
    preview.__scribbleTooltipBound = true;
    if (preview.getAttribute("data-preview-tooltips") === "off") return;
    if (!tooltipText(preview)) return;
    preview.style.cursor = "help";
    preview.addEventListener("mouseenter", function (e) {
      showTooltip(preview, e.clientX, e.clientY);
    });
    preview.addEventListener("mousemove", function (e) {
      moveTooltip(e.clientX, e.clientY);
    });
    preview.addEventListener("mouseleave", hideTooltip);
    preview.addEventListener("focus", function () {
      var r = preview.getBoundingClientRect();
      showTooltip(preview, r.left + r.width / 2, r.bottom);
    });
    preview.addEventListener("blur", hideTooltip);
  }

  var GENERIC = new Set([
    "serif", "sans-serif", "monospace", "cursive", "fantasy",
    "system-ui", "emoji", "math", "fangsong",
    "ui-serif", "ui-sans-serif", "ui-monospace", "ui-rounded"
  ]);

  function splitFontStack(raw) {
    var s = (raw || "").trim();
    var out = [];
    var cur = "";
    var quote = null;
    var esc = false;
    for (var i = 0; i < s.length; i++) {
      var ch = s[i];
      if (esc) {
        cur += ch;
        esc = false;
        continue;
      }
      if (ch === "\\\\") {
        cur += ch;
        esc = true;
        continue;
      }
      if (quote) {
        cur += ch;
        if (ch === quote) quote = null;
        continue;
      }
      if (ch === "'" || ch === "\"") {
        cur += ch;
        quote = ch;
        continue;
      }
      if (ch === ",") {
        out.push(cur.trim());
        cur = "";
        continue;
      }
      cur += ch;
    }
    if (cur.trim() !== "") out.push(cur.trim());
    return out.map(function (part) {
      var p = part.trim();
      if ((p.startsWith("\"") && p.endsWith("\"")) || (p.startsWith("'") && p.endsWith("'"))) {
        p = p.slice(1, -1);
      }
      return p.trim();
    }).filter(Boolean);
  }

  function isGenericFamily(name) {
    return GENERIC.has((name || "").toLowerCase());
  }

  function hasFont(name) {
    if (!name) return false;
    if (isGenericFamily(name)) return true;
    if (!document.fonts || !document.fonts.check) return null;
    try {
      var escaped = String(name).replace(/"/g, "\\\\\"");
      return document.fonts.check('16px "' + escaped + '"');
    } catch (e) {
      return null;
    }
  }

  function addWarning(preview) {
    var warn = preview.querySelector(".css-font-preview-warning");
    if (warn) return;
    warn = document.createElement("span");
    warn.className = "css-font-preview-warning";
    warn.setAttribute("aria-hidden", "true");
    warn.textContent = " \\u26A0";
    preview.appendChild(warn);
  }

  function clearWarning(preview) {
    var warn = preview.querySelector(".css-font-preview-warning");
    if (warn) warn.remove();
  }

  function computeFontState(preview) {
    var stack = preview.getAttribute("data-font-stack") || "";
    var families = splitFontStack(stack);
    var nonGeneric = families.filter(function (f) { return !isGenericFamily(f); });
    var generic = families.filter(function (f) { return isGenericFamily(f); });
    var available = null;
    var availabilityUnknown = false;

    for (var i = 0; i < families.length; i++) {
      var ok = hasFont(families[i]);
      if (ok === null) {
        availabilityUnknown = true;
      } else if (ok) {
        available = families[i];
        break;
      }
    }

    var fallback = generic[0] || "monospace";
    var firstRequested = nonGeneric[0] || generic[0] || "(default)";
    var resolved = available || generic[0] || "(browser default)";
    var usedFallback = available && firstRequested && (available !== firstRequested);
    var missing = (!availabilityUnknown && nonGeneric.length > 0 && !available);

    if (missing) {
      addWarning(preview);
      setPreviewLabel(preview, "Font not found on system\\nUsing fallback: " + fallback);
    } else {
      clearWarning(preview);
      if (usedFallback) {
        setPreviewLabel(preview, "Rendered using: " + resolved + " (fallback)");
      } else {
        setPreviewLabel(preview, "Rendered using: " + resolved);
      }
    }
  }

  function setVisible(preview, on) {
    if (preview.getAttribute("data-preview-mode") !== "hover") return;
    preview.style.display = on ? "inline-block" : "none";
  }

  function bindPreview(preview) {
    if (preview.__scribblePreviewBound) return;
    preview.__scribblePreviewBound = true;
    var mode = preview.getAttribute("data-preview-mode") || "always";
    var isFont = preview.classList.contains("css-font-preview-ui");

    if (isFont) computeFontState(preview);
    bindTooltip(preview);
    if (mode !== "hover") return;

    preview.__scribbleFontPreviewBound = true;
    setVisible(preview, false);

    var host =
      preview.closest("tr") ||
      preview.closest("p") ||
      preview.closest("li") ||
      preview.closest("dd") ||
      preview.closest("dt") ||
      preview.parentElement;
    if (!host) return;

    host.addEventListener("mouseenter", function () {
      if (isFont) computeFontState(preview);
      setVisible(preview, true);
    });
    host.addEventListener("mouseleave", function () {
      setVisible(preview, false);
    });
    host.addEventListener("focusin", function () {
      if (isFont) computeFontState(preview);
      setVisible(preview, true);
    });
    host.addEventListener("focusout", function () {
      setVisible(preview, false);
    });
  }

  function scan() {
    ensureStyles();
    var previews = document.querySelectorAll(".css-preview-ui");
    for (var i = 0; i < previews.length; i++) bindPreview(previews[i]);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", scan, { once: true });
  } else {
    scan();
  }
})();
JS
  )

(define css-font-preview-runtime-element
  (make-element
   (make-style #f (list (script-property "text/javascript"
                                         (list css-font-preview-runtime-script))))
   null))

(define css-preview-runtime-emitted? (box #f))

(define (runtime-prefix-elements)
  (if (unbox css-preview-runtime-emitted?)
      null
      (begin
        (set-box! css-preview-runtime-emitted? #t)
        (list css-font-preview-runtime-element))))

(define (style-for lang cls)
  (case lang
    [(css)
     (case cls
       [(comment) comment-color]
       [(keyword) css-keyword-color]
       [(value) value-color]
       [(name) css-name-color]
       [(punct) paren-color]
       [else no-color])]
    [(html)
     (case cls
       [(comment) comment-color]
       [(keyword) html-tag-color]
       [(value) value-color]
       [(static-keyword) js-static-keyword-color]
       [(object-key) js-object-key-color]
       [(param-name) js-param-name-color]
       [(decl-name) js-decl-name-color]
       [(prop-name) js-prop-name-color]
       [(method-name) js-method-name-color]
       [(private-name) js-private-name-color]
       [(name) symbol-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [(js)
     (case cls
       [(comment) comment-color]
       [(keyword) js-keyword-color]
       [(value) value-color]
       [(static-keyword) js-static-keyword-color]
       [(object-key) js-object-key-color]
       [(param-name) js-param-name-color]
       [(decl-name) js-decl-name-color]
       [(prop-name) js-prop-name-color]
       [(method-name) js-method-name-color]
       [(private-name) js-private-name-color]
       [(name) js-name-color]
       [(operator) js-operator-color]
       [(punct) paren-color]
       [else no-color])]
    [else no-color]))

(define (next-char s i)
  (and (< i (string-length s)) (string-ref s i)))

(define (read-while s start pred?)
  (let loop ([i start])
    (if (and (< i (string-length s))
             (pred? (string-ref s i)))
        (loop (add1 i))
        i)))

(define (read-until s start needle)
  (define n-len (string-length needle))
  (let loop ([i start])
    (cond
      [(> (+ i n-len) (string-length s)) (string-length s)]
      [(string=? needle (substring s i (+ i n-len))) (+ i n-len)]
      [else (loop (add1 i))])))

(define (css-ident-start? c)
  (or (char-alphabetic? c) (char=? c #\_) (char=? c #\-)))

(define (css-ident-char? c)
  (or (css-ident-start? c) (char-numeric? c)))

(define (hex-digit? c)
  (or (char-numeric? c)
      (and (char-ci>=? c #\a) (char-ci<=? c #\f))))

(define (read-string-literal s i)
  (define len (string-length s))
  (define q (string-ref s i))
  (let loop ([k (add1 i)] [escaped? #f])
    (cond
      [(>= k len) len]
      [else
       (define c (string-ref s k))
       (cond
         [escaped? (loop (add1 k) #f)]
         [(char=? c #\\) (loop (add1 k) #t)]
         [(char=? c q) (add1 k)]
         [else (loop (add1 k) #f)])])))

(define (read-css-number s i)
  (define len (string-length s))
  (define j0
    (if (and (< i len) (member (string-ref s i) '(#\+ #\-)))
        (add1 i)
        i))
  (define j1 (read-while s j0 char-numeric?))
  (define j2
    (if (and (< j1 len) (char=? (string-ref s j1) #\.))
        (read-while s (add1 j1) char-numeric?)
        j1))
  (if (and (< j2 len) (char=? (string-ref s j2) #\%))
      (add1 j2)
      (read-while s j2
                  (lambda (c)
                    (or (char-alphabetic? c) (char=? c #\-))))))

(define (tokenize-css s)
  (define len (string-length s))
  (let loop ([i 0]
             [mode 'selector]
             [expect-property? #f]
             [paren-depth 0]
             [acc null])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j [new-mode mode] [new-expect-property? expect-property?] [new-paren-depth paren-depth])
         (loop j
               new-mode
               new-expect-property?
               new-paren-depth
               (cons (cons cls (substring s i j)) acc)))
       (cond
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\*))
          (emit 'comment (read-until s (+ i 2) "*/"))]
         [(or (char=? ch #\") (char=? ch #\'))
          (emit 'value (read-string-literal s i))]
         [(char-whitespace? ch)
          (emit 'plain (add1 i))]
         [(char=? ch #\@)
          (emit 'keyword
                (read-while s (add1 i) css-ident-char?))]
         [(char=? ch #\{)
          (emit 'punct (add1 i) 'declaration #t 0)]
         [(char=? ch #\})
          (emit 'punct (add1 i) 'selector #f 0)]
         [(char=? ch #\:)
          (if (and (eq? mode 'declaration) expect-property?)
              (emit 'punct (add1 i) mode #f paren-depth)
              (emit 'punct (add1 i)))]
         [(char=? ch #\;)
          (if (and (eq? mode 'declaration) (zero? paren-depth))
              (emit 'punct (add1 i) mode #t paren-depth)
              (emit 'value (add1 i)))]
         [(char=? ch #\()
          (if (and (eq? mode 'declaration) (not expect-property?))
              (emit 'punct (add1 i) mode #f (add1 paren-depth))
              (emit 'punct (add1 i)))]
         [(char=? ch #\))
          (if (and (eq? mode 'declaration) (not expect-property?) (positive? paren-depth))
              (emit 'punct (add1 i) mode #f (sub1 paren-depth))
              (emit 'punct (add1 i)))]
         [(member ch '(#\[ #\] #\, #\> #\+ #\~ #\* #\= #\|))
          (emit 'punct (add1 i))]
         [(char=? ch #\#)
          (define j (read-while s (add1 i) hex-digit?))
          (if (and (> j (add1 i))
                   (<= 3 (- j (add1 i)) 8))
              (emit 'value j)
              (emit 'punct (add1 i)))]
         [(or (char-numeric? ch)
              (and (member ch '(#\+ #\-))
                   (< (add1 i) len)
                   (let ([c2 (string-ref s (add1 i))])
                     (or (char-numeric? c2) (char=? c2 #\.)))))
          (emit 'value (read-css-number s i))]
         [(css-ident-start? ch)
          (define j (read-while s i css-ident-char?))
          (define cls
            (cond
              [(eq? mode 'selector) 'keyword]
              [expect-property? 'name]
              [else 'value]))
          (emit cls j)]
         [else
          (emit 'plain (add1 i))])])))

(define js-keywords
  '(break case catch class const continue debugger default delete do else export extends
          false finally for function if import in instanceof let new null of return super
          switch this throw true try typeof var void while with yield await
          as from static get set enum implements interface package private protected public))

(define js-literal-keywords
  '(true false null this super))

(define js-regex-context-keywords
  '(return throw case delete void typeof new in instanceof do else if while for switch catch await yield))

(define (js-ident-start? c)
  (or (char-alphabetic? c) (char=? c #\_) (char=? c #\$)))

(define (js-ident-char? c)
  (or (js-ident-start? c) (char-numeric? c)))

(define (read-js-digit-seq s i pred?)
  ;; Accept separators but only between digits (reject leading/trailing/consecutive _).
  (define len (string-length s))
  (let loop ([k i] [saw-digit? #f] [prev-us? #f])
    (if (>= k len)
        (if prev-us? (sub1 k) k)
        (let ([c (string-ref s k)])
          (cond
            [(pred? c) (loop (add1 k) #t #f)]
            [(char=? c #\_)
             (if (and saw-digit?
                      (not prev-us?)
                      (< (add1 k) len)
                      (pred? (string-ref s (add1 k))))
                 (loop (add1 k) saw-digit? #t)
                 k)]
            [else k])))))

(define (read-js-number s i)
  (define len (string-length s))
  (define j0
    (if (and (< i len) (member (string-ref s i) '(#\+ #\-)))
        (add1 i)
        i))
  (cond
    [(and (<= (+ j0 2) len)
          (char=? (string-ref s j0) #\0)
          (member (char-downcase (string-ref s (add1 j0))) '(#\x #\o #\b)))
     (define kind (char-downcase (string-ref s (add1 j0))))
     (define pred
       (case kind
         [(#\x) hex-digit?]
         [(#\o) (lambda (c) (member c '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)))]
         [else (lambda (c) (member c '(#\0 #\1)))]))
     (define jx (read-js-digit-seq s (+ j0 2) pred))
     (if (and (< jx len) (char=? (string-ref s jx) #\n))
         (add1 jx)
         jx)]
    [else
     (define has-dot-leading?
       (and (< j0 len)
            (char=? (string-ref s j0) #\.)
            (< (add1 j0) len)
            (char-numeric? (string-ref s (add1 j0)))))
     (define j-int
       (if has-dot-leading?
           j0
           (read-js-digit-seq s j0 char-numeric?)))
     (define-values (j-frac has-dot?)
       (if (and (< j-int len) (char=? (string-ref s j-int) #\.))
           (values (read-js-digit-seq s (add1 j-int) char-numeric?) #t)
           (values j-int #f)))
     (define-values (j-exp has-exp?)
       (if (and (< j-frac len) (member (string-ref s j-frac) '(#\e #\E)))
           (let* ([k0 (add1 j-frac)]
                  [k1 (if (and (< k0 len) (member (string-ref s k0) '(#\+ #\-)))
                          (add1 k0)
                          k0)]
                  [k2 (read-js-digit-seq s k1 char-numeric?)])
             (if (> k2 k1)
                 (values k2 #t)
                 (values j-frac #f)))
           (values j-frac #f)))
     (define j-end
       (if (and (< j-exp len)
                (char=? (string-ref s j-exp) #\n)
                (not has-dot?)
                (not has-exp?))
           (add1 j-exp)
           j-exp))
     (if (> j-end j0) j-end (add1 i))]))

(define (read-js-string-literal s i)
  ;; For recovery, stop at line boundary if the quote is not closed on this line.
  (define len (string-length s))
  (define q (string-ref s i))
  (let loop ([k (add1 i)] [escaped? #f])
    (cond
      [(>= k len) len]
      [else
       (define c (string-ref s k))
       (cond
         [escaped? (loop (add1 k) #f)]
         [(char=? c #\\) (loop (add1 k) #t)]
         [(char=? c q) (add1 k)]
         [(or (char=? c #\newline) (char=? c #\return)) k]
         [else (loop (add1 k) #f)])])))

(define (read-js-regex s i)
  (define len (string-length s))
  (let loop ([k (add1 i)] [escaped? #f] [in-class? #f])
    (cond
      [(>= k len) #f]
      [else
       (define c (string-ref s k))
       (cond
         [(or (char=? c #\newline) (char=? c #\return)) #f]
         [escaped? (loop (add1 k) #f in-class?)]
         [(char=? c #\\) (loop (add1 k) #t in-class?)]
         [(and (not in-class?) (char=? c #\/))
          (read-while s (add1 k) char-alphabetic?)]
         [(char=? c #\[) (loop (add1 k) #f #t)]
         [(and in-class? (char=? c #\])) (loop (add1 k) #f #f)]
         [else (loop (add1 k) #f in-class?)])])))

(define (prev-nonspace-char s i)
  (let loop ([k (sub1 i)])
    (cond
      [(negative? k) #f]
      [(char-whitespace? (string-ref s k)) (loop (sub1 k))]
      [else (string-ref s k)])))

(define (next-nonspace-index s i)
  (define len (string-length s))
  (let loop ([k i])
    (cond
      [(>= k len) #f]
      [(char-whitespace? (string-ref s k)) (loop (add1 k))]
      [else k])))

(define (next-nonspace-char s i)
  (define k (next-nonspace-index s i))
  (and k (string-ref s k)))

(define js-operators
  '(">>>=" "<<=" ">>=" "&&=" "||=" "??=" "**=" "===" "!=="
    ">>>" "<<" ">>" "==" "!=" "<=" ">=" "&&" "||" "??"
    "++" "--" "+=" "-=" "*=" "/=" "%=" "&=" "|=" "^=" "=>"
    "**" "?." "=" "<" ">" "!" "~" "+" "-" "*" "/" "%" "&"
    "|" "^" "?" ":" "@"))

(define (string-prefix-at? s i prefix)
  (define n (string-length prefix))
  (and (<= (+ i n) (string-length s))
       (string=? (substring s i (+ i n)) prefix)))

(define (read-js-operator s i)
  (for/or ([op (in-list js-operators)])
    (and (string-prefix-at? s i op)
         (+ i (string-length op)))))

(define (js-operator-can-start-regex? txt)
  (and (not (member txt '("++" "--")))
       (member txt
               '("=" "==" "===" "!=" "!==" "+" "-" "*" "/" "%" "+=" "-="
                 "*=" "/=" "%=" "&&" "||" "&&=" "||=" "&" "|" "^" "~"
                 "<" ">" "<=" ">=" "<<" ">>" ">>>" "<<=" ">>=" ">>>="
                 "=>" "??" "??=" "?." "?" ":" "!" "@"))))

(define js-condition-open-keywords
  '(if while for switch catch with))

(define (js-delimiter-char? ch)
  (member ch '(#\{ #\} #\( #\) #\[ #\] #\, #\; #\.)))

(define (js-ident-can-start-regex? id kw?)
  (and kw?
       (not (memq id js-literal-keywords))
       (memq id js-regex-context-keywords)))

(define (tsx-generic-angle-candidate? s i)
  ;; In JSX mode, avoid treating TS-like generic arrows as JSX tags.
  (define len (string-length s))
  (and (< i len)
       (char=? (string-ref s i) #\<)
       (let* ([j0 (next-nonspace-index s (add1 i))])
         (and j0
              (js-ident-start? (string-ref s j0))
              (let* ([j1 (read-while s j0 js-ident-char?)]
                     [j2 (next-nonspace-index s j1)])
                (and j2
                     (< j2 len)
                     (char=? (string-ref s j2) #\>)
                     (let ([j3 (next-nonspace-index s (add1 j2))])
                       (and j3 (< j3 len) (char=? (string-ref s j3) #\()))))))))

(define (jsx-ident-char? c)
  (or (js-ident-char? c) (member c '(#\- #\: #\.))))

(define (jsx-start-candidate? s i)
  (define len (string-length s))
  (and (< (add1 i) len)
       (let ([n (string-ref s (add1 i))])
         (or (char=? n #\/) (char=? n #\>) (char-alphabetic? n)))
       (let ([p (prev-nonspace-char s i)])
         (or (not p)
             (member p
                     '(#\( #\[ #\{ #\= #\, #\: #\? #\; #\! #\> #\| #\&
                       #\+ #\- #\* #\/))))))

(define (read-jsx-brace-expr s i)
  (define len (string-length s))
  (if (or (>= i len) (not (char=? (string-ref s i) #\{)))
      (values null (min len (add1 i)))
      (let* ([expr-start (add1 i)]
             [expr-end (js-template-expr-end s expr-start)]
             [expr-src (if (<= expr-end len) (substring s expr-start expr-end) "")]
             [inner (tokenize-js expr-src)])
        (values (append (list (cons 'punct "{"))
                        inner
                        (if (< expr-end len) (list (cons 'punct "}")) null))
                (if (< expr-end len) (add1 expr-end) len)))))

(define (tokenize-jsx-tag s i)
  (define len (string-length s))
  (define tokens null)
  (define (push cls a b)
    (when (< a b)
      (set! tokens (cons (cons cls (substring s a b)) tokens))))
  (define (skip-ws j)
    (define k (read-while s j char-whitespace?))
    (push 'plain j k)
    k)
  (define (read-attr-value j)
    (cond
      [(>= j len) j]
      [else
       (define q (string-ref s j))
       (cond
         [(or (char=? q #\") (char=? q #\'))
          (define end (read-string-literal s j))
          (push 'value j end)
          end]
         [(char=? q #\{)
          (define-values (expr k) (read-jsx-brace-expr s j))
          (set! tokens (append (reverse expr) tokens))
          k]
         [else
          (define end
            (read-while s j
                        (lambda (x)
                          (not (or (char-whitespace? x)
                                   (char=? x #\>)
                                   (char=? x #\/))))))
          (push 'value j end)
          end])]))
  (define j i)
  (push 'punct j (add1 j)) ; <
  (set! j (add1 j))
  (when (and (< j len) (char=? (string-ref s j) #\/))
    (push 'punct j (add1 j))
    (set! j (add1 j)))
  (cond
    [(and (< j len) (char=? (string-ref s j) #\>))
     (push 'punct j (add1 j))
     (values (reverse tokens) (add1 j))]
    [else
     (define name-start j)
     (set! j (read-while s j jsx-ident-char?))
     (if (> j name-start)
         (push 'keyword name-start j)
         (push 'plain name-start (min len (add1 name-start))))
     (let loop ()
       (cond
         [(>= j len) (values (reverse tokens) j)]
         [else
          (define c (string-ref s j))
          (define c2 (next-char s (add1 j)))
          (cond
            [(char-whitespace? c)
             (set! j (skip-ws j))
             (loop)]
            [(char=? c #\>)
             (push 'punct j (add1 j))
             (values (reverse tokens) (add1 j))]
            [(and c2 (char=? c #\/) (char=? c2 #\>))
             (push 'punct j (add1 j))
             (push 'punct (add1 j) (+ j 2))
             (values (reverse tokens) (+ j 2))]
            [(char=? c #\{)
             (define-values (expr k) (read-jsx-brace-expr s j))
             (set! tokens (append (reverse expr) tokens))
             (set! j k)
             (loop)]
            [else
             (define attr-start j)
             (set! j (read-while s j jsx-ident-char?))
             (if (= attr-start j)
                 (begin
                   (push 'plain j (add1 j))
                   (set! j (add1 j))
                   (loop))
                 (begin
                   (push 'name attr-start j)
                   (set! j (skip-ws j))
                   (when (and (< j len) (char=? (string-ref s j) #\=))
                     (push 'punct j (add1 j))
                     (set! j (add1 j))
                     (set! j (skip-ws j))
                     (set! j (read-attr-value j)))
                   (loop)))])]))]))

(define (js-template-expr-end s start)
  (define len (string-length s))
  (let loop ([k start]
             [depth 1]
             [in-single? #f]
             [in-double? #f]
             [in-backtick? #f]
             [in-line-comment? #f]
             [in-block-comment? #f]
             [escaped? #f])
    (cond
      [(>= k len) len]
      [else
       (define c (string-ref s k))
       (define c2 (next-char s (add1 k)))
       (cond
         [in-line-comment?
          (if (or (char=? c #\newline) (char=? c #\return))
              (loop (add1 k) depth in-single? in-double? in-backtick? #f in-block-comment? #f)
              (loop (add1 k) depth in-single? in-double? in-backtick? in-line-comment? in-block-comment? #f))]
         [in-block-comment?
          (if (and c2 (char=? c #\*) (char=? c2 #\/))
              (loop (+ k 2) depth in-single? in-double? in-backtick? #f #f #f)
              (loop (add1 k) depth in-single? in-double? in-backtick? #f #t #f))]
         [escaped?
          (loop (add1 k) depth in-single? in-double? in-backtick? #f #f #f)]
         [in-single?
          (cond
            [(char=? c #\\) (loop (add1 k) depth #t in-double? in-backtick? #f #f #t)]
            [(char=? c #\') (loop (add1 k) depth #f in-double? in-backtick? #f #f #f)]
            [else (loop (add1 k) depth #t in-double? in-backtick? #f #f #f)])]
         [in-double?
          (cond
            [(char=? c #\\) (loop (add1 k) depth in-single? #t in-backtick? #f #f #t)]
            [(char=? c #\") (loop (add1 k) depth in-single? #f in-backtick? #f #f #f)]
            [else (loop (add1 k) depth in-single? #t in-backtick? #f #f #f)])]
         [in-backtick?
          (cond
            [(char=? c #\\) (loop (add1 k) depth in-single? in-double? #t #f #f #t)]
            [(char=? c #\`) (loop (add1 k) depth in-single? in-double? #f #f #f #f)]
            [else (loop (add1 k) depth in-single? in-double? #t #f #f #f)])]
         [else
          (cond
            [(and c2 (char=? c #\/) (char=? c2 #\/))
             (loop (+ k 2) depth in-single? in-double? in-backtick? #t #f #f)]
            [(and c2 (char=? c #\/) (char=? c2 #\*))
             (loop (+ k 2) depth in-single? in-double? in-backtick? #f #t #f)]
            [(char=? c #\') (loop (add1 k) depth #t in-double? in-backtick? #f #f #f)]
            [(char=? c #\") (loop (add1 k) depth in-single? #t in-backtick? #f #f #f)]
            [(char=? c #\`) (loop (add1 k) depth in-single? in-double? #t #f #f #f)]
            [(char=? c #\{) (loop (add1 k) (add1 depth) in-single? in-double? in-backtick? #f #f #f)]
            [(char=? c #\})
             (if (= depth 1) k
                 (loop (add1 k) (sub1 depth) in-single? in-double? in-backtick? #f #f #f))]
            [else (loop (add1 k) depth in-single? in-double? in-backtick? #f #f #f)])])])))

(define (tokenize-js-template s i)
  (define len (string-length s))
  (define tokens null)
  (define (push cls a b)
    (when (< a b)
      (set! tokens (cons (cons cls (substring s a b)) tokens))))
  (define k (add1 i))
  (define seg-start i)
  (let loop ()
    (cond
      [(>= k len)
       (push 'value seg-start len)
       (values (reverse tokens) len)]
      [else
       (define c (string-ref s k))
       (define c2 (next-char s (add1 k)))
       (cond
         [(char=? c #\\)
          (set! k (if c2 (+ k 2) (add1 k)))
          (loop)]
         [(char=? c #\`)
          (push 'value seg-start (add1 k))
          (values (reverse tokens) (add1 k))]
         [(and c2 (char=? c #\$) (char=? c2 #\{))
          (push 'value seg-start k)
          (push 'punct k (+ k 2))
          (define expr-start (+ k 2))
          (define expr-end (js-template-expr-end s expr-start))
          (define expr-src
            (if (<= expr-end len)
                (substring s expr-start expr-end)
                ""))
          (define expr-tokens
            (if (>= (current-js-template-depth) 8)
                (list (cons 'plain expr-src))
                (parameterize ([current-js-template-depth (add1 (current-js-template-depth))])
                  (tokenize-js expr-src))))
          (set! tokens (append (reverse expr-tokens) tokens))
          (if (< expr-end len)
              (begin
                (push 'punct expr-end (add1 expr-end))
                (set! k (add1 expr-end))
                (set! seg-start k)
                (loop))
              (values (reverse tokens) len))]
         [else
          (set! k (add1 k))
          (loop)])])))

(define (tokenize-js s)
  (define len (string-length s))
  (define (has-fn-kind? brace-stack kinds)
    (for/or ([k (in-list brace-stack)])
      (and (symbol? k) (member k kinds))))
  (let loop ([i 0]
             [acc null]
             [can-start-regex? #t]
             [last-keyword #f]
             [paren-stack null]
             [decl-state 'none]
             [brace-stack null]
             [pending-fn-kind #f]
             [expect-params? #f]
             [pending-async? #f])
    (cond
      [(>= i len) (reverse acc)]
      [else
       (define ch (string-ref s i))
       (define (emit cls j
                     [next-can-start-regex? #f]
                     [next-last-keyword #f]
                     [next-paren-stack paren-stack]
                     [next-decl-state decl-state]
                     [next-brace-stack brace-stack]
                     [next-pending-fn-kind pending-fn-kind]
                     [next-expect-params? expect-params?]
                     [next-pending-async? pending-async?])
         (loop j
               (cons (cons cls (substring s i j)) acc)
               next-can-start-regex?
               next-last-keyword
               next-paren-stack
               next-decl-state
               next-brace-stack
               next-pending-fn-kind
               next-expect-params?
               next-pending-async?))
       (cond
         [(and (current-jsx?)
               (char=? ch #\<)
               (jsx-start-candidate? s i)
               (not (tsx-generic-angle-candidate? s i)))
          (define-values (jsx-tokens j) (tokenize-jsx-tag s i))
          (loop j (append (reverse jsx-tokens) acc) #f #f paren-stack decl-state
                brace-stack pending-fn-kind expect-params? pending-async?)]
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\*))
          (emit 'comment (read-until s (+ i 2) "*/") can-start-regex? last-keyword paren-stack decl-state)]
         [(and (char=? ch #\/)
               (< (add1 i) len)
               (char=? (string-ref s (add1 i)) #\/))
          (define j (read-until s (+ i 2) "\n"))
          (emit 'comment j can-start-regex? last-keyword paren-stack decl-state)]
         [(and (char=? ch #\#)
               (< (add1 i) len)
               (js-ident-start? (string-ref s (add1 i))))
          (define j (read-while s (add1 i) js-ident-char?))
          (emit 'private-name j #f #f paren-stack decl-state)]
         [(or (char=? ch #\") (char=? ch #\'))
          (emit 'value (read-js-string-literal s i) #f #f paren-stack decl-state)]
         [(char=? ch #\`)
          (define-values (template-tokens j) (tokenize-js-template s i))
          (loop j (append (reverse template-tokens) acc) #f #f paren-stack decl-state
                brace-stack pending-fn-kind expect-params? pending-async?)]
         [(char-whitespace? ch)
          (emit 'plain (add1 i) can-start-regex? last-keyword paren-stack decl-state)]
         [(or (char-numeric? ch)
              (and (char=? ch #\.)
                   (< (add1 i) len)
                   (char-numeric? (string-ref s (add1 i))))
              (and (member ch '(#\+ #\-))
                   (< (add1 i) len)
                   (let ([c2 (string-ref s (add1 i))])
                     (or (char-numeric? c2)
                         (char=? c2 #\.)))))
          (emit 'value (read-js-number s i) #f #f paren-stack decl-state)]
         [(js-ident-start? ch)
          (define j (read-while s i js-ident-char?))
          (define id (string->symbol (substring s i j)))
          (define in-async?
            (has-fn-kind? brace-stack '(fn-async fn-async-generator)))
          (define in-generator?
            (has-fn-kind? brace-stack '(fn-generator fn-async-generator)))
          (define base-kw? (memq id js-keywords))
          (define kw?
            (cond
              [(eq? id 'await) (and base-kw? in-async?)]
              [(eq? id 'yield) (and base-kw? in-generator?)]
              [else base-kw?]))
          (define prevc (prev-nonspace-char s i))
          (define nextc (next-nonspace-char s j))
          (define decl-name?
            (and (not kw?)
                 (member decl-state '(var-name function-name class-name))))
          (define object-key?
            (and (not kw?)
                 nextc
                 (char=? nextc #\:)
                 (member prevc '(#\{ #\,))))
          (define param-name?
            (and (not kw?)
                 (pair? paren-stack)
                 (eq? (car paren-stack) 'params)
                 (not object-key?)))
          (define prop-name?
            (and (not kw?) prevc (char=? prevc #\.)))
          (define method-name?
            (and prop-name? nextc (string=? (string nextc) "(")))
          (define static-block?
            (and kw? (eq? id 'static) nextc (char=? nextc #\{)))
          (define next-decl
            (cond
              [(and kw? (member id '(const let var))) 'var-name]
              [(and kw? (eq? id 'function)) 'function-name]
              [(and kw? (eq? id 'class)) 'class-name]
              [(and kw? (member id '(in of))) 'none]
              [decl-name? 'none]
              [else decl-state]))
          (define next-fn-kind
            (if (and kw? (eq? id 'function))
                (let* ([k (next-nonspace-index s j)]
                       [gen? (and k (< k len) (char=? (string-ref s k) #\*))])
                  (cond
                    [(and pending-async? gen?) 'fn-async-generator]
                    [pending-async? 'fn-async]
                    [gen? 'fn-generator]
                    [else 'fn-normal]))
                pending-fn-kind))
          (emit (cond [static-block? 'static-keyword]
                      [kw? 'keyword]
                      [object-key? 'object-key]
                      [method-name? 'method-name]
                      [prop-name? 'prop-name]
                      [param-name? 'param-name]
                      [decl-name? 'decl-name]
                      [else 'name])
                j
                (if kw? (js-ident-can-start-regex? id kw?) #f)
                (and kw? id)
                paren-stack
                next-decl
                brace-stack
                next-fn-kind
                (or expect-params? (and kw? (member id '(function catch))))
                (and kw? (eq? id 'async)))]
         [(char=? ch #\/)
          (cond
            [can-start-regex?
             (define j (read-js-regex s i))
             (if j
                 (emit 'value j #f)
                 (emit 'operator (or (read-js-operator s i) (add1 i))
                       (js-operator-can-start-regex? (substring s i (or (read-js-operator s i) (add1 i))))
                       #f paren-stack 'none))]
            [else
             (define j (or (read-js-operator s i) (add1 i)))
             (define op (substring s i j))
             (emit 'operator j (js-operator-can-start-regex? op) #f paren-stack 'none)])]
         [(js-delimiter-char? ch)
          (define j (add1 i))
          (cond
            [(char=? ch #\()
             (define open-kind
               (cond
                 [expect-params? 'params]
                 [(and last-keyword (memq last-keyword js-condition-open-keywords))
                  'condition]
                 [else 'group]))
             (emit 'punct j #t #f (cons open-kind paren-stack) decl-state
                   brace-stack pending-fn-kind #f pending-async?)]
            [(char=? ch #\{)
             (define new-brace
               (if pending-fn-kind
                   (cons pending-fn-kind brace-stack)
                   (cons #f brace-stack)))
             (emit 'punct j #t #f paren-stack decl-state
                   new-brace #f expect-params? pending-async?)]
            [(char=? ch #\))
             (define popped (and (pair? paren-stack) (car paren-stack)))
             (define rest-stack (if (pair? paren-stack) (cdr paren-stack) paren-stack))
             (emit 'punct j (eq? popped 'condition) #f rest-stack
                   (if (eq? decl-state 'var-name) 'none decl-state))]
            [(char=? ch #\})
             (emit 'punct j #f #f paren-stack 'none
                   (if (pair? brace-stack) (cdr brace-stack) brace-stack)
                   pending-fn-kind expect-params? pending-async?)]
            [(char=? ch #\])
             (emit 'punct j #f #f paren-stack 'none)]
            [(char=? ch #\;)
             (emit 'punct j #t #f paren-stack 'none
                   brace-stack pending-fn-kind #f #f)]
            [else
             (emit 'punct j #t #f paren-stack decl-state)])]
         [(read-js-operator s i)
          (define j (read-js-operator s i))
          (define op (substring s i j))
          (define next-decl
            (cond
              [(and (eq? decl-state 'var-name) (string=? op ",")) 'var-name]
              [(eq? decl-state 'var-name) 'none]
              [else decl-state]))
          (emit 'operator j (js-operator-can-start-regex? op) #f paren-stack next-decl)]
         [else
          (emit 'plain (add1 i) can-start-regex? last-keyword paren-stack decl-state)])])))

(define (string-ci-prefix-at? s i prefix)
  (define n (string-length prefix))
  (and (<= (+ i n) (string-length s))
       (string-ci=? (substring s i (+ i n)) prefix)))

(define (find-ci s start needle)
  (define n (string-length needle))
  (let loop ([i start])
    (cond
      [(> (+ i n) (string-length s)) #f]
      [(string-ci=? (substring s i (+ i n)) needle) i]
      [else (loop (add1 i))])))

(define (html-name-char? c)
  (or (char-alphabetic? c)
      (char-numeric? c)
      (member c '(#\- #\_ #\: #\.))))

(define (parse-html-tag s i)
  (define len (string-length s))
  (define tokens null)
  (define (push cls a b)
    (when (< a b)
      (set! tokens (cons (cons cls (substring s a b)) tokens))))

  (define j (+ i 1))
  (push 'punct i j) ; <
  (define closing?
    (and (< j len) (char=? (string-ref s j) #\/)))
  (when closing?
    (push 'punct j (add1 j))
    (set! j (add1 j)))

  (define name-start j)
  (set! j (read-while s j html-name-char?))
  (define tag-name
    (string-downcase (substring s name-start j)))
  (push 'keyword name-start j)

  (let loop ()
    (if (>= j len)
        (values (reverse tokens) j tag-name closing? #f)
        (let ((ch (string-ref s j)))
          (cond
            [(or (char=? ch #\newline) (char=? ch #\return))
             ;; Recover from malformed tags by stopping at line boundary.
             (values (reverse tokens) j tag-name closing? #f)]
            ((char-whitespace? ch)
             (let ((k (read-while s j char-whitespace?)))
               (push 'plain j k)
               (set! j k)
               (loop)))
            ((char=? ch #\>)
             (push 'punct j (add1 j))
             (values (reverse tokens) (add1 j) tag-name closing? #f))
            ((and (char=? ch #\/)
                  (< (add1 j) len)
                  (char=? (string-ref s (add1 j)) #\>))
             (push 'punct j (add1 j))
             (push 'punct (add1 j) (+ j 2))
             (values (reverse tokens) (+ j 2) tag-name closing? #t))
            (else
             (let ((attr-start j))
               (set! j (read-while s j html-name-char?))
               (if (= attr-start j)
                   (begin
                     (push 'plain j (add1 j))
                     (set! j (add1 j))
                     (loop))
                   (begin
                     (push 'name attr-start j)
                     (let ((ws-end (read-while s j char-whitespace?)))
                       (push 'plain j ws-end)
                       (set! j ws-end))
                     (when (and (< j len) (char=? (string-ref s j) #\=))
                       (push 'punct j (add1 j))
                       (set! j (add1 j))
                       (let ((ws2-end (read-while s j char-whitespace?)))
                         (push 'plain j ws2-end)
                         (set! j ws2-end))
                       (when (< j len)
                         (let ((q (string-ref s j)))
                           (if (or (char=? q #\") (char=? q #\'))
                               (let* ([end (read-string-literal s j)]
                                      [closed? (and (< (sub1 end) len)
                                                    (> end j)
                                                    (char=? (string-ref s (sub1 end)) q))])
                                 (if closed?
                                     (push 'value j end)
                                     (push 'plain j end))
                                 (set! j end))
                               (let ((end
                                      (read-while s j
                                                  (lambda (c)
                                                    (not (or (char-whitespace? c)
                                                             (char=? c #\>)
                                                             (char=? c #\/)))))))
                                 (push 'value j end)
                                 (set! j end))))))
                     (loop))))))))))

(define (find-script/style-close s start tag)
  (define len (string-length s))
  (define close-mark (string-append "</" tag))
  (let loop ([i start]
             [in-single? #f]
             [in-double? #f]
             [in-backtick? #f]
             [in-line-comment? #f]
             [in-block-comment? #f]
             [escaped? #f])
    (cond
      [(>= i len) len]
      [else
       (define c (string-ref s i))
       (define c2 (next-char s (add1 i)))
       (define close? (string-ci-prefix-at? s i close-mark))
       (cond
         [(and close?
               (not in-single?) (not in-double?) (not in-backtick?)
               (not in-line-comment?) (not in-block-comment?))
          i]
         [in-line-comment?
          (if (or (char=? c #\newline) (char=? c #\return))
              (loop (add1 i) in-single? in-double? in-backtick? #f in-block-comment? #f)
              (loop (add1 i) in-single? in-double? in-backtick? #t in-block-comment? #f))]
         [in-block-comment?
          (if (and c2 (char=? c #\*) (char=? c2 #\/))
              (loop (+ i 2) in-single? in-double? in-backtick? #f #f #f)
              (loop (add1 i) in-single? in-double? in-backtick? #f #t #f))]
         [escaped?
          (loop (add1 i) in-single? in-double? in-backtick? #f #f #f)]
         [in-single?
          (cond
            [(char=? c #\\) (loop (add1 i) #t in-double? in-backtick? #f #f #t)]
            [(char=? c #\') (loop (add1 i) #f in-double? in-backtick? #f #f #f)]
            [else (loop (add1 i) #t in-double? in-backtick? #f #f #f)])]
         [in-double?
          (cond
            [(char=? c #\\) (loop (add1 i) in-single? #t in-backtick? #f #f #t)]
            [(char=? c #\") (loop (add1 i) in-single? #f in-backtick? #f #f #f)]
            [else (loop (add1 i) in-single? #t in-backtick? #f #f #f)])]
         [in-backtick?
          (cond
            [(char=? c #\\) (loop (add1 i) in-single? in-double? #t #f #f #t)]
            [(char=? c #\`) (loop (add1 i) in-single? in-double? #f #f #f #f)]
            [else (loop (add1 i) in-single? in-double? #t #f #f #f)])]
         [else
          (cond
            [(and c2 (char=? c #\/) (char=? c2 #\/))
             (loop (+ i 2) in-single? in-double? in-backtick? #t #f #f)]
            [(and c2 (char=? c #\/) (char=? c2 #\*))
             (loop (+ i 2) in-single? in-double? in-backtick? #f #t #f)]
            [(char=? c #\') (loop (add1 i) #t in-double? in-backtick? #f #f #f)]
            [(char=? c #\") (loop (add1 i) in-single? #t in-backtick? #f #f #f)]
            [(char=? c #\`) (loop (add1 i) in-single? in-double? #t #f #f #f)]
            [else (loop (add1 i) #f #f #f #f #f #f)])])])))

(define (tokenize-html s)
  (define len (string-length s))
  (let loop ([i 0] [mode 'text] [acc null])
    (define (emit cls a b [new-mode mode])
      (if (< a b)
          (loop b new-mode (cons (cons cls (substring s a b)) acc))
          (loop b new-mode acc)))
    (cond
      [(>= i len) (reverse acc)]
      [(eq? mode 'script)
       (define close-i (find-script/style-close s i "script"))
       (define js-body-tokens
         (if (< i close-i)
             (insert-js-preview-tokens
              (tokenize-js (substring s i close-i))
              (current-html-script-preview?))
             null))
       (define acc2
         (if (< i close-i)
             (append (reverse js-body-tokens) acc)
             acc))
       (if (>= close-i len)
           (reverse acc2)
           (let-values ([(tag-tokens j _tag-name _closing? _self-closing?)
                         (parse-html-tag s close-i)])
             (loop j 'text (append (reverse tag-tokens) acc2))))]
      [(eq? mode 'style)
       (define close-i (find-script/style-close s i "style"))
       (define mode-val (current-html-style-preview-mode))
       (define enabled? (not (eq? mode-val 'none)))
       (define css-body-tokens
         (if (< i close-i)
             (let* ([base (tokenize-css (substring s i close-i))]
                    [with-color (insert-css-color-swatch-tokens base (and enabled? (current-html-style-color-swatch?)))]
                    [with-font (insert-css-font-preview-tokens with-color (and enabled? (current-html-style-font-preview?)))]
                    [with-dim (insert-css-dimension-preview-tokens with-font (and enabled? (current-html-style-dimension-preview?)))]
                    [with-token (insert-css-design-token-tokens with-dim enabled?)])
               (move-css-decorations-to-decl-end with-token))
             null))
       (define acc2
         (if (< i close-i)
             (append (reverse css-body-tokens) acc)
             acc))
       (if (>= close-i len)
           (reverse acc2)
           (let-values ([(tag-tokens j _tag-name _closing? _self-closing?)
                         (parse-html-tag s close-i)])
             (loop j 'text (append (reverse tag-tokens) acc2))))]
      [else
       (cond
         [(string-ci-prefix-at? s i "<!--")
          (define j (read-until s (+ i 4) "-->"))
          (emit 'comment i j)]
         [(and (string-ci-prefix-at? s i "<!")
               (not (string-ci-prefix-at? s i "<!--")))
          (define j (or (find-ci s i ">") (sub1 len)))
          (emit 'keyword i (min len (add1 j)))]
         [(char=? (string-ref s i) #\<)
          (let-values ([(tag-tokens j tag-name closing? self-closing?)
                        (parse-html-tag s i)])
            (define next-mode
              (cond
                [closing? 'text]
                [self-closing? 'text]
                [(string=? tag-name "script") 'script]
                [(string=? tag-name "style") 'style]
                [else 'text]))
            (loop j next-mode (append (reverse tag-tokens) acc)))]
         [(char=? (string-ref s i) #\&)
          (define semi (or (find-ci s i ";") (sub1 len)))
          (define end (min len (add1 semi)))
          (if (> end i)
              (emit 'value i end)
              (emit 'plain i (add1 i)))]
         [else
          (define next-special
            (let find ([k i])
              (cond
                [(>= k len) len]
                [(or (char=? (string-ref s k) #\<)
                     (char=? (string-ref s k) #\&))
                 k]
                [else (find (add1 k))])))
          (emit 'plain i next-special)])])))

(define (tokenize lang s)
  (case lang
    [(css) (tokenize-css s)]
    [(html) (tokenize-html s)]
    [(js) (tokenize-js s)]
    [else (list (cons 'plain s))]))

(define (split-lines style s)
  (cond
    [(regexp-match-positions #rx"(?:\r\n|\r|\n)" s)
     => (lambda (m)
          (append (split-lines style (substring s 0 (caar m)))
                  (list 'newline)
                  (split-lines style (substring s (cdar m)))))]
    [(regexp-match-positions #rx" +" s)
     => (lambda (m)
          (append (split-lines style (substring s 0 (caar m)))
                  (list (hspace (- (cdar m) (caar m))))
                  (split-lines style (substring s (cdar m)))))]
    [else
     (define e (if (equal? s "") "" (element style s)))
     (if (equal? e "") null (list e))]))

(define (escape->element v)
  (cond
    [(element? v) v]
    [(list? v) (make-element #f v)]
    [else (make-element #f (list v))]))

(define (consume-css-color-function tokens)
  (define first (and (pair? tokens) (car tokens)))
  (define second (and (pair? (cdr tokens)) (cadr tokens)))
  (cond
    [(and first second
          (eq? (car first) 'value)
          (or (set-member? css-color-functions (string-downcase (cdr first)))
              (set-member? css-gradient-functions (string-downcase (cdr first))))
          (eq? (car second) 'punct)
          (string=? (cdr second) "("))
     (define fn-name (string-downcase (cdr first)))
     (let loop ([rest (cddr tokens)]
                [depth 1]
                [taken-rev (list second first)])
       (cond
         [(null? rest) (values #f tokens #f #f)]
         [else
          (define t (car rest))
          (define cls (car t))
          (define txt (cdr t))
          (define new-depth
            (cond
              [(and (eq? cls 'punct) (string=? txt "(")) (add1 depth)]
              [(and (eq? cls 'punct) (string=? txt ")")) (sub1 depth)]
              [else depth]))
          (define new-taken-rev (cons t taken-rev))
          (if (zero? new-depth)
              (let ([taken (reverse new-taken-rev)])
                (values taken
                        (cdr rest)
                        (apply string-append (map cdr taken))
                        fn-name))
              (loop (cdr rest) new-depth new-taken-rev))]))]
    [else (values #f tokens #f #f)]))

(define (insert-css-color-swatch-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail color-fn fn-name) (consume-css-color-function rest))
           (cond
             [taken
              (define acc2 (append (reverse taken) acc))
              (if (and color-fn (safe-css-color-literal? color-fn))
                  (loop tail (cons (cons (if (set-member? css-gradient-functions fn-name)
                                             'swatch-gradient
                                             'swatch)
                                         color-fn)
                                   acc2))
                  (loop tail acc2))]
             [else
              (define t (car rest))
              (define cls (car t))
              (define txt (cdr t))
              (define add-swatch?
                (and (eq? cls 'value)
                     (css-color-literal? txt)
                     (safe-css-color-literal? txt)))
              (if add-swatch?
                  (loop (cdr rest) (cons (cons 'swatch txt) (cons t acc)))
                  (loop (cdr rest) (cons t acc)))])]))))

(define (consume-css-property-decl tokens property?)
  (define first (and (pair? tokens) (car tokens)))
  (cond
    [(and first
          (eq? (car first) 'name)
          (property? (string-downcase (cdr first))))
     (let loop ([rest (cdr tokens)]
                [seen-colon? #f]
                [taken-rev (list first)]
                [value-rev null])
       (cond
         [(null? rest)
          (if seen-colon?
              (values (reverse taken-rev) null
                      (normalize-css-font-family
                       (apply string-append (map cdr (reverse value-rev)))))
              (values #f tokens #f))]
         [else
          (define t (car rest))
          (define cls (car t))
          (define txt (cdr t))
          (cond
            [(not seen-colon?)
             (cond
               [(and (eq? cls 'punct) (string=? txt ":"))
                (loop (cdr rest) #t (cons t taken-rev) value-rev)]
               [(and (eq? cls 'punct) (or (string=? txt ";") (string=? txt "}")))
                (values #f tokens #f)]
               [else
                (loop (cdr rest) #f (cons t taken-rev) value-rev)])]
            [else
             (cond
               [(and (eq? cls 'punct) (or (string=? txt ";") (string=? txt "}")))
                (values (reverse (cons t taken-rev))
                        (cdr rest)
                        (normalize-css-decl-value
                         (apply string-append (map cdr (reverse value-rev)))))]
               [else
                (loop (cdr rest) #t (cons t taken-rev) (cons t value-rev))])])]))]
    [else (values #f tokens #f)]))

(define (consume-css-font-family-decl tokens)
  (consume-css-property-decl
   tokens
   (lambda (prop) (string=? prop "font-family"))))

(define (consume-css-dimension-decl tokens)
  (consume-css-property-decl
   tokens
   (lambda (prop)
     (or (set-member? css-spacing-properties prop)
         (string=? prop "border-radius")
         (set-member? css-blur-properties prop)))))

(define (insert-css-font-preview-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail family-text) (consume-css-font-family-decl rest))
           (if taken
               (let ([acc2 (append (reverse taken) acc)])
                 (if (safe-css-font-family-literal? family-text)
                     (loop tail (cons (cons 'font-preview family-text) acc2))
                     (loop tail acc2)))
               (loop (cdr rest) (cons (car rest) acc)))]))))

(define (insert-css-dimension-preview-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail value-text) (consume-css-dimension-decl rest))
           (if taken
               (let* ([acc2 (append (reverse taken) acc)]
                      [prop (string-downcase (cdr (car taken)))])
                 (cond
                   [(set-member? css-spacing-properties prop)
                    (define width (spacing-width-px value-text))
                    (if width
                        (loop tail (cons (cons 'spacing-preview (cons width value-text)) acc2))
                        (loop tail acc2))]
                   [(set-member? css-blur-properties prop)
                    (define blur-arg (extract-blur-arg value-text))
                    (define width (and blur-arg (spacing-width-px blur-arg)))
                    (if width
                        (loop tail (cons (cons 'spacing-preview (cons width (format "blur(~a)" blur-arg))) acc2))
                        (loop tail acc2))]
                   [(string=? prop "border-radius")
                    (define radius (radius-size-px value-text))
                    (if radius
                        (loop tail (cons (cons 'radius-preview (cons radius value-text)) acc2))
                        (loop tail acc2))]
                   [else
                   (loop tail acc2)]))
               (loop (cdr rest) (cons (car rest) acc)))]))))

(define (consume-css-custom-token-decl tokens)
  (define-values (taken tail value-text)
    (consume-css-property-decl
     tokens
     (lambda (prop)
       (and (>= (string-length prop) 2)
            (string-prefix? prop "--")))))
  (if taken
      (values taken tail (string-downcase (cdr (car taken))) value-text)
      (values #f tokens #f #f)))

(define (insert-css-design-token-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define-values (taken tail token-name value-text) (consume-css-custom-token-decl rest))
           (cond
             [taken
              (define acc2 (append (reverse taken) acc))
              (define maybe-color
                (cond
                  [(css-color-literal? (string-trim value-text)) (string-trim value-text)]
                  [else #f]))
              (if maybe-color
                  (loop tail (cons (cons 'token-def (cons token-name maybe-color)) acc2))
                  (loop tail acc2))]
             [else
              (define t1 (car rest))
              (define t2 (if (>= (length rest) 2) (cadr rest) #f))
              (define t3 (if (>= (length rest) 3) (caddr rest) #f))
              (if (and t1 t2 t3
                       (member (car t1) '(value name keyword))
                       (string-ci=? (cdr t1) "var")
                       (eq? (car t2) 'punct)
                       (string=? (cdr t2) "(")
                       (member (car t3) '(name value))
                       (string-prefix? (string-downcase (cdr t3)) "--"))
                  (loop (cdr rest)
                        (cons (cons 'token-ref (string-downcase (cdr t3)))
                              (cons t1 acc)))
                  (loop (cdr rest) (cons (car rest) acc)))])]))))

(define (insert-js-preview-tokens tokens enabled?)
  (if (not enabled?)
      tokens
      (let loop ([rest tokens] [acc null])
        (cond
          [(null? rest) (reverse acc)]
          [else
           (define t (car rest))
           (define cls (car t))
           (define txt (cdr t))
           (define is-regex?
             (and (eq? cls 'value)
                  (regexp-match? #px"^/.+/[a-zA-Z]*$" txt)))
           (define is-template?
             (and (eq? cls 'value)
                  (regexp-match? #px"`" txt)))
           (cond
             [is-regex?
              (loop (cdr rest) (cons (cons 'js-regex-preview "") (cons t acc)))]
             [is-template?
              (loop (cdr rest) (cons (cons 'js-template-preview "") (cons t acc)))]
             [else
              (loop (cdr rest) (cons t acc))])]))))

(define css-decoration-classes
  ;; Only color/gradient swatches need relocation to declaration ends.
  (set 'swatch 'swatch-gradient))

(define (move-css-decorations-to-decl-end tokens)
  (let loop ([rest tokens] [pending null] [acc null])
    (cond
      [(null? rest)
       (reverse (append (reverse pending) acc))]
      [else
       (define t (car rest))
       (define cls (car t))
       (cond
         [(set-member? css-decoration-classes cls)
          (loop (cdr rest) (cons t pending) acc)]
         [(and (eq? cls 'punct) (string=? (cdr t) ";"))
          (loop (cdr rest) null (append (reverse pending) (cons t acc)))]
         [(and (eq? cls 'punct) (string=? (cdr t) "}"))
          ;; If final declaration omits ';', show decorations right before '}'.
          (loop (cdr rest) null (cons t (append (reverse pending) acc)))]
         [else
          (loop (cdr rest) pending (cons t acc))])])))

(define js-global-objects
  (list->set
   '("Array" "Object" "String" "Number" "Boolean" "Promise"
     "Map" "Set" "WeakMap" "WeakSet"
     "Date" "RegExp" "Math" "JSON"
     "URL" "URLSearchParams" "Error" "TypeError" "SyntaxError"
     "Symbol" "BigInt" "Intl")))

(define js-webapi-objects
  (list->set
   '("CanvasRenderingContext2D"
     "WebGLRenderingContext"
     "WebGL2RenderingContext"
     "ImageBitmapRenderingContext"
     "console"
     "Document" "Window" "Element" "HTMLElement" "Node" "EventTarget"
     "Navigator" "Location" "History")))

(define js-known-objects
  (set-union js-global-objects js-webapi-objects))

(define js-method-owner-index
  ;; Maps lowercase method name -> possible owning global/API objects.
  (let ([pairs
         '(("map" . "Array") ("filter" . "Array") ("reduce" . "Array")
           ("forEach" . "Array") ("includes" . "Array") ("find" . "Array")
           ("findIndex" . "Array") ("some" . "Array") ("every" . "Array")
           ("flatMap" . "Array") ("join" . "Array") ("slice" . "Array")
           ("push" . "Array") ("pop" . "Array") ("shift" . "Array")
           ("unshift" . "Array") ("sort" . "Array") ("toSorted" . "Array")
           ("toReversed" . "Array") ("toSpliced" . "Array") ("at" . "Array")
           ("entries" . "Array") ("keys" . "Array") ("values" . "Array")
           ("startsWith" . "String") ("endsWith" . "String")
           ("split" . "String") ("match" . "String") ("replace" . "String")
           ("test" . "RegExp") ("exec" . "RegExp")
           ("parse" . "JSON") ("stringify" . "JSON")
           ("max" . "Math") ("min" . "Math") ("round" . "Math")
           ("floor" . "Math") ("ceil" . "Math") ("abs" . "Math")
           ("random" . "Math")
           ("then" . "Promise") ("catch" . "Promise") ("finally" . "Promise")
           ("all" . "Promise") ("allSettled" . "Promise")
           ("race" . "Promise") ("any" . "Promise")
           ("resolve" . "Promise") ("reject" . "Promise")
           ("get" . "Map") ("set" . "Map") ("has" . "Map")
           ("delete" . "Map") ("clear" . "Map")
           ("assign" . "Object") ("fromEntries" . "Object")
           ("querySelector" . "Document")
           ("querySelectorAll" . "Document")
           ("getElementById" . "Document")
           ("getElementsByClassName" . "Document")
           ("getElementsByTagName" . "Document")
           ("createElement" . "Document")
           ("createTextNode" . "Document")
           ("matches" . "Element") ("closest" . "Element")
           ("setAttribute" . "Element") ("getAttribute" . "Element")
           ("hasAttribute" . "Element") ("removeAttribute" . "Element")
           ("appendChild" . "Node") ("removeChild" . "Node")
           ("insertBefore" . "Node") ("replaceChild" . "Node")
           ("cloneNode" . "Node")
           ("addEventListener" . "EventTarget")
           ("removeEventListener" . "EventTarget")
           ("dispatchEvent" . "EventTarget")
           ("requestAnimationFrame" . "Window")
           ("cancelAnimationFrame" . "Window")
           ("setTimeout" . "Window") ("clearTimeout" . "Window")
           ("setInterval" . "Window") ("clearInterval" . "Window")
           ("log" . "console") ("info" . "console") ("warn" . "console")
           ("error" . "console") ("debug" . "console")
           ("dir" . "console") ("table" . "console")
           ("trace" . "console") ("assert" . "console")
           ("group" . "console") ("groupCollapsed" . "console")
           ("groupEnd" . "console")
           ("time" . "console") ("timeLog" . "console") ("timeEnd" . "console")
           ("count" . "console") ("countReset" . "console")
           ("clear" . "console"))])
    (for/fold ([h (hash)])
              ([p (in-list pairs)])
      (hash-update h
                   (string-downcase (car p))
                   (lambda (owners) (cons (cdr p) owners))
                   null))))

(define (js-known-object? s)
  (set-member? js-known-objects s))

(define (js-global-object? s)
  (set-member? js-global-objects s))

(define (js-object-url owner)
  (if (js-global-object? owner)
      (format "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/~a"
              owner)
      (format "https://developer.mozilla.org/en-US/docs/Web/API/~a"
              owner)))

(define (js-object-method-url owner method)
  (if (js-global-object? owner)
      (format "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/~a/~a"
              owner method)
      (let ([canonical-owner
             (cond
               [(string=? owner "console") "console"]
               [(member method '("addEventListener" "removeEventListener" "dispatchEvent"))
                "EventTarget"]
               [(member method '("appendChild" "removeChild" "insertBefore" "replaceChild" "cloneNode"))
                "Node"]
               [else owner])])
        (if (string=? canonical-owner "console")
            (format "https://developer.mozilla.org/en-US/docs/Web/API/console/~a_static"
                    method)
            (format "https://developer.mozilla.org/en-US/docs/Web/API/~a/~a"
                    canonical-owner method)))))

(define (token-nonplain? t)
  (not (eq? (car t) 'plain)))

(define (token-class-in? t classes)
  (and t (memq (car t) classes)))

(define (next-nonplain-token rest)
  (let loop ([xs rest])
    (cond
      [(null? xs) #f]
      [(token-nonplain? (car xs)) (car xs)]
      [else (loop (cdr xs))])))

(define (resolve-js-owner name object-aliases)
  (or (and (js-known-object? name) name)
      (hash-ref object-aliases name #f)))

(define (strip-js-string-quotes s)
  (if (and (>= (string-length s) 2)
           (let ([f (string-ref s 0)]
                 [l (string-ref s (sub1 (string-length s)))])
             (and (or (char=? f #\") (char=? f #\'))
                  (char=? f l))))
      (substring s 1 (sub1 (string-length s)))
      s))

(define (canvas-context-owner-from-token t)
  (and t
       (eq? (car t) 'value)
       (let ([k (string-downcase (strip-js-string-quotes (cdr t)))])
         (cond
           [(member k '("2d")) "CanvasRenderingContext2D"]
           [(member k '("webgl")) "WebGLRenderingContext"]
           [(member k '("webgl2")) "WebGL2RenderingContext"]
           [(member k '("bitmaprenderer")) "ImageBitmapRenderingContext"]
           [else #f]))))

(define (rhs-context-owner np start)
  ;; Heuristic: detect ...getContext("<kind>") on RHS.
  (define max-j (min (length np) (+ start 28)))
  (let loop ([j start])
    (cond
      [(>= j max-j) #f]
      [else
       (define tj (list-ref np j))
       (define t1 (and (< (add1 j) (length np)) (list-ref np (add1 j))))
       (define t2 (and (< (+ j 2) (length np)) (list-ref np (+ j 2))))
       (define t3 (and (< (+ j 3) (length np)) (list-ref np (+ j 3))))
       (cond
         [(and (token-class-in? tj '(method-name prop-name name))
               (string=? (cdr tj) "getContext")
               t1 t2
               (eq? (car t1) 'punct) (string=? (cdr t1) "("))
          (or (canvas-context-owner-from-token t2)
              (and t3 (canvas-context-owner-from-token t3))
              #f)]
         [(and (eq? (car tj) 'punct) (or (string=? (cdr tj) ";") (string=? (cdr tj) ",")))
          #f]
         [else (loop (add1 j))])])))

(define (rhs-dom-owner np start)
  ;; Heuristic: detect common DOM-returning expressions on RHS.
  (define max-j (min (length np) (+ start 28)))
  (let loop ([j start])
    (cond
      [(>= j max-j) #f]
      [else
       (define tj (list-ref np j))
       (define t1 (and (< (add1 j) (length np)) (list-ref np (add1 j))))
       (define t2 (and (< (+ j 2) (length np)) (list-ref np (+ j 2))))
       (define t3 (and (< (+ j 3) (length np)) (list-ref np (+ j 3))))
       (define t4 (and (< (+ j 4) (length np)) (list-ref np (+ j 4))))
       (define t5 (and (< (+ j 5) (length np)) (list-ref np (+ j 5))))
       (cond
         ;; document.querySelector(...), el.querySelector(...)
         [(and (token-class-in? tj '(name decl-name prop-name object-key keyword))
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(method-name prop-name name))
               (member (cdr t2) '("querySelector" "querySelectorAll"
                                  "getElementById" "createElement")))
          "Element"]
         ;; document.body, document.documentElement
         [(and (token-class-in? tj '(name decl-name prop-name object-key keyword))
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(name prop-name method-name))
               (member (cdr t2) '("body" "documentElement")))
          "HTMLElement"]
         ;; document, window, navigator, history, location aliases
         [(and (token-class-in? tj '(name decl-name prop-name keyword))
               (member (cdr tj) '("document" "window" "navigator" "history" "location")))
          (case (string->symbol (cdr tj))
            [(document) "Document"]
            [(window) "Window"]
            [(navigator) "Navigator"]
            [(history) "History"]
            [else "Location"])]
         ;; window.document
         [(and (token-class-in? tj '(name decl-name keyword))
               (string=? (cdr tj) "window")
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(name prop-name))
               (string=? (cdr t2) "document"))
          "Document"]
         ;; event.target / event.currentTarget
         [(and (token-class-in? tj '(name decl-name))
               (member (cdr tj) '("event" "ev" "e"))
               (token-class-in? t1 '(punct)) (string=? (cdr t1) ".")
               (token-class-in? t2 '(name prop-name))
               (member (cdr t2) '("target" "currentTarget")))
          "EventTarget"]
         [(and (eq? (car tj) 'punct) (or (string=? (cdr tj) ";") (string=? (cdr tj) ",")))
          #f]
         [else
          (loop (add1 j))])])))

(define (js-token-literal-owner t)
  (and t
       (eq? (car t) 'value)
       (let ([txt (cdr t)])
         (cond
           [(regexp-match? #px"^['\"]" txt) "String"]
           [(regexp-match? #px"^`" txt) "String"]
           [(regexp-match? #px"^/" txt) "RegExp"]
           [(regexp-match? #px"^[+-]?(?:[0-9]|\\.[0-9])" txt) "Number"]
           [else #f]))))

(define (build-js-alias-env tokens)
  ;; Returns two values:
  ;;   object-aliases : alias -> built-in object name (e.g. m -> Math)
  ;;   method-aliases : alias -> fully resolved method URL (e.g. parse -> .../JSON/parse)
  (define np (filter token-nonplain? tokens))
  (define len (length np))
  (define (tok i) (and (<= 0 i) (< i len) (list-ref np i)))
  (define object-aliases0
    (hash "document" "Document"
          "window" "Window"
          "console" "console"
          "navigator" "Navigator"
          "location" "Location"
          "history" "History"))
  (let loop ([i 0] [object-aliases object-aliases0] [method-aliases (hash)])
    (if (>= i len)
        (values object-aliases method-aliases)
        (let* ([t0 (tok i)]
               [t1 (tok (+ i 1))]
               [t2 (tok (+ i 2))]
               [t3 (tok (+ i 3))]
               [t4 (tok (+ i 4))]
               [t5 (tok (+ i 5))]
               [kw? (and t0 (eq? (car t0) 'keyword)
                         (member (cdr t0) '("const" "let" "var")))])
          (cond
            ;; const p = JSON.parse;
            [(and kw?
                  (token-class-in? t1 '(decl-name name))
                  (and t2 (eq? (car t2) 'operator) (string=? (cdr t2) "="))
                  (token-class-in? t3 '(name decl-name))
                  (resolve-js-owner (cdr t3) object-aliases)
                  (and t4 (eq? (car t4) 'punct) (string=? (cdr t4) "."))
                  (token-class-in? t5 '(method-name prop-name name)))
             (define owner (resolve-js-owner (cdr t3) object-aliases))
             (if owner
                 (loop (add1 i)
                       object-aliases
                       (hash-set method-aliases (cdr t1)
                                 (js-object-method-url owner (cdr t5))))
                 (loop (add1 i) object-aliases method-aliases))]
            ;; const m = Math;
            [(and kw?
                  (token-class-in? t1 '(decl-name name))
                  (and t2 (eq? (car t2) 'operator) (string=? (cdr t2) "="))
                  (token-class-in? t3 '(name decl-name prop-name object-key))
                  (resolve-js-owner (cdr t3) object-aliases)
                  (not (and t4 (eq? (car t4) 'punct) (string=? (cdr t4) "."))))
             (loop (add1 i)
                   (hash-set object-aliases (cdr t1) (resolve-js-owner (cdr t3) object-aliases))
                   method-aliases)]
            ;; const ctx = canvas.getContext("2d");
            [(and kw?
                  (token-class-in? t1 '(decl-name name))
                  (and t2 (eq? (car t2) 'operator) (string=? (cdr t2) "=")))
             (define owner (or (rhs-context-owner np (+ i 3))
                               (rhs-dom-owner np (+ i 3))))
             (if owner
                 (loop (add1 i)
                       (hash-set object-aliases (cdr t1) owner)
                       method-aliases)
                 (loop (add1 i) object-aliases method-aliases))]
            ;; const {parse} = JSON;
            [(and kw? t1 (eq? (car t1) 'punct) (string=? (cdr t1) "{"))
             (let parse-destruct ([j (+ i 2)] [names null])
               (define tj (tok j))
               (cond
                 [(or (not tj)
                      (and (eq? (car tj) 'punct) (string=? (cdr tj) "}")))
                  (define close-j j)
                  (define t-op (tok (+ close-j 1)))
                  (define t-rhs (tok (+ close-j 2)))
                  (define owner
                    (and t-op t-rhs
                         (eq? (car t-op) 'operator)
                         (string=? (cdr t-op) "=")
                         (token-class-in? t-rhs '(name decl-name))
                         (resolve-js-owner (cdr t-rhs) object-aliases)))
                  (if owner
                      (let ([method-aliases*
                             (for/fold ([h method-aliases])
                                       ([n (in-list (reverse names))])
                               (hash-set h n (js-object-method-url owner n)))])
                        (loop (add1 i) object-aliases method-aliases*))
                      (loop (add1 i) object-aliases method-aliases))]
                 [(token-class-in? tj '(name decl-name))
                  (define tcolon (tok (+ j 1)))
                  (define talias (tok (+ j 2)))
                  (cond
                    ;; {parse: p}
                    [(and tcolon talias
                          (eq? (car tcolon) 'punct) (string=? (cdr tcolon) ":")
                          (token-class-in? talias '(name decl-name)))
                     (parse-destruct (+ j 3) (cons (cdr talias) names))]
                    [else
                     (parse-destruct (add1 j) (cons (cdr tj) names))])]
                 [else (parse-destruct (add1 j) names)]))]
            [else (loop (add1 i) object-aliases method-aliases)])))))

(define (js-infer-method-owner prev1 prev2 object-aliases)
  (and prev1 prev2
       (eq? (car prev1) 'punct)
       (string=? (cdr prev1) ".")
       (or (and (token-class-in? prev2 '(name decl-name prop-name object-key keyword))
                (resolve-js-owner (cdr prev2) object-aliases))
           (js-token-literal-owner prev2)
           (and (eq? (car prev2) 'punct) (string=? (cdr prev2) "]") "Array")
           (and (eq? (car prev2) 'punct) (string=? (cdr prev2) "}") "Object"))))

(define (js-contextual-mdn-url lang cls txt prev1 prev2 next1 object-aliases method-aliases)
  (define direct (mdn-url-for-token lang cls txt))
  (cond
    [direct direct]
    [(not (memq lang '(js html))) #f]
    [(and (token-class-in? (cons cls txt) '(name decl-name prop-name method-name object-key))
          (hash-ref method-aliases txt #f))
     (hash-ref method-aliases txt #f)]
    [(and (memq cls '(name decl-name prop-name method-name object-key))
          (resolve-js-owner txt object-aliases))
     (js-object-url (resolve-js-owner txt object-aliases))]
    [(eq? cls 'method-name)
     (define owner (js-infer-method-owner prev1 prev2 object-aliases))
     (cond
       [owner (js-object-method-url owner txt)]
       [else
        (define owners (hash-ref js-method-owner-index (string-downcase txt) null))
        (and (= (length owners) 1)
             (js-object-method-url (car owners) txt))])]
    ;; Alias call case: const parse = JSON.parse; parse(...)
    [(and (memq cls '(name decl-name))
          next1
          (eq? (car next1) 'punct)
          (string=? (cdr next1) "("))
     (hash-ref method-aliases txt #f)]
    [else #f]))

(define (tokens->pieces lang tokens
                        #:color-swatch? [color-swatch? #f]
                        #:font-preview? [font-preview? #f]
                        #:dimension-preview? [dimension-preview? #f]
                        #:mdn-links? [mdn-links? #t]
                        #:preview-tooltips? [preview-tooltips? #t]
                        #:preview-mode [preview-mode 'always])
  (define mode (normalize-preview-mode 'tokens->pieces preview-mode))
  (define css-preview-enabled? (not (eq? mode 'none)))
  (define tokens*
    (if (eq? lang 'css)
        (insert-css-color-swatch-tokens tokens (and color-swatch? css-preview-enabled?))
        tokens))
  (define tokens**
    (if (eq? lang 'css)
        (insert-css-font-preview-tokens tokens* (and font-preview? css-preview-enabled?))
        tokens*))
  (define tokens***
    (if (eq? lang 'css)
        (insert-css-dimension-preview-tokens tokens** (and dimension-preview? css-preview-enabled?))
        tokens**))
  (define tokens****
    (if (eq? lang 'css)
        (insert-css-design-token-tokens tokens*** css-preview-enabled?)
        tokens***))
  (define tokens*****
    (if (eq? lang 'css)
        (move-css-decorations-to-decl-end tokens****)
        tokens****))
  (define-values (js-object-aliases js-method-aliases)
    (if (memq lang '(js html))
        (build-js-alias-env tokens*****)
        (values (hash) (hash))))
  (let loop ([rest tokens*****] [acc null] [runtime-inserted? #f] [i 0])
    (cond
      [(null? rest) (reverse acc)]
      [else
        (define t (car rest))
        (define cls (car t))
        (define prev1
          (let loop-prev ([k (sub1 i)])
            (cond
              [(negative? k) #f]
              [else
               (define tk (list-ref tokens***** k))
               (if (token-nonplain? tk) tk (loop-prev (sub1 k)))])))
        (define prev2
          (and prev1
               (let ([k1
                      (let loop-prev ([k (sub1 i)])
                        (cond
                          [(negative? k) #f]
                          [else
                           (define tk (list-ref tokens***** k))
                           (if (token-nonplain? tk) k (loop-prev (sub1 k)))]))])
                 (and k1
                      (let loop-prev2 ([k (sub1 k1)])
                        (cond
                          [(negative? k) #f]
                          [else
                           (define tk (list-ref tokens***** k))
                           (if (token-nonplain? tk) tk (loop-prev2 (sub1 k)))]))))))
        (define next1 (next-nonplain-token (cdr rest)))
       (cond
         [(eq? cls 'escape)
         (loop (cdr rest) (append (reverse (list (escape->element (cdr t)))) acc) runtime-inserted? (add1 i))]
         [(eq? cls 'swatch)
          (if runtime-inserted?
              (loop (cdr rest) (append (reverse (list (css-swatch-element (cdr t) mode))) acc) #t (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-swatch-element (cdr t) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'swatch-gradient)
          (if runtime-inserted?
              (loop (cdr rest) (append (reverse (list (css-gradient-swatch-element (cdr t) mode))) acc) #t (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-gradient-swatch-element (cdr t) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'spacing-preview)
          (define p (cdr t))
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-spacing-preview-element (car p) (cdr p) mode))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-spacing-preview-element (car p) (cdr p) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'radius-preview)
          (define p (cdr t))
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-radius-preview-element (car p) (cdr p) mode))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-radius-preview-element (car p) (cdr p) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'token-def)
          (define p (cdr t))
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-token-def-element (car p) (cdr p)))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-token-def-element (car p) (cdr p)))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'token-ref)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-token-ref-element (cdr t)))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-token-ref-element (cdr t)))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'js-regex-preview)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (js-regex-preview-element))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (js-regex-preview-element))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'js-template-preview)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (js-template-preview-element))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (js-template-preview-element))))
                            acc)
                    #t
                    (add1 i)))]
         [(eq? cls 'font-preview)
          (if runtime-inserted?
              (loop (cdr rest)
                    (append (reverse (list (css-font-preview-element (cdr t) mode))) acc)
                    #t
                    (add1 i))
              (loop (cdr rest)
                    (append (reverse (append (runtime-prefix-elements)
                                             (list (css-font-preview-element (cdr t) mode))))
                            acc)
                    #t
                    (add1 i)))]
         [else
          (define txt (cdr t))
          (define token-style (style-for lang cls))
          (define maybe-url
            (and mdn-links?
                 (not (regexp-match? #px"[[:space:]]" txt))
                 (js-contextual-mdn-url lang cls txt prev1 prev2 next1
                                        js-object-aliases js-method-aliases)))
          (define pieces
            (if maybe-url
                (list (hyperlink maybe-url #:style mdn-link-style #:underline? #f
                                 (element token-style txt)))
                (split-lines token-style txt)))
          (loop (cdr rest)
                (append (reverse pieces) acc)
                runtime-inserted?
                (add1 i))])])))

(define (break-list lst delim)
  (let loop ([l lst] [n null] [c null])
    (cond
      [(null? l) (reverse (if (null? c) n (cons (reverse c) n)))]
      [(eq? delim (car l)) (loop (cdr l) (cons (reverse c) n) null)]
      [else (loop (cdr l) n (cons (car l) c))])))

(define (list->lines indent-amt l
                     #:line-numbers line-numbers
                     #:line-number-sep line-number-sep
                     #:block? block?)
  (define indent-elem (if (zero? indent-amt) "" (hspace indent-amt)))
  (define lines (break-list l 'newline))
  (define line-cnt (length lines))
  (define line-cntl (string-length (format "~a" (+ line-cnt (or line-numbers 0)))))

  (define (prepend-line-number n r)
    (define ln (format "~a" n))
    (define lnl (string-length ln))
    (define diff (- line-cntl lnl))
    (define l1 (list (tt ln) (hspace line-number-sep)))
    (cons (make-element 'smaller
                        (make-element 'smaller
                                      (if (zero? diff)
                                          l1
                                          (cons (hspace diff) l1))))
          r))

  (define (make-line accum-line line-number)
    (define rest (cons indent-elem accum-line))
    (list ((if block? paragraph (lambda (s e) e))
           omitable
           (if line-numbers
               (prepend-line-number line-number rest)
               rest))))

  (for/list ([one-line (in-list (break-list l 'newline))]
             [i (in-naturals (or line-numbers 1))])
    (make-line one-line i)))

(define (normalize-inline-text s)
  (regexp-replace* #px"(?:\\s*(?:\r|\n|\r\n)\\s*)+" s " "))

(define (tokens-from-chunks lang chunks #:inline? [inline? #f])
  (define (normalize-text txt)
    (if inline? (normalize-inline-text txt) txt))
  (let loop ([rest chunks] [pending ""] [acc null])
    (cond
      [(null? rest)
       (define acc2
         (if (string=? pending "")
             acc
             (append (reverse (tokenize lang (normalize-text pending))) acc)))
       (reverse acc2)]
      [else
       (define chunk (car rest))
       (cond
         [(eq? (car chunk) 'escape)
          (define acc2
            (if (string=? pending "")
                acc
                (append (reverse (tokenize lang (normalize-text pending))) acc)))
          (loop (cdr rest) "" (cons (cons 'escape (cdr chunk)) acc2))]
         [else
          (define txt (cdr chunk))
          (unless (string? txt)
            (raise-argument-error 'typeset-lang-code "string?" txt))
          (loop (cdr rest) (string-append pending txt) acc)])])))

(define (typeset-lang-block/chunks lang
                                   #:file [filename #f]
                                   #:indent [indent 0]
                                   #:line-numbers [line-numbers #f]
                                   #:line-number-sep [line-number-sep 1]
                                   #:color-swatch? [color-swatch? #f]
                                   #:font-preview? [font-preview? #f]
                                   #:dimension-preview? [dimension-preview? #f]
                                   #:mdn-links? [mdn-links? #t]
                                   #:preview-tooltips? [preview-tooltips? #t]
                                   #:preview-mode [preview-mode 'always]
                                   #:preview-css-url [preview-css-url #f]
                                   #:jsx? [jsx? #f]
                                   #:inset? [inset? #t]
                                   chunks)
  (define html-style-color? (if (eq? lang 'html) #t color-swatch?))
  (define html-style-font? (if (eq? lang 'html) #t font-preview?))
  (define html-style-dim? (if (eq? lang 'html) #t dimension-preview?))
  (define html-style-mode (if (eq? lang 'html) 'always preview-mode))
  (define tokens
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?]
                   [current-jsx? (and (eq? lang 'js) jsx?)]
                   [current-html-style-color-swatch? html-style-color?]
                   [current-html-style-font-preview? html-style-font?]
                   [current-html-style-dimension-preview? html-style-dim?]
                   [current-html-style-preview-mode html-style-mode])
      (tokens-from-chunks lang chunks)))
  (define lines (list->lines indent
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?])
      (tokens->pieces lang tokens
                                              #:color-swatch? color-swatch?
                                              #:font-preview? font-preview?
                                              #:dimension-preview? dimension-preview?
                                              #:mdn-links? mdn-links?
                                              #:preview-tooltips? preview-tooltips?
                                               #:preview-mode preview-mode))
                             #:line-numbers line-numbers
                             #:line-number-sep line-number-sep
                             #:block? #t))
  (define tbl (table block-color lines))
  (define block (if inset?
                    (nested #:style 'code-inset tbl)
                    tbl))
  (if filename
      (filebox filename block)
      block))

(define (typeset-lang-inline/chunks lang chunks
                                    #:color-swatch? [color-swatch? #f]
                                    #:font-preview? [font-preview? #f]
                                    #:dimension-preview? [dimension-preview? #f]
                                    #:mdn-links? [mdn-links? #t]
                                    #:preview-tooltips? [preview-tooltips? #t]
                                    #:preview-mode [preview-mode 'always]
                                    #:preview-css-url [preview-css-url #f]
                                    #:jsx? [jsx? #f])
  (define html-style-color? (if (eq? lang 'html) #t color-swatch?))
  (define html-style-font? (if (eq? lang 'html) #t font-preview?))
  (define html-style-dim? (if (eq? lang 'html) #t dimension-preview?))
  (define html-style-mode (if (eq? lang 'html) 'always preview-mode))
  (define tokens
    (parameterize ([current-preview-css-url preview-css-url]
                   [current-preview-tooltips? preview-tooltips?]
                   [current-jsx? (and (eq? lang 'js) jsx?)]
                   [current-html-style-color-swatch? html-style-color?]
                   [current-html-style-font-preview? html-style-font?]
                   [current-html-style-dimension-preview? html-style-dim?]
                   [current-html-style-preview-mode html-style-mode])
      (tokens-from-chunks lang chunks #:inline? #t)))
  (make-element #f
                (parameterize ([current-preview-css-url preview-css-url]
                               [current-preview-tooltips? preview-tooltips?])
                  (tokens->pieces lang
                                  tokens
                                  #:color-swatch? color-swatch?
                                  #:font-preview? font-preview?
                                  #:dimension-preview? dimension-preview?
                                  #:mdn-links? mdn-links?
                                  #:preview-tooltips? preview-tooltips?
                                  #:preview-mode preview-mode))))

(define-for-syntax (chunks-template args-stx escape-id-stx)
  (for/list ([arg (in-list (syntax->list args-stx))])
    (syntax-parse arg
      [(esc e:expr)
       #:when (and (identifier? #'esc)
                   (free-identifier=? #'esc escape-id-stx))
       #`(cons 'escape e)]
      [_ #`(cons 'text #,arg)])))

(define-for-syntax (do-block stx lang inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:file filename-expr:expr)
                              #:defaults ([filename-expr #'#f])
                              #:name "#:file keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-block/chunks '#,lang
                                  #:file filename-expr
                                  #:indent indent-expr
                                  #:line-numbers line-numbers-expr
                                  #:line-number-sep line-number-sep-expr
                                  #:mdn-links? mdn-links-expr
                                  #:inset? #,inset?
                                  (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-for-syntax (do-css-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:color-swatch? color-swatch-expr:expr)
                              #:defaults ([color-swatch-expr #'#t])
                              #:name "#:color-swatch? keyword")
                   (~optional (~seq #:font-preview? font-preview-expr:expr)
                              #:defaults ([font-preview-expr #'#t])
                              #:name "#:font-preview? keyword")
                   (~optional (~seq #:dimension-preview? dimension-preview-expr:expr)
                              #:defaults ([dimension-preview-expr #'#f])
                              #:name "#:dimension-preview? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:preview-mode preview-mode-expr:expr)
                              #:defaults ([preview-mode-expr #''always])
                              #:name "#:preview-mode keyword")
                   (~optional (~seq #:preview-tooltips? preview-tooltips-expr:expr)
                              #:defaults ([preview-tooltips-expr #'#t])
                              #:name "#:preview-tooltips? keyword")
                   (~optional (~seq #:preview-css-url preview-css-url-expr:expr)
                              #:defaults ([preview-css-url-expr #'#f])
                              #:name "#:preview-css-url keyword")
                   (~optional (~seq #:file filename-expr:expr)
                              #:defaults ([filename-expr #'#f])
                              #:name "#:file keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-block/chunks 'css
                                  #:file filename-expr
                                  #:indent indent-expr
                                  #:line-numbers line-numbers-expr
                                  #:line-number-sep line-number-sep-expr
                                  #:color-swatch? color-swatch-expr
                                  #:font-preview? font-preview-expr
                                  #:dimension-preview? dimension-preview-expr
                                  #:mdn-links? mdn-links-expr
                                  #:preview-tooltips? preview-tooltips-expr
                                  #:preview-mode preview-mode-expr
                                  #:preview-css-url preview-css-url-expr
                                  #:inset? #,inset?
                                  (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-for-syntax (do-js-block stx inset?)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:indent indent-expr:expr)
                              #:defaults ([indent-expr #'0])
                              #:name "#:indent keyword")
                   (~optional (~seq #:line-numbers line-numbers-expr:expr)
                              #:defaults ([line-numbers-expr #'#f])
                              #:name "#:line-numbers keyword")
                   (~optional (~seq #:line-number-sep line-number-sep-expr:expr)
                              #:defaults ([line-number-sep-expr #'1])
                              #:name "#:line-number-sep keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:jsx? jsx-expr:expr)
                              #:defaults ([jsx-expr #'#f])
                              #:name "#:jsx? keyword")
                   (~optional (~seq #:file filename-expr:expr)
                              #:defaults ([filename-expr #'#f])
                              #:name "#:file keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-block/chunks 'js
                                  #:file filename-expr
                                  #:indent indent-expr
                                  #:line-numbers line-numbers-expr
                                  #:line-number-sep line-number-sep-expr
                                  #:mdn-links? mdn-links-expr
                                  #:jsx? jsx-expr
                                  #:inset? #,inset?
                                  (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (css-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:color-swatch? color-swatch-expr:expr)
                              #:defaults ([color-swatch-expr #'#t])
                              #:name "#:color-swatch? keyword")
                   (~optional (~seq #:font-preview? font-preview-expr:expr)
                              #:defaults ([font-preview-expr #'#t])
                              #:name "#:font-preview? keyword")
                   (~optional (~seq #:dimension-preview? dimension-preview-expr:expr)
                              #:defaults ([dimension-preview-expr #'#f])
                              #:name "#:dimension-preview? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:preview-mode preview-mode-expr:expr)
                              #:defaults ([preview-mode-expr #''always])
                              #:name "#:preview-mode keyword")
                   (~optional (~seq #:preview-tooltips? preview-tooltips-expr:expr)
                              #:defaults ([preview-tooltips-expr #'#t])
                              #:name "#:preview-tooltips? keyword")
                   (~optional (~seq #:preview-css-url preview-css-url-expr:expr)
                              #:defaults ([preview-css-url-expr #'#f])
                              #:name "#:preview-css-url keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-inline/chunks 'css
                                   #:color-swatch? color-swatch-expr
                                   #:font-preview? font-preview-expr
                                   #:dimension-preview? dimension-preview-expr
                                   #:mdn-links? mdn-links-expr
                                   #:preview-tooltips? preview-tooltips-expr
                                   #:preview-mode preview-mode-expr
                                   #:preview-css-url preview-css-url-expr
                                   (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (html-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-inline/chunks 'html
                                   #:mdn-links? mdn-links-expr
                                   (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (js-code stx)
  (syntax-parse stx
    [(_ (~seq (~or (~optional (~seq #:jsx? jsx-expr:expr)
                              #:defaults ([jsx-expr #'#f])
                              #:name "#:jsx? keyword")
                   (~optional (~seq #:mdn-links? mdn-links-expr:expr)
                              #:defaults ([mdn-links-expr #'#t])
                              #:name "#:mdn-links? keyword")
                   (~optional (~seq #:escape escape-id:identifier)
                              #:name "#:escape keyword"))
              ...)
        str ...)
     (define esc-id (if (attribute escape-id)
                        #'escape-id
                        (datum->syntax stx 'unsyntax)))
     #`(typeset-lang-inline/chunks 'js
                                   #:jsx? jsx-expr
                                   #:mdn-links? mdn-links-expr
                                   (list #,@(chunks-template #'(str ...) esc-id)))]))

(define-syntax (cssblock0 stx) (do-css-block stx #f))
(define-syntax (cssblock stx) (do-css-block stx #t))
(define-syntax (htmlblock0 stx) (do-block stx 'html #f))
(define-syntax (htmlblock stx) (do-block stx 'html #t))
(define-syntax (jsblock0 stx) (do-js-block stx #f))
(define-syntax (jsblock stx) (do-js-block stx #t))

(module+ test
  (require rackunit)
  (define-syntax-rule (unsyntax e) e)
  (define-syntax-rule (UNQ e) e)
  (define-runtime-path fixtures-dir "test-fixtures")
  (define (read-fixture file)
    (file->string (build-path fixtures-dir file)))
  (define (classes lang src)
    (map car (tokenize lang src)))
  (define (class-count cls l)
    (for/sum ([x (in-list l)])
      (if (eq? x cls) 1 0)))
  (define (has-target-url-prop? st)
    (and (style? st)
         (for/or ([p (in-list (style-properties st))])
           (target-url? p))))
  (define (contains-link? v)
    (cond
      [(element? v)
       (or (has-target-url-prop? (element-style v))
           (let ([c (element-content v)])
             (if (list? c)
                 (for/or ([x (in-list c)]) (contains-link? x))
                 (contains-link? c))))]
      [(list? v) (for/or ([c (in-list v)]) (contains-link? c))]
      [else #f]))
  (define (collect-target-urls v)
    (define (style-target st)
      (and (style? st)
           (for/or ([p (in-list (style-properties st))])
             (and (target-url? p)
                  (vector-ref (struct->vector p) 1)))))
    (cond
      [(element? v)
       (append
        (let ([u (style-target (element-style v))])
          (if u (list u) null))
        (let ([c (element-content v)])
          (if (list? c)
              (append-map collect-target-urls c)
              (collect-target-urls c))))]
      [(list? v) (append-map collect-target-urls v)]
      [else null]))
  (check-true (block? (cssblock "h1 { color: red; }")))
  (check-true (block? (htmlblock "<h1 class=\"x\">Hi</h1>")))
  (check-true (block? (jsblock "const x = 1;")))
  (check-true (block? (jsblock #:jsx? #t "const el = <A x={1}/>;")))
  (check-true (element? (css-code "h1 { color: red; }")))
  (check-true (element? (html-code "<h1 class=\"x\">Hi</h1>")))
  (check-true (element? (js-code "const x = 1;")))
  (check-true (element? (js-code #:jsx? #t "const el = <A/>;")))
  (check-not-false
   (member 'name (classes 'css "h1.title { color: #c33; --gap: 1.5rem; }")))
  (check-not-false
   (member 'value (classes 'css "h1.title { color: #c33; --gap: 1.5rem; }")))
  (check-not-false
   (member 'keyword (classes 'css "@media (min-width: 60rem) { .x { display: grid; } }")))
  (check-not-false
   (member 'keyword (classes 'html "<section id=main class=\"card\">Hi</section>")))
  (check-not-false
   (member 'name (classes 'html "<section id=main class=\"card\">Hi</section>")))
  (check-not-false
   (member 'value (classes 'html "<section id=main class=\"card\">Hi &amp; bye</section>")))
  (check-not-false
   (member 'comment (classes 'html "<!-- note -->")))
  (check-not-false
   (member 'keyword (classes 'js "const x = 1; if (x) { console.log(x); }")))
  (let ([cls (classes 'js "const x = 1; function f() { return x; } class C {}")])
    (check-not-false (member 'decl-name cls))
    (check-not-false (member 'operator cls)))
  (check-not-false
   (member 'comment (classes 'js "// hi\nconst x = 1;")))
  (check-true
   (element? (css-code "a { color: " (unsyntax (bold "red")) "; }")))
  (check-true
   (element? (css-code #:escape UNQ "a { color: " (UNQ (italic "red")) "; }")))
  (check-true
   (block? (htmlblock "<p>" (unsyntax (bold "hi")) "</p>")))
  (check-not-false (mdn-url-for-token 'css 'name "color"))
  (check-not-false (mdn-url-for-token 'html 'keyword "div"))
  (check-not-false (mdn-url-for-token 'js 'keyword "const"))
  (check-true (contains-link? (css-code "a{color:red;}")))
  (check-false (contains-link? (css-code #:mdn-links? #f "a{color:red;}")))
  (check-true (contains-link? (html-code "<div class='x'>x</div>")))
  (check-false (contains-link? (js-code #:mdn-links? #f "const x = 1;")))
  (let ([urls (collect-target-urls (js-code "Math.max(1, 2);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/max"
             urls)))
  (let ([urls (collect-target-urls (js-code "const p = JSON.parse; p(\"{}\");"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse"
             urls)))
  (let ([urls (collect-target-urls (js-code "const {parse} = JSON; parse(\"{}\");"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse"
             urls)))
  (let ([urls (collect-target-urls (js-code "\"x\".startsWith(\"x\"); [1,2].map((n)=>n);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/startsWith"
             urls))
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "const ctx = canvas.getContext(\"2d\"); ctx.fillRect(0, 0, 10, 10);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillRect"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "const gl = canvas.getContext(\"webgl\"); gl.clear();"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext/clear"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "document.querySelector(\"#app\").appendChild(node);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector"
             urls))
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "const el = document.getElementById(\"app\"); el.setAttribute(\"role\", \"main\");"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "window.addEventListener(\"resize\", onResize);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener"
             urls)))
  (let ([urls (collect-target-urls
               (js-code "console.log(msg); console.error(err);"))])
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/console/log_static"
             urls))
    (check-not-false
     (member "https://developer.mozilla.org/en-US/docs/Web/API/console/error_static"
             urls)))
  (check-not-false
   (member 'name (classes 'css (read-fixture "css-basic.css"))))
  (let ([sw (insert-css-color-swatch-tokens (tokenize 'css ".x { color: #c33; }") #t)])
    (check-not-false (member 'swatch (map car sw))))
  (let ([sw (insert-css-color-swatch-tokens (tokenize 'css ".x { color: #c33; }") #f)])
    (check-false (member 'swatch (map car sw))))
  (let* ([sw (insert-css-color-swatch-tokens
              (tokenize 'css
                        ".x { color: oklch(62% 0.21 25); background: conic-gradient(red, blue); outline-color: color-mix(in srgb, #c33 60%, white); }")
              #t)]
         [classes (map car sw)])
    (check-not-false (member 'swatch classes))
    (check-not-false (member 'swatch-gradient classes)))
  (let* ([dp (insert-css-dimension-preview-tokens
              (tokenize 'css
                        ".x { margin: clamp(1rem, 2vw, 2rem); padding: min(1.2rem, 14px); gap: max(0.6rem, 1.5em); }")
              #t)]
         [classes (map car dp)])
    (check-not-false (member 'spacing-preview classes)))
  (let* ([on-attrs (preview-tooltip-attrs "Color preview: #c33")]
         [off-attrs (parameterize ([current-preview-tooltips? #f])
                      (preview-tooltip-attrs "Color preview: #c33"))])
    (check-equal? (assoc 'data-preview-tooltips on-attrs) '(data-preview-tooltips . "on"))
    (check-equal? (assoc 'title on-attrs) '(title . "Color preview: #c33"))
    (check-equal? (assoc 'data-preview-tooltips off-attrs) '(data-preview-tooltips . "off"))
    (check-false (assoc 'title off-attrs)))
  (let ([sw (insert-css-color-swatch-tokens
             (tokenize 'css ".x { background: linear-gradient(red, blue); }")
             #t)])
    (check-not-false (member 'swatch-gradient (map car sw))))
  (let ([fp (insert-css-font-preview-tokens
             (tokenize 'css ".x { font-family: \"Fira Code\"; }")
             #t)])
    (check-not-false (member 'font-preview (map car fp))))
  (let ([fp (insert-css-font-preview-tokens
             (tokenize 'css ".x { font-family: \"Fira Code\"; }")
             #f)])
    (check-false (member 'font-preview (map car fp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { margin: 16px; gap: 1.5em; }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { border-radius: 12px; }")
             #t)])
    (check-not-false (member 'radius-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { margin: calc(1rem + 8px) 2rem; }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { filter: blur(3px) saturate(130%); }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([dp (insert-css-dimension-preview-tokens
             (tokenize 'css ".x { letter-spacing: 0.08em; text-indent: 2em; }")
             #t)])
    (check-not-false (member 'spacing-preview (map car dp))))
  (let ([tp (insert-css-design-token-tokens
             (tokenize 'css ":root { --brand: #c33; } .x { color: var(--brand); }")
             #t)])
    (check-not-false (member 'token-def (map car tp)))
    (check-not-false (member 'token-ref (map car tp))))
  (let ([jp (insert-js-preview-tokens
             (tokenize 'js "const re = /ab+c/i; const msg = `hi ${name}`;")
             #t)])
    (check-not-false (member 'js-regex-preview (map car jp)))
    (check-not-false (member 'js-template-preview (map car jp))))
  (check-equal? (normalize-preview-mode 't 'always) 'always)
  (check-equal? (normalize-preview-mode 't 'hover) 'hover)
  (check-equal? (normalize-preview-mode 't 'none) 'none)
  (check-exn exn:fail?
             (lambda () (normalize-preview-mode 't 'auto)))
  (let* ([tok (insert-css-color-swatch-tokens
               (tokenize 'css ".x { color: #c33; }")
               #t)]
         [moved (move-css-decorations-to-decl-end tok)]
         [semi-i (let loop ([xs moved] [i 0])
                   (cond
                     [(null? xs) #f]
                     [(and (eq? (caar xs) 'punct) (string=? (cdar xs) ";")) i]
                     [else (loop (cdr xs) (add1 i))]))]
         [sw-i (index-of (map car moved) 'swatch)])
    (check-not-false semi-i)
    (check-not-false sw-i)
    (check-true (< semi-i sw-i)))
  (let* ([tok (insert-css-color-swatch-tokens
               (tokenize 'css ".x { color: #c33 }")
               #t)]
         [moved (move-css-decorations-to-decl-end tok)]
         [kinds (map car moved)])
    (check-true (< (index-of kinds 'swatch)
                   (let loop ([xs moved] [i 0])
                     (cond
                       [(null? xs) 999]
                       [(and (eq? (caar xs) 'punct) (string=? (cdar xs) "}")) i]
                       [else (loop (cdr xs) (add1 i))])))))
  (check-not-false
   (member 'keyword (classes 'html (read-fixture "html-basic.html"))))
  (check-not-false
   (member 'keyword (classes 'html (read-fixture "html-script.html"))))
  (check-not-false
   (member 'comment (classes 'html (read-fixture "html-script.html"))))
  (let ([cls (classes 'js (read-fixture "js-tricky.js"))])
    (check-not-false (member 'comment cls))
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls))
    (check-true ((class-count 'punct cls) . >= . 6)))
  (let ([cls (classes 'js (read-fixture "js-async.js"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-true ((class-count 'keyword cls) . >= . 6)))
  (let ([cls (classes 'css (read-fixture "css-nesting.css"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls))
    (check-true ((class-count 'punct cls) . >= . 8)))
  (let ([cls (classes 'html (read-fixture "html-mixed.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls))
    (check-true ((class-count 'keyword cls) . >= . 5)))
  (let ([cls (classes 'html (read-fixture "html-broken.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls)))
  (let ([cls (classes 'js (read-fixture "js-regex-vs-division.js"))])
    (check-not-false (member 'value cls))   ; regex literal
    (check-not-false (member 'operator cls)) ; division/operator
    (check-true ((class-count 'value cls) . >= . 2))
    (check-true ((class-count 'operator cls) . >= . 3)))
  (let ([cls (classes 'js (read-fixture "js-regex-condition.js"))])
    (check-not-false (member 'value cls))    ; /ab+c/
    (check-not-false (member 'operator cls)) ; divisions
    (check-true ((class-count 'value cls) . >= . 1))
    (check-true ((class-count 'operator cls) . >= . 4)))
  (let ([cls (classes 'js "for (;;) /ab+/.test(s); const q = a / b;")])
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (let ([cls (classes 'js (read-fixture "js-numeric-edge.js"))])
    (check-not-false (member 'value cls))
    (check-true ((class-count 'value cls) . >= . 5)))
  (let ([cls (classes 'js (read-fixture "js-recovery-edge.js"))])
    (check-not-false (member 'punct cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'js (read-fixture "js-recovery-string-edge.js"))])
    (check-not-false (member 'value cls))
    (check-not-false (member 'keyword cls))
    (check-true ((class-count 'keyword cls) . >= . 2)))
  (let ([cls (classes 'js "const o = {a: 1, b: 2};")])
    (check-not-false (member 'object-key cls)))
  (let ([cls (classes 'js "function f({a, b: c}, d = 0) { return d + c; }")])
    (check-not-false (member 'param-name cls)))
  (let ([cls (classes 'js "obj.value = obj.run(1);")])
    (check-not-false (member 'prop-name cls))
    (check-not-false (member 'method-name cls)))
  (let ([cls (classes 'js "class C { static { this.#x = 1; } #x = 0; }")])
    (check-not-false (member 'static-keyword cls))
    (check-not-false (member 'private-name cls)))
  (let ([cls (parameterize ([current-jsx? #t])
               (classes 'js "const id = <T>(x) => x;"))])
    (check-not-false (member 'operator cls))
    (check-not-false (member 'name cls)))
  (let ([cls (classes 'js "async function f(){ await x; } function g(){ await x; }")])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls)))
  (let ([cls (parameterize ([current-jsx? #t])
               (classes 'js (read-fixture "js-jsx.js")))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'punct cls))
    (check-true ((class-count 'keyword cls) . >= . 5)))
  (let ([cls (parameterize ([current-jsx? #t])
               (classes 'js (read-fixture "js-real-react.jsx")))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'operator cls))
    (check-true ((class-count 'punct cls) . >= . 8)))
  (let ([cls (classes 'js (read-fixture "js-modern-ops.js"))])
    (check-not-false (member 'operator cls))
    (check-not-false (member 'decl-name cls))
    (check-not-false (member 'keyword cls))
    (check-true ((class-count 'operator cls) . >= . 8)))
  (let ([cls (classes 'js (read-fixture "js-real-config.js"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (or (member 'name cls)
                         (member 'prop-name cls)
                         (member 'object-key cls)))
    (check-not-false (member 'value cls))
    (check-not-false (member 'operator cls)))
  (let ([cls (classes 'js (read-fixture "js-template-interpolation.js"))])
    (check-not-false (member 'value cls))   ; template chunks
    (check-not-false (member 'punct cls))   ; ${ and }
    (check-not-false (member 'name cls))
    (check-not-false (member 'keyword cls)))
  (let ([cls (classes 'js (read-fixture "js-template-nested.js"))])
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls))
    (check-not-false (member 'name cls))
    (check-true ((class-count 'punct cls) . >= . 4)))
  (let ([cls (classes 'html (read-fixture "html-inline-style-script-full.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'comment cls))
    (check-not-false (member 'swatch cls))
    (check-true ((class-count 'keyword cls) . >= . 6)))
  (let ([cls (classes 'html (read-fixture "html-malformed-recovery-2.html"))])
    (check-not-false (member 'keyword cls))
    (check-not-false (member 'name cls))
    (check-not-false (member 'value cls))
    (check-not-false (member 'punct cls)))
  (check-true
   (block? (cssblock #:file "demo.css" ".x { color: red; }"))))
