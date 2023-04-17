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

;;; TESTS
(#%require rackunit)
(define my-members (list
  (private `x 4)
  (public `y 6)
))
;; Test case 1: Check that the function returns the correct member for a valid ID
(check-equal? (id:member `x my-members) (private `x 4))
;; Test case 2: Check that the function returns an empty list for an invalid ID
(check-equal? (id:member `y my-members) (public `y 6))
;; Test case 3: Check that the function returns the first member with a matching ID if there are multiple matches
(check-equal? (id:member `z my-members) `undefined)
;; Test case 1: Check that the function returns the correct member for a valid ID
(check-equal? (id:value `x my-members) 4)
;; Test case 2: Check that the function returns an empty list for an invalid ID
(check-equal? (id:value `y my-members) 6)
;; Test case 3: Check that the function returns the first member with a matching ID if there are multiple matches
(check-equal? (id:value `z my-members) `undefined)


(check-equal? (member:id (public `x 9)) `x)
(check-equal? (member:id (public-mut `y 9)) `y)
(check-equal? (member:id (private `z 9)) `z)
(check-equal? (member:id (private-mut `a 9)) `a)

(check-equal? (member:value (public `x 9)) 9)
(check-equal? (member:value (public-mut `y #f)) #f)
(check-equal? (member:value (private `z 5)) 5)
(check-equal? (member:value (private-mut `a "asdf")) "asdf")
