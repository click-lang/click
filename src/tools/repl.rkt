#lang racket/base
(require readline/readline)
(require "help.rkt")
(require "../frontend/reader.rkt")

(define [get-input prompt]
  (let ([input (readline prompt)])
    (add-history input)
    input))
  
(define [repl]
  (define prompt "click~> ")
  (displayln (string-append
              "Welcome to Click v0.0.1\n"
              "type \"$help\" for information on using Click, or \"$exit\" to escape the REPL\n"))
  (let loop ([input (get-input prompt)])
    (cond [(equal? input "$exit")
           (displayln "\nGoodbye!")
           (exit)]
          [(equal? input "$help")
           (click-help)]
          [else (displayln (string->sexpr input))])
    (loop (get-input prompt))))

(provide repl)
