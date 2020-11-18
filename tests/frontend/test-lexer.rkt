#lang racket/base

(require rackunit)
(require "../src/frontend/lexer.rkt"
         "../src/frontend/types.rkt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pass cases ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal?
 "Basic parentheses test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'r_paren ")")
       (Token 0 0 'r_paren ")"))
 (tokenize "()"))

(test-equal?
 "Basic curly-brace test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_curly "{")
       (Token 1 2 'r_curly "}")
       (Token 0 0 'r_paren ")"))
 (tokenize "{}"))

(test-equal?
 "Basic brace test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_brace "[")
       (Token 1 2 'r_brace "]")
       (Token 0 0 'r_paren ")"))
 (tokenize "[]"))

(test-equal?
 "Basic integer test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'integer "42")
       (Token 0 0 'r_paren ")"))
 (tokenize "42"))

(test-equal?
 "Basic string test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'string "\"Hello world\"")
       (Token 0 0 'r_paren ")"))
 (tokenize "\"Hello world\""))

(test-equal?
 "Basic symbol test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'symbol "some_symbol-with<chars>")
       (Token 0 0 'r_paren ")"))
 (tokenize "some_symbol-with<chars>"))

(test-equal?
 "Basic reader test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'reader "#some_symbol-with<chars>")
       (Token 0 0 'r_paren ")"))
 (tokenize "#some_symbol-with<chars>"))

(test-equal?
 "Basic reader test"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'reader "#some_symbol-with<chars>")
       (Token 0 0 'r_paren ")"))
 (tokenize "#some_symbol-with<chars>"))

(test-equal?
 "Nested parens"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'l_brace "[")
       (Token 1 3 'l_curly "{")
       (Token 1 4 'r_curly "}")
       (Token 1 5 'r_brace "]")
       (Token 1 6 'r_paren ")")
       (Token 0 0 'r_paren ")"))
 (tokenize "([{}])"))

(test-equal?
 "Basic function call"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'symbol "+")
       (Token 1 4 'integer "1")
       (Token 1 6 'integer "2")
       (Token 1 7 'r_paren ")")
       (Token 0 0 'r_paren ")"))
 (tokenize "(+ 1 2)"))

(test-equal?
 "Nested function call"
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'symbol "~a")
       (Token 1 5 'l_paren "(")
       (Token 1 6 'symbol "+")
       (Token 1 8 'integer "1")
       (Token 1 10 'integer "2")
       (Token 1 11 'r_paren ")")
       (Token 1 13 'float "1.5")
       (Token 1 17 'string "\"Hello\"")
       (Token 1 25 'symbol "a")
       (Token 1 26 'r_paren ")")
       (Token 0 0 'r_paren ")"))
 (tokenize "(~a (+ 1 2) 1.5 \"Hello\" a)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Fail cases ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test-exn
 "Nested function call"
 exn:fail?
 (λ () (tokenize "1.1.1")))
