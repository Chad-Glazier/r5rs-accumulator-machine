#lang r5rs

(#%provide 
  has
  some
  find
  filter
  reduce
  deep-copy
)

(define has (lambda (target lst)
  (some 
    (lambda (element)
      (equal? element target)
    )
    lst
  )
))

(define some (lambda (predicate lst)
  (cond
    ((null? lst) 
      #f
    )
    ((predicate (car lst))
      #t
    )
    (else
      (some predicate (cdr lst))
    )
  )
))

(define find (lambda (predicate lst)
  (cond
    ((null? lst) 
      `()
    )
    ((predicate (car lst))
      (car lst)
    )
    (else
      (find predicate (cdr lst))
    )
  )
))

(define filter (lambda (predicate lst)
  (cond
    ((null? lst) 
      '()
    )
    ((predicate (car lst))
     (cons (car lst) (filter predicate (cdr lst)))
    )
    (else 
      (filter predicate (cdr lst))
    )
  )
))

(define reduce-helper (lambda (reducer lst acc)
  (cond
    ((null? lst) acc)
    (else
      (reduce-helper
        reducer
        (cdr lst)
        (reducer acc (car lst))
      )
    )
  )
))

(define reduce (lambda (reducer lst . init)
  (cond
    ((null? lst) lst)
    ((null? (cdr lst)) (car lst))
    (else
      (if (null? init)
        (reduce-helper
          reducer
          (cdr lst)
          (car lst)
        )
        (reduce-helper
          reducer
          lst
          (car init)
        )
      )    
    )
  )
))

(define deep-copy (lambda (lst)
  (cond
    ((null? lst) 
      lst
    )
    ((not (pair? lst))
      lst
    )
    ((pair? (car lst))
      (cons 
        (deep-copy (car lst)) 
        (deep-copy (cdr lst))
      )
    )
    (else
      (cons 
        (car lst) 
        (deep-copy (cdr lst))
      )
    )
  )
))

;;; TESTS
(#%require rackunit)

(define test-list (list 1 2 3 4 5))

(check-equal? (has 3 test-list) #t)
(check-equal? (has 6 test-list) #f)

(check-equal? (some even? test-list) #t)
(check-equal? (some (lambda (x) (> x 6)) test-list) #f)

(check-equal? (find (lambda (x) (= x 2)) test-list) 2)
(check-equal? (find (lambda (x) (= x 6)) test-list) '())

(check-equal? (filter odd? test-list) (list 1 3 5))
(check-equal? (filter (lambda (x) (> x 6)) test-list) '())

(check-equal? (reduce + test-list) 15)
(check-equal? (reduce * test-list) 120)
(check-equal? (reduce + test-list 10) 25)
(check-equal? (reduce (lambda (x y) (string-append x y)) '("hello" "world" "goodbye")) "helloworldgoodbye")
(check-equal? (reduce (lambda (x y) (if (> x y) x y)) test-list) 5)
(check-equal? (reduce (lambda (x y) (- x y)) (list 1)) 1)

; Define some example lists for testing
(define example-list-1 '(1 2 3))
(define example-list-2 '((1 2) (3 4)))
(define example-list-3 '(1 (2 (3 (4) 5) 6) 7))

(check-equal? (reduce append example-list-2) '(1 2 3 4))

; Test that deep-copy returns an equal list when given a simple flat list
(check-equal? (deep-copy example-list-1) example-list-1)

; Test that deep-copy returns an equal list when given a nested list
(check-equal? (deep-copy example-list-2) example-list-2)

; Test that deep-copy returns an equal list when given a more complex nested list
(check-equal? (deep-copy example-list-3) example-list-3)

; Test that modifying the original list doesn't affect the copied list
(define copied-list (deep-copy example-list-2))
(set-car! (car example-list-2) 999)
(check-equal? copied-list '((1 2) (3 4)))

; Test that deep-copy handles empty list
(check-equal? (deep-copy '()) '())
