#lang racket/base

;; Official Go sources used here:
;; - Language spec: https://go.dev/ref/spec
;; - Package docs:   https://pkg.go.dev/

(require racket/set
         racket/string)

(provide go-doc-url-for-token)

(define go-spec-url "https://go.dev/ref/spec")

(define go-keywords
  (list->seteq
   '(break case chan const continue default defer else fallthrough for func go
           goto if import interface map package range return select struct
           switch type var)))

(define go-predeclared-url
  (hash
   "any"     go-spec-url
   "bool"    go-spec-url
   "byte"    go-spec-url
   "comparable" go-spec-url
   "complex64"  go-spec-url
   "complex128" go-spec-url
   "error"   "https://pkg.go.dev/builtin@go1.26.1#error"
   "false"   go-spec-url
   "float32" go-spec-url
   "float64" go-spec-url
   "int"     go-spec-url
   "int8"    go-spec-url
   "int16"   go-spec-url
   "int32"   go-spec-url
   "int64"   go-spec-url
   "nil"     go-spec-url
   "rune"    go-spec-url
   "string"  go-spec-url
   "true"    go-spec-url
   "uint"    go-spec-url
   "uint8"   go-spec-url
   "uint16"  go-spec-url
   "uint32"  go-spec-url
   "uint64"  go-spec-url
   "uintptr" go-spec-url))

(define go-item-url
  (hash
   "fmt"       "https://pkg.go.dev/fmt@go1.26.1"
   "Println"   "https://pkg.go.dev/fmt@go1.26.1#Println"
   "Printf"    "https://pkg.go.dev/fmt@go1.26.1#Printf"
   "Sprintf"   "https://pkg.go.dev/fmt@go1.26.1#Sprintf"
   "Errorf"    "https://pkg.go.dev/fmt@go1.26.1#Errorf"
   "context"   "https://pkg.go.dev/context@go1.26.1"
   "Context"   "https://pkg.go.dev/context@go1.26.1#Context"
   "WithCancel" "https://pkg.go.dev/context@go1.26.1#WithCancel"
   "WithTimeout" "https://pkg.go.dev/context@go1.26.1#WithTimeout"
   "bytes"     "https://pkg.go.dev/bytes@go1.26.1"
   "Buffer"    "https://pkg.go.dev/bytes@go1.26.1#Buffer"
   "Reader"    "https://pkg.go.dev/strings@go1.26.1#Reader"
   "strings"   "https://pkg.go.dev/strings@go1.26.1"
   "Contains"  "https://pkg.go.dev/strings@go1.26.1#Contains"
   "Join"      "https://pkg.go.dev/strings@go1.26.1#Join"
   "Split"     "https://pkg.go.dev/strings@go1.26.1#Split"
   "time"      "https://pkg.go.dev/time@go1.26.1"
   "Time"      "https://pkg.go.dev/time@go1.26.1#Time"
   "Duration"  "https://pkg.go.dev/time@go1.26.1#Duration"
   "Now"       "https://pkg.go.dev/time@go1.26.1#Now"
   "http"      "https://pkg.go.dev/net/http@go1.26.1"
   "Handler"   "https://pkg.go.dev/net/http@go1.26.1#Handler"
   "Client"    "https://pkg.go.dev/net/http@go1.26.1#Client"
   "Request"   "https://pkg.go.dev/net/http@go1.26.1#Request"
   "Response"  "https://pkg.go.dev/net/http@go1.26.1#Response"
   "json"      "https://pkg.go.dev/encoding/json@go1.26.1"
   "Marshal"   "https://pkg.go.dev/encoding/json@go1.26.1#Marshal"
   "Unmarshal" "https://pkg.go.dev/encoding/json@go1.26.1#Unmarshal"
   "Decoder"   "https://pkg.go.dev/encoding/json@go1.26.1#Decoder"
   "Encoder"   "https://pkg.go.dev/encoding/json@go1.26.1#Encoder"))

(define (go-doc-url-for-token cls token prev1 prev2 next1)
  (define t (string-trim token))
  (cond
    [(or (string=? t "") (regexp-match? #px"[[:space:]]" t))
     #f]
    [(eq? cls 'keyword)
     (and (set-member? go-keywords (string->symbol t)) go-spec-url)]
    [(or (eq? cls 'value) (eq? cls 'name))
     (or (hash-ref go-predeclared-url t #f)
         (hash-ref go-item-url t #f))]
    [else
     (or (hash-ref go-predeclared-url t #f)
         (hash-ref go-item-url t #f))]))

(module+ test
  (require rackunit)

  (check-equal? (go-doc-url-for-token 'keyword "func" #f #f #f)
                "https://go.dev/ref/spec")
  (check-equal? (go-doc-url-for-token 'value "nil" #f #f #f)
                "https://go.dev/ref/spec")
  (check-equal? (go-doc-url-for-token 'name "Println" #f #f #f)
                "https://pkg.go.dev/fmt@go1.26.1#Println")
  (check-equal? (go-doc-url-for-token 'name "Context" #f #f #f)
                "https://pkg.go.dev/context@go1.26.1#Context")
  (check-equal? (go-doc-url-for-token 'name "Marshal" #f #f #f)
                "https://pkg.go.dev/encoding/json@go1.26.1#Marshal")
  (check-false (go-doc-url-for-token 'name "DefinitelyNotAGoThing" #f #f #f)))
