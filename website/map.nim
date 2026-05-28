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
    pictureDimensions: tuple[width, height, maxWidth, maxHeight: int] = (
        90, 85, 1500, 1500
    )
    locations: seq[Location] = getLocationsSorted()
    picture: HtmlElement = img(svgExportPath, "Karte wird geladen...").add(
        "usemap" <=> "#location-map",
        "width" <=> $mapScaleTo & "px",
        "height" <=> $mapScaleTo & "px"
    ).setStyle(
        "border-radius" := "20px",
        "text-align" := "center",
        "color" := colourText,
        "width" := $mapScaleTo & "px",
        "height" := $mapScaleTo & "px",
        "margin" := "0px"
    )

var areas: seq[string]
for location in locations.withCoords():
    let
        coords: Coords = get location.coords
        scale: float = toFloat(mapScaleTo) / toFloat(mapResolution)
    var area: HtmlElement = newHtmlElement("area")

    # Shape:
    case coords.len():
    of 3: area.add "shape" <=> "circle"
    of 4: area.add "shape" <=> "rect"
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
        "coords" <=> scaledCoords.join(","),
        "alt" <=> location.name,
        "href" <=> location.getLocationPath(),
        "tabindex" <=> "0",
        "class" <=> "map-element",
        "title" <=> location.name
    )

    # Dirty quick-fix for weird behaviour:
    area.attributes = area.attributes.deduplicate()

    # Add to sequence:
    areas.add($area)

var map: HtmlElement = newHtmlElement("map", html areas.join("\n")).add(
    "name" <=> "location-map"
)

var locationButtons: seq[HtmlElement]
for location in locations:
    locationButtons.add a(location.path.get("404.html"), location.name).setClass(buttonClass).setStyle("color" := colourText)

html.addToBody(
    divSpacerTop, # TODO: Fix this dirty hack, someday
    h1(html "Karte von Herzogsägmühle"),
    pc("Diese Karte ist interaktiv. Du kannst jede Stecknadel/Grau-Schwarzes Rechteck anklicken und zu dem entsprechenden Ort gelangen."),
    insertButtons(hrefIndex),
    `div`(
        picture,
        map
    ).setClass(centerClass).setStyle(
        "overflow" := "scroll",
        "touch-action" := "pan-x pan-y pinch-zoom",
        "max-width" := $pictureDimensions.maxWidth & "px",
        "max-height" := $pictureDimensions.maxHeight & "px",
        "width" := $pictureDimensions.width & "%",
        "height" := $pictureDimensions.height & "vh",
        "border-radius" := "20px",
        "margin" := "10px auto"
    ),
    `div`(
        locationButtons
    ).setClass(flexContainerClass),
    divSpacerBottom # TODO: Fix this dirty hack, someday
)

generateFullSvgMap()
stdout.write "\r📌 Finished generating big map\n"
stdout.flushFile()

html.add ogImage(urlImages & "map.svg")
html.applyStylesheet(css)
html.generate()
