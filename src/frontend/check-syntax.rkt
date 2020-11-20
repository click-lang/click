(module click/frontend/check-syntax typed/racket/base
  (require racket/match)
  (require "../types.rkt")

  (provide check-syntax)

  (: check-syntax (-> Ast SyntaxCheckedAst))
  (define [check-syntax ast]
    (match ast
      [(list) (list)]
      [(list (list xs ...) ys ...)
       (cons (check-syntax xs) (check-syntax ys))]
      [(cons (Token r c t "let") xs)
       (check-let (cons (Token r c t "let") xs))]
      [(cons (Token r c t "do") xs)
       (check-do (cons (Token r c t "do") xs))]
      [(cons (Token r c t "if") xs)
       (check-if (cons (Token r c t "if") xs))]
      ;; TODO
      [(cons (Token r c t "struct") xs)
       (check-struct (cons (Token r c t "struct") xs))]
      ;; TODO
      [(cons (Token r c t "type") xs)
       (check-type (cons (Token r c t "type") xs))]
      ;; TODO
      [(cons (Token r c t "interface") xs)
       (check-interface (cons (Token r c t "interface") xs))]
      ;; TODO
      [(cons (Token r c t "module") xs)
       (check-module (cons (Token r c t "module") xs))]
      ;; TODO
      [(cons (Token r c t "require") xs)
       (check-require (cons (Token r c t "require") xs))]
      ;; TODO
      [(cons (Token r c t "provide") xs)
       (check-provide (cons (Token r c t "provide") xs))]
      ;; TODO
      [(cons (Token r c t "error") xs)
       (check-error (cons (Token r c t "error") xs))]
      ;; TODO
      [(cons (Token r c t ":") xs)
       (check-: (cons (Token r c t ":") xs))]
      ;; TODO
      [(cons (Token r c t "->") xs)
       (check--> (cons (Token r c t "->") xs))]
      ;; TODO
      [(cons (Token r c t "cond") xs)
       (check-cond (cons (Token r c t "cond") xs))]
      ;; TODO
      [(cons (Token r c t "match") xs)
       (check-match (cons (Token r c t "match") xs))]
      [(cons (Token r c t v) xs)
       (cons (Token r c t v) (check-syntax xs))]))

  #|
  All of the possible forms for `let`

  - Defining variables at current scope:
  (let id value)
  - Defining lexically scoped variables:
  (let {ids values ... ...} body ...)
  - Defining lexically scoped variables bound to a named block
  (let id {ids values ... ...} body ...)
  - Defining a function
  (let id [ids ...] body ...)
  - Defining multiple forms for a given function
  (let id ([ids ...] body ...) ...)
  |#
  (: check-let (-> Ast SyntaxCheckedAst))
  (define [check-let stx]
    (match stx
      ;; (define id val) -- Racket
      [(list l id value) (list l id value)]
      ;; (let [id val ... ...] body ...) -- Clojure
      [(list l (list ':cb ids ...) body ...)
       (cons l (cons (cons ':cb ids) (check-syntax body)))]
      ;; (let tag ((id val) ...) body ...) -- Racket
      [(list l id (list ':cb ids ...) body ...)
       (cons l (cons id (cons (cons ':cb ids) (check-syntax body))))]
      ;; (defun id (ids ...) body ...) -- Common Lisp
      [(list l id (list ':sb binds ...) body ...)
       (cons l (cons id (cons (cons ':sb binds) (check-syntax body))))]
      ;; (defn fnName ([id ...] body ...) ...) -- Clojure
      ;; No multi-arity functions for now - TODO
      ;; [(list l id (list (list ':sb ids ...) body ...) ...)
      ;;  (append (list l) (list id) (check-function-def bodies))]
      ;; If none of these syntaxes match, then there's a syntax error
      [_ (stx->error stx)]))

  (: check-function-def (-> (U Ast Metadata Token) SyntaxCheckedAst))
  (define [check-function-def stx]
    (println stx)
    (match stx
      [(cons (cons ':sb bindings) body)
       (cons (cons ':sb bindings) body)]
      [(cons x xs)
       (cons (check-function-def x)
             (check-function-def xs))]
      [a (match a
           [(or ':sb ':cb) (error 'UnexpectedInternalError1)]
           [(Token a b c d) (stx->error (list (Token a b c d)))]
           [_ (error 'UnexpectedInternalError2)])]
      [_ (error 'UnexpectedInternalError3)]))

  #|
  Check all possible inputs for `if`. Whenever `$cond`, `then` or `else`
  are a list ,they need to be syntax checked.

  `if` must have two arguments supplied to it ,one armed ifs aren 't valid.
  |#
  (: check-if (-> Ast SyntaxCheckedAst))
  (define [check-if stx]
    (match stx
      [(list l (list $cond ...) (list $then ...) (list $else ...))
       (list l (check-syntax $cond) (check-syntax $then) (check-syntax $else))]
      [(list l (list $cond ...) (list $then ...) $else)
       (list l (check-syntax $cond) (check-syntax $then) $else)]
      [(list l (list $cond ...) $then (list $else ...))
       (list l (check-syntax $cond) $then (check-syntax $else))]
      [(list l $cond (list $then ...) (list $else ...))
       (list l $cond (check-syntax $then) (check-syntax $else))]
      [(list l (list $cond ...) $then $else)
       (list l (check-syntax $cond) $then $else)]
      [(list l $cond (list $then ...) $else)
       (list l $cond (check-syntax $then) $else)]
      [(list l $cond $then (list $else ...))
       (list l $cond $then (check-syntax $else))]
      [(list l $cond $then $else)
       (list l $cond $then $else)]
      [_ (stx->error stx)]))

  (: check-error (-> Ast SyntaxCheckedAst))
  (define [check-error stx]
    (match stx
      [(list e) (stx->error (list e))]
      [(list e (Token a b c d) (Token m n o p))
       (list e (Token a b c d) (Token m n o p))]
      [(list e (Token a b c d)) (list e (Token a b c d))]
      [_ (stx->error stx)]))

  (: check-cond (-> Ast SyntaxCheckedAst))
  (define [check-cond stx] stx)

  (: check-match (-> Ast SyntaxCheckedAst))
  (define [check-match stx] stx)

  (: check-struct (-> Ast SyntaxCheckedAst))
  (define [check-struct stx]
    (match stx
      [(list s (Token r c 'symbol v) (list attrs ...))
       (list s (Token r c 'symbol v) (check-hash attrs))]
      [(list s (list t ...) (list attrs ...))
       (list s (check-all-tokens t) (check-hash attrs))]
      [(list s (Token r c 'symbol v) (list attrs ...) settings ...)
       (list s (Token r c 'symbol v)
             (check-hash attrs) (check-all-tokens settings))]
      [(list s (list t ...) (list attrs ...) settings ...)
       (list s (check-all-tokens t)
             (check-hash attrs) (check-all-tokens settings))]))

  (: check-hash (-> Ast SyntaxCheckedAst))
  (define [check-hash stx]
    (match stx
      [(cons ':cb xs) (cons ':cb (check-hash xs))]
      [(list) (list)]
      [(list a) (stx->error (list a))]
      [(cons (Token a b c d) (cons x xs))
       (cons (Token a b c d)
             (cons (match x
                     [(Token a b c d) (Token a b c d)]
                     [(list xs ...) (check-syntax xs)])
                   (check-hash xs)))]
      [_ (println stx) (error 'UnexpectedError)]))

  (: check-type (-> Ast SyntaxCheckedAst))
  (define [check-type stx] stx)

  (: check-interface (-> Ast SyntaxCheckedAst))
  (define [check-interface stx]
    (match stx
      [(list i (Token r c 'symbol v) bindings ...)
       (cons i (cons (Token r c 'symbol v) (check-list-of bindings check-:)))]
      [(list i (list interface-sig ...) bindings ...)
       (cons i (cons (check-all-tokens interface-sig)
                     (check-list-of bindings check-:)))]))

  (: check-module (-> Ast SyntaxCheckedAst))
  (define [check-module stx] stx)

  (: check-require (-> Ast SyntaxCheckedAst))
  (define [check-require stx]
    (match stx
      [(list xs ...) (check-all-tokens xs)]
      [_ (stx->error stx)]))

  (: check-provide (-> Ast SyntaxCheckedAst))
  (define [check-provide stx]
    (match stx
      [(list xs ...) (check-all-tokens xs)]
      [_ (stx->error stx)]))

  (: check-: (-> Ast SyntaxCheckedAst))
  (define [check-: stx]
    (match stx
      [(list t (Token r c 'symbol v) (list typesig ...))
       (list t (Token r c 'symbol v) (check--> typesig))]
      [(list t (list generics ...) (list typesig ...))
       (list t (check-all-tokens generics) (check--> typesig))]
      [_ (stx->error stx)]))

  (: check--> (-> Ast SyntaxCheckedAst))
  (define [check--> stx] stx)

  #|
  Nothing much to syntax check here
  (do
  (let x 10)
  (let y 20)
  (println (+ x y)))
  |#
  (: check-do (-> Ast SyntaxCheckedAst))
  (define [check-do stx]
    (match stx
      [(cons d body)
       (cons d (check-syntax body))]
      [_ (stx->error stx)]))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;; Helper functions ;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (: check-parameterized-name (-> (U Token Ast) (U Token SyntaxCheckedAst)))
  (define [check-parameterized-name stx]
    (match stx
      [(Token a b c d) (Token a b c d)]
      [(list tokens ...) (check-all-tokens tokens)]))
  
  (: check-all-tokens (-> Ast SyntaxCheckedAst))
  (define [check-all-tokens stx]
    (if (all-tokens? stx)
        stx
        (stx->error stx)))
  
  (: all-tokens? (-> Ast Boolean))
  (define [all-tokens? stx]
    (match stx
      [(list) #true]
      [(cons (Token _ _ _ _) xs) (all-tokens? xs)]
      [_ #false]))

  (: check-list-of (-> Ast (-> Ast SyntaxCheckedAst) SyntaxCheckedAst))
  (define [check-list-of stx fun]
    (match stx
      [(list) (list)]
      [(cons (list xs ...) ys) (cons (fun xs) (check-list-of ys fun))]
      [(cons x xs) (error "Probably shouldn't hit here?")]))

  (: stx->error (-> Ast (Listof SyntaxError)))
  (define [stx->error stx]
    (let* ([token : Token (get-first-token stx)]
           [row : Natural (Token-row token)]
           [col : Natural (Token-col token)])
      (list (SyntaxError row col "" ""))))

  (: get-first-token (-> Ast Token))
  (define [get-first-token stx]
    (println stx)
    (match stx
      [(list (Token a b c d) xs ...) (Token a b c d)]
      [_ (error "I have no idea how we got here")])))
