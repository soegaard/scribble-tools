#lang racket/base

(require racket/cmdline
         racket/file
         racket/list
         racket/path
         racket/string
         "html.rkt")

(provide demo-examples
         render-demo-page
         write-demo-page
         main)

(define demo-examples
  (list
   (list "CSS" 'css
         ".card { color: #c33; }"
         ".dashboard {\n  --brand: #c33;\n  display: grid;\n  gap: 1.25rem;\n  margin: clamp(1rem, 2vw, 2rem);\n  border-radius: 12px;\n  font-family: system-ui, sans-serif;\n  background: linear-gradient(135deg, #fff, color-mix(in srgb, var(--brand) 12%, white));\n}\n\n.dashboard h2 {\n  color: var(--brand);\n}")
   (list "C" 'c
         "int answer = 42;"
         "#include <stdio.h>\n\nstruct sample {\n  const char *name;\n  int score;\n};\n\nint main(void) {\n  struct sample row = {\"Ada\", 42};\n  printf(\"%s: %d\\n\", row.name, row.score);\n  return 0;\n}")
   (list "C++" 'cpp
         "std::vector<int> xs = {1, 2, 3};"
         "#include <algorithm>\n#include <iostream>\n#include <vector>\n\nint main() {\n  std::vector<int> xs = {3, 1, 2};\n  std::sort(xs.begin(), xs.end());\n  for (int n : xs) {\n    std::cout << n << \"\\n\";\n  }\n}")
   (list "CSV" 'csv
         "name,age"
         "name,age,role\nAda,37,programmer\nGrace,85,admiral\nKatherine,101,mathematician\n")
   (list "Go" 'go
         "func add(x int, y int) int { return x + y }"
         "package main\n\nimport \"fmt\"\n\ntype User struct {\n    Name  string\n    Score int\n}\n\nfunc top(users []User) string {\n    best := users[0]\n    for _, user := range users[1:] {\n        if user.Score > best.Score {\n            best = user\n        }\n    }\n    return best.Name\n}\n\nfunc main() {\n    fmt.Println(top([]User{{\"Ada\", 42}, {\"Grace\", 51}}))\n}")
   (list "HTML" 'html
         "<button class=\"primary\">Save</button>"
         "<main class=\"dashboard\">\n  <section class=\"card\" data-state=\"ready\">\n    <h1>Build status</h1>\n    <p>All checks passed.</p>\n    <button type=\"button\">Deploy</button>\n  </section>\n</main>")
   (list "Java" 'java
         "class Example { void run() { System.out.println(\"hi\"); } }"
         "import java.util.List;\n\nclass Example {\n  static int total(List<Integer> values) {\n    int sum = 0;\n    for (int value : values) {\n      sum += value;\n    }\n    return sum;\n  }\n\n  public static void main(String[] args) {\n    System.out.println(total(List.of(1, 2, 3)));\n  }\n}")
   (list "JavaScript" 'js
         "const total = items.reduce((a, b) => a + b, 0);"
         "const users = [\n  { name: \"Ada\", score: 42 },\n  { name: \"Grace\", score: 51 }\n];\n\nconst total = users\n  .filter((user) => user.score > 40)\n  .map((user) => user.score)\n  .reduce((sum, score) => sum + score, 0);\n\nconsole.log(`total: ${total}`);")
   (list "JSON" 'json
         "{\"name\": \"Ada\"}"
         "{\n  \"project\": \"scribble-tools\",\n  \"features\": [\"sxml\", \"html\", \"copy-button\"],\n  \"stable\": true,\n  \"counts\": { \"languages\": 29, \"examples\": 29 }\n}")
   (list "Haskell" 'haskell
         "sumSquares xs = sum (map (^ (2 :: Int)) xs)"
         "module Main where\n\nsumSquares :: [Int] -> Int\nsumSquares xs = sum (map (^ (2 :: Int)) xs)\n\nmain :: IO ()\nmain = do\n  let values = [1, 2, 3, 4]\n  print (sumSquares values)")
   (list "LaTeX" 'latex
         "\\section{Intro}"
         "\\documentclass{article}\n\\usepackage{tikz}\n\n\\begin{document}\n\\section{Intro}\n\\begin{itemize}\n  \\item Typeset snippets.\n  \\item Link common commands.\n\\end{itemize}\n\\begin{tikzpicture}\n  \\draw (0,0) -- (1,1);\n\\end{tikzpicture}\n\\end{document}")
   (list "Makefile" 'makefile
         "all: build test"
         ".PHONY: all build test clean\n\nall: build test\n\nbuild:\n\traco make html-demo.rkt\n\ntest:\n\traco test private/lang-code.rkt\n\nclean:\n\trm -rf compiled html/renderer-demo.html\n")
   (list "Markdown" 'markdown
         "# Hello"
         "# Renderer Demo\n\nThe page includes:\n\n- inline snippets\n- block snippets\n- copy buttons\n\n```racket\n(require scribble-tools/html)\n```\n")
   (list "Mathematica" 'mathematica
         "f[x_] := Module[{y = x^2}, y + 1]"
         "ClearAll[score]\nscore[data_] := Module[{values},\n  values = data[[All, \"score\"]];\n  <|\n    \"Total\" -> Total[values],\n    \"Mean\" -> Mean[values]\n  |>\n]\nscore[Dataset[{<|\"name\" -> \"Ada\", \"score\" -> 42|>}]]")
   (list "Objective-C" 'objc
         "@\"Hello\""
         "#import <Foundation/Foundation.h>\n\n@interface Greeter : NSObject\n@property NSString *name;\n- (NSString *)message;\n@end\n\n@implementation Greeter\n- (NSString *)message {\n  return [NSString stringWithFormat:@\"Hello, %@\", self.name];\n}\n@end")
   (list "Pascal" 'pascal
         "function Add(x, y: Integer): Integer; begin Add := x + y; end;"
         "program Demo;\n\ntype\n  TPoint = record\n    X, Y: Integer;\n  end;\n\nfunction Add(X, Y: Integer): Integer;\nbegin\n  Add := X + Y;\nend;\n\nbegin\n  WriteLn(Add(20, 22));\nend.")
   (list "plist" 'plist
         "<plist/>"
         "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<plist version=\"1.0\">\n<dict>\n  <key>Name</key>\n  <string>Ada</string>\n  <key>Enabled</key>\n  <true/>\n</dict>\n</plist>")
   (list "Python" 'python
         "def total(xs): return sum(xs)"
         "from dataclasses import dataclass\n\n@dataclass\nclass User:\n    name: str\n    score: int\n\n\ndef top_user(users):\n    return max(users, key=lambda user: user.score)\n\n\nprint(top_user([User(\"Ada\", 42), User(\"Grace\", 51)]))")
   (list "Racket" 'racket
         "(define (add x y) (+ x y))"
         "#lang racket/base\n\n(define (group-by-length words)\n  (for/fold ([table (hash)])\n            ([word (in-list words)])\n    (hash-update table\n                 (string-length word)\n                 (lambda (existing) (cons word existing))\n                 '())))\n\n(group-by-length '(\"one\" \"two\" \"three\"))")
   (list "Rhombus" 'rhombus
         "fun add(x, y): x + y"
         "#lang rhombus\n\nfun total(values):\n  values.foldl(0, fun (sum, value): sum + value)\n\nval scores = [10, 20, 12]\ntotal(scores)")
   (list "Ruby" 'ruby
         "class Greeter; def call(name:) puts name; end; end"
         "class Greeter\n  DEFAULT_GREETING = \"Hello\"\n\n  def initialize(name)\n    @name = name\n  end\n\n  def call(greeting: DEFAULT_GREETING)\n    puts \"#{greeting}, #{@name}\"\n  end\nend\n\nGreeter.new(:Ada).call(greeting: \"Hi\")")
   (list "Shell" 'bash
         "if [ -f ~/.zshrc ]; then echo ok; fi"
         "set -euo pipefail\n\nfor file in README.md html-demo.rkt; do\n  if [ -f \"$file\" ]; then\n    printf 'found %s\\n' \"$file\"\n  else\n    printf 'missing %s\\n' \"$file\" >&2\n  fi\ndone")
   (list "Rust" 'rust
         "let xs: Vec<i32> = vec![1, 2, 3];"
         "use std::collections::HashMap;\n\nfn histogram(words: &[&str]) -> HashMap<usize, usize> {\n    let mut counts = HashMap::new();\n    for word in words {\n        *counts.entry(word.len()).or_insert(0) += 1;\n    }\n    counts\n}\n\nfn main() {\n    println!(\"{:?}\", histogram(&[\"one\", \"two\", \"three\"]));\n}")
   (list "Swift" 'swift
         "let answer = 42"
         "struct User {\n  let name: String\n  let score: Int\n}\n\nfunc topName(_ users: [User]) -> String? {\n  users.sorted { $0.score > $1.score }.first?.name\n}\n\nlet users = [User(name: \"Ada\", score: 42), User(name: \"Grace\", score: 51)]\nprint(topName(users) ?? \"none\")")
   (list "TeX" 'tex
         "\\hbox{Hello}"
         "\\def\\name#1{\\hbox{Hello, #1}}\n\\name{Ada}\n\n$$\n  \\sum_{n=1}^{4} n^2 = 30\n$$")
   (list "TSV" 'tsv
         "name\tage"
         "name\tage\trole\nAda\t37\tprogrammer\nGrace\t85\tadmiral\nKatherine\t101\tmathematician\n")
   (list "WebAssembly" 'wasm
         "(module (func (result i32) (i32.const 42)))"
         "(module\n  (func $answer (result i32)\n    (i32.const 42))\n  (func $add (param $x i32) (param $y i32) (result i32)\n    (i32.add\n      (local.get $x)\n      (local.get $y)))\n  (export \"answer\" (func $answer))\n  (export \"add\" (func $add)))")
   (list "YAML" 'yaml
         "name: Ada"
         "---\nproject: scribble-tools\nfeatures:\n  - sxml\n  - html\n  - copy-button\nchecks:\n  compile: true\n  examples: 29\n")
   (list "Scribble" 'scribble
         "@bold{Hello} world."
         "#lang scribble/manual\n\n@(require scribble-tools)\n\n@title{Renderer Demo}\n\nUse @racket[code-block->html] to produce a normal HTML snippet.\n\n@itemlist[\n @item{Inline code}\n @item{Block code}\n @item{Copy buttons}\n]")))

(define (html-escape s)
  (string-replace
   (string-replace
    (string-replace
     (string-replace s "&" "&amp;")
     "<" "&lt;")
    ">" "&gt;")
   "\"" "&quot;"))

(define page-css
  #<<CSS
<style>
:root {
  color-scheme: light;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  background: #f6f7f9;
  color: #1e2329;
}
body {
  margin: 0;
}
main {
  width: min(1120px, calc(100% - 32px));
  margin: 0 auto;
  padding: 32px 0 48px;
}
header {
  margin-bottom: 28px;
}
h1 {
  margin: 0 0 8px;
  font-size: 32px;
  line-height: 1.15;
  letter-spacing: 0;
}
.lede {
  margin: 0;
  max-width: 760px;
  color: #59616d;
  line-height: 1.55;
}
.examples {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 16px;
}
.example {
  min-width: 0;
  border: 1px solid #d9dee7;
  border-radius: 8px;
  background: #fff;
  overflow: hidden;
}
.example h2 {
  margin: 0;
  padding: 12px 14px;
  border-bottom: 1px solid #e7ebf1;
  font-size: 15px;
  line-height: 1.3;
  letter-spacing: 0;
}
.example .inline-row {
  margin: 0;
  padding: 12px 14px;
  border-bottom: 1px solid #eef1f5;
  color: #59616d;
  line-height: 1.5;
}
.example .inline-row code {
  color: #1e2329;
}
.example .scribble-tools-block {
  margin: 0;
  border: 0;
  border-radius: 0;
  background: #fbfcfe;
  max-height: 240px;
}
</style>
CSS
  )

(define (render-example example)
  (define label (first example))
  (define lang (second example))
  (define inline-source (third example))
  (define block-source (fourth example))
  (string-append
   "<section class=\"example\">"
   "<h2>" (html-escape label) "</h2>"
   "<p class=\"inline-row\">Inline: "
   (code->html lang inline-source)
   "</p>"
   (code-block->html lang
                     #:line-numbers 1
                     #:copy-button? #t
                     block-source)
   "</section>"))

(define (render-demo-page [examples demo-examples])
  (string-append
   "<!doctype html>\n"
   "<html lang=\"en\">\n"
   "<head>\n"
   "<meta charset=\"utf-8\">\n"
   "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
   "<title>scribble-tools HTML renderer demo</title>\n"
   page-css
   "\n"
   (code-html-support)
   "\n"
   "</head>\n"
   "<body>\n"
   "<main>\n"
   "<header>\n"
   "<h1>scribble-tools HTML renderer demo</h1>\n"
   "<p class=\"lede\">A standalone page generated with scribble-tools/html. "
   "Each card shows inline and block output from the new SXML/HTML renderer.</p>\n"
   "</header>\n"
   "<div class=\"examples\">\n"
   (apply string-append (map render-example examples))
   "\n</div>\n"
   "</main>\n"
   "</body>\n"
   "</html>\n"))

(define (write-demo-page out)
  (define path (if (path? out) out (string->path out)))
  (define dir (path-only path))
  (when dir
    (make-directory* dir))
  (call-with-output-file path
    (lambda (port)
      (display (render-demo-page) port))
    #:exists 'replace)
  path)

(define (main)
  (define output-path "html/renderer-demo.html")
  (command-line
   #:program "racket -l scribble-tools/html-demo"
   #:once-each
   [("-o" "--output") out
    "Write the demo page to OUT. Default: html/renderer-demo.html"
    (set! output-path out)]
   #:args ()
   (define written (write-demo-page output-path))
   (printf "wrote: ~a\n" (path->string written))))

(module+ main (main))
