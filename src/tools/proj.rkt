(module click/tools/proj racket/base
  (require readline/readline
           racket/format
           racket/match
           racket/file)
  (provide proj-subcommand)

  (define [proj-subcommand argv]
    (match argv
      [(cons "new" xs) (proj-new xs)]
      [(cons "run" xs) (proj-run xs)]
      [(cons "help" xs) (proj-help xs)]
      [(cons "test" xs) (proj-test xs)]
      [(cons "exec" xs) (proj-exec xs)]
      [(cons "build" xs) (proj-build xs)]
      [(cons "clean" xs) (proj-clean xs)]
      [(cons "check" xs) (proj-check xs)]
      [(list) (proj-help (list))]
      [_ (println "Invalid command.")
         (proj-help (list))]))
  
  (define [proj-run argv]
    (println "Not implemented yet"))
  (define [proj-test argv]
    (println "Not implemented yet"))
  (define [proj-exec argv]
    (println "Not implemented yet"))
  (define [proj-build argv]
    (println "Not implemented yet"))
  (define [proj-clean argv]
    (println "Not implemented yet"))
  (define [proj-check argv]
    (println "Not implemented yet"))
  
  (define [proj-help]
    (println (string-append "Usage: click proj <command>\n"
                            "Commands:\n"
                            "new [name]" "Creates a project in the current directory or a new one if a name is specified"
                            "run [name]" "Compiles and executes from the main entry point, or a secondary one if specified"
                            "build [name]" "Compiles from the main entry point, or a secondary one if specified"
                            "clean [name]" "Removes all binaries or a specified one"
                            "check [name]" "Checks to make sure the build will compile without actually compiling it. Saves time."
                            "test [name]" "Runs all tests, or a single test if specified")))
  

  (define [proj-new {name #f}]
    (cond [name]
          [(file-exists? "config.clk")
           (println "This directory is already a Click project. If you want to make changes to it, edit the 'config.clk' file.")]
          [else
           (set! name (readline (~a "Project name (" (current-directory) "): ")))
           (define desc (readline "description: "))
           (define entry (readline "Main (src/main.clk): "))
           (define git? (readline "Initialize with git? (Y/n)"))
           (define license (readline (~a "Would you like to add a License?"
                                         "No license/Add your own (default): 0\n"
                                         "Apache License 2.0: 1\n"
                                         "BSD 2: 2\n"
                                         "BSD 3: 3\n"
                                         "GNU GPL 3: 4\n"
                                         "MIT: 5\n"
                                         "Unlicense: 6\n")))
           
           
           (set! name (current-directory))
           (write-to-file (~a "##" name) "README.md" #:mode 'text)
           (write-to-file (~a "(name " name ")") "config.clk" #:mode 'text)
           
           (make-directory* "test")
           (write-to-file "(def-test [])")
           
           (make-directory* "src")
           (write-to-file "(def main [] \n\t(println \"Hello World!\"))" "src/main.clk" #:mode 'text)]))
  )
