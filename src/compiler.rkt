(module click/compliler racket/base
  (require racket/function)
  (require threading)
  (require
   "./frontend/lexer.rkt"
   "./frontend/parser.rkt"
   "./frontend/expander.rkt"
   "./frontend/check-syntax.rkt"
   "./frontend/typechecker.rkt"
   )

  (provide
   compile/tokenize
   compile/parse
   compile/check-syntax
   compile/macro-expand
   compile/typecheck
   compile/click)

  (define compile/tokenize tokenize)
  (define compile/parse (compose1 parse compile/tokenize))
  (define compile/macro-expand (compose1 macro-expand compile/parse))
  (define compile/check-syntax (compose1 check-syntax compile/macro-expand))
  (define compile/typecheck (compose1 typecheck compile/check-syntax))

  (define compile/frontend-toolchain compile/typecheck)
  (define compile/backend-toolchain identity)

  (define compile/click
    (compose1 compile/frontend-toolchain
              compile/backend-toolchain))

  )
