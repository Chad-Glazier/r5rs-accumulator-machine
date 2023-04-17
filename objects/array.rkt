#lang r5rs

(#%require 
  "object.rkt"
  "class.rkt"
  "member.rkt"
)

(#%provide
  array
)

(define vector-of (lambda (length members)
  (let
    (
      (vec (make-vector length 0))
    )
    (let loop
      ((i 0))
      (if (< i length)
        (begin
          (vector-set! vec i (new members))
          (loop (+ i 1))        
        )
        vec
      )
    )
  )
))

(define array (lambda (members length)
  (new
    (class
      (public `vector (vector-of length members))
      (public `access (lambda (this index)
        (cond 
          ((>= index (vector-length (this `vector)))
            `undefined
          )
          ((< index 0)
            (if (<= (abs index) (vector-length (this `vector)))
              (vector-ref (this `vector) (- (vector-length (this `vector)) (abs index)))
              `undefined
            )
          )
          (else
            (vector-ref (this `vector) index)
          )
        )
      ))
      (public `length (lambda (this)
        (vector-length (this `vector))
      ))
      (public `for-each (lambda (this callback)
        (let loop
          ((i 0))
          (if (< i (this `length))
            (begin
              (callback (this i) i)
              (loop (+ i 1))        
            )
            this
          )
        )
      ))
    )  
  )
))

;;; TESTS
(#%require rackunit)
(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (public `to-vector (lambda (this)
    (vector (this `x) (this `y))
  ))
))
(define vector-of-example (vector-of 100 point))
(check-equal? (eq? (vector-ref vector-of-example 0) (vector-ref vector-of-example 1)) #f)
(check-equal? ((vector-ref vector-of-example 0) `x) 0)

(define arr (array point 100))
((arr -1) `x 99)
;;; (arr `for-each (lambda (p i) (display i) (newline) (display (p `to-string))))
