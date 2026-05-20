#lang racket/base

(require net/uri-codec
         racket/contract/base
         racket/match
         racket/string
         scribble/core
         scribble/html-properties)

(provide
 (contract-out
  [youtube
   (->* ((or/c string? symbol?))
        (#:title string?
         #:width exact-positive-integer?
         #:height exact-positive-integer?
         #:start (or/c #f exact-nonnegative-integer?)
         #:params (listof (cons/c (or/c symbol? string?)
                                  (or/c string? symbol? number? boolean?)))
         #:privacy-enhanced? boolean?
         #:allow string?
         #:allow-fullscreen? boolean?)
        block?)]))

(define video-id-rx #px"^[A-Za-z0-9_-]{11}$")
(define video-url-id-rx
  #px"(?:[?&]v=|youtu\\.be/|/embed/|/shorts/|/live/)([A-Za-z0-9_-]{11})")

(define (youtube video
                 #:title [title "YouTube video player"]
                 #:width [width 640]
                 #:height [height 360]
                 #:start [start #f]
                 #:params [params null]
                 #:privacy-enhanced? [privacy-enhanced? #f]
                 #:allow [allow "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"]
                 #:allow-fullscreen? [allow-fullscreen? #t])
  (define video-id (extract-video-id 'youtube video))
  (define width* (checked-dimension 'youtube '#:width width))
  (define height* (checked-dimension 'youtube '#:height height))
  (define src
    (embed-url video-id
               #:start start
               #:params params
               #:privacy-enhanced? privacy-enhanced?))
  (define iframe-attrs
    (append
     `((src . ,src)
       (title . ,title)
       (width . ,width*)
       (height . ,height*)
       (frameborder . "0")
       (allow . ,allow)
       (referrerpolicy . "strict-origin-when-cross-origin"))
     (if allow-fullscreen?
         '((allowfullscreen . "allowfullscreen"))
         null)))
  (make-nested-flow
   (make-style #f (list (attributes '((class . "youtube-embed")))))
   (list
    (make-paragraph
     (make-style #f null)
     (list (make-element
            (make-style #f (list (alt-tag "iframe")
                                 (attributes iframe-attrs)))
            null))))))

(define (extract-video-id who video)
  (define s (string-trim (format "~a" video)))
  (cond
    [(regexp-match? video-id-rx s) s]
    [(regexp-match video-url-id-rx s)
     => (lambda (m) (cadr m))]
    [else
     (raise-argument-error who
                           "YouTube video id or URL containing a video id"
                           video)]))

(define (checked-dimension who keyword value)
  (unless (>= value 200)
    (raise-arguments-error who
                           "YouTube embedded players require a viewport of at least 200px by 200px"
                           "keyword" keyword
                           "value" value))
  (number->string value))

(define (embed-url video-id
                   #:start start
                   #:params params
                   #:privacy-enhanced? privacy-enhanced?)
  (define host
    (if privacy-enhanced?
        "www.youtube-nocookie.com"
        "www.youtube.com"))
  (define query
    (params->query
     (append (if start
                 (list (cons 'start start))
                 null)
             params)))
  (string-append "https://" host "/embed/" video-id
                 (if (string=? query "") "" (string-append "?" query))))

(define (params->query params)
  (string-join
   (for/list ([param (in-list params)])
     (match-define (cons key value) param)
     (define key* (param-key->string key))
     (string-append (uri-encode key*) "=" (uri-encode (param-value->string value))))
   "&"))

(define (param-key->string key)
  (define s (if (symbol? key) (symbol->string key) key))
  (unless (regexp-match? #px"^[A-Za-z0-9_-]+$" s)
    (raise-argument-error 'youtube
                          "player parameter key containing only letters, numbers, underscores, or hyphens"
                          key))
  s)

(define (param-value->string value)
  (cond
    [(boolean? value) (if value "1" "0")]
    [(symbol? value) (symbol->string value)]
    [else (format "~a" value)]))

(module+ test
  (require rackunit)

  (check-equal? (extract-video-id 'youtube "dQw4w9WgXcQ")
                "dQw4w9WgXcQ")
  (check-equal? (extract-video-id 'youtube "https://youtu.be/dQw4w9WgXcQ")
                "dQw4w9WgXcQ")
  (check-equal? (extract-video-id 'youtube "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42s")
                "dQw4w9WgXcQ")
  (check-equal? (embed-url "dQw4w9WgXcQ"
                           #:start 30
                           #:params '((rel . 0) (controls . #f))
                           #:privacy-enhanced? #t)
                "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?start=30&rel=0&controls=0")
  (check-pred block? (youtube "dQw4w9WgXcQ"))
  (check-exn exn:fail:contract?
             (lambda () (youtube "not a video"))))
