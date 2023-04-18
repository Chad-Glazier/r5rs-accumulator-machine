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
