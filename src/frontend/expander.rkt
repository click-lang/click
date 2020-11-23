(module click/parser typed/racket/base
  (require racket/match
           racket/format
           typed/racket/class)
  (require "../types.rkt")

  (provide macro-expand
           expand-let
           expand-match
           expand-cond)

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
      [(cons (Token a b c "let") xs)
       (expand-let (cons (Token a b c "let") xs))]
      [(cons (Token a b c "cond") xs)
       (expand-cond (cons (Token a b c "cond") xs))]
      [(cons (Token a b c d) xs)
       (cons (Token a b c d) (macro-expand xs))]
      [(cons (list exprs ...) xs)
       (cons (macro-expand exprs) (macro-expand xs))]
      [(list) (list)]))

  (: expand-let (-> Ast Ast))
  (define [expand-let stx]
    (match stx
      ;; Expand a typed `let`
      [(list l (Token a b 'symbol id) (Token c d e ":") type value)
       (list (list (Token c d e ":") (Token a b 'symbol id) type)
             (list l (Token a b 'symbol id) value))]
      ;; Expand function definition
      ;; (let f [x] (+ x 2)) -> (let f (fn [x] (+ x 2)))
      [(list l (Token a b 'symbol id) (cons ':sb ids) body ...)
       (list l (Token a b 'symbol id)
             (cons (Token a b 'symbol "fn")
                   (cons (cons ':sb ids) (macro-expand body))))]
      ;; Expand multi-arity functions
      ;; (let f ([] (f 10)) ([x] (+ x 10)))
      ;; (let f (fn [& argv] (match argv [] => (f 10) [x] => (+ x 10))))
      [(list l (Token a b 'symbol name) bodies ...)
       (match bodies
         [(list (list [cons ':sb args] body ...) ...)
          (define argv : String (symbol->string (gensym 'argv)))
          (list l (Token a b 'symbol name)
                (list (Token a b 'symbol "fn")
                      (list ':sb (Token a b 'symbol "&")
                            (Token a b 'symbol argv))
                      (cons (Token a b 'symbol "match")
                            (cons (Token a b 'symbol argv)
                                  (expand-multi-arity-let bodies)))))]
         [_ (cons l (cons (Token a b 'symbol name) bodies))])]
      [a a]))

  (: expand-multi-arity-let (-> Ast Ast))
  (define [expand-multi-arity-let stx] 
    (match stx
      [(list) (list)]
      [(cons (list args body ...) xs)
       (define start-of-body : Token (get-first-token body))
       (define row (Token-row start-of-body))
       (define col (Token-col start-of-body))
       (append (list args (Token row col 'symbol "=>")
                     (cons (Token row col 'symbol "do") body))
               (expand-multi-arity-let xs))])) 

  (: expand-cond (-> Ast Ast))
  (define [expand-cond stx]
    (match stx
      [(list) (list)]
      [(list (Token a b c "cond") x y z conds ...)
       (append (list (Token a b c "if"))
               (list x)
               (list z)
               (expand-cond conds))]
      [(list (Token a b c "else") (Token x y z "=>") body) (list body)]
      [(list (Token a b c d) (Token _ _ _ "=>") body conds ...)
       (list (append (list (Token a b c "if"))
                     (list (Token a b c d))
                     (list body)
                     (expand-cond conds)))]))

  (: expand-match (-> Ast Ast))
  (define [expand-match stx]
    (match stx
      [(list) (list)]
      [(list (Token a b c "match") patterns ...)
       (cons (Token a b c "match") (expand-match patterns))]
      [(list p (Token x y z "=>") body patts ...)
       (list (Token x y z "if") p body (expand-match patts))]))

  (: token-from (-> Token TokenType String Token))
  (define [token-from token new-type new-value]
    (define row (Token-row token))
    (define col (Token-col token))
    (Token row col new-type new-value))

  (: get-first-token (-> Ast Token))
  (define [get-first-token stx]
    (match stx
      [(list (Token a b c d) xs ...) (Token a b c d)]
      [(list (list xs ...) ys ...)
       (get-first-token xs)]))
  
  )
