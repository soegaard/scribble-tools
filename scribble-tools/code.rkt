#lang racket/base

(require "private/lang-code.rkt"
         "private/mdn-map.rkt")

(provide css-code
         html-code
         js-code
         cssblock
         htmlblock
         jsblock
         cssblock0
         htmlblock0
         jsblock0
         mdn-map-path
         mdn-default-map-entries
         mdn-entry?
         mdn-install-map!
         mdn-reset-map!
         mdn-export-default-map!)
