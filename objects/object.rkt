#lang r5rs

(#%require 
  "member.rkt"
  "form.rkt"
  "util/strings.rkt"
  "util/types.rkt"
  "util/lists.rkt"
)
(#%provide
  object
  object->form
  object->string
  object::subset?
  object::superset?
)

(define object (lambda original-members
  (let*
    (
      (members (map member::new original-members))
    )
    (letrec
      (
        (interact (lambda args
          (let*
            (
              (private-access? (if (null? args)
                #f
                (car args)
              ))
              (accessible-members (if private-access?
                members
                (filter member::public? members)
              ))
              (message (if (or (null? args) (null? (cdr args)))
                `undefined
                (cadr args)
              ))
              (args (if (or (null? args) (null? (cdr args)) (null? (cddr args)))
                `undefined
                (cddr args)
              ))
            )
            (case message
              (`object? #t)
              (`method? #f)
              (`new (apply object original-members))
              (`clone (apply object members))
              (`add-member
                (if (defined? args)
                  (apply object (members::add-member original-members (car args)))
                  (apply object original-members)
                )
              )
              (`add-members 
                (if (defined? args)
                  (apply object (members::add-members original-members (car args)))
                  (apply object original-members)
                )
              )
              (`form
                (members->form members)
              )
              (`form-to-string
                (form->string 
                  (members->form members) 
                  (if (defined? args) (car args) 0)
                )
              )
              (`subset-of?
                (if (and (defined? args) (object? (car args)))
                  (form::subset? 
                    (members->form members)
                    (object->form (car args))
                  )
                  #f             
                )
              )
              (`superset-of?
                (if (and (defined? args) (object? (car args)))
                  (form::superset? 
                    (members->form members)
                    (object->form (car args))
                  )
                  #f             
                )
              )
              (`to-string 
                (members->string 
                  members 
                  (if (defined? args) 
                    (car args) 
                    0
                  )
                )
              )
              (`set!
                (
                  (find 
                    (lambda (mem) (equal? (member::id mem) (car args)))
                    members
                  )
                  `value
                  (cadr args)
                )
              )
              (`get
                (member::value
                  (find 
                    (lambda (mem) (equal? (member::id mem) (car args)))
                    members
                  )
                )
              )
              (else
                (if (memv message (map member::id accessible-members))
                  (let 
                    (
                      (target 
                        (find 
                          (lambda (mem) (equal? message (mem `id)))
                          accessible-members
                        )
                      )
                    )
                    (cond
                      ((member::method? target)
                        (apply (member::value target) (cons
                          (lambda args
                            (apply interact (cons #f args))
                          )
                          (if (defined? args) args `())
                        ))
                      )
                      ((member::object? target)
                        (if (defined? args)
                          (apply (member::value target) args)
                          (member::value target)
                        )
                      )
                      ((undefined? args)
                        (member::value target)
                      )
                      ((member::mutable? target)
                        (target `value (list-ref args (- (length args) 1)))
                      )
                      (else 
                        (begin 
                          (display (string-append
                            "Warning: Attempted to mutate the member `" (symbol->string (member::id target)) ",\n"
                            "         which was declared as read-only. The mutation was not\n"
                            "         applied and the value was left as " (any->string (member::value target)) ".\n\n"
                          ))
                          (member::value target)
                        )
                      )
                    )
                  )
                  (begin
                    (display (string-append
                      "Warning: Attempted to access the nonexistent member `" (symbol->string message) "\n"
                      "         of an object.\n\n"
                    ))
                    #f
                  )
                )  
              )
            )
          )
        ))        
      )
      (lambda args
        (apply interact (cons #f args))
      )
    )
  )
))

(define object->string (lambda (obj . indenation-depth)
  (obj 
    `to-string 
    (if (null? indenation-depth)
      0
      (car indenation-depth)
    )
  )
))

(define object->form (lambda (obj)
  (obj `form)
))

(define object::subset? (lambda (obj-a obj-b)
  (form::subset?
    (object->form obj-a)
    (object->form obj-b)
  )
))

(define object::superset? (lambda (obj-a obj-b)
  (form::superset?
    (object->form obj-a)
    (object->form obj-b)
  )
))
