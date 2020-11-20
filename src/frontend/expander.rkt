(module click/parser typed/racket/base
  (require racket/match
           racket/format
           typed/racket/class)
  (require "../types.rkt")

  (provide macro-expand)

  #|
  This function will expand basic macros as determined by the # prefix.
  Any symbol with the `#' prefix will be inserted as the first element of a
  new list containing the following element. For example:

  #re"/[abc]+/" would be changed to `(#re "/[abc]+/")' or
  #["two" "strings"] would be changed to (# (:sb "two" "string"))
  |#
  (: macro-expand (-> Ast Ast))
  (define [macro-expand ast]
    (match ast
      [(list (Token a b 'reader d) x xs ...)
       (cons (list (Token a b 'reader d) x) (macro-expand xs))]
      [(cons ':sb xs) (cons ':sb xs)]
      [(cons ':cb xs) (cons ':cb xs)]
      [(cons (Token a b c d) xs)
       (cons (Token a b c d) (macro-expand xs))]
      [(cons (list exprs ...) xs)
       (cons (macro-expand exprs) (macro-expand xs))]
      [(list) (list)])))
