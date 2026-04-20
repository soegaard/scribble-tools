#lang racket/base

(require racket/cmdline
         racket/file
         racket/format
         racket/list
         racket/string
         parser-tools/lex
         lexers/python
         lexers/token
         lexers/wat)

(provide projected-token->scribble-token
         projected-tokens->scribble-tokens
         python-string->scribble-tokens
         wat-string->scribble-tokens
         normalize-render-class
         token-stream->source
         token-stream-contiguous?
         compare-token-streams)

(define (projected-token->scribble-token token
                                         #:class-map [class-map #f])
  (define name (lexer-token-name token))
  (define raw-value (lexer-token-value token))
  (define text
    (cond
      [(string? raw-value) raw-value]
      [(bytes? raw-value) (bytes->string/utf-8 raw-value)]
      [(not raw-value) ""]
      [else (~a raw-value)]))
  (define cls
    (if class-map
        (class-map name text)
        (case name
          [(comment) 'comment]
          [(keyword) 'keyword]
          [(literal string number boolean) 'value]
          [(operator delimiter) 'punct]
          [(identifier) 'name]
          [else 'plain])))
  (cons cls text))

(define (projected-tokens->scribble-tokens tokens
                                           #:class-map [class-map #f])
  (for/list ([token (in-list tokens)]
             #:unless (lexer-token-eof? token))
    (projected-token->scribble-token token #:class-map class-map)))

(define (python-string->scribble-tokens source)
  (projected-tokens->scribble-tokens
   (python-string->tokens source
                          #:profile 'coloring
                          #:source-positions #t)))

(define (wat-string->scribble-tokens source
                                     #:class-map [class-map #f])
  (projected-tokens->scribble-tokens
   (wat-string->tokens source
                       #:profile 'coloring
                       #:source-positions #t)
   #:class-map class-map))

(define (normalize-render-class cls)
  (case cls
    [(wasm-form wasm-type wasm-instr keyword) 'keyword]
    [(wasm-id name decl-name prop-name method-name object-key param-name) 'name]
    [(value) 'value]
    [(comment) 'comment]
    [(operator punct) 'punct]
    [else 'plain]))

(define (token-stream->source tokens)
  (apply string-append
         (for/list ([token (in-list tokens)])
           (cdr token))))

(define (token-stream-contiguous? tokens)
  (define tokens*
    (for/list ([token (in-list tokens)]
               #:unless (lexer-token-eof? token))
      token))
  (or (null? tokens*)
      (for/and ([left-token (in-list tokens*)]
                [right-token (in-list (cdr tokens*))])
        (and (lexer-token-has-positions? left-token)
             (lexer-token-has-positions? right-token)
             (= (position-offset (lexer-token-end left-token))
                (position-offset (lexer-token-start right-token)))))))

(define (compare-token-streams source old-tokens new-token-likes
                               #:old-class-normalizer [old-class-normalizer normalize-render-class]
                               #:new-class-normalizer [new-class-normalizer normalize-render-class]
                               #:new-token->piece [new-token->piece projected-token->scribble-token])
  (define old-source
    (token-stream->source old-tokens))
  (define new-pieces
    (for/list ([token (in-list new-token-likes)]
               #:unless (lexer-token-eof? token))
      (new-token->piece token)))
  (define new-source
    (token-stream->source new-pieces))
  (define old-classes
    (map (lambda (token) (old-class-normalizer (car token))) old-tokens))
  (define new-classes
    (map (lambda (piece) (new-class-normalizer (car piece))) new-pieces))
  (hash 'source source
        'old-source old-source
        'new-source new-source
        'source-match? (and (string=? source old-source)
                            (string=? source new-source))
        'new-contiguous? (token-stream-contiguous? new-token-likes)
        'old-classes old-classes
        'new-classes new-classes
        'class-match? (equal? old-classes new-classes)))

(module+ main
  (define language #f)
  (define path #f)
  (command-line
   #:program "lexer-compare"
   #:args (lang file)
   (set! language lang)
   (set! path file))
  (define source (file->string path))
  (case (string->symbol language)
    [(python)
     (define tokens (python-string->tokens source
                                           #:profile 'coloring
                                           #:source-positions #t))
     (for ([piece (in-list (projected-tokens->scribble-tokens tokens))])
       (displayln piece))]
    [(wat)
     (define tokens (wat-string->tokens source
                                        #:profile 'coloring
                                        #:source-positions #t))
     (for ([piece (in-list (projected-tokens->scribble-tokens tokens))])
       (displayln piece))]
    [else
     (error 'lexer-compare
            "unsupported debug language: ~a"
            language)]))
