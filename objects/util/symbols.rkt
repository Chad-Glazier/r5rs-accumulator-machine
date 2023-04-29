#lang r5rs

(#%require "strings.rkt")
(#%provide any->symbol)

(define (any->symbol obj)
  (if (symbol? obj)
    obj
    (string->symbol (any->string obj))
  )
)