## Tools 

Everything in this directory is tools that users of Click interface with directly. 
The main entry point is in `click.rkt` and every other file is a subcommand of Click. 

For example, `$ click repl` will invoke functions inside the `repl.rkt` file. For more complex
subcommands like `$click pkg install <package-name>`, everything continues to exist inside just the 
`pkg.rkt` file, and everything is treated as arguments to the `pkg` function.

### Click
This is the main tool that users interface with. It contains everything that Click aims to do
including package managment, build system tools, formatting, etc.

### Docs
This is a subcommand of the `click` tool. It allows you to interface with the Click docs by looking 
up functions or concepts in click and searching through the docs for them. 

### Help
This is a simpler version of docs. It's to get people going initially and give a brief, more 
controlled overview of Click.

### Pkg 
This tools contains everything related to package management. Downloading packages, adding project 
dependencies, updating packages, removing packages, and setting up your own project to be uploaded 
to the package repository system. 

### Repl
This is the subcommand for interacting with the repl. You can specify commands to have other files 
loaded into the repl, specify connecting to remote repl sessions, loading old sessions, etc.

### Proj
Probably the main tool that people will interact with. Allows you to interact with the compiler 
to produce binaries, allows you to run your project, run your tests, run specified builds with 
various entry points, create commands for your project, etc.
