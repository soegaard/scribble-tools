#lang racket/base

(require (prefix-in api: "code.rkt"))

(provide css-code
         c-code
         cpp-code
         makefile-code
         tex-code
         latex-code
         objc-code
         haskell-code
         pascal-code
         plist-code
         csv-code
         go-code
         html-code
         java-code
         mathematica-code
         js-code
         json-code
         markdown-code
         python-code
         racket-code
         rhombus-code
         rust-code
         swift-code
         wasm-code
         shell-code
         scribble-code
         tsv-code
         yaml-code
         cssblock
         cblock
         cppblock
         makefileblock
         texblock
         latexblock
         objcblock
         haskellblock
         pascalblock
         plistblock
         csvblock
         goblock
         htmlblock
         javablock
         mathematicablock
         jsblock
         jsonblock
         markdownblock
         pythonblock
         racketblock
         rhombusblock
         rustblock
         swiftblock
         wasmblock
         shellblock
         scribbleblock
         tsvblock
         yamlblock
         cssblock0
         cblock0
         cppblock0
         makefileblock0
         texblock0
         latexblock0
         objcblock0
         haskellblock0
         pascalblock0
         plistblock0
         csvblock0
         goblock0
         htmlblock0
         javablock0
         mathematicablock0
         jsblock0
         jsonblock0
         markdownblock0
         pythonblock0
         racketblock0
         rhombusblock0
         rustblock0
         swiftblock0
         wasmblock0
         shellblock0
         scribbleblock0
         tsvblock0
         yamlblock0
         code->sxml
         code-block->sxml
         code->html
         code-block->html
         code-html-support-sxml
         code-html-support
         raw-sxml
         raw-sxml?
         raw-sxml-value
         raw-html
         raw-html?
         raw-html-value
         current-wasm-docs-source
         current-scribble-shell
         current-shell-docs-source
         current-scribble-context
         mdn-map-path
         mdn-default-map-entries
         mdn-entry?
         mdn-install-map!
         mdn-reset-map!
         mdn-export-default-map!)

(define-syntax-rule (css-code . rest) (api:css-code . rest))
(define-syntax-rule (c-code . rest) (api:c-code . rest))
(define-syntax-rule (cpp-code . rest) (api:cpp-code . rest))
(define-syntax-rule (makefile-code . rest) (api:makefile-code . rest))
(define-syntax-rule (tex-code . rest) (api:tex-code . rest))
(define-syntax-rule (latex-code . rest) (api:latex-code . rest))
(define-syntax-rule (objc-code . rest) (api:objc-code . rest))
(define-syntax-rule (haskell-code . rest) (api:haskell-code . rest))
(define-syntax-rule (pascal-code . rest) (api:pascal-code . rest))
(define-syntax-rule (plist-code . rest) (api:plist-code . rest))
(define-syntax-rule (csv-code . rest) (api:csv-code . rest))
(define-syntax-rule (go-code . rest) (api:go-code . rest))
(define-syntax-rule (html-code . rest) (api:html-code . rest))
(define-syntax-rule (java-code . rest) (api:java-code . rest))
(define-syntax-rule (mathematica-code . rest) (api:mathematica-code . rest))
(define-syntax-rule (js-code . rest) (api:js-code . rest))
(define-syntax-rule (json-code . rest) (api:json-code . rest))
(define-syntax-rule (markdown-code . rest) (api:markdown-code . rest))
(define-syntax-rule (python-code . rest) (api:python-code . rest))
(define-syntax-rule (racket-code . rest) (api:racket-code . rest))
(define-syntax-rule (rhombus-code . rest) (api:rhombus-code . rest))
(define-syntax-rule (rust-code . rest) (api:rust-code . rest))
(define-syntax-rule (swift-code . rest) (api:swift-code . rest))
(define-syntax-rule (wasm-code . rest) (api:wasm-code . rest))
(define-syntax-rule (shell-code . rest) (api:shell-code . rest))
(define-syntax-rule (scribble-code . rest) (api:scribble-code . rest))
(define-syntax-rule (tsv-code . rest) (api:tsv-code . rest))
(define-syntax-rule (yaml-code . rest) (api:yaml-code . rest))
(define-syntax-rule (cssblock . rest) (api:cssblock . rest))
(define-syntax-rule (cblock . rest) (api:cblock . rest))
(define-syntax-rule (cppblock . rest) (api:cppblock . rest))
(define-syntax-rule (makefileblock . rest) (api:makefileblock . rest))
(define-syntax-rule (texblock . rest) (api:texblock . rest))
(define-syntax-rule (latexblock . rest) (api:latexblock . rest))
(define-syntax-rule (objcblock . rest) (api:objcblock . rest))
(define-syntax-rule (haskellblock . rest) (api:haskellblock . rest))
(define-syntax-rule (pascalblock . rest) (api:pascalblock . rest))
(define-syntax-rule (plistblock . rest) (api:plistblock . rest))
(define-syntax-rule (csvblock . rest) (api:csvblock . rest))
(define-syntax-rule (goblock . rest) (api:goblock . rest))
(define-syntax-rule (htmlblock . rest) (api:htmlblock . rest))
(define-syntax-rule (javablock . rest) (api:javablock . rest))
(define-syntax-rule (mathematicablock . rest) (api:mathematicablock . rest))
(define-syntax-rule (jsblock . rest) (api:jsblock . rest))
(define-syntax-rule (jsonblock . rest) (api:jsonblock . rest))
(define-syntax-rule (markdownblock . rest) (api:markdownblock . rest))
(define-syntax-rule (pythonblock . rest) (api:pythonblock . rest))
(define-syntax-rule (racketblock . rest) (api:racketblock . rest))
(define-syntax-rule (rhombusblock . rest) (api:rhombusblock . rest))
(define-syntax-rule (rustblock . rest) (api:rustblock . rest))
(define-syntax-rule (swiftblock . rest) (api:swiftblock . rest))
(define-syntax-rule (wasmblock . rest) (api:wasmblock . rest))
(define-syntax-rule (shellblock . rest) (api:shellblock . rest))
(define-syntax-rule (scribbleblock . rest) (api:scribbleblock . rest))
(define-syntax-rule (tsvblock . rest) (api:tsvblock . rest))
(define-syntax-rule (yamlblock . rest) (api:yamlblock . rest))
(define-syntax-rule (cssblock0 . rest) (api:cssblock0 . rest))
(define-syntax-rule (cblock0 . rest) (api:cblock0 . rest))
(define-syntax-rule (cppblock0 . rest) (api:cppblock0 . rest))
(define-syntax-rule (makefileblock0 . rest) (api:makefileblock0 . rest))
(define-syntax-rule (texblock0 . rest) (api:texblock0 . rest))
(define-syntax-rule (latexblock0 . rest) (api:latexblock0 . rest))
(define-syntax-rule (objcblock0 . rest) (api:objcblock0 . rest))
(define-syntax-rule (haskellblock0 . rest) (api:haskellblock0 . rest))
(define-syntax-rule (pascalblock0 . rest) (api:pascalblock0 . rest))
(define-syntax-rule (plistblock0 . rest) (api:plistblock0 . rest))
(define-syntax-rule (csvblock0 . rest) (api:csvblock0 . rest))
(define-syntax-rule (goblock0 . rest) (api:goblock0 . rest))
(define-syntax-rule (htmlblock0 . rest) (api:htmlblock0 . rest))
(define-syntax-rule (javablock0 . rest) (api:javablock0 . rest))
(define-syntax-rule (mathematicablock0 . rest) (api:mathematicablock0 . rest))
(define-syntax-rule (jsblock0 . rest) (api:jsblock0 . rest))
(define-syntax-rule (jsonblock0 . rest) (api:jsonblock0 . rest))
(define-syntax-rule (markdownblock0 . rest) (api:markdownblock0 . rest))
(define-syntax-rule (pythonblock0 . rest) (api:pythonblock0 . rest))
(define-syntax-rule (racketblock0 . rest) (api:racketblock0 . rest))
(define-syntax-rule (rhombusblock0 . rest) (api:rhombusblock0 . rest))
(define-syntax-rule (rustblock0 . rest) (api:rustblock0 . rest))
(define-syntax-rule (swiftblock0 . rest) (api:swiftblock0 . rest))
(define-syntax-rule (wasmblock0 . rest) (api:wasmblock0 . rest))
(define-syntax-rule (shellblock0 . rest) (api:shellblock0 . rest))
(define-syntax-rule (scribbleblock0 . rest) (api:scribbleblock0 . rest))
(define-syntax-rule (tsvblock0 . rest) (api:tsvblock0 . rest))
(define-syntax-rule (yamlblock0 . rest) (api:yamlblock0 . rest))

(define code->sxml api:code->sxml)
(define code-block->sxml api:code-block->sxml)
(define code->html api:code->html)
(define code-block->html api:code-block->html)
(define code-html-support-sxml api:code-html-support-sxml)
(define code-html-support api:code-html-support)
(define raw-sxml api:raw-sxml)
(define raw-sxml? api:raw-sxml?)
(define raw-sxml-value api:raw-sxml-value)
(define raw-html api:raw-html)
(define raw-html? api:raw-html?)
(define raw-html-value api:raw-html-value)
(define current-wasm-docs-source api:current-wasm-docs-source)
(define current-scribble-shell api:current-scribble-shell)
(define current-shell-docs-source api:current-shell-docs-source)
(define current-scribble-context api:current-scribble-context)
(define (mdn-map-path) (api:mdn-map-path))
(define mdn-default-map-entries api:mdn-default-map-entries)
(define (mdn-entry? v) (api:mdn-entry? v))
(define (mdn-install-map! entries-or-path) (api:mdn-install-map! entries-or-path))
(define (mdn-reset-map!) (api:mdn-reset-map!))
(define (mdn-export-default-map! dest) (api:mdn-export-default-map! dest))
