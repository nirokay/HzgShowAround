## Locations module
## ================
##
## This module deals with locations and generating them from the
## [locations JSON file](https://github.com/nirokay/HzgShowAroundData/blob/master/locations.json).

import std/[tables, options, strutils, json]
import generator, styles, typedefs, mapgenerator
import snippets except pc

var locationLookupTable: OrderedTable[string, LocationLookup]

proc convert*(desc: Description): seq[HtmlElement] =
    ## Converts a `Location`s description to a sequence of `HtmlElement`s
    for header, content in desc:
        # Table index as header:
        if header.strip() != "":
            result.add ih2(header)
        # For each line, put in a separate `<p> ... </p>` and replace all `\n` with `<br />`:
        for line in content:
            result.add p(line.replace("\n", $br()))

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
    block settingLocationOgImage:
        if location.pics.isSome():
            let pics: Pictures = get location.pics
            if pics.header.isSet():
                # Header image:
                html.add ogImage(url pics.header.get())
            elif pics.footer.isSet():
                # First footer image:
                html.add ogImage(url pics.footer.get()[0])
            elif location.coords.isSome():
                # Map location image:
                if location.coords.get().len() < 4: break settingLocationOgImage
                html.add ogImage(location.getLocationMapPath(absolute = true))
            else:
                # Set no og:image, will use default favicon image
                discard

proc generateLocationHtml*(location: Location) =
    ## Generates HTML site for a location
    let
        name: string = location.name
        path: string = location.getLocationPath()
    var html: HtmlDocument = newPage(
        name,
        path,
        "Infos zum Ort " & name
    )

    html.addToHead importScript("../javascript/commons.js").add(attr("defer"))
    html.addToHead importScript("../javascript/news/typedefs.js").add(attr("defer"))
    html.addToHead importScript("../javascript/news/html.js").add(attr("defer"))
    html.addToHead importScript("../javascript/news/news.js").add(attr("defer"))
    html.addToHead importScript("../javascript/locations.js").add(attr("defer"))

    let newsfeedEnclave: HtmlElement = `div`(
        `var`(name).add(
            attr("style", "display:none;"),
            attr("id", locationNewsfeedEnclaveVarId)
        )
    ).add(
        attr("id", locationNewsfeedEnclaveDivId),
        attr("style", "width:75%;margin:auto;scale:0.9;")
    )

    # Add to lookup table (used by newsfeed to replace substrings):
    locationLookupTable[name] = LocationLookup(
        names: @[name],
        path: path
    )
    if location.alias.isSome():
        let aliases: seq[string] = get location.alias
        locationLookupTable[name].names = locationLookupTable[name].names & aliases

    let headerText: string = block:
        if location.link.isSet(): $aNewTab(get location.link, name)
        else: name
    # Add header and header image:
    if location.has(imgHeader):
        html.addToBody contentBox @[
            h1(headerText),
            location.getLocationImage(imgHeader),
            newsfeedEnclave
        ]
    else:
        html.addToBody(
            h1(headerText),
            newsfeedEnclave
        )

    # Opening times:
    if location.open.isSet():
        let open: OpeningTimes = get location.open
        var elements: seq[HtmlElement]
        for day, time in open:
            elements.add(tr(@[
                td($b(day & ":")),
                #[
                I FIXED IT!!!!!!!!!!!!!!!!!
                This comment will stay for historic purposes though! i am happy:

                    # Invisible and zero width character, so stuff is spaced a tad more... # DONE: implement this properly # DONE: eventually # DONE: not today, but seriously do this someday
                ]#
                td(time)
            ]))
        html.addToBody(contentBox @[
            ih2("Öffnungszeiten"),
            table(elements).setClass(centerTableClass)
        ])

    # Add paragraphs:
    let description: seq[HtmlElement] = location.desc.convert()
    if description != @[]:
        html.addToBody contentBox description

    # Insert spacing, if header and footer image are next to another:
    if description == @[] and location.has(imgHeader) and location.has(imgFooter) and not location.open.isSet():
        html.addToBody p($br())

    # Add footer image:
    if location.has(imgFooter):
        html.addToBody contentBox @[
            location.getLocationImage(imgFooter).setClass(locationImageFooterDiv)
        ]

    # Add map element (if location has coords):
    if location.coords.isSet():
        let path: string = location.getLocationMapPath()

        html.addToBody(contentBox @[
            ih2("Position auf der Karte", "position"),
            img(path, "Kartenausschnitt kann nicht angezeigt werden").setClass(locationImageMapPreview)
        ])

    # Add similar places as links:
    if location.same.isSet():
        var
            same: seq[string] = get location.same
            table: OrderedTable[string, string]

        for name in same:
            table[name] = name.getRelativeUrlPath()

        let buttons: seq[HtmlElement] = table.buttonList("location/")

        # Only actually add if the stuff is set:
        if same.len() != 0:
            html.addToBody(contentBox @[
                ih2("Das könnte dich auch interessieren", "aehnliches"),
                `div`(buttons).setClass(centerClass)
            ])

    # Back buttons:
    html.addToBody(contentBox @[
        ih2("Mehr interessante Orte entdecken", "mehr"),
        insertButtons(
            hrefIndex,
            hrefMap
        )
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

    # Write lookup-table to disk:
    locationLookupTableFile.writeFile($%locationLookupTable)
