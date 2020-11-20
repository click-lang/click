#lang racket/base

(require rackunit)
(require "../../src/compiler.rkt"
         "../../src/types.rkt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pass cases ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal?
 "Basic parentheses test"
 (compile/tokenize "()")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'r_paren ")")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic curly-brace test"
 (compile/tokenize "{}")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_curly "{")
       (Token 1 2 'r_curly "}")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic brace test"
 (compile/tokenize "[]")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_brace "[")
       (Token 1 2 'r_brace "]")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic integer test"
 (compile/tokenize "42")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'integer "42")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic string test"
 (compile/tokenize "\"Hello world\"")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'string "\"Hello world\"")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic symbol test"
 (compile/tokenize "some_symbol-with<chars>")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'symbol "some_symbol-with<chars>")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic reader test"
 (compile/tokenize "#some_symbol-with<chars>")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'reader "#some_symbol-with<chars>")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic reader test"
 (compile/tokenize "#some_symbol-with<chars>")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'reader "#some_symbol-with<chars>")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Nested parens"
 (compile/tokenize "([{}])")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'l_brace "[")
       (Token 1 3 'l_curly "{")
       (Token 1 4 'r_curly "}")
       (Token 1 5 'r_brace "]")
       (Token 1 6 'r_paren ")")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Basic function call"
 (compile/tokenize "(+ 1 2)")
 (list (Token 0 0 'l_paren "(")
       (Token 1 1 'l_paren "(")
       (Token 1 2 'symbol "+")
       (Token 1 4 'integer "1")
       (Token 1 6 'integer "2")
       (Token 1 7 'r_paren ")")
       (Token 0 0 'r_paren ")")))

(test-equal?
 "Nested function call"
 (compile/tokenize "(~a (+ 1 2) 1.5 \"Hello\" a)")
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
       (Token 0 0 'r_paren ")")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Fail cases ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test-exn
 "Nested function call"
 exn:fail?
 (λ () (compile/tokenize "1.1.1")))
