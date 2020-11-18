(module click/types typed/racket/base
  (require (for-syntax syntax/parse
                       syntax/stx
                       racket/syntax
                       racket/base
                       racket/sequence))
  (require racket/match)
  (provide (all-defined-out))

  (begin-for-syntax
    (define-syntax-class type
      (pattern name:id
               #:attr [param 1] '()
               #:attr [field-id 1] '())
      (pattern (name:id param ...+)
               #:attr [field-id 1] (generate-temporaries #'(param ...)))))

  (define-syntax define-datatype
    (syntax-parser
      [(_ type-name:type data-constructor:type ...)

       (define/with-syntax [data-type ...]
         (for/list ([name (in-syntax #'(data-constructor.name ...))])
           (if (stx-null? #'(type-name.param ...))
               name
               #`(#,name type-name.param ...))))

       #'(begin
           (struct (type-name.param ...) data-constructor.name
             ([data-constructor.field-id : data-constructor.param] ...)) ...
           (define-type type-name (U data-type ...)))]))

  (define-type TokenType
    (U 'symbol 'string 'integer 'float 'reader 'special 'keyword
       'l_paren 'r_paren 'l_brace 'r_brace 'l_curly 'r_curly))

  (define-type Metadata
    (U ':sb ':cb))

  (struct SyntaxError
    ([row : Natural]
     [col : Natural]
     [msg : String]
     [filename : String])
    #:transparent)

  (define-type SyntaxCheckedAst
    (Listof (U SyntaxCheckedAst Token Metadata SyntaxError)))
  
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
    ([row : Natural]
     [col : Natural]
     [type : TokenType]
     [value : String])
    #:transparent)

  )
