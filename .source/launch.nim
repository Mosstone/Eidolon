import os
import osproc
import times


var name = "Eidolon"
var version = "v0.0.1"
var verbosity = false
var interactive = false
var sin = "/.engine/Eidolon"
var loc = getAppDir()

var arg = " "
if paramCount() > 0:
    arg = paramStr(1)
    if arg in ["--shell", "--verbose"]:
        arg = ":"






proc printhelp() =

    echo """[094m
        Copyright (c) 2025, Daniel Buerer. All rights reserved. This software is not licensed
        for distribution, modification, or commercial use without explicit written permission


        Usage:
            Passing the Eidolon command by itself launches the preconfigured architecture and
            runs the framework in a new window. Using arguments alongside allows you to alter
            the singularity environment

            Commands to be run go in quotations as the second argument, followed by any flags
            
            If you pass commands and enter the shell, the command will run immediately before
            you can start interacting with the terminal

            Eidolon "[095m<commands>[094m" <flags>

            Flags:
                --verbose       |   Prints additional information
                --shell         |   Enter an interactive terminal

            
    [0m"""
    quit(0)


proc printversion() =

    echo "[035m\n    " & name & "[094m\n    " & version & "[0m\n"
    quit(0)


proc arguments() =
    for arg in commandLineParams():

        case arg
            of "--help":
                printhelp()

            of "--version":
                printversion()

            of "--verbose":
                verbosity = true

            of "--shell":
                interactive = true

            else:
                discard
    
    if verbosity: echo "[90m" & getTime().format("HH:mm:ss") & " ... command passed: " & arg & " [0m"






##############################################################################################################################






proc depCheck(): bool =
    if findExe("singularity").len == 0:
        if verbosity: echo "[90m" & getTime().format("HH:mm:ss") & " ... checking dependencies [0m"
        echo "\n    [94mEidolon requires [35mApptainer[94m to be installed[0m\n"
        return false
    else:
        return true


proc launch() =

    if     verbosity:
        echo    "[90m" & getTime().format("HH:mm:ss") & " ... start singularity [0m"

    echo   "[94m"                                                               # this injects arguments into the interactive shell
    if     interactive:  discard execCmd("singularity exec --writable " & loc & sin & " bash --rcfile <(echo \'source /etc/profile && " & arg & "\') -i")
    if not interactive:  discard execCmd("singularity exec --writable " & loc & sin & " bash -lc \"" & arg & "\"")
    echo   "[0m"


    if     verbosity:
        echo    "[90m" & getTime().format("HH:mm:ss") & " ... close singularity [0m"




proc main() =

    arguments()


    if depCheck():
        launch()
        if verbosity: echo "[90m" & getTime().format("HH:mm:ss") & " ... entrypoint closed [0m"
        quit(1)
    else:
        quit(0)

main()