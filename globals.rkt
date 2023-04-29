#lang r5rs

(#%provide
  __halt__
  __ld__
  __sto__
  __add__
  __sub__
  __mpy__
  __div__
  __in__
  __out__
  __br__
  __bz__
  __bgrt__
)

(define __halt__ 0)    
(define __ld__ 1)       
(define __sto__ 2)     
(define __add__ 3)
(define __sub__ 4)
(define __mpy__ 5)
(define __div__ 6)
(define __in__ 7)
(define __out__ 8)
(define __br__ 9)
(define __bz__ 10)
(define __bgrt__ 11)
