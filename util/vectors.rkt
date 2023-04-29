#lang r5rs

(#%provide
  len
  vector-map
  vector-map-with-index
  vector-of
)

(define len vector-length)

(define (vector-map mapper vec)
  (let 
    ((mapped-vector (make-vector (vector-length vec))))
    (do 
      ((i 0 (+ i 1)))
      ((>= i (vector-length vec)))
      (vector-set! 
        mapped-vector i 
        (mapper (vector-ref vec i))
      )
    )
    mapped-vector
  )
)

(define (vector-map-with-index mapper vec)
  (let 
    ((mapped-vector (make-vector (vector-length vec))))
    (do 
      ((i 0 (+ i 1)))
      ((>= i (vector-length vec)))
      (vector-set! 
        mapped-vector i 
        (mapper (vector-ref vec i) i)
      )
    )
    mapped-vector
  )
)

(define (vector-of length obj)
  (vector-map
    (lambda (el) (obj `new))
    (make-vector length)
  )
)
