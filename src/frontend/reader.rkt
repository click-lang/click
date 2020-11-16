#lang typed/racket/base

(require racket/match
         racket/format)
(require datatype
         data/either
         data/maybe
         dyoo-while-loop)

(define-type TokenType
  (U 'symbol 'string 'integer 'float 'hash 'reader
     'l_paren 'r_paren 'l_brace 'r_brace 'l_curly 'r_curly))

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
  #:transparent)

(: lex (-> String Integer Integer (Listof Token)))
(define [lex input row col]
  (if (string=? input "")
      '()  
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
        [#\newline (lex (substring input 1) (+ 1 row) 1)]
        [#\space (lex (substring input 1) row (+ 1 col))]
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
        [_ (let* ([token (lex-symbol input row col 'symbol)]
                  [len (string-length (Token-value token))])
             (cons token (lex (substring input len) row (+ col len))))])))

(: delimiter? (-> Char Boolean))
(define [delimiter? char]
  (case char
    [(#\( #\) #\[ #\] #\{ #\} #\space #\, #\" #\') #true]
    [else #false]))

(: lex-symbol (-> String Integer Integer TokenType Token))
(define [lex-symbol input row col type]
  (define token
    (for/fold ([token : String ""])
              ([char : Char input]
               #:break (delimiter? char))
      (~a token char)))
  (Token row col type token))

(: lex-string (-> String Integer Integer Token))
(define [lex-string input row col]
  (define token
    (for/fold ([token : String "\""])
              ([char : Char (substring input 1)]
               #:break (char=? char #\"))
      (~a token char)))

  (Token row col 'string (~a token "\"")))

(: lex-number (-> String Integer Integer Token))
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

  (Token row col (if float? 'float 'integer) token))

(println (lex "(println (~a 1.1 #re\"Hello world\"))" 1 1))
