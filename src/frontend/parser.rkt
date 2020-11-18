(module click/parser typed/racket/base
  (require racket/match
           racket/format
           typed/racket/class)
  (require "types.rkt")

  (provide parse)


  (struct Reader ([tokens : Tokens]
                  [position : Natural])
    #:transparent
    #:mutable)

  (: peek (-> Reader (Maybe Token)))
  (define [peek reader]
    (cond [(>= (Reader-position reader) (length (Reader-tokens reader)))
           (None)]
          [else
           (Some (list-ref (Reader-tokens reader)
                           (Reader-position reader)))]))

  (: next (-> Reader (Maybe Token)))
  (define [next reader]
    (cond [(>= (Reader-position reader) (length (Reader-tokens reader)))
           (None)]
          [else (set-Reader-position! reader (+ 1 (Reader-position reader)))
                (Some (list-ref (Reader-tokens reader)
                                (- (Reader-position reader) 1)))]))
  
  (: parse (-> Tokens Ast))
  (define [parse tokens]
    (match (parse-form (Reader tokens 0))
      [(Token a b c d) (list (Token a b c d))]
      [(list a ...) a]))
  
  (: parse-list-entries (-> Reader TokenType Ast))
  (define [parse-list-entries reader end]
    (let ([token : (Maybe Token) (peek reader)])
      (match token
        [(None) (error 'UnexpectedEOF)]
        [(Some (Token _ _ (== end) _)) null]
        [else
         (cons (parse-form reader) (parse-list-entries reader end))])))

  (: parse-list (-> Reader TokenType TokenType Ast))
  (define [parse-list reader start end]
    (let ([token : (Maybe Token) (next reader)])
      (match token
        [(Some (Token _ _ start _))
         (let ([lst : Ast (parse-list-entries reader end)])
           (next reader)
           lst)]
        [_ (error 'UnexpectedEOF)])))
  
  (: parse-form (-> Reader (U Token Ast)))
  (define [parse-form reader]
    (let ([token : (Maybe Token) (peek reader)])
      (match token
        [(None) null]
        [(Some (Token r c 'r_paren _)) (error 'UnexpectedClosingParen)]
        [(Some (Token r c 'l_paren _)) (parse-list reader 'l_paren 'r_paren)]
        [(Some (Token r c 'r_brace _)) (error 'UnexpectedClosingBrace)]
        [(Some (Token r c 'l_brace _))
         (cons ':sb (parse-list reader 'l_brace 'r_brace))]
        [(Some (Token r c 'r_curly _)) (error 'UnexpectedClosingCurly)]
        [(Some (Token r c 'l_curly _))
         (cons ':cb (parse-list reader 'l_curly 'r_curly))]
        ;; Any atomic value: numbers, strings, symbols, etc
        [(Some a) (maybe-then (next reader))]))))
