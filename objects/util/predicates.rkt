#lang r5rs

(#%require "../member.rkt")
(#%provide
  mutable?
  private?
  public?
  method?
  property?
  defined?
  undefined?
  object?
)

(define object? (lambda (member)
  (cdr (assoc `object member))
))

(define mutable? (lambda (member)
  (cdr (assoc `mutable member))
))

(define private? (lambda (member)
  (equal? `private (cdr (assoc `access-modifier member)))
))

(define public? (lambda (member)
  (equal? `public (cdr (assoc `access-modifier member)))
))

(define method? (lambda (member)
  (and
    (not (object? member))
    (procedure? (cdr (assoc `value member)))
  )
))

(define property? (lambda (member)
  (and
    (not (object? member))
    (not (method? member))
  )
))

(define defined? (lambda (x)
  (not (equal? `undefined x))
))

(define undefined? (lambda (x)
  (equal? `undefined x)
))

;;; TESTS
(#%require rackunit)
(check-equal? (method? (public-mut `x (lambda () 8))) #t)
(check-equal? (method? (public-mut `x 45)) #f)
(check-equal? (property? (public-mut `x 4)) #t)
(check-equal? (property? (public-mut `x (lambda () 8))) #f)
(check-equal? (mutable? (public `x 5)) #f)
(check-equal? (mutable? (public-mut `x 5)) #t)
(check-equal? (mutable? (public-mut `x (lambda () 8))) #f)
(check-equal? (private? (private-mut `x 5)) #t)
(check-equal? (private? (public-mut `x 5)) #f)
(check-equal? (public? (private-mut `x 5)) #f)
(check-equal? (public? (public-mut `x 5)) #t)
(check-equal? (object? (public-obj `obj (lambda () #f))) #t)
(check-equal? (object? (private `fn (lambda () #f))) #f)