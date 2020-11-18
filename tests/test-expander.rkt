#lang racket/base

(require rackunit)
(require "../src/frontend/lexer.rkt"
         "../src/frontend/expander.rkt"
         "../src/frontend/parser.rkt"
         "../src/frontend/types.rkt")

(test-equal?
 "Basic parentheses test"
 (expander (parse (tokenize "()")))
 '(()))

(test-equal?
 "Basic bracket test"
 (expander (parse (tokenize "[]")))
 '((:sb)))

(test-equal?
 "Basic curly brace test"
 (expander (parse (tokenize "{}")))
 '((:cb)))

(test-equal?
 "Basic function call test"
 (expander (parse (tokenize "(+ 1 2)")))
 `((,(Token 1 2 'symbol "+")
    ,(Token 1 4 'integer "1")
    ,(Token 1 6 'integer "2"))))

(test-equal?
 "Two function calls test"
 (expander (parse (tokenize "(let x 10) (+ x 2)")))
 `((,(Token 1 2 'symbol "let")
    ,(Token 1 6 'symbol "x")
    ,(Token 1 8 'integer "10"))
   (,(Token 1 13 'symbol "+")
    ,(Token 1 15 'symbol "x")
    ,(Token 1 17 'integer "2"))))

(test-equal?
 "Nested let a-la Clojure"
 (expander (parse (tokenize
                   "(let [x 10]
  (+ x 2))")))
 `((,(Token 1 2 'symbol "let")
    (:sb
     ,(Token 1 7 'symbol "x")
     ,(Token 1 9 'integer "10"))
    (,(Token 2 4 'symbol "+")
     ,(Token 2 6 'symbol "x")
     ,(Token 2 8 'integer "2")))))

(test-equal?
 "Defining a fuller function"
 (expander (parse (tokenize
                   "(let f [x y]
  (let sum (+ x y))
  (println #i\"Sum of {x} and {y} is {sum}\")
  sum)

(f 10 20)")))
 `((,(Token 1 2 'symbol "let")
    ,(Token 1 6 'symbol "f")
    (:sb ,(Token 1 9 'symbol "x") ,(Token 1 11 'symbol "y"))
    (,(Token 2 4 'symbol "let")
     ,(Token 2 8 'symbol "sum")
     (,(Token 2 13 'symbol "+")
      ,(Token 2 15 'symbol "x")
      ,(Token 2 17 'symbol "y")))
    (,(Token 3 4 'symbol "println")
     (,(Token 3 12 'reader "#i")
      ,(Token 3 14 'string "\"Sum of {x} and {y} is {sum}\"")))
    ,(Token 4 3 'symbol "sum"))
   (,(Token 6 2 'symbol "f")
    ,(Token 6 4 'integer "10")
    ,(Token 6 7 'integer "20"))))
