#lang racket/base

(require racket/set
         racket/string)

(provide shell-doc-url-for-token
         normalize-shell-docs-source)

(define (normalize-shell-docs-source who v)
  (cond
    [(memq v '(auto bash zsh posix none)) v]
    [else
     (raise-argument-error who
                           "(or/c 'auto 'bash 'zsh 'posix 'none)"
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
    [(eq? cls 'keyword)
     "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09"]
    [(eq? cls 'name)
     "https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_14"]
    [else #f]))

(define (shell-doc-url-for-token shell cls token #:docs-source [docs-source 'auto])
  (case (resolve-shell-docs-source shell docs-source)
    [(none) #f]
    [(bash) (bash-url cls token)]
    [(zsh) (zsh-url cls token)]
    [(posix) (posix-url cls token)]
    [else #f]))
