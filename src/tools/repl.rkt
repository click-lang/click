(module click/tools/repl racket/base
  (require racket/match
           racket/pretty)
  (require readline/readline)
  (require "../compiler.rkt")

  (provide repl-subcommand)

  (define [repl-subcommand argv]
    (repl))

  (define [get-input prompt]
    (let ([input (readline prompt)])
      (add-history input)
      input))
  
  (define [repl]
    (define prompt "click~> ")
    (displayln (string-append
                "Welcome to Click v0.0.1\n"
                "type \"$help\" for information on using Click, or \"$exit\" to escape the REPL\n"))
    (let loop ([input (get-input prompt)])
      (match input
        ["$exit" (repl-exit)]
        ["$help" (repl-help)]
        [s (pretty-display (compile-click s))])
      (loop (get-input prompt))))

  (define [repl-exit]
    (displayln "\nGoodbye!")
    (exit))

  (define [repl-help]
    (displayln "\nHelp")
    )
  )
