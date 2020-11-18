#lang racket/base

(require rackunit)
(require "../src/frontend/lexer.rkt"
         "../src/frontend/parser.rkt"
         "../src/frontend/types.rkt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pass cases ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal?
 "Basic parentheses test"
 (parse (tokenize "()"))
 '(()))

(test-equal?
 "Basic bracket test"
 (parse (tokenize "[]"))
 '((:sb)))

(test-equal?
 "Basic curly brace test"
 (parse (tokenize "{}"))
 '((:cb)))

(test-equal?
 "Basic function call test"
 (parse (tokenize "(+ 1 2)"))
 `((,(Token 1 2 'symbol "+")
    ,(Token 1 4 'integer "1")
    ,(Token 1 6 'integer "2"))))

(test-equal?
 "Two function calls test"
 (parse (tokenize "(let x 10) (+ x 2)"))
 `((,(Token 1 2 'symbol "let")
    ,(Token 1 6 'symbol "x")
    ,(Token 1 8 'integer "10"))
   (,(Token 1 13 'symbol "+")
    ,(Token 1 15 'symbol "x")
    ,(Token 1 17 'integer "2"))))

(test-equal?
 "Nested let a-la Clojure"
 (parse (tokenize
         "(let [x 10]
  (+ x 2))"))
 `((,(Token 1 2 'symbol "let")
    (:sb
     ,(Token 1 7 'symbol "x")
     ,(Token 1 9 'integer "10"))
    (,(Token 2 4 'symbol "+")
     ,(Token 2 6 'symbol "x")
     ,(Token 2 8 'integer "2")))))

(test-equal?
 "Defining a fuller function"
 (parse (tokenize
         "(let f [x y]
  (let sum (+ x y))
  (println sum)
  sum)

(f 10 20)"))
 `((,(Token 1 2 'symbol "let")
    ,(Token 1 6 'symbol "f")
    (:sb ,(Token 1 9 'symbol "x") ,(Token 1 11 'symbol "y"))
    (,(Token 2 4 'symbol "let")
     ,(Token 2 8 'symbol "sum")
     (,(Token 2 13 'symbol "+")
      ,(Token 2 15 'symbol "x")
      ,(Token 2 17 'symbol "y")))
    (,(Token 3 4 'symbol "println") ,(Token 3 12 'symbol "sum"))
    ,(Token 4 3 'symbol "sum"))
   (,(Token 6 2 'symbol "f")
    ,(Token 6 4 'integer "10")
    ,(Token 6 7 'integer "20"))))
