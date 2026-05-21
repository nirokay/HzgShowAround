#/usr/bin/env bash

PIXELS=350

if ! rsvg-convert -v &> /dev/null; then
    echo -e "Dependency missing: rsvg-convert\nPlease install before running again, aborting."
    exit 1
fi

function convert() {
    INPUT_FILE=$1
    OUTPUT_FILE="${INPUT_FILE%.svg}.png"
    rsvg-convert -f png -w $PIXELS -h $PIXELS -o $OUTPUT_FILE $INPUT_FILE
}

for file in ./docs/resources/images/map-locations/*.svg; do
    echo -e "Converting '$file'..."
    convert $file &
done
