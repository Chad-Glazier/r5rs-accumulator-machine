#lang r5rs

(#%require "../objects/index.rkt")
(#%provide register)

(define register (class 
  (private-mut `value 0)
  (public `read (lambda (this)
    (this `value)
  ))
  (public `write (lambda (this new-value)
    (this `value new-value)
  ))
))

;;; TESTS
(#%require rackunit)
(define el (new register))
(el `write 9)
(check-equal? (el `read) 9)
(el `write 3)
(check-equal? (el `read) 3)