(module click/tools/pkg racket/base
  (require
   racket/match)
  (provide pkg-subcommand)

  (define [pkg-subcommand argv]
    (match argv
      [(cons "install" xs) (pkg-install xs)]
      [(cons "update" xs) (pkg-update xs)]
      [(cons "delete" xs) (pkg-delete xs)]
      [(cons "show" xs) (pkg-show xs)]
      [(cons "query" xs) (pkg-query xs)]
      [(cons "deps" xs) (pkg-deps xs)]
      [(cons "help" xs) (pkg-help xs)]
      [(list) (pkg-help null)]
      [_ (println "Invalid command.")
         (pkg-help null)]))
  
  (define [pkg-help argv]
    (println "Not implemented yet"))
  (define [pkg-install argv]
    (println "Not implemented yet"))
  (define [pkg-update argv]
    (println "Not implemented yet"))
  (define [pkg-delete argv]
    (println "Not implemented yet"))
  (define [pkg-show argv]
    (println "Not implemented yet"))
  (define [pkg-query argv]
    (println "Not implemented yet"))
  (define [pkg-deps argv]
    (println "Not implemented yet"))

  )
