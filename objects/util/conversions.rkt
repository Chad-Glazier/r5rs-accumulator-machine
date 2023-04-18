#lang r5rs

(#%require
  "lists.rkt"
  "predicates.rkt"
  "accessors.rkt"
  "../member.rkt"
)

(#%provide 
  any->string
  member->string
  members->string
)

(define any->string (lambda (x)
  (cond
    ((null? x) "()")
    ((boolean? x) (if x "#t" "#f"))
    ((number? x) (number->string x))
    ((char? x) (string x))
    ((string? x) x)
    ((symbol? x) (symbol->string x))
    ((list? x)
      (string-append
        "("
        (reduce 
          (lambda (a b)
            (string-append (any->string a) " " (any->string b))
          )
          x
        )
        ")"      
      )
    )
    ((pair? x)
      (string-append
        "("
        (any->string (car x))
        " . "
        (any->string (cdr x))
        ")"
      )
    )
    ((vector? x) 
      (if (> (vector-length x) 5)
        (string-append "#(" (number->string (vector-length x)) ")")
        (string-append "#" (any->string (vector->list x)))
      )
    )
    ((procedure? x) (string-append "#<procedure>"))
  )
))

(define member->string (lambda (member)
  (string-append
    (if (public? member) "public " "private ")
    (if (mutable? member) "mut " "")
    (symbol->string (member:id member)) " = "
    (if (string? (member:value member))
      (string-append "'" (member:value member) "'")
      (any->string (member:value member)) 
    )
    ";"
  )
))

(define members->string (lambda (members)
  (string-append
    "{\n\t"
    (if (null? (cdr members))
      (member->string (car members))
      (reduce
        (lambda (a b)
          (string-append  
            (if (not (string? a))
              (member->string a)
              a
            )
            "\n\t" 
            (member->string b)
          )
        )
        members
      )
    )
    "\n}\n"
  )
))
