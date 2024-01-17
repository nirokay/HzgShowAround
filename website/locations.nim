## Locations module
## ================
##
## This module deals with locations and generating them from the
## [locations JSON file](https://github.com/nirokay/HzgShowAroundData/blob/master/locations.json).

import std/[tables, options, strutils]
import generator, styles, typedefs, mapgenerator

proc convert*(desc: Description): seq[HtmlElement] =
    ## Converts a `Location`s description to a sequence of `HtmlElement`s
    for header, content in desc:
        var content: string = content.join("\n").replace("\n", $br())
        result.add h2(header) # Table index as header
        result.add pc(content) # Table values as paragraph

proc getLocationImage(location: Location, img: LocationImageType): HtmlElement =
    ## Gets the HTML for a header/footer image
    let
        pics: Pictures = get location.pics
        src: string = get(
            case img:
                of imgHeader: pics.header
                of imgFooter: pics.footer
            )
        altText: string = "$1 $2 nicht vorhanden" % [location.name, $img]
    result = img(urlLocationImages & src, altText)

    case img:
    of imgHeader: result.setClass("")
    of imgFooter: result.setClass("")

proc generateLocationMap*(location: Location) =
    ## Generates the location map
    location.generateLocationSvgMap()

proc getLocationMapPath*(location: Location): string =
    ## Gets the relative path to the location map (from the perspective of a location page)
    result = "../resources/images/map-locations/" & location.name.getRelativeUrlId() & ".svg"

proc generateLocationHtml*(location: Location) =
    ## Generates HTML site for a location
    var html: HtmlDocument = newPage(
        location.name,
        location.getLocationPath(),
        "Infos zum Ort " & location.name
    )

    # Add header:
    let headerText: string = block:
        if location.link.isSome(): $a(get location.link, location.name)
        else: location.name
    html.addToBody h1(headerText)

    # Add header image:
    if location.pics.isSome():
        let pics = get location.pics
        if pics.header.isSome():
            html.addToBody location.getLocationImage(imgHeader).setClass(locationImageHeader)

    if location.open.isSet():
        let open: OpeningTimes = get location.open
        var elements: seq[HtmlElement]
        for day, time in open:
            elements.add(tr(@[
                td($b(day & ": ⁣")), # Invisible, zero width, character, so stuff is spaced a tad more... # TODO: implement this properly
                td(time)
            ]))
        html.addToBody(
            h2("Öffnungszeiten"),
            table(elements).setClass(centerTableClass)
        )

    # Add paragraphs:
    html.addToBody location.desc.convert()

    # Add footer image:
    if location.pics.isSome():
        let pics = get(location.pics)
        if pics.footer.isSome():
            html.addToBody location.getLocationImage(imgFooter).setClass(locationImageFooter)

    # Add map element (if location has coords):
    if location.coords.isSet():
        let path: string = location.getLocationMapPath()

        html.addToBody(
            h2("Position auf der Karte"),
            img(path, "Kartenausschnitt kann nicht angezeigt werden").setClass(locationImageHeader)
        )

    # Add similar places as links:
    if location.same.isSet():
        var
            same: seq[string] = get location.same
            table: OrderedTable[string, string]

        for name in same:
            table[name] = name.getRelativeUrlPath()

        let buttons: seq[HtmlElement] = table.buttonList()

        # Only actually add if the stuff is set:
        if same.len() != 0:
            html.addToBody(
                h2("Das könnte dich auch interessieren"),
                `div`(buttons).setClass(centerClass)
            )

    # Back buttons:
    html.addToBody(
        h2("Mehr interessante Orte entdecken"),
        `div`(
            button("← Startseite", "../index.html"),
            button("← Karte", "../map.html")
        ).setClass(centerClass)
    )
    # Apply css and write to disk:
    html.addToHead(stylesheet("../styles.css"))
    html.generate()

proc generateLocations*(locations: seq[Location]) =
    ## Generates all html sites for all locations
    for location in locations:
        location.generateLocationMap()
        location.generateLocationHtml()
