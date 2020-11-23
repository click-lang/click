#lang racket/base

(require rackunit)
(require
 "../util.rkt"
 "../../src/compiler.rkt"
 "../../src/types.rkt")

;; I can't just test against the output of the parser if I pass to the parser
;; what the code should expand to because the tokens will have a different row
;; and col value since the expander will use the row and col values from other
;; tokens in the expression.

(test-equal?
 "Basic parentheses test"
 (compile/macro-expand "()")
 '(()))

(test-equal?
 "Basic bracket test"
 (compile/macro-expand "[]")
 '((:sb)))

(test-equal?
 "Basic curly brace test"
 (compile/macro-expand "{}")
 '((:cb)))

(test-equal?
 "Basic function call test"
 (compile/macro-expand "(+ 1 2)")
 `((,(Token 1 2 'symbol "+")
    ,(Token 1 4 'integer "1")
    ,(Token 1 6 'integer "2"))))

(test-equal?
 "Two function calls test"
 (compile/macro-expand "(let x 10) (+ x 2)")
 `((,(Token 1 2 'symbol "let")
    ,(Token 1 6 'symbol "x")
    ,(Token 1 8 'integer "10"))
   (,(Token 1 13 'symbol "+")
    ,(Token 1 15 'symbol "x")
    ,(Token 1 17 'integer "2"))))

;; Let tests
(begin
  (test-equal?
   "Nested let a-la Clojure"
   (compile/macro-expand 
    "(let {x 10}
  (+ x 2))")
   `((,(Token 1 2 'symbol "let")
      (:cb ,(Token 1 7 'symbol "x")
           ,(Token 1 9 'integer "10"))
      (,(Token 2 4 'symbol "+")
       ,(Token 2 6 'symbol "x")
       ,(Token 2 8 'integer "2")))))

  (test-equal?
   "Defining a function"
   (compile/macro-expand 
    "(let f [x y]
  (let sum (+ x y))
  (println #i\"Sum of {x} and {y} is {sum}\")
  sum)

  (f 10 20)")
   `((,(Token 1 2 'symbol "let")
      ,(Token 1 6 'symbol "f")
      (,(Token 1 6 'symbol "fn")
       (:sb ,(Token 1 9 'symbol "x") ,(Token 1 11 'symbol "y"))
       (,(Token 2 4 'symbol "let")
        ,(Token 2 8 'symbol "sum")
        (,(Token 2 13 'symbol "+")
         ,(Token 2 15 'symbol "x")
         ,(Token 2 17 'symbol "y")))
       (,(Token 3 4 'symbol "println")
        (,(Token 3 12 'reader "#i")
         ,(Token 3 14 'string "\"Sum of {x} and {y} is {sum}\"")))
       ,(Token 4 3 'symbol "sum")))
     (,(Token 6 4 'symbol "f")
      ,(Token 6 6 'integer "10")
      ,(Token 6 9 'integer "20"))))

  (test-equal?
   "Define match function"
   (compile/macro-expand
    "(let f ([] (f 10)) ([x] (f x 10)) ([x y] (+ x y)))")
   (let* ([argv (symbol->string (last-gensym 'argv))])
     `((,(Token 1 2 'symbol "let")
        ,(Token 1 6 'symbol "f")
        (,(Token 1 6 'symbol "fn")
         (:sb ,(Token 1 6 'symbol "&") ,(Token 1 6 'symbol argv))
         (,(Token 1 6 'symbol "match")
          ,(Token 1 6 'symbol argv)
          (:sb)
          ,(Token 1 13 'symbol "=>")
          (,(Token 1 13 'symbol "do")
           (,(Token 1 13 'symbol "f")
            ,(Token 1 15 'integer "10")))
          (:sb ,(Token 1 22 'symbol "x"))
          ,(Token 1 26 'symbol "=>")
          (,(Token 1 26 'symbol "do")
           (,(Token 1 26 'symbol "f")
            ,(Token 1 28 'symbol "x")
            ,(Token 1 30 'integer "10")))
          (:sb ,(Token 1 37 'symbol "x")
               ,(Token 1 39 'symbol "y"))
          ,(Token 1 43 'symbol "=>")
          (,(Token 1 43 'symbol "do")
           (,(Token 1 43 'symbol "+")
            ,(Token 1 45 'symbol "x")
            ,(Token 1 47 'symbol "y")))))))))
  
  )

;;; Test expand cond
(begin
  (test-equal?
   "Basic if/else"
   (compile/macro-expand
    "(cond a => b, else => c)")
   `((,(Token 1 2 'symbol "if")
      ,(Token 1 7 'symbol "a")
      ,(Token 1 12 'symbol "b")
      ,(Token 1 23 'symbol "c"))))

  (test-equal?
   "If, else-if, else"
   (compile/macro-expand
    "(cond a => b, c => d, else => e)")
   `((,(Token 1 2 'symbol "if")
      ,(Token 1 7 'symbol "a")
      ,(Token 1 12 'symbol "b")
      (,(Token 1 15 'symbol "if")
       ,(Token 1 15 'symbol "c")
       ,(Token 1 20 'symbol "d")
       ,(Token 1 31 'symbol "e")))))

  (test-equal?
   "If, else-if, else"
   (compile/macro-expand
    "(cond a => (let {x 10} (+ x 20)), c => d, else => e)")
   `((,(Token 1 2 'symbol "if")
      ,(Token 1 7 'symbol "a")
      (,(Token 1 13 'symbol "let")
       (:cb ,(Token 1 18 'symbol "x")
            ,(Token 1 20 'integer "10"))
       (,(Token 1 25 'symbol "+")
        ,(Token 1 27 'symbol "x")
        ,(Token 1 29 'integer "20")))
      (,(Token 1 35 'symbol "if")
       ,(Token 1 35 'symbol "c")
       ,(Token 1 40 'symbol "d")
       ,(Token 1 51 'symbol "e")))))
  )
