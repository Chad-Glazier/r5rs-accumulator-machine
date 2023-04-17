#lang r5rs

(#%provide 
  public
  public-mut
  private
  private-mut
  public-obj
  private-obj
)

(define new-member (lambda (identifier value access-modifier mutable object)
  (list
    (cons `id identifier)
    (cons `value value)
    (cons `access-modifier access-modifier)
    (cons `mutable mutable)
    (cons `object object)
  )
))

(define public-mut (lambda (identifier value)
  (new-member identifier value `public (not (procedure? value)) #f)
))

(define public (lambda (identifier value)
  (new-member identifier value `public #f #f)
))

(define private-mut (lambda (identifier value)
  (new-member identifier value `private (not (procedure? value)) #f)
))

(define private (lambda (identifier value)
  (new-member identifier value `private #f #f)
))

(define public-obj (lambda (identifier value)
  (new-member identifier value `public #f #t)
))

(define private-obj (lambda (identifier value)
  (new-member identifier value `private #f #t)
))

;;; TESTS
(#%require rackunit)
