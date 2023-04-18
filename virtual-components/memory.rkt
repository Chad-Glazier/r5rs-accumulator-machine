#lang r5rs

(#%require "../objects/index.rkt")
(#%require "memory-element.rkt")
(#%provide memory)

(define memory (class
  (private-obj `elements (array memory-element 100))
  (public `read (lambda (this index)
    ((this `elements index) `read)
  ))
  (public `write (lambda (this index new-value)
    ((this `elements index) `write new-value)
  ))
  (public `dump (lambda (this)
    (display "MEMORY DUMP\n")
    (this `elements `for-each (lambda (el i) 
      (display (string-append "\t[" (number->string i) "]:\t" (number->string (el `read)) 
        (if (= 3 (remainder i 4))
          "\n"
          "\t"
        )
      ))
    ))
    (display "END OF DUMP\n")
  ))
))

;;; TESTS
(#%require rackunit)
(define mem (new memory))
(mem `write 0 4)
(check-equal? (mem `read 0) 4)
(mem `write 0 5)
(check-equal? (mem `read 0) 5)
(mem `write -1 8)
(check-equal? (mem `read -1) 8)