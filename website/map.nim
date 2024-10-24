## Map module
## ==========
##
## This module generates the `map.html` file. It adds clickable area tags to an image to simulate a dynamic map.
##
## At the end: calls external proc to generate a SVG file

import std/[strutils, options, sequtils]
import generator, styles, mapgenerator, typedefs, snippets

var html: HtmlDocument = newPage(
    "Karte von Herzogsägmühle",
    "map.html",
    "Interaktive Karte von Herzogsägmühle."
)


var
    locations: seq[Location] = getLocations()
    picture: HtmlElement = img(svgExportPath, "Interaktive Karte ist unverfügbar").add(
        attr("usemap", "#location-map"),
        attr("width", px(mapScaleTo)),
        attr("height", px(mapScaleTo))
    )

picture.addStyle(
    "border-radius" := "20px"
)

var areas: seq[string]

for location in locations.withCoords():
    let
        coords: Coords = get location.coords
        scale: float = toFloat(mapScaleTo) / toFloat(mapResolution)
    var area: HtmlElement = newHtmlElement("area")

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
        scaledCoords.add int(toFloat(coord) * scale)

    # Coords and link:
    area.add(
        attr("coords", scaledCoords.join(",")),
        attr("alt", location.name),
        attr("href", location.getLocationPath()),
        attr("tabindex", "0"),
        attr("class", "map-element")
    )

    # Dirty quick-fix for weird behaviour:
    area.tagAttributes = area.tagAttributes.deduplicate()

    # Add to sequence:
    areas.add($area)

var map: HtmlElement = newHtmlElement("map", areas.join("\n"))
    .add(attr("name", "location-map"))

html.addToBody(
    divSpacerTop, # TODO: Fix this dirty hack, someday
    h1("Karte von Herzogsägmühle"),
    pc("Diese Karte ist interaktiv. Du kannst jede Stecknadel/Grau-Schwarzes Rechteck anklicken und zu dem entsprecheneden Ort gelangen."),
    insertButtons(hrefIndex),
    `div`(
        picture,
        map
    ).setClass(centerClass).addStyle(
        "overflow" := "scroll",
        "touch-action" := "pan-x pan-y pinch-zoom",
        "max-width" := "1000px",
        "max-height" := "1000px",
        "height" := "60vh",
        "width" := "90%",
        "border-radius" := "20px"
    ),
    divSpacerBottom # TODO: Fix this dirty hack, someday
)

generateFullSvgMap()

html.add ogImage(urlImages & "map.svg")
html.setStylesheet(css)
html.generate()
