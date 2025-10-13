#!/usr/bin/env bash

DIR_DATA="HzgShowAroundData"

git pull
[ -d "$DIR_DATA" ] && {
    cd "$DIR_DATA"
    git pull
    cd ..
}
