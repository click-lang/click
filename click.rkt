#lang racket/base

(require racket/cmdline
         racket/match)

(require
 "./src/tools/errors.rkt"
 "./src/tools/docs.rkt"
 "./src/tools/help.rkt"
 "./src/tools/repl.rkt"
 "./src/tools/proj.rkt"
 "./src/tools/pkg.rkt"
 "./src/tools/version.rkt"
 )

(let main ([argv (vector->list (current-command-line-arguments))])
  (match argv
    [(cons "pkg" xs) (pkg-subcommand xs)]
    [(cons "docs" xs) (docs-subcommand xs)]
    [(cons "help" xs) (help-subcommand xs)]
    [(cons "proj" xs) (proj-subcommand xs)]
    [(cons "repl" xs) (repl-subcommand xs)]
    [(cons "version" xs) (version-subcommand xs)]
    [(list) (repl-subcommand)]
    [_ (unknown-command-error (car argv) "click")]
    ))
