(module click/adt typed/racket/base
  (require (for-syntax syntax/parse
                       syntax/stx
                       racket/syntax
                       racket/base
                       racket/sequence))

  (provide define-datatype)

  (begin-for-syntax
    (define-syntax-class type
      (pattern name:id
               #:attr [param 1] '()
               #:attr [field-id 1] '())
      (pattern (name:id param ...+)
               #:attr [field-id 1] (generate-temporaries #'(param ...)))))

  (define-syntax define-datatype
    (syntax-parser
      [(_ type-name:type data-constructor:type ...)

       (define/with-syntax [data-type ...]
         (for/list ([name (in-syntax #'(data-constructor.name ...))])
           (if (stx-null? #'(type-name.param ...))
               name
               #`(#,name type-name.param ...))))

       #'(begin
           (struct (type-name.param ...) data-constructor.name
             ([data-constructor.field-id : data-constructor.param] ...)) ...
           (define-type type-name (U data-type ...)))])))

