#lang r5rs

(#%require 
  "objects/index.rkt"
  "util/vectors.rkt"
  "globals.rkt"
  "io.rkt"
  "memory.rkt"
)
(#%provide
  cpu
  register
)

(define register (memory-element `add-member
  (public-method `clear (lambda (this)
    (this `value 0)
  ))
))

(define cpu (object
  ;; internal registers
  (private `instruction-register (register `new))
  (private `program-counter      (register `new))
  (private `accumulator          (register `new))
  (private `mar                  (register `new))
  (private `mdr                  (register `new))
  ;; connected devices
  (private `main-memory          (memory `new))
  (private `input-device         (input-device `new))
  (private `output-device        (output-device `new))
  ;; flags (for bus refresh)
  (private `store?  #f)
  (private `load?   #f)
  (private `input?  #f)
  (private `output? #f)
  (private `halt?   #f)
  ;; bus refresh
  (private-method `bus-refresh (lambda (this) (begin
    (cond
      ((this `store?)
        (begin
          (this `mdr `write
            (this `accumulator `read)
          )
          (this `main-memory `write
            (this `mar `read)
            (this `mdr `read)
          )        
        )
      )
      ((this `input?)
        (this `main-memory `write
          (this `mar `read)
          (this `input-device `read)
        )
      )
      ((this `output?)
        (this `output-device `write
          (this `main-memory `read
            (this `mar `read)
          )
        )
      )
      ((this `load?)
        (begin
          (this `mdr `write 
            (this `main-memory `read 
              (this `mar `read)
            )
          )
          (this `accumulator `write
            (this `mdr `read)
          )        
        )      
      )
      (else
        (this `mdr `write 
          (this `main-memory `read 
            (this `mar `read)
          )
        )
      )
    )
    (this `store?   #f)
    (this `load?    #f)
    (this `input?   #f)
    (this `output?  #f)
  )))
  ;; fetch
  (private-method `fetch (lambda (this) (begin
    ; write the address of the next instruction to the MAR
    (this `mar `write (this `program-counter `read))
    ; increment the Program Counter
    (this `program-counter `write
      (+ 1 (this `program-counter `read))
    )
    ; read the address stored at the MAR, then store the data
    ; in the MDR
    (this `bus-refresh)
  )))
  ;; decode
  (private-method `decode (lambda (this) (begin
    ; move the instruction from the MDR to the Instruction 
    ; Register
    (this `instruction-register `write
      (this `mdr `read)
    )
    ; separate the address and store it in the MAR
    ; note: address = ir % 100; opcode = ir / 100
    (this `mar `write 
      (remainder 
        (this `instruction-register `read)
        100
      )
    )
    ; set the flags based on the opcode
    (define opcode (quotient (this `instruction-register `read) 100))
    (cond 
      ((= opcode __sto__)  (this `store?   #t))
      ((= opcode __ld__)   (this `load?    #t))
      ((= opcode __in__)   (this `input?   #t))
      ((= opcode __out__)  (this `output?  #t))
      ((= opcode __halt__) (this `halt?    #t))
    )
    ; bus refresh
    (this `bus-refresh)
  )))
  ;; execute
  (private-method `execute (lambda (this) (begin
    (define opcode (quotient (this `instruction-register `read) 100))
    (cond 
      ((= opcode __add__)
        (this `accumulator `write
          (+ 
            (this `accumulator `read)
            (this `mdr `read)
          )
        )
      )
      ((= opcode __sub__)
        (this `accumulator `write
          (- 
            (this `accumulator `read)
            (this `mdr `read)
          )
        )
      )
      ((= opcode __mpy__)
        (this `accumulator `write
          (* 
            (this `accumulator `read)
            (this `mdr `read)
          )
        )
      )
      ((= opcode __div__)
        (this `accumulator `write
          (/ 
            (this `accumulator `read)
            (this `mdr `read)
          )
        )
      )
      ((= opcode __br__)
        (this `program-counter `write
          (quotient (this `instruction-register `read) 100)
        )
      )
      ((= opcode __bz__)
        (if (= 0 (this `accumulator `read))
          (this `program-counter `write
            (quotient (this `instruction-register `read) 100)
          )
        )
      )
      ((= opcode __bgrt__)
        (if (> 0 (this `accumulator `read))
          (this `program-counter `write
            (quotient (this `instruction-register `read) 100)
          )
        )
      )
    )
  )))
  ;; load a program
  (public-method `load (lambda (this lst . index) (begin
    (if (or (null? lst) (= 0 (car lst)))
      (this `main-memory `write 
        (if (null? index) 0 (car index))
        (car lst)
      )    
      (begin
        (this `main-memory `write 
          (if (null? index) 0 (car index))
          (car lst)
        )
        (this `load 
          (cdr lst) 
          (if (null? index) 1 (+ 1 (car index)))
        )
      )
    )
  )))
  ;; run
  (public-method `run (lambda (this) (begin
    (if (this `halt?)
      0
      (begin
        (this `fetch)
        (this `decode)
        (this `execute)
        (this `run)
      )
    )
  )))
))
