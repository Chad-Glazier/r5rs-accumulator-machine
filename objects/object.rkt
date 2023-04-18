#lang r5rs

(#%require 
  "util/predicates.rkt"
  "util/lists.rkt"
  "util/accessors.rkt"
  "util/conversions.rkt"
  "member.rkt"
  "class.rkt"
)
(#%provide new)

(define get-member (lambda (member)
  (member:value member)
))

(define set-member! (lambda (member new-value)
  (set-cdr!
    (assoc `value member)
    new-value
  )
))

(define call-member (lambda (member this args)
  (if (object? member)
    (apply
      (member:value member)
      args
    )
    (apply
      (member:value member)
      (cons this args)
    )
  )

))

(define new-private (lambda (original-members all-members)
  (lambda (original-id . original-args)
    (let*
      (
        (indexing? (number? original-id))
        (id (if indexing? `access original-id))
        (args (if indexing? (cons original-id original-args) original-args))
        (member (id:member id all-members))
      )
      (cond
        ((undefined? member)
          (case id
            (`to-string (members->string all-members))
            (`class original-members)
            (else 
              (begin
                (display (string-append "Member " (any->string id) " not found.\n"))
                `undefined
              )
            )          
          )
        )
        ((or (method? member) (object? member))
          (call-member member (new-private original-members all-members) args)
        )
        ((property? member)
          (cond
            ((null? args)
              (get-member member)
            )
            ((not (mutable? member))
              (begin
                (display (string-append "Member " (any->string id) " is not mutable.\n"))
                `undefined
              )
            )
            (else
              (set-member! member (list-ref args (- (length args) 1)))
            )
          )
        )
      )
    )
  )
))

(define new (lambda (members)
  (let*
    (
      (all-members (deep-copy members))
      (public-members (filter public? all-members))      
    )
    (lambda (original-id . original-args)
      (let*
        (
          (indexing? (number? original-id))
          (id (if indexing? `access original-id))
          (args (if indexing? (cons original-id original-args) original-args))
          (member (id:member id all-members))
        )
        (cond
          ((undefined? member)
            (case id
              (`to-string (members->string all-members))
              (`class members)
              (else 
                (begin
                  (display (string-append "Member " (any->string id) " not found.\n"))
                  `undefined
                )
              )
            )
          )
          ((method? member)
            (call-member member (new-private members all-members) args)
          )
          ((property? member)
            (cond
              ((null? args)
                (get-member member)
              )
              ((not (mutable? member))
                (begin
                  (display (string-append "Member " (any->string id) " is not mutable.\n"))
                  `undefined
                )
              )
              (else
                (set-member! member (list-ref args (- (length args) 1)))
              )
            )
          )
        )
      )
    )
  )
))
