#lang r5rs

(#%provide 
  has
  some
  find
  filter
  reduce
  deep-copy
)

(define has (lambda (target lst)
  (some 
    (lambda (element)
      (equal? element target)
    )
    lst
  )
))

(define some (lambda (predicate lst)
  (cond
    ((null? lst) 
      #f
    )
    ((predicate (car lst))
      #t
    )
    (else
      (some predicate (cdr lst))
    )
  )
))

(define find (lambda (predicate lst)
  (cond
    ((null? lst) 
      `()
    )
    ((predicate (car lst))
      (car lst)
    )
    (else
      (find predicate (cdr lst))
    )
  )
))

(define filter (lambda (predicate lst)
  (cond
    ((null? lst) 
      '()
    )
    ((predicate (car lst))
     (cons (car lst) (filter predicate (cdr lst)))
    )
    (else 
      (filter predicate (cdr lst))
    )
  )
))

(define reduce-helper (lambda (reducer lst acc)
  (cond
    ((null? lst) acc)
    (else
      (reduce-helper
        reducer
        (cdr lst)
        (reducer acc (car lst))
      )
    )
  )
))

(define reduce (lambda (reducer lst . init)
  (cond
    ((null? lst) lst)
    ((null? (cdr lst)) (car lst))
    (else
      (if (null? init)
        (reduce-helper
          reducer
          (cdr lst)
          (car lst)
        )
        (reduce-helper
          reducer
          lst
          (car init)
        )
      )    
    )
  )
))

(define deep-copy (lambda (lst)
  (cond
    ((null? lst) 
      lst
    )
    ((not (pair? lst))
      lst
    )
    ((pair? (car lst))
      (cons 
        (deep-copy (car lst)) 
        (deep-copy (cdr lst))
      )
    )
    (else
      (cons 
        (car lst) 
        (deep-copy (cdr lst))
      )
    )
  )
))

