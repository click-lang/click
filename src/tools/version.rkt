(module click/tools/version racket/base
  (provide version-subcommand)

  (define [version-subcommand argv]
    (println "0.0.1"))
  )
