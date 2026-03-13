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
    [(or (set-member? shell-builtins t)
         (and (eq? cls 'name)
              (regexp-match? #px"^[a-z_][a-z0-9_]*$" t)))
     "https://www.gnu.org/software/bash/manual/bash.html#Bourne-Shell-Builtins"]
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
     "https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html"]
    [(and (eq? cls 'name)
          (regexp-match? #px"^[a-z_][a-z0-9_]*$" t))
     "https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html"]
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

