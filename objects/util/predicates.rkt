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

