(module click/reader typed/racket/base
  (require racket/match
           racket/format)
  (require "../types.rkt")
  (provide tokenize)

  (: tokenize (-> String (Listof Token)))
  (define [tokenize input]
    (cons (Token 0 0 'l_paren "(") (lex input 1 1)))

  (: lex (-> String Natural Natural (Listof Token)))
  (define [lex input row col]
    (if (string=? input "")
        (list (Token 0 0 'r_paren ")"))
        (match (string-ref input 0)
          [#\( (cons (Token row col 'l_paren "(")
                     (lex (substring input 1) row (+ 1 col)))]  
          [#\) (cons (Token row col 'r_paren ")")
                     (lex (substring input 1) row (+ 1 col)))]
          [#\[ (cons (Token row col 'l_brace "[")
                     (lex (substring input 1) row (+ 1 col)))]  
          [#\] (cons (Token row col 'r_brace "]")
                     (lex (substring input 1) row (+ 1 col)))]
          [#\{ (cons (Token row col 'l_curly "{")
                     (lex (substring input 1) row (+ 1 col)))]  
          [#\} (cons (Token row col 'r_curly "}")
                     (lex (substring input 1) row (+ 1 col)))]
          ;;; The reader macros for quoting I'm keeping commented for now and
          ;;; will have the implemented with `#'` readers for now
          ;; [#\' (cons (Token row col 'special "'")
          ;;            (lex (substring input 1) row (+ 1 col)))]
          ;; [#\` (cons (Token row col 'special "`")
          ;;            (lex (substring input 1) row (+ 1 col)))]
          ;; [#\~ (if (char=? (string-ref input 1) #\@)
          ;;          (cons (Token row col 'special "~@")
          ;;                (lex (substring input 1) row (+ 2 col)))
          ;;          (cons (Token row col 'special "~")
          ;;                (lex (substring input 1) row (+ 1 col))))]
          [#\newline (lex (substring input 1) (+ 1 row) 1)]
          [#\space (lex (substring input 1) row (+ 1 col))]
          [#\, (lex (substring input 1) row (+ 1 col))]
          [(? char-numeric? n)
           (let* ((token (lex-number input row col))
                  (len (string-length (Token-value token)))) 
             (cons token (lex (substring input len) row (+ col len))))]
          [#\" (let* ([token (lex-string input row col)]
                      [len (string-length (Token-value token))])
                 (cons token (lex (substring input len) row (+ col len))))]
          [#\# (let* ([token (lex-symbol input row col 'reader)]
                      [len (string-length (Token-value token))])
                 (cons token (lex (substring input len) row (+ col len))))]
          [#\: 
           (let* ([token
                   (lex-symbol input row col
                               (if (char-whitespace? (string-ref input 1))
                                   'symbol
                                   'keyword))]
                  [len (string-length (Token-value token))])
             (cons token (lex (substring input len) row (+ col len))))]
          [_ (let* ([token (lex-symbol input row col 'symbol)]
                    [len (string-length (Token-value token))])
               (cons token (lex (substring input len) row (+ col len))))])))

  (: delimiter? (-> Char Boolean))
  (define [delimiter? char]
    (case char
      [(#\( #\) #\[ #\] #\{ #\} #\space #\, #\" #\') #true]
      [else #false]))

  (: lex-symbol (-> String Natural Natural TokenType Token))
  (define [lex-symbol input row col type]
    (define token
      (for/fold ([token : String ""])
                ([char : Char input]
                 #:break (delimiter? char))
        (~a token char)))
    (Token row col type token))

  (: lex-string (-> String Natural Natural Token))
  (define [lex-string input row col]
    (define token
      (for/fold ([token : String "\""])
                ([char : Char (substring input 1)]
                 #:break (char=? char #\"))
        (~a token char)))

    (Token row col 'string (~a token "\"")))

  (: lex-number (-> String Natural Natural Token))
  (define [lex-number input row col]
    (define float? : Boolean #f)
    (define token
      (for/fold ([token : String ""])
                ([char : Char input]
                 #:break (delimiter? char))
        (~a token
            (cond [(char-numeric? char) char]
                  [(and float? (char=? char #\.)) 
                   (error 'SyntaxError "Invalid number")]
                  [(char=? char #\.)
                   (set! float? #t)
                   char]
                  [else
                   (error "UNEXPECTED TOKEN")]))))
    (Token row col (if float? 'float 'integer) token)))
