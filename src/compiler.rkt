(module click/compliler racket/base
  (require threading)
  (require
   "./frontend/lexer.rkt"
   "./frontend/parser.rkt"
   "./frontend/expander.rkt"
   "./frontend/typechecker.rkt"
   )

  (provide compile-click)

  (define [compile-click input]
    (~> input
        (run-front-end-toolchain)))

  (define [run-front-end-toolchain input]
    (~> input
        (tokenize)
        (parse)
        (expander)))

  )
