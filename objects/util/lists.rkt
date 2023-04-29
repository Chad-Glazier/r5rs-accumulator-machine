#lang r5rs

(#%require "strings.rkt")
(#%provide
  filter
  find
)

(define (filter predicate? lst)
  (cond
    ((vector? lst) 
      (list->vector (filter predicate? (vector->list lst)))
    )
    ((string? lst) 
      (list->string (filter predicate? (string->list lst)))
    )
    ((and (pair? lst) (not (list? lst)))
      (begin
        (display (string-append
          "Warning: Attempted to `filter` a non-list pair. In this case,\n"
          "  `filter` will return the given pair. The given pair was\n"
          "  " (any->string lst) "\n\n"
        ))
        lst
      )
    )
    ((null? lst) `())
    ((predicate? (car lst))
      (cons (car lst) (filter predicate? (cdr lst)))
    )
    (else
      (filter predicate? (cdr lst))
    )
  )
)

(define (find predicate? lst)
  (cond
    ((vector? lst) 
      (list->vector (find predicate? (vector->list lst)))
    )
    ((string? lst) 
      (list->string (find predicate? (string->list lst)))
    )
    ((and (pair? lst) (not (list? lst)))
      (begin
        (display (string-append
          "Warning: Attempted to `find` with a non-list pair. In this case,\n"
          "  `find` will return the given pair, i.e.,\n"
          "  " (any->string lst) "\n\n"
        ))
        lst
      )
    )
    ((null? lst) `())
    ((predicate? (car lst))
      (car lst)
    )
    (else
      (find predicate? (cdr lst))
    )
  )
)