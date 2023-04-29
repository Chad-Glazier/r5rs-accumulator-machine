#lang r5rs

(#%require
  "types.rkt"
)
(#%provide
  any->string
  repeat-string
)

(define (repeat-string multiplier str)
  (cond
    ((= 0 multiplier) "")
    ((= 1 multiplier) str)
    (else (string-append str (repeat-string (- multiplier 1) str)))
  )
)

(define (any->string obj . indentation-depth)
  (cond
    ((undefined? obj) "<undefined>")
    ((boolean? obj) (if obj "#t" "#f"))
    ((number? obj) (number->string obj))
    ((symbol? obj) (symbol->string obj))
    ((string? obj) (string-append "\"" obj "\""))
    ((char? obj) (string-append "'" (list->string (list obj)) "'"))
    ((method? obj) "<#method>")
    ((object? obj) 
      (obj `to-string (if (not (null? indentation-depth))
        (+ 1 (car indentation-depth))
        1
      ))
    )
    ((procedure? obj) "<#procedure>")
    ((vector? obj)
      (string-append "#" (any->string (vector->list obj)))
    )
    ((list? obj)
      (let
        ((str (apply string-append 
          (append (cons "(" (map 
            (lambda (el)
              (string-append (any->string el) " ")
            )
            obj
          )))
        )))
        (string-append
          (substring str 0 (- (string-length str) 1))
          ")"
        )
      )
    )
    ((pair? obj)
      (string-append
        "(" (any->string (car obj))
        " . " (any->string (cdr obj)) ")" 
      )
    ) 
  )
)