#lang r5rs

(#%require
  "types.rkt"
)
(#%provide
  deep-copy
)

(define (deep-copy obj)
  (case (typeof obj)
    (`list (map deep-copy obj))
    (`pair (cons (deep-copy (car obj)) (deep-copy (cdr obj))))
    (`vector (list->vector (deep-copy (vector->list obj))))
    (`object (obj `new))
    (else obj)
  )
)