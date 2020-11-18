(module click/tools/error racket/base
  (provide unknown-command-error)

  (define [unknown-command-error cmd subcmd]
    (displayln
     (string-append
      "The command '" cmd "' is not a sub-command of '" subcmd "'."))))
