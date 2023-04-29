#lang r5rs

(#%require
  "util/deep-copy.rkt"
  "util/types.rkt"
  "util/strings.rkt"
  "util/symbols.rkt"
  "util/lists.rkt"
)

(#%provide
  member
  members->form
  members->string
  member->string
  member::id
  member::new
  member::private?
  member::public?
  member::value
  member::original-attributes
  member::type
  member::object?
  member::method?
  member::mutable?
  members::add-member
  members::add-members

  ;; Wrappers for "member"
  public
  public-readonly
  public-method
  private
  private-readonly
  private-method
)

(define member (lambda original-attributes
  (let*
    (
      (attributes (deep-copy original-attributes))
      (id (if (assoc `id attributes)
        (if (symbol? (cadr (assoc `id attributes)))
          (cadr (assoc `id attributes))
          (begin
            (display (string-append
              "Warning: Declared a member with a non-symbol id."
              "\n"
              "         The provided id was " (any->string (cadr (assoc `id attributes))) ","
              "\n"
              "         which was coerced to the symbol `" 
              (symbol->string (any->symbol (cadr (assoc `id attributes))))
              "\n\n"
            ))
            (any->symbol (cadr (assoc `id attributes)))
          )
        )
        (begin
          (display "Warning: Member was defined without an id. Defaulting to `undefined.\n\n")
          `undefined
        )
      ))
      (private? 
        (if (assoc `private? attributes)
          (cadr (assoc `private? attributes))
          (if (assoc `public? attributes)
            (not (cadr (assoc `public? attributes)))
            #t
          )
        )
      )
      (public? (not private?))
      (value
        (if (assoc `value attributes)
          (cadr (assoc `value attributes))
          `undefined
        )
      )
      (mutable?
        (if (assoc `mutable? attributes)
          (cadr (assoc `mutable? attributes))
          #f
        )
      )
      (method? (if (procedure? value)
        (value `method?)
        #f
      ))
      (object? (if (procedure? value)
        (value `object?)
        #f
      ))
    )
    (lambda args
      (let
        (
          (message (if (null? args)
            `undefined
            (car args)
          ))
          (arg-1 (if (and (not (null? args)) (not (null? (cdr args))))
            (cadr args)
            `undefined
          ))
          (all-args (if (null? args)
            `undefined
            (cdr args)
          ))
        )
        (case message
          (`id (if (defined? arg-1)
            (begin
              (display (string-append
                "Warning: A member's ID was modified.\n"
                "         The id `" (symbol->string id) " was changed to " 
                (symbol->string (any->symbol arg-1)) "\n"
                "         The modification of an ID is allowed, but discouraged.\n"
                "\n"
              ))
              (set! id (any->symbol arg-1))
              id
            )
            id
          ))
          (`type (if (defined? arg-1)
            (equal? (typeof value) arg-1)
            (typeof value)              
          ))
          (`value (if (defined? arg-1)
            (begin
              (if 
                (and
                  (not (equal? (typeof arg-1) (typeof value)))
                  (defined? value)
                )
                (display (string-append
                  "Warning: The type of member " (symbol->string id) " was changed "
                  "from " (symbol->string (typeof value)) " to " (symbol->string (typeof arg-1)) ".\n" 
                  "         Dynamic typing is allowed, but discouraged.\n\n"
                ))
              )
              (set! value arg-1)
              arg-1
            )
            value
          ))
          (`private? (if (defined? arg-1)
            (begin
              (display (string-append
                "Warning: A member's access modifier was modified.\n"
                "         The member `" (symbol->string id) " was " (if public? "public" "private") ",\n"
                "         but is now " (if (not (not arg-1)) "private" "public") ".\n\n"
              ))
              (set! private? (not (not arg-1)))
              (set! public? (not private?))
              private?
            )
            private?
          ))
          (`public? (if (defined? arg-1)
            (begin
              (display (string-append
                "Warning: A member's access modifier was modified.\n"
                "         The member `" (symbol->string id) " was " (if public? "public" "private") ",\n"
                "         but is now " (if (not (not arg-1)) "public" "private") ".\n\n"
              ))
              (set! public? (not (not arg-1)))
              (set! private? (not public?))
              public?
            )
            public?
          ))
          (`mutable? mutable?)
          (`new (if (defined? arg-1)
            (apply member (map (lambda (attribute)
              (case (car attribute)
                (`id (list `id arg-1))
                (`value (list `value (deep-copy value)))
                (else
                  attribute
                )
              )              
            ) attributes))
            (apply member attributes)
          ))
          (`to-string (string-append
            (if public? "public " "private ")
            (if (or mutable? method?) "" "readonly ")
            (symbol->string id)
            (if (undefined? value)
              ""
              (string-append ": " (symbol->string (typeof value)) " ")
            )
            (if (and (defined? value) (not method?))
              (string-append "= " (any->string value (if (defined? arg-1) arg-1 0)))
              ""
            )
          ))
          (`undefined original-attributes)
          (else (begin
            (display (string-append
              "Warning: Attempted to access a nonexistent attribute\n" 
              "         " (any->string message) " on the member `" (symbol->string id) "\n\n"
            ))
            `undefined
          ))
        )
      )
    )
  )
))

(define (member->string mem)
  (mem `to-string)
)

(define (member::private? mem)
  (mem `private?)
)

(define (member::public? mem)
  (mem `public?)
)

(define (member::value mem)
  (mem `value)
)

(define (member::id mem)
  (mem `id)
)

(define (member::new mem . new-id)
  (if (null? new-id)
    (mem `new)
    (mem `new (car new-id))
  )
)

(define (member::type mem)
  (typeof (mem `value))
)

(define (member::method? mem)
  (if (procedure? (mem `value))
    ((mem `value) `method?)
    #f
  )
)

(define (member::object? mem)
  (if (procedure? (mem `value))
    ((mem `value) `object?)
    #f
  )
)

(define (member::original-attributes mem)
  (mem)
)

(define (member::mutable? mem)
  (mem `mutable?)
)

(define members->form (lambda (members)
  (map 
    (lambda (mem)
      (cons
        (member::id mem)
        (if (member::object? mem)
          ((member::value mem) `form)
          (member::type mem)
        )
      )
    )  
    (filter member::public? members)
  )
))

(define members->string (lambda (members . indenation-depth)
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
        (lambda (mem) 
          (string-append "  " indendation (mem `to-string indenation-depth) "\n")
        )
        (append 
          (filter (lambda (mem) (not (member::method? mem))) members)
          (filter member::method? members)
        )
      ))
      indendation "}"                  
    )
  )
))

(define members::add-member (lambda (members new-member)
  (cond
    ((null? members) (list new-member))
    ( 
      (and
        (equal? 
          (member::id (car members))
          (member::id new-member)
        )
        (equal?
          (member::public? (car members))
          (member::public? new-member)
        )
      )
      members
    )
    (else
      (cons
        (car members)
        (members::add-member
          (cdr members)
          new-member
        )
      )
    )
  )
))

(define members::add-members (lambda (members new-members)
  (if (null? new-members)
    members
    (members::add-members 
      (members::add-member members (car new-members)) 
      (cdr new-members)
    )
  )
))


;; This section is just a set of wrappers for the `member` function to make
;; object definitions easier.

(define public (lambda (id . value)
  (member
    (list `public? #t)
    (list `mutable? #t)
    (list `id id)
    (list `value (if (null? value) `undefined (car value)))
  )       
))

(define private (lambda (id . value)
  (member
    (list `private? #t)
    (list `mutable? #t)
    (list `id id)
    (list `value (if (null? value) `undefined (car value)))
  )
))

(define public-readonly (lambda (id . value)
  (member
    (list `public? #t)
    (list `mutable? #f)
    (list `id id)
    (list `value (if (null? value) `undefined (car value)))
  )
))

(define private-readonly (lambda (id . value)
  (member
    (list `private? #t)
    (list `mutable? #f)
    (list `id id)
    (list `value (if (null? value) `undefined (car value)))
  )
))

(define public-method (lambda (id value)
  (member
    (list `public? #t)
    (list `mutable? #f)
    (list `id id)
    (list `value (lambda args
      (case (car args)
        (`object? #f)
        (`method? #t)
        (else
          (apply value args)
        )        
      )
    ))
  )
))

(define private-method (lambda (id value)
  (member
    (list `private? #t)
    (list `mutable? #f)
    (list `id id)
    (list `value (lambda args
      (case (car args)
        (`object? #f)
        (`method? #t)
        (else
          (apply value args)
        )        
      )
    ))
  )
))