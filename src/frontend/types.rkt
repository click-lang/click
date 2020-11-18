(module click/types typed/racket/base
  (require "adt.rkt")
  (require racket/match)
  (provide (all-defined-out))

  (define-type TokenType
    (U 'symbol 'string 'integer 'float 'reader 'special 'keyword
       'l_paren 'r_paren 'l_brace 'r_brace 'l_curly 'r_curly))

  (define-type Metadata
    (U ':sb ':cb))

  (define-type Ast
    (Listof (U Ast Token Metadata)))

  (: maybe-then (∀ [a] (Maybe a) -> (U a Null)))
  (define/match [maybe-then m]
    [((Some a)) a]
    [((None)) '()])

  (define-datatype (Maybe a)
    None
    (Some a))

  (define-type Tokens (Listof Token))
  
  (struct Token
    ([row : Integer]
     [col : Integer]
     [type : TokenType]
     [value : String])
    #:transparent)

  (struct SyntaxError
    ([row : Integer]
     [col : Integer]
     [loc : String])
    #:transparent))
