#lang r5rs

(#%require
  "util/strings.rkt"
  "util/types.rkt"
)
(#%provide
  form->string
  form::subset?
  form::superset?
)

(define form->string (lambda (form . indenation-depth)
  (let* 
    (
      (indenation-depth (if (not (null? indenation-depth))
        (car indenation-depth)
        0
      ))
      (indendation (repeat-string indenation-depth "  "))
    )
    (string-append
      "{\n"
      (apply string-append (map 
        (lambda (form-item) 
          (string-append "  " indendation 
            (symbol->string (car form-item)) 
            (cond
              ((pair? (cdr form-item))
                (string-append 
                  ": " (form->string (cdr form-item) (+ 1 indenation-depth))
                )
              )
              ((undefined? (cdr form-item))
                ""
              )
              (else
                (string-append
                  ": " (symbol->string (cdr form-item))
                )
              )
            ) 
            "\n"
          ) 
        )
        form
      ))
      indendation "}"                  
    )
  )
))

(define form::subset? (lambda (form-a form-b)
  (cond
    ((null? form-a) #t)
    ((null? form-b) #f)
    ((assoc (caar form-a) form-b)
      (and
        (equal? 
          (cdr (car form-a)) 
          (cdr (assoc (caar form-a) form-b))
        )
        (form::subset? (cdr form-a) form-b)
      ) 
    )
    (else
      #f
    )
  )
))

(define form::superset? (lambda (form-a form-b)
  (form::subset? form-b form-a)
))