#lang racket/base

(require rackunit)
(require "../../src/frontend/lexer.rkt"
         "../../src/frontend/expander.rkt"
         "../../src/frontend/parser.rkt"
         "../../src/frontend/check-syntax.rkt"
         "../../src/types.rkt")

(test-equal? "example" 1 2)
