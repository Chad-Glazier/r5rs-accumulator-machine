#lang r5rs

(#%require
  "util/accessors.rkt"
  "util/lists.rkt"
  "util/conversions.rkt"
  "util/predicates.rkt"
  "member.rkt"
)

(#%provide
  class
  compose
)

(define class (lambda members
  (deep-copy members)
))

(define add-member (lambda (members new-member)
  (if (defined? (id:member (member:id new-member) members))
    members
    (append members (list new-member))
  )
))

(define add-all-members (lambda (members new-members)
  (if (null? new-members)
    members
    (add-all-members (add-member members (car new-members)) (cdr new-members))
  )
))

(define compose (lambda classes
  (cond
    ((null? classes) classes)
    ((null? (cdr classes)) (apply class (car classes)))
    (else
      (apply class (reduce add-all-members classes))
    )
  )
))

;;; TESTS
(#%require rackunit)

(define example-class-1 (class
  (public-mut `x 0)
  (public-mut `y 0)
))
(define example-class-2 (class
  (public-mut `x "ecks")
  (public-mut `z (vector 1 4))
))
(define example-class-3 (class
  (public-mut `x -1)
  (public-mut `z "thingy")
  (public-mut `a 4)
))

(check-equal?
  (compose)
  `()
)

(check-equal?
  (compose (class))
  `()
)

(check-equal?
  (compose example-class-1)
  example-class-1
)

(check-equal?
  (compose example-class-1 example-class-2)
  (append
    example-class-1
    (list (public-mut `z (vector 1 4)))
  )
)

(check-equal? 
  (compose example-class-1 example-class-2 example-class-3)
  (append
    example-class-1
    (list (public-mut `z (vector 1 4)))
    (list (public-mut `a 4))
  )
)
