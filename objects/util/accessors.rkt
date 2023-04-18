#lang r5rs

(#%require 
  "../member.rkt"
  "predicates.rkt"
)
(#%provide
  id:member
  id:value
  member:id
  member:value
)

(define id:member (lambda (id members)
  (cond
    ((null? members) `undefined)
    ((equal? id (cdr (assoc `id (car members))))
      (car members)
    )
    (else
      (id:member id (cdr members))
    )
  )
))

(define id:value (lambda (id members)
  (cond
    ((null? members) `undefined)
    ((equal? id (cdr (assoc `id (car members))))
      (cdr (assoc `value (car members)))
    )
    (else
      (id:value id (cdr members))
    )
  )
))

(define member:id (lambda (member)
  (cdr (assoc `id member))
))

(define member:value (lambda (member)
  (cdr (assoc `value member))
))
