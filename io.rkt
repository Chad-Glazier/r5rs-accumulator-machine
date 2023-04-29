#lang r5rs

(#%require
  "objects/index.rkt"
)
(#%provide
  input-device
  output-device
)

(define input-device (object
  (public-method `read (lambda (this)
    (begin
      (display "? ")
      (read)
    )
  ))
))

(define output-device (object
  (public-method `write (lambda (this output)
    (begin
      (display "-> ")
      (display (number->string output))
      (newline)
      output
    )
  ))
))