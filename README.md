# Click 

Click is a general-purpose functional programming language that aim to be a
combination of powerful features from Racket, Clojure and Common Lisp. Click is
will aim to target LLVM and WASM for use natively and on the web. 

## Racket 
Racket is a very solid base language. It's got the elegant and simple syntax of
Scheme, with some very powerful additions like it's looping and comprehensions
mechanisms. It's also got state-of-the-art macros that pieces of will be
incorporated into Click. In addition, Racket has pattern matching and the
contract system that are very powerful.

## Clojure
While Racket provides a very solid base for the language, Clojure has some
must-have features as well. Clojure's lazy immutable data structures, it's
protocol system, it's solution to multi-threading, as well as some simple 
nicities like concise lambda syntax and a simple way to declare functions that 
take a variable number of arguments. 

## Common Lisp
Common Lisp has Sly and SLIME, the most powerful REPL available for interactive
development. Click aims to provide the same type of interactive experience that
you get with Sly and SLIME, without forcing you into Emacs. Having that
streamlined REPL experience should be available from anything with a terminal.

## Click
Click will aim to incorporate many of the key features from these 3 different
programming languages to create a new language that is:
- Simple and elegant 
- Provides a lot of solid data structures
- A powerful macro system 
- Interactive development

## Samples
Just some simple example toy programs
```scheme
(def -main []
    (println "Hello world!"))
```

```scheme
(def fibonnaci 
    [((or 0 1)) 1]
    [(n) (+ (fibonnaci (- n 1)) (fibonnaci (- n 2)))])
```

```scheme
(def contains?
    [(()) :f]
    [(() el) :f]
    [((x) el) (= x el)]
    [((x : xs) el) (or (=? x el) (contains? xs el))])
```

```scheme
(def filter 
    [(() _) '()]
    [((x) cb) (or (cb x) '())]
    [((x : xs) cb) 
      (if (cb x) (cons x (filter xs cb)) (filter xs cb))])
      
(filter '(1 2 3 4 5) odd?)
(filter '(1 2 3 4 5) \(> %0 3))
(filter '(1 2 3 4 5) (lambda (n) (> n 3)))
```
