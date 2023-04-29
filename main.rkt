#lang r5rs

(#%require "cpu.rkt")

(define simple-addition-program (list
  799
  798
  199
  398
  299
  899
  0
))

(cpu `load simple-addition-program)
(cpu `run)
