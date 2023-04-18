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

