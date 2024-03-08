#!/usr/bin/env bash

SLEEP=$(( 60 * 60 * 24 ))
ADDITIONAL_COMMIT_MESSAGE=""

function fetch() {
    git pull
}

function push() {
    git push
}

function commit() {
    DATE=$(date "+%Y-%m-%d  %H:%M:%S")
    git add .
    git commit -m "Automatic deployment @ $DATE""$ADDITIONAL_COMMIT_MESSAGE"
    ADDITIONAL_COMMIT_MESSAGE=""
}

function rebuild() {
    # Blindly build it, trust it works :))))
    nimble run
}

function main() {
    ADDITIONAL_COMMIT_MESSAGE=""
    echo -e "Automatic deployment script started, sleeping for $SLEEP seconds..."
    sleep $SLEEP
    echo "Automatic deployment starting @ $(date)"

    # Attempt to fetch from source, over and over until it works:
    while ! fetch; do
        sleep 10
    done

    if ! rebuild; then
        ADDITIONAL_COMMIT_MESSAGE="+ failed build!"
    fi
    commit
    PUSHING=0
    REVERT=0
    while ! push; do
        sleep 10
        PUSHING=$((PUSHING + 1))
        [ $PUSHING -eq 10 ] && REVERT=1 && break # Give up trying to push
    done

    [ ! $REVERT -eq 0 ] && git reset --hard master # Give up on current push, try again on next call
}

while true; do
    main
done

