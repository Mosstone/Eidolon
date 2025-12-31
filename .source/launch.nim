import os
import osproc
import times
import strutils


var name = "Eidolon"
var version = "v0.0.1"
var verbosity = false
var interactive = false
var download = false
var sin = "/.engine/Eidolon"
var loc = getAppDir()

var command = ""
if paramCount() > 0:

    if paramStr(1) in ["--shell", "--verbose"]:
        command = ":"       #   if the command arg is a flag, turn it into a passe


if paramStr(1) == "sin":
    download = true
    let p = commandLineParams()
    command = p[1..^1].join(" ")
else:
    command = paramStr(1)

echo "command is " & command







proc printhelp() =

    echo """[094m
        Copyright (c) 2025, Daniel Buerer. All rights reserved. This software is not licensed
        for distribution, modification, or commercial use without explicit written permission


        Usage:
            Pass 'Eidolon' with nothing added
            
            Passing the Eidolon command by itself launches the preconfigured architecture and
            runs the framework in a new window. Using arguments alongside allows you to alter
            the singularity environment

            Commands to be run go in quotations as the second argument, followed by any flags
            
            If you pass commands and enter the shell, the command will run immediately before
            you can start interacting with the terminal

            Eidolon "[095m<commands>[094m" <flags>

            A utility was added to Eidolon for pulling docker images in a sif format. However
            this is for utility; the Eidolon system expects the particular image built for it

            Eidolon sin search arch
            Eidolon sin download archlinux

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
    
    if verbosity: echo "[90m" & getTime().format("HH:mm:ss") & " ... command passed: " & command & " [0m"






##############################################################################################################################






proc depCheck(): bool =
    if verbosity: echo "[90m" & getTime().format("HH:mm:ss") & " ... checking dependencies [0m"
    
    var exit = false


    if findExe("singularity").len == 0:
        echo "\n    [94mEidolon requires [35mApptainer[94m to be installed[0m\n"
        exit = true


    if download:
        if findExe("skopeo").len == 0:
            echo "\n    [94mDownloader requires [35mSkopeo[94m to be installed[0m\n"
            exit = true

        if findExe("trivy").len == 0:
            echo "\n    [94mDownloader requires [35mTrivy[94m to be installed[0m\n"
            exit = true


    if exit == true:
        return false
    else:
        return true


proc pull() =

    discard execCmd(loc & "/.assets/Sin " & command)


proc launch() =

    if     verbosity:
        echo    "[90m" & getTime().format("HH:mm:ss") & " ... start singularity [0m"

    echo   "[94m"                                                               # this injects arguments into the interactive shell
    if     interactive:  discard execCmd("singularity exec --writable " & loc & sin & " bash --rcfile <(echo \'source /etc/profile && " & command & "\') -i")
    if not interactive:  discard execCmd("singularity exec --writable " & loc & sin & " bash -lc \"" & command & "\"")
    echo   "[0m"


    if     verbosity:
        echo    "[90m" & getTime().format("HH:mm:ss") & " ... close singularity [0m"




proc main() =

    arguments()


    if depCheck():
        if download == true:
            echo "download true"
            pull()
        else:
            echo "download false"
            launch()


        if verbosity: echo "[90m" & getTime().format("HH:mm:ss") & " ... entrypoint closed [0m"
        quit(1)
    else:
        quit(0)

main()