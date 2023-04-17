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

;;; TESTS
(#%require rackunit)

(check-equal? (any->string '()) "()")
(check-equal? (any->string #t) "#t")
(check-equal? (any->string #f) "#f")
(check-equal? (any->string 123) "123")
(check-equal? (any->string #\a) "a")
(check-equal? (any->string "hello") "hello")
(check-equal? (any->string 'foo) "foo")
(check-equal? (any->string '(1 2 3)) "(1 2 3)")
(check-equal? (any->string (cons 1 2)) "(1 . 2)")
(check-equal? (any->string (cons (cons 1 2) 3)) "((1 . 2) . 3)")
(check-equal? (any->string #(1 2 3)) "#(1 2 3)")
(check-equal? (any->string (lambda (x) (+ x 1))) "#<procedure>")

(check-equal? (member->string (public-mut`x "apple")) "public mut x = 'apple';")
(check-equal? (member->string (private `y `pear)) "private y = pear;")
(check-equal? (member->string (public `z 3)) "public z = 3;")
(check-equal? (member->string (private-mut`q 4)) "private mut q = 4;")
(check-equal? (member->string (public-mut`fn (lambda () #f))) "public fn = #<procedure>;")

(check-equal? 
  (members->string
    (list
      (private `G 6.67430e-11)
      (public-mut`x 0)
      (public-mut`y (list `a 1 "letters"))
      (public-mut`z `some-symbol)
      (public `v (vector 0 -2 5))
      (public-mut`name "spherical chicken in a vacuum")
      (public-mut`as-vector (lambda (this) 
        (vector (this `x) (this `y) (this `z))
      ))
    )
  )
  (string-append
    "{"
    "\n\tprivate g = 6.6743e-11;"
    "\n\tpublic mut x = 0;"
    "\n\tpublic mut y = (a 1 letters);"
    "\n\tpublic mut z = some-symbol;"
    "\n\tpublic v = #(0 -2 5);"
    "\n\tpublic mut name = 'spherical chicken in a vacuum';"
    "\n\tpublic as-vector = #<procedure>;"
    "\n}\n"
  )
)
