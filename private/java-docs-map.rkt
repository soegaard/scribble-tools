#lang racket/base

;; Official Java sources used here:
;; - Java SE 26 Language Specification:
;;   https://docs.oracle.com/en/java/javase/26/docs/specs/jls/
;; - Java SE 26 API docs:
;;   https://docs.oracle.com/en/java/javase/26/docs/api/

(require racket/string)

(provide java-doc-url-for-token)

(define java-jls-base-url
  "https://docs.oracle.com/en/java/javase/26/docs/specs/jls/")

(define java-api-base-url
  "https://docs.oracle.com/en/java/javase/26/docs/api/java.base/")

(define java-keyword-url
  (hash
   "abstract"   (string-append java-jls-base-url "jls-8.html")
   "assert"     (string-append java-jls-base-url "jls-14.html")
   "break"      (string-append java-jls-base-url "jls-14.html")
   "case"       (string-append java-jls-base-url "jls-14.html")
   "catch"      (string-append java-jls-base-url "jls-14.html")
   "class"      (string-append java-jls-base-url "jls-8.html")
   "continue"   (string-append java-jls-base-url "jls-14.html")
   "default"    (string-append java-jls-base-url "jls-14.html")
   "do"         (string-append java-jls-base-url "jls-14.html")
   "else"       (string-append java-jls-base-url "jls-14.html")
   "enum"       (string-append java-jls-base-url "jls-8.html")
   "extends"    (string-append java-jls-base-url "jls-8.html")
   "final"      (string-append java-jls-base-url "jls-8.html")
   "finally"    (string-append java-jls-base-url "jls-14.html")
   "for"        (string-append java-jls-base-url "jls-14.html")
   "if"         (string-append java-jls-base-url "jls-14.html")
   "implements" (string-append java-jls-base-url "jls-8.html")
   "import"     (string-append java-jls-base-url "jls-7.html")
   "instanceof" (string-append java-jls-base-url "jls-15.html")
   "interface"  (string-append java-jls-base-url "jls-9.html")
   "module"     (string-append java-jls-base-url "jls-7.html")
   "new"        (string-append java-jls-base-url "jls-15.html")
   "package"    (string-append java-jls-base-url "jls-7.html")
   "private"    (string-append java-jls-base-url "jls-8.html")
   "protected"  (string-append java-jls-base-url "jls-8.html")
   "public"     (string-append java-jls-base-url "jls-8.html")
   "record"     (string-append java-jls-base-url "jls-8.html")
   "return"     (string-append java-jls-base-url "jls-14.html")
   "sealed"     (string-append java-jls-base-url "jls-8.html")
   "static"     (string-append java-jls-base-url "jls-8.html")
   "super"      (string-append java-jls-base-url "jls-15.html")
   "switch"     (string-append java-jls-base-url "jls-14.html")
   "this"       (string-append java-jls-base-url "jls-15.html")
   "throw"      (string-append java-jls-base-url "jls-14.html")
   "throws"     (string-append java-jls-base-url "jls-8.html")
   "try"        (string-append java-jls-base-url "jls-14.html")
   "var"        (string-append java-jls-base-url "jls-14.html")
   "void"       (string-append java-jls-base-url "jls-8.html")
   "while"      (string-append java-jls-base-url "jls-14.html")
   "yield"      (string-append java-jls-base-url "jls-14.html")))

(define java-literal-url
  (hash
   "true"  (string-append java-jls-base-url "jls-3.html")
   "false" (string-append java-jls-base-url "jls-3.html")
   "null"  (string-append java-jls-base-url "jls-3.html")))

(define java-item-url
  (hash
   "Object"      (string-append java-api-base-url "java/lang/Object.html")
   "String"      (string-append java-api-base-url "java/lang/String.html")
   "System"      (string-append java-api-base-url "java/lang/System.html")
   "Override"    (string-append java-api-base-url "java/lang/Override.html")
   "Integer"     (string-append java-api-base-url "java/lang/Integer.html")
   "Boolean"     (string-append java-api-base-url "java/lang/Boolean.html")
   "List"        (string-append java-api-base-url "java/util/List.html")
   "Map"         (string-append java-api-base-url "java/util/Map.html")
   "Set"         (string-append java-api-base-url "java/util/Set.html")
   "ArrayList"   (string-append java-api-base-url "java/util/ArrayList.html")
   "HashMap"     (string-append java-api-base-url "java/util/HashMap.html")
   "HashSet"     (string-append java-api-base-url "java/util/HashSet.html")
   "Optional"    (string-append java-api-base-url "java/util/Optional.html")
   "Comparator"  (string-append java-api-base-url "java/util/Comparator.html")
   "Collections" (string-append java-api-base-url "java/util/Collections.html")
   "Objects"     (string-append java-api-base-url "java/util/Objects.html")
   "Stream"      (string-append java-api-base-url "java/util/stream/Stream.html")
   "Files"       (string-append java-api-base-url "java/nio/file/Files.html")
   "Path"        (string-append java-api-base-url "java/nio/file/Path.html")
   "Runnable"    (string-append java-api-base-url "java/lang/Runnable.html")
   "PrintStream" (string-append java-api-base-url "java/io/PrintStream.html")
   "println"     (string-append java-api-base-url "java/io/PrintStream.html#println(java.lang.String)")))

(define (java-doc-url-for-token cls token prev1 prev2 next1)
  (define t (string-trim token))
  (cond
    [(or (string=? t "") (regexp-match? #px"[[:space:]]" t))
     #f]
    [(or (hash-ref java-item-url t #f)
         (and (equal? prev1 "@")
              (hash-ref java-item-url t #f)))]
    [(eq? cls 'keyword)
     (hash-ref java-keyword-url t #f)]
    [(eq? cls 'value)
     (hash-ref java-literal-url t #f)]
    [else
     (hash-ref java-item-url t #f)]))

(module+ test
  (require rackunit)

  (check-equal? (java-doc-url-for-token 'keyword "class" #f #f #f)
                "https://docs.oracle.com/en/java/javase/26/docs/specs/jls/jls-8.html")
  (check-equal? (java-doc-url-for-token 'keyword "return" #f #f #f)
                "https://docs.oracle.com/en/java/javase/26/docs/specs/jls/jls-14.html")
  (check-equal? (java-doc-url-for-token 'value "null" #f #f #f)
                "https://docs.oracle.com/en/java/javase/26/docs/specs/jls/jls-3.html")
  (check-equal? (java-doc-url-for-token 'name "String" #f #f #f)
                "https://docs.oracle.com/en/java/javase/26/docs/api/java.base/java/lang/String.html")
  (check-equal? (java-doc-url-for-token 'keyword "Override" "@" #f #f)
                "https://docs.oracle.com/en/java/javase/26/docs/api/java.base/java/lang/Override.html")
  (check-equal? (java-doc-url-for-token 'name "println" "." "out" #f)
                "https://docs.oracle.com/en/java/javase/26/docs/api/java.base/java/io/PrintStream.html#println(java.lang.String)")
  (check-false (java-doc-url-for-token 'name "DefinitelyNotAJavaThing" #f #f #f)))
