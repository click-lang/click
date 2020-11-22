(module click/tests/util typed/racket/base
  (provide last-gensym)
  
  (: last-gensym (-> Symbol Symbol))
  (define [last-gensym sym]
    (let* ([sym : String (symbol->string (gensym sym))]
           [last-idx : Integer (- (string-length sym) 1)]
           [last-char : String (substring sym last-idx)]
           [last-num : (U Complex False) (string->number last-char)])
      (if last-num
          (let ([new-last : Char (string-ref
                                  (number->string (- last-num 1)) 0)])
            (string-set! sym last-idx new-last)
            (string->symbol sym))
          (error 'SymbolNotPreviouslyGenerated)))))
