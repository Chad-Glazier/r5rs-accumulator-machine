#lang r5rs

(#%require "objects/index.rkt")

(define obj (object
  (public `a (vector `apple "bottom" (list #\j #\e #\a #\n #\s)))
  (public `b (list `el-1 "el-2" 3))
  (public `nested-object (object
    (public `x 0)
    (public `y "1")
    (public `z `2)
  ))
))

(display (obj `to-string))
(newline)