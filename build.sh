#!/usr/bin/env bash

TASKS=(
    # Build main project:
    "nimble run"

    # Build js:
    "cd javascript"
    "nimble build"
    "cd .."
)

function printRed() {
    echo -e "\\e[31m$*"
}

for task in "${TASKS[@]}"; do
    printRed "Executing '$task'"
    $task
done

