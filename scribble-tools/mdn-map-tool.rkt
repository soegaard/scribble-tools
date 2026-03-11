#lang racket/base

(require racket/cmdline
         racket/format
         racket/path
         "code.rkt")

(provide main)

(define (main)
  (command-line
   #:program "racket -l scribble-tools/mdn-map-tool"
   #:once-each
   ["--path" "Print the user override map path."
             (printf "~a\n" (path->string (mdn-map-path)))
             (exit 0)]
   ["--reset" "Delete user override map and revert to bundled defaults."
              (printf "removed: ~a\n" (if (mdn-reset-map!) "yes" "no"))
              (exit 0)]
   ["--export-default" out
    "Write bundled defaults to OUT (.rktd)."
    (mdn-export-default-map! out)
    (printf "wrote: ~a\n" out)
    (exit 0)]
   ["--install" in
    "Install map from IN (.rktd)."
    (mdn-install-map! in)
    (printf "installed: ~a\n" in)
    (exit 0)]
   #:args ()
   (printf "No action given. Try --path, --export-default FILE, --install FILE, or --reset\n")))

(module+ main (main))
