#lang racket/base

(require "repl.rkt")

(let main ([args (current-command-line-arguments)])
  (let ([head (vector-ref args 0)])
    (cond [(equal? head "repl") (repl)])))
