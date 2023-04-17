#lang r5rs

(#%require "objects/index.rkt")

(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (public `to-vector (lambda (this)
    (vector (this `x) (this `y))
  ))
))

(define p1 (new point))
(define p2 (new point))

(define line (class
  (public-obj `point-a p1)
  (public-obj `point-b p2)
  (public `to-vector (lambda (this)
    (vector
      (this `point-a `to-vector)
      (this `point-b `to-vector)
    )
  ))
))

(define ln (new line))

(display (ln `to-vector))