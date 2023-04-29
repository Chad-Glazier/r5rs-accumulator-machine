#lang r5rs

(#%require
  "object.rkt"
)
(#%provide
  new
  polymorph
)

(define new (lambda (members)
  (apply object members)
))

(define polymorph (lambda member-lists
  (cond
    ((null? member-lists) (begin
      (display (string-append
        "Warning: Attempted to create a polymorph object without\n"
        "         any specified member-lists. Returning `undefined.\n"
        "\n"
      ))
      `undefined
    ))
    ((null? (cdr member-lists))
      (new (car member-lists))
    )
    (else
      ((new (car member-lists)) 
        `add-members 
        (apply append (cdr member-lists))
      )
    )
  )
))
