#!/usr/bin/env bash

FLAGS=$*

SLEEP=$(( 60 * 5 * 1 ))
ADDITIONAL_COMMIT_MESSAGE=""
TMP_FILE=$(mktemp)

function fetch() {
    git pull
}

function push() {
    git push
}

function commit() {
    DATE=$(date "+%Y-%m-%d  %H:%M:%S")
    [ "$ADDITIONAL_COMMIT_MESSAGE" == "" ] && ADDITIONAL_COMMIT_MESSAGE="no details"
    git add .
    git commit -m "Automatic deployment @ $DATE" -m "$ADDITIONAL_COMMIT_MESSAGE"
    ADDITIONAL_COMMIT_MESSAGE=""
}

function rebuild() {
    # Blindly build it, trust it works :))))
    nimble run
}

function main() {
    ADDITIONAL_COMMIT_MESSAGE=""
    echo "Automatic deployment starting @ $(date)"

    # Attempt to fetch from source, over and over until it works:
    while ! fetch; do
        sleep 10
    done

    # Rebuild (output from nimble to tmp file, then to `ADDITIONAL_COMMIT_MESSAGE`):
    rebuild &> "$TMP_FILE"
    ADDITIONAL_COMMIT_MESSAGE=$(cat "$TMP_FILE")

    # Commit, using `ADDITIONAL_COMMIT_MESSAGE` as description:
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


if [[ "${FLAGS[*]}" =~ "--once" ]]; then
    echo "Running once!"
    main
else
    while true; do
        echo -e "Automatic deployment script started, sleeping for $SLEEP seconds..."
        sleep $SLEEP
        main
    done
fi

