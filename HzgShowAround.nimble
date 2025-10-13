# Package

version       = "1.0.0"
author        = "nirokay"
description   = "Builder for website-project 'hzgshowaround'."
license       = "GPL-3.0-only"
bin           = @["hzgshowaround"]

# Tasks

task runall, "Compiles all and runs executable":
    echo "Pulling changes..."
    exec "./pull-all.sh"

    echo "Compiling TS..."
    exec "./compile-typescript.sh"

    echo "Running builder..."
    exec "nimble run"

# Dependencies

requires "nim >= 2.2.2"
requires "websitegenerator >= 2.5.1"
