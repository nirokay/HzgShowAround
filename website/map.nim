## Map module
## ==========
##
## This module generates the `map.html` file. It adds clickable area tags to an image to simulate a dynamic map.
##
## At the end: calls external proc to generate a SVG file

import std/[strutils, options]
import generator, styles, mapgenerator, typedefs, locations as locationModule

var html: HtmlDocument = newPage(
    "Karte von Herzogsägmühle",
    "map.html",
    "Interaktive Karte von Herzogsägmühle."
)


var
    locations: seq[Location] = getLocations()
    picture: HtmlElement = img(svgExportPath, "Interaktive Karte ist unverfügbar").add(
        attr("usemap", "#location-map"),
        attr("width", $mapScaleTo),
        attr("height", $mapScaleTo)
    )

var areas: seq[string]

for location in locations.withCoords():
    let
        coords: Coords = get location.coords
        scale: float = float(mapScaleTo) / float(mapResolution)
    var area: HtmlElement = newElement("area")

    # Shape:
    case coords.len():
    of 3: area.add attr("shape", "circle")
    of 4: area.add attr("shape", "rect")
    else:
        raise ValueError.newException(
            "Got a length of " & $coords.len() & " for coordinates! Expected 3-4. " &
            "Please double check location " & location.name & "!"
        )

    var scaledCoords: seq[int]
    for coord in coords:
        scaledCoords.add int(float(coord) * scale)

    # Coords and link:
    area.add(
        attr("coords", scaledCoords.join(",")),
        attr("alt", location.name),
        attr("href", location.getLocationPath()),
        attr("tabindex", "0"),
        attr("class", "map-element")
    )

    # Add to sequence:
    areas.add($area)

var map: HtmlElement = newElement("map", areas.join("\n"))
    .add(attr("name", "location-map"))

html.addToBody(
    h1("Karte von Herzogsägmühle"),
    pc("Diese Karte ist interaktiv. Du kannst jede Stecknadel/Grau-Schwarzes Rechteck anklicken und zu dem entsprecheneden Ort gelangen."),
    `div`(
        button("← Startseite", "index.html"),
    ).setClass(centerClass),
    `div`(
        picture,
        map
    ).setClass(centerWidth100Class).add(
        attr("style", "overflow:auto;")
    )
)

generateFullSvgMap()

html.setStyle(css)
html.generate()
