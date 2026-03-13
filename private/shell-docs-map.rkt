#lang racket/base

(require racket/set
         racket/string)

(provide shell-doc-url-for-token
         normalize-shell-docs-source)

(define (normalize-shell-docs-source who v)
  (cond
    [(eq? v 'pwsh) 'powershell]
    [(memq v '(auto bash zsh powershell posix none)) v]
    [else
     (raise-argument-error who
                           "(or/c 'auto 'bash 'zsh 'powershell 'pwsh 'posix 'none)"
                           v)]))

(define bash-keywords
  (list->set
   '("if" "then" "elif" "else" "fi"
     "for" "while" "until" "do" "done"
     "case" "in" "esac" "select" "function" "time" "coproc")))

(define shell-builtins
  (list->set
   '("cd" "echo" "printf" "read"
     "export" "unset" "readonly"
     "alias" "unalias"
     "set" "shift" "test" "source" "." "eval" "exec" "exit" "return")))

(define zsh-builtins
  (list->set
   '("autoload" "setopt" "unsetopt" "emulate" "typeset" "local" "zmodload")))

(define powershell-keyword-url
  (hash "if" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if"
        "elseif" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if"
        "else" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if"
        "switch" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_switch"
        "for" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_for"
        "foreach" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_foreach"
        "while" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_while"
        "do" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_do"
        "until" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_do"
        "break" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_break"
        "continue" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_continue"
        "function" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions"
        "filter" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions"
        "param" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters"
        "begin" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods"
        "process" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods"
        "end" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods"
        "return" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_return"
        "throw" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_throw"
        "try" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally"
        "catch" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally"
        "finally" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally"
        "trap" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_trap"
        "class" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes"
        "enum" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_enum"
        "using" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_using"))

(define powershell-cmdlet-url
  (hash "get-childitem" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem"
        "set-location" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-location"
        "get-content" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content"
        "set-content" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-content"
        "new-item" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item"
        "copy-item" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item"
        "move-item" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/move-item"
        "remove-item" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item"
        "test-path" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path"
        "join-path" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path"
        "get-command" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-command"
        "get-help" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help"
        "select-object" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object"
        "where-object" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object"
        "foreach-object" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object"
        "sort-object" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object"
        "measure-object" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/measure-object"
        "convertto-json" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json"
        "convertfrom-json" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json"
        "invoke-restmethod" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod"
        "invoke-webrequest" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest"
        "write-output" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-output"
        "write-host" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host"
        "write-warning" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-warning"
        "write-error" "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-error"))

(define posix-command-url
  (hash "." "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/dot.html"
        "alias" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/alias.html"
        "unalias" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/unalias.html"
        "cd" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/cd.html"
        "echo" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/echo.html"
        "printf" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html"
        "read" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html"
        "export" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "unset" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "readonly" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "set" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_19"
        "shift" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "test" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html"
        "source" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/dot.html"
        "eval" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "exec" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "exit" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"
        "return" "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15"))

(define bash-command-fragments
  (hash "." ". [-p path] filename [arguments]"
        "alias" "alias [-p] [name[=value] ...]"
        "unalias" "unalias [-a] [name ...]"
        "cd" "cd [-L|[-P [-e]] [-@]] [dir]"
        "echo" "echo [-neE] [arg ...]"
        "printf" "printf [-v var] format [arguments]"
        "read" "read [-ers] [-a aname] [-d delim]"
        "export" "export [-fn] [name[=value] ...]"
        "unset" "unset [-f] [-v] [-n] [name ...]"
        "readonly" "readonly [-aAf] [-p] [name[=value] ...]"
        "set" "set [--abefhkmnptuvxBCEHPT]"
        "shift" "shift [n]"
        "test" "test expr"
        "source" "source [-p path] filename [arguments]"
        "eval" "eval [arguments]"
        "exec" "exec [-cl] [-a name] [command [arguments]]"
        "exit" "exit [n]"
        "return" "return [n]"))

(define bash-command-entry-url
  (hash "." "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-_002e"
        "alias" "https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-alias"
        "unalias" "https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-unalias"
        "cd" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-cd"
        "echo" "https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-echo"
        "printf" "https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-printf"
        "read" "https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-read"
        "export" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-export"
        "unset" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-unset"
        "readonly" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-readonly"
        "set" "https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#index-set"
        "shift" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-shift"
        "test" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-test"
        "source" "https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-source"
        "eval" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-eval"
        "exec" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-exec"
        "exit" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-exit"
        "return" "https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-return"))

(define zsh-entry-no-bracket
  (list->set
   '("." ":" "bye" "chdir")))

(define (unreserved-char? c)
  (or (char-alphabetic? c)
      (char-numeric? c)
      (memv c '(#\- #\_ #\. #\~))))

(define (hex2 n)
  (define digits "0123456789ABCDEF")
  (string (string-ref digits (quotient n 16))
          (string-ref digits (remainder n 16))))

(define (pct-encode s)
  (define out (open-output-string))
  (for ([ch (in-string s)])
    (cond
      [(unreserved-char? ch) (write-char ch out)]
      [else
       (display "%" out)
       (display (hex2 (char->integer ch)) out)]))
  (get-output-string out))

(define (zsh-fragment-for-command token)
  (cond
    [(string=? token ".") "`.` file [ arg ... ]"]
    [(set-member? zsh-entry-no-bracket token)
     (string-append "`" token "`")]
    [else
     ;; Most builtin entries begin with a synopsis line like: `cmd` [ ... ]
     ;; Using this fragment avoids matching incidental mentions earlier on the page.
     (string-append "`" token "` [")]))

(define (zsh-text-fragment-url fragment)
  (string-append
   "https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html#:~:text="
   (pct-encode fragment)))

(define bash-builtins-url
  "https://www.gnu.org/software/bash/manual/bash.html#Bash-Builtins")

(define (bash-fragment-for-command token)
  (hash-ref bash-command-fragments token
            (string-append token " [")))

(define (resolve-shell-docs-source shell docs-source)
  (case (normalize-shell-docs-source 'shell-doc-url-for-token docs-source)
    [(none) 'none]
    [(auto) shell]
    [else docs-source]))

(define (bash-url cls token)
  (define t (string-downcase (string-trim token)))
  (cond
    [(or (string=? t "$")
         (regexp-match? #px"^\\$\\{?" t))
     "https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters"]
    [(set-member? bash-keywords t)
     (cond
       [(member t '("if" "then" "elif" "else" "fi" "case" "in" "esac"))
        "https://www.gnu.org/software/bash/manual/bash.html#Conditional-Constructs"]
       [(member t '("for" "while" "until" "do" "done" "select"))
        "https://www.gnu.org/software/bash/manual/bash.html#Looping-Constructs"]
       [else
        "https://www.gnu.org/software/bash/manual/bash.html#Shell-Functions"])]
    [(set-member? shell-builtins t)
     (hash-ref bash-command-entry-url t bash-builtins-url)]
    [(and (eq? cls 'name)
          (regexp-match? #px"^[a-z_][a-z0-9_]*$" t)
          (set-member? shell-builtins t))
     (hash-ref bash-command-entry-url t bash-builtins-url)]
    [else #f]))

(define (zsh-url cls token)
  (define t (string-downcase (string-trim token)))
  (cond
    [(or (string=? t "$")
         (regexp-match? #px"^\\$\\{?" t))
     "https://zsh.sourceforge.io/Doc/Release/Parameters.html"]
    [(set-member? bash-keywords t)
     (cond
       [(member t '("if" "then" "elif" "else" "fi" "case" "in" "esac"))
        "https://zsh.sourceforge.io/Doc/Release/Shell-Grammar.html#Conditional-Expressions"]
       [(member t '("for" "while" "until" "do" "done" "select"))
        "https://zsh.sourceforge.io/Doc/Release/Shell-Grammar.html#Loops"]
       [else
        "https://zsh.sourceforge.io/Doc/Release/Functions.html"])]
    [(or (set-member? shell-builtins t)
         (set-member? zsh-builtins t))
     (zsh-text-fragment-url (zsh-fragment-for-command t))]
    [(and (eq? cls 'name)
          (regexp-match? #px"^[a-z_][a-z0-9_]*$" t)
          (or (set-member? shell-builtins t)
              (set-member? zsh-builtins t)))
     (zsh-text-fragment-url (zsh-fragment-for-command t))]
    [else #f]))

(define (posix-url cls token)
  (define t (string-downcase (string-trim token)))
  (cond
    [(or (string=? t "$")
         (regexp-match? #px"^\\$\\{?" t))
     "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02"]
    [(set-member? bash-keywords t)
     (cond
       [(member t '("if" "then" "elif" "else" "fi"
                    "for" "while" "until" "do" "done"
                    "case" "in" "esac"))
        "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_04"]
       [(member t '("function"))
        "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_05"]
       [else
        ;; Non-POSIX shell words like `coproc` should not point at random sections.
        #f])]
    [(or (set-member? shell-builtins t)
         (and (eq? cls 'name) (regexp-match? #px"^[a-z_][a-z0-9_]*$" t)))
     (hash-ref posix-command-url
               t
               "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_15")]
    [else #f]))

(define (powershell-url cls token)
  (define raw (string-trim token))
  (define t (string-downcase raw))
  (cond
    [(or (string=? t "$")
         (regexp-match? #px"^\\$\\{?" t))
     "https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables"]
    [(hash-ref powershell-keyword-url t #f)
     (hash-ref powershell-keyword-url t #f)]
    [(hash-ref powershell-cmdlet-url t #f)
     (hash-ref powershell-cmdlet-url t #f)]
    [(and (eq? cls 'keyword)
          (regexp-match? #px"^[a-z][a-z0-9]*-[a-z][a-z0-9-]*$" t))
     (string-append
      "https://learn.microsoft.com/en-us/search/?terms="
      (pct-encode raw)
      "%20site%3Alearn.microsoft.com%2Fpowershell%2Fmodule")]
    [else #f]))

(define (shell-doc-url-for-token shell cls token #:docs-source [docs-source 'auto])
  (case (resolve-shell-docs-source shell docs-source)
    [(none) #f]
    [(bash) (bash-url cls token)]
    [(zsh) (zsh-url cls token)]
    [(powershell) (powershell-url cls token)]
    [(posix) (posix-url cls token)]
    [else #f]))
