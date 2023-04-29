#lang r5rs

(#%require
  "util/vectors.rkt"
  "objects/index.rkt"
)
(#%provide 
  memory-element
  memory
)

(define memory-element (object
  (private `value 0)
  (public-method `read (lambda (this)
    (this `value)
  ))
  (public-method `write (lambda (this value)
    (this `value value)
  ))
))

(define memory (object
  (private `elements (vector-of 100 memory-element))
  (public-method `read (lambda (this index)
    ((vector-ref (this `elements) index) `read)
  ))
  (public-method `write (lambda (this index new-value)
    ((vector-ref (this `elements) index)
      `write
      new-value
    )
  ))
  (public-method `dump (lambda (this)
    (apply string-append
      (vector->list (vector-map-with-index
        (lambda (el i)
          (string-append
            "[" (number->string i) "]:\t"
            (number->string (this `read i))
            (if (= 3 (remainder i 4))
              "\n"
              "\t"
            )
          )
        )
        (this `elements)
      ))
    )
  ))
))
