#lang racket

(define position (Pos 0 0 0))

(struct Pos [row col curr]
  #:mutable #:transparent)

(define (+row [n 0])
  (position (+ n (Pos-row position))
            (Pos-col position)
            (+ n (Pos-curr position))))
(define (+col [n 0])
  (position (Pos-row position)
            (+ n (Pos-col position))
            (+ n (Pos-curr position))))

(define [parse source]
  (define [peek source]
    (string-ref source (Pos-curr position)))

  (match (peek source)
    ["("
     (+row 1)
     `(,(parse source))]))

(read "(print \"Hello worl\")")
