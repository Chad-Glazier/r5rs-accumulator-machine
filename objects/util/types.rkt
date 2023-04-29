#lang r5rs

(#%provide
  object?
  method?
  defined?
  undefined?
  typeof
)

(define (object? obj)
  (if (procedure? obj)
    (obj `object?)
    #f
  )
)

(define (method? obj)
  (if (procedure? obj)
    (obj `method?)
    #f
  )
)

(define (defined? obj)
  (not (equal? obj `undefined))
)

(define (undefined? obj)
  (equal? obj `undefined)
)

(define (typeof val)
  (cond
    ((equal? `undefined val) `undefined)
    ((object? val) `object)
    ((method? val) `method)
    ((procedure? val)
      (begin 
        (display (string-append
          "Warning: Attempted to get the `typeof` a non-method, non-object procedure.\n"
          "         This is allowed, but all member values which are procedures should,\n"
          "         under normal circumstances, be either a method or an object.\n\n"
        ))
        `procedure
      )
    )
    ((number? val) `number)
    ((boolean? val) `boolean)
    ((string? val) `string)
    ((symbol? val) `symbol)
    ((char? val) `char)
    ((list? val) `list)
    ((pair? val) `pair)
    ((vector? val) `vector)
    (else (begin
      (display (string-append
        "Warning: Unrecognized type passed to `typeof`. This is likely an error with\n"
        "         the `typeof` function.\n\n"
      ))
      `undefined
    ))
  )
)