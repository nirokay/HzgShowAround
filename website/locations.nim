## Locations module
## ================
##
## This module deals with locations and generating them from the
## [locations JSON file](https://github.com/nirokay/HzgShowAroundData/blob/master/locations.json).

import std/[tables, options, strutils]
import generator, styles, typedefs, mapgenerator
import snippets except pc

proc pc(lines: varargs[string]): HtmlElement =
    ## Override for non-centering stuff
    result = p(lines)

proc convert*(desc: Description): seq[HtmlElement] =
    ## Converts a `Location`s description to a sequence of `HtmlElement`s
    for header, content in desc:
        # Table index as header:
        if header.strip() != "":
            result.add h2(header)
        # For each line, put in a separate `<p> ... </p>` and replace all `\n` with `<br />`:
        for line in content:
            result.add pc(line.replace("\n", $br()))

proc has*(location: Location, img: LocationImageType): bool =
    if not location.pics.isSome(): return false
    let pics: Pictures = get location.pics
    result = case img:
        of imgHeader: pics.header.isSet()
        of imgFooter: pics.footer.isSet()

proc getLocationImage*(location: Location, img: LocationImageType): HtmlElement =
    ## Gets the HTML for a header/footer image(s)
    let
        pics: Pictures = get location.pics
        altText: string = "$1 $2 nicht vorhanden" % [location.name, $img]
    var sources: seq[string] = block:
        case img:
        of imgHeader: @[pics.header.get()]
        of imgFooter: pics.footer.get()

    var imageBlock: seq[HtmlElement]

    for src in sources:
        imageBlock.add img(urlLocationImages & src, altText)

    let class: CssElement = case img:
        of imgHeader: locationImageHeader
        of imgFooter: locationImageFooter

    for index, img in imageBlock:
        imageBlock[index] = img.setClass(class)

    result = `div`(imageBlock)

proc generateLocationMap*(location: Location) =
    ## Generates the location map
    location.generateLocationSvgMap()

proc getLocationMapPath*(location: Location, absolute: bool = false): string =
    ## Gets the relative/absolute path to the location map (from the perspective of a location page)
    if not absolute: result = "../resources/images/map-locations/"
    else: result = urlDeploymentLocationMaps
    result &= location.name.getRelativeUrlId() & ".svg"

proc setOgImage*(html: var HtmlDocument, location: Location) =
    ## Sets `og:image` for a location, follows this hierarchy:
    ## 1. header image
    ## 2. first footer image
    ## 3. map location
    proc url(path: string): string =
        ## Gets the image from remote repo
        urlLocationImages & path

    # Abomination:
    if location.pics.get().header.isSet():
        # Header image:
        html.addOgImage(url location.pics.get().header.get())
    elif location.pics.get().footer.isSet():
        # First footer image:
        html.addOgImage(url location.pics.get().footer.get()[0])
    else:
        # Map location image:
        html.addOgImage(location.getLocationMapPath(absolute = true))

proc generateLocationHtml*(location: Location) =
    ## Generates HTML site for a location
    var html: HtmlDocument = newPage(
        location.name,
        location.getLocationPath(),
        "Infos zum Ort " & location.name
    )

    let headerText: string = block:
        if location.link.isSet(): $a(get location.link, location.name)
        else: location.name
    # Add header and header image:
    if location.has(imgHeader):
        html.addToBody contentBox @[
            h1(headerText),
            location.getLocationImage(imgHeader)
        ]
    else:
        html.addToBody h1(headerText)

    # Opening times:
    if location.open.isSet():
        let open: OpeningTimes = get location.open
        var elements: seq[HtmlElement]
        for day, time in open:
            elements.add(tr(@[
                td($b(day & ": ⁣")), # Invisible and zero width character, so stuff is spaced a tad more... # TODO: implement this properly # TODO: eventually
                td(time)
            ]))
        html.addToBody(contentBox @[
            h2("Öffnungszeiten"),
            table(elements).setClass(centerTableClass)
        ])

    # Add paragraphs:
    let description: seq[HtmlElement] = location.desc.convert()
    if description != @[]:
        html.addToBody contentBox description

    # Insert spacing, if header and footer image are next to another:
    if description == @[] and location.has(imgHeader) and location.has(imgFooter) and not location.open.isSet():
        html.addToBody pc($br())

    # Add footer image:
    if location.has(imgFooter):
        html.addToBody contentBox @[
            location.getLocationImage(imgFooter).setClass(locationImageFooterDiv)
        ]

    # Add map element (if location has coords):
    if location.coords.isSet():
        let path: string = location.getLocationMapPath()

        html.addToBody(contentBox @[
            h2("Position auf der Karte"),
            img(path, "Kartenausschnitt kann nicht angezeigt werden").setClass(locationImageMapPreview)
        ])

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
            html.addToBody(contentBox @[
                h2("Das könnte dich auch interessieren"),
                `div`(buttons).setClass(centerClass)
            ])

    # Back buttons:
    html.addToBody(contentBox @[
        h2("Mehr interessante Orte entdecken"),
        `div`(
            buttonLink("← Startseite", "../index.html"),
            buttonLink("← Karte", "../map.html")
        ).setClass(centerClass)
    ])
    # Apply css and write to disk:
    html.addToHead(stylesheet("../styles.css"))
    html.setOgImage(location)
    html.generate()

proc generateLocations*(locations: seq[Location]) =
    ## Generates all html sites for all locations
    for location in locations:
        location.generateLocationMap()
        location.generateLocationHtml()
