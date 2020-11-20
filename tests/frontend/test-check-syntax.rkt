#lang racket/base

(require rackunit)
(require "../../src/compiler.rkt"
         "../../src/types.rkt")

;;; Test `let` syntax
(begin
  (test-equal?
   "test simple `let` assignment"
   (compile/check-syntax "(let x 10)")
   `((,(Token 1 2 'symbol "let")
      ,(Token 1 6 'symbol "x")
      ,(Token 1 8 'integer "10"))))

  (test-equal?
   "test lexically scopped `let` assignment"
   (compile/check-syntax "(let {x 10} (+ x 20))")
   `((,(Token 1 2 'symbol "let")
      (:cb ,(Token 1 7 'symbol "x")
           ,(Token 1 9 'integer "10"))
      (,(Token 1 14 'symbol "+")
       ,(Token 1 16 'symbol "x")
       ,(Token 1 18 'integer "20")))))

  (test-equal?
   "test lexically scopped named `let` assignment"
   (compile/check-syntax "(let loop {x 10} (+ x 20))")
   `((,(Token 1 2 'symbol "let")
      ,(Token 1 6 'symbol "loop")
      (:cb ,(Token 1 12 'symbol "x")
           ,(Token 1 14 'integer "10"))
      (,(Token 1 19 'symbol "+")
       ,(Token 1 21 'symbol "x")
       ,(Token 1 23 'integer "20")))))

  (test-equal?
   "test `let` function declaration assignment"
   (compile/check-syntax "(let hello [x] (str \"Hello \" x))")
   `((,(Token 1 2 'symbol "let")
      ,(Token 1 6 'symbol "hello")
      (:sb ,(Token 1 13 'symbol "x"))
      (,(Token 1 17 'symbol "str")
       ,(Token 1 21 'string "\"Hello \"")
       ,(Token 1 30 'symbol "x")))))

  ;; Removed multi-arity functions for now because they're
  ;; Being a pain in the ass
  ;; (test-equal?
  ;;  "test `let` match function declaration assignment"
  ;;  (compile/check-syntax
  ;;   "(let greet ([x] (greet \"Hello \" x))
  ;;   ([x y] (str x y)))")
  ;;  `((,(Token 1 2 'symbol "let")
  ;;     ,(Token 1 6 'symbol "greet")
  ;;     ((:sb ,(Token 1 14 'symbol "x"))
  ;;      (,(Token 1 18 'symbol "str")
  ;;       ,(Token 1 24 'string "\"Hello \"")
  ;;       ,(Token 1 33 'symbol "x")))
  ;;     ((:sb ,(Token 1 5 'symbol "x")
  ;;           ,(Token 1 7 'symbol "y"))
  ;;      (,(Token 1 11 'symbol "str")
  ;;       ,(Token 1 15 'symbol "x")
  ;;       ,(Token 1 17 'symbol "y"))) )))

  )

;;; Test type annotations
(begin
  (test-equal?
   "Simple type annotation check"
   (compile/check-syntax
    "(: sum (-> Number Number Number))")
   `((,(Token 1 2 'symbol ":")
      ,(Token 1 4 'symbol "sum")
      (,(Token 1 9 'symbol "->")
       ,(Token 1 12 'symbol "Number")
       ,(Token 1 19 'symbol "Number")
       ,(Token 1 26 'symbol "Number")))))

  (test-equal?
   "Generic type annotation check"
   (compile/check-syntax
    "(: (~a t) (-> String t String))")
   `((,(Token 1 2 'symbol ":")
      (,(Token 1 5 'symbol "~a")
       ,(Token 1 8 'symbol "t"))
      (,(Token 1 12 'symbol "->")
       ,(Token 1 15 'symbol "String")
       ,(Token 1 22 'symbol "t")
       ,(Token 1 24 'symbol "String")))))

  (test-equal?
   "Function parameter type annotation check"
   (compile/check-syntax
    "(: (map a b) (-> (-> a b) (Listof a) (Listof b)))")
   `((,(Token 1 2 'symbol ":")
      (,(Token 1 5 'symbol "map")
       ,(Token 1 9 'symbol "a")
       ,(Token 1 11 'symbol "b"))
      (,(Token 1 15 'symbol "->")
       (,(Token 1 19 'symbol "->")
        ,(Token 1 22 'symbol "a")
        ,(Token 1 24 'symbol "b"))
       (,(Token 1 28 'symbol "Listof")
        ,(Token 1 35 'symbol "a"))
       (,(Token 1 39 'symbol "Listof")
        ,(Token 1 46 'symbol "b"))))))
  )

;;; Test interface syntax
(begin
  (test-equal?
   "simple interface implementation"
   (compile/check-syntax
    "(interface Person (: name (-> String)) (: age (-> Natural)))")
   `((,(Token 1 2 'symbol "interface")
      ,(Token 1 12 'symbol "Person")
      (,(Token 1 20 'symbol ":")
       ,(Token 1 22 'symbol "name")
       (,(Token 1 28 'symbol "->")
        ,(Token 1 31 'symbol "String")))
      (,(Token 1 41 'symbol ":")
       ,(Token 1 43 'symbol "age")
       (,(Token 1 48 'symbol "->")
        ,(Token 1 51 'symbol "Natural"))))))

  (test-equal?
   "parameterized interface implementation"
   (compile/check-syntax
    "(interface (Comp a) (: > (-> a a Bool)) (: < (-> a a Bool)))")
   `((,(Token 1 2 'symbol "interface")
      (,(Token 1 13 'symbol "Comp")
       ,(Token 1 18 'symbol "a"))
      (,(Token 1 22 'symbol ":")
       ,(Token 1 24 'symbol ">")
       (,(Token 1 27 'symbol "->")
        ,(Token 1 30 'symbol "a")
        ,(Token 1 32 'symbol "a")
        ,(Token 1 34 'symbol "Bool")))
      (,(Token 1 42 'symbol ":")
       ,(Token 1 44 'symbol "<")
       (,(Token 1 47 'symbol "->")
        ,(Token 1 50 'symbol "a")
        ,(Token 1 52 'symbol "a")
        ,(Token 1 54 'symbol "Bool"))))))
  )

;;; Test struct syntax
(begin
  (test-equal?
   "basic struct test"
   (compile/check-syntax
    "(struct Person {name String age Natural})")
   `((,(Token 1 2 'symbol "struct")
      ,(Token 1 9 'symbol "Person")
      (:cb ,(Token 1 17 'symbol "name")
           ,(Token 1 22 'symbol "String")
           ,(Token 1 29 'symbol "age")
           ,(Token 1 33 'symbol "Natural")))))

  (test-equal?
   "Parameterized struct test"
   (compile/check-syntax
    "(struct (Tree a) {Node a Left (Tree a) Right (Tree a)})")
   `((,(Token 1 2 'symbol "struct")
      (,(Token 1 10 'symbol "Tree")
       ,(Token 1 15 'symbol "a"))
      (:cb ,(Token 1 19 'symbol "Node")
           ,(Token 1 24 'symbol "a")
           ,(Token 1 26 'symbol "Left")
           (,(Token 1 32 'symbol "Tree")
            ,(Token 1 37 'symbol "a"))
           ,(Token 1 40 'symbol "Right")
           (,(Token 1 47 'symbol "Tree")
            ,(Token 1 52 'symbol "a"))))))
  )

;;; Test if syntax
(begin
  (test-equal?
   "if -- all atoms"
   (compile/check-syntax
    "(if true \"True\" \"False\")")
   `((,(Token 1 2 'symbol "if")
      ,(Token 1 5 'symbol "true")
      ,(Token 1 10 'string "\"True\"")
      ,(Token 1 17 'string "\"False\""))))

  (test-equal?
   "if -- list condition"
   (compile/check-syntax
    "(if (list 1 2) \"True\" \"False\")")
   `((,(Token 1 2 'symbol "if")
      (,(Token 1 6 'symbol "list")
       ,(Token 1 11 'integer "1")
       ,(Token 1 13 'integer "2"))
      ,(Token 1 16 'string "\"True\"")
      ,(Token 1 23 'string "\"False\""))))

  (test-equal?
   "if -- then list"
   (compile/check-syntax
    "(if (list 1 2) (list \"True\") \"False\")")
   `((,(Token 1 2 'symbol "if")
      (,(Token 1 6 'symbol "list")
       ,(Token 1 11 'integer "1")
       ,(Token 1 13 'integer "2"))
      (,(Token 1 17 'symbol "list")
       ,(Token 1 22 'string "\"True\""))
      ,(Token 1 30 'string "\"False\""))))
  
  (test-equal?
   "if -- else list"
   (compile/check-syntax
    "(if (list 1 2) (list \"True\") (list \"False\"))")
   `((,(Token 1 2 'symbol "if")
      (,(Token 1 6 'symbol "list")
       ,(Token 1 11 'integer "1")
       ,(Token 1 13 'integer "2"))
      (,(Token 1 17 'symbol "list")
       ,(Token 1 22 'string "\"True\""))
      (,(Token 1 31 'symbol "list")
       ,(Token 1 36 'string "\"False\"")))))
  )

