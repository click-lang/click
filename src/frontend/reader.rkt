#lang racket/base
(require racket/port)

(define [string->sexpr str]
  (call-with-input-string
   str
   (lambda (in)
     (parameterize ([read-square-bracket-with-tag #t]
                    [read-curly-brace-with-tag #t])
       (read in)))))

(provide string->sexpr)
