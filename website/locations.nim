## Locations module
## ================
##
## This module deals with locations and generating them from the
## [locations JSON file](https://github.com/nirokay/HzgShowAroundData/blob/master/json/locationslocations.json).

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
            result.add p(html line.replace("\n", $br()))

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
                let imgUrl: string = url pics.header.get()
                html.addToHead(
                    ogImage(imgUrl),
                    twitterImage(imgUrl),
                    ogImageAlt("Bild vom Ort '" & location.name & "'."),
                    twitterImageAlt("Bild vom Ort '" & location.name & "'.")
                )
            elif pics.footer.isSet():
                # First footer image:
                let imgUrl: string = url pics.footer.get()[0]
                html.addToHead(
                    ogImage(imgUrl),
                    twitterImage(imgUrl),
                    ogImageAlt("Bild vom Ort '" & location.name & "'."),
                    twitterImageAlt("Bild vom Ort '" & location.name & "'.")
                )
            elif location.coords.isSome():
                # Map location image:
                if location.coords.get().len() < 4: break settingLocationOgImage
                var path: string = location.getLocationMapPath(absolute = true)
                # PNG instead of SVG, because SVG seems to not be supported as preview in og image
                path.removeSuffix(".svg")
                path &= ".png"
                html.addToHead(
                    ogImage(path),
                    twitterImage(path),
                    ogImageAlt("Kartenausschnitt mit dem Ort '" & location.name & "'."),
                    twitterImageAlt("Kartenausschnitt mit dem Ort '" & location.name & "'.")
                )
            else:
                # Set no og:image, will use default favicon image
                discard

proc getLocationContact(elements: OrderedTable[string, string], singular, plural, htmlHref: string): HtmlElement =
    var contactElements: seq[HtmlElement]
    let allElements: seq[array[2, string]] = block:
        var r: seq[array[2, string]]
        for name, referTo in elements: r.add [name, referTo]
        r

    # Single entry:
    if allElements.len() == 0:
        return html "ERROR, should not have happened."
    elif allElements.len() == 1:
        let element: array[2, string] = allElements[0]
        contactElements.add b(html singular & ": ")
        contactElements.add a(htmlHref & ":" & element[1], element[1])

    # Multiple entries:
    else:
        var children: seq[HtmlElement]

        # Construct bullet points:
        for element in allElements:
            var listElements: seq[HtmlElement]
            # Only add prefix name, if not whitespace-only:
            if element[0].strip() != "": listElements.add i(html element[0] & ": ")
            listElements.add a(htmlHref & ":" & element[1], element[1])
            children.add li(listElements)

        contactElements.add b(html plural & ": ")
        contactElements.add ul(children).setStyle("margin-top" := "0")

    result = `div`(contactElements).setClass(locationContactElementDiv)

proc generateLocationHtml*(location: Location) =
    ## Generates HTML site for a location
    let
        name: string = location.name
        path: string = location.getLocationPath()
    var html: HtmlDocument = newPage(
        name,
        path,
        "Infos zum Ort '" & name & "' in der Diakonie Herzogsägmühle."
    )

    html.importScripts(
        "../javascript/commons.js",
        "../javascript/news/typedefs.js",
        "../javascript/news/ical.js",
        "../javascript/news/html.js",
        "../javascript/news/news.js",
        "../javascript/locations.js"
    )

    let newsfeedEnclave: HtmlElement = `div`(
        `var`(html name).add(
            "style" <=> "display:none;",
            "id" <=> locationNewsfeedEnclaveVarId
        )
    ).add(
        "id" <=> locationNewsfeedEnclaveDivId,
        "style" <=> "width:75%;margin:auto;scale:0.9;"
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
            h1(html headerText),
            location.getLocationImage(imgHeader),
            newsfeedEnclave
        ]
    else:
        html.addToBody(
            h1(html headerText),
            newsfeedEnclave
        )

    # Opening times:
    if location.open.isSet():
        let openTable: OrderedTable[string, OpeningTimes] = get location.open
        var tables: seq[HtmlElement]
        for headingText, open in openTable:
            var elements: seq[HtmlElement]
            for day, time in open:
                elements.add(tr(@[
                    td(b(html day & ":")),
                    #[
                    I FIXED IT!!!!!!!!!!!!!!!!!
                    This comment will stay for historic purposes though! i am happy:
                    # Invisible and zero width character, so stuff is spaced a tad more... # DONE: implement this properly # DONE: eventually # DONE: not today, but seriously do this someday
                    ]#
                    td(html time)
                ]))

            if headingText != "": tables.add h3(html headingText) # add heading, if `headingText` is not `""` ...
            elif unlikely openTable.len() >= 2: tables.add h3(html name) # ... or if `headingText` is `""` but also there are multiple entries (defaults to location name)

            tables.add table(elements).setClass(centerTableClass)
        html.addToBody contentBox(ih2("Öffnungszeiten") & tables)

    # Add paragraphs:
    let description: seq[HtmlElement] = location.desc.convert()
    if description.len() != 0:
        html.addToBody contentBox description

    # Insert spacing, if header and footer image are next to another:
    if description.len() == 0 and location.has(imgHeader) and location.has(imgFooter) and not location.open.isSet():
        html.addToBody p(br())

    # Add footer image:
    if location.has(imgFooter):
        html.addToBody contentBox @[
            location.getLocationImage(imgFooter).setClass(locationImageFooterDiv)
        ]

    # Add map element (if location has coords):
    if location.coords.isSet() or location.contact.isSet():
        let path: string = location.getLocationMapPath()
        var elements: seq[HtmlElement] = @[
            ih2("Ort und Kontakt", "ort-und-kontakt"),
        ]

        # Contact info:
        if location.contact.isSet():
            var contactElements: seq[HtmlElement]
            let contact: ContactInformation = get location.contact
            # Address:
            if contact.address.isSet():
                let
                    address: string = contact.address.get()
                    parts: seq[string] = address.split(",")
                    street: string = parts[0].strip()
                    area: string = block:
                        if parts.len() < 2: "86971 Peiting-Herzogsägmühle"
                        else: parts[1].strip()
                contactElements.add `div`(
                    b(html "Anschrift: "),
                    html street,
                    html ", ",
                    i(html area)
                ).setClass(locationContactElementDiv)

            # Telephone and Email:
            if contact.tels.isSet(): contactElements.add getLocationContact(get contact.tels, "Telefonnummer", "Telefonnummern", "tel")
            if contact.emails.isSet(): contactElements.add getLocationContact(get contact.emails, "Email-Adresse", "Email-Adressen", "mailto")

            elements.add `div`(contactElements).setClass(contentBoxClass).setStyle(
                "width" := "fit-content",
                "background-color" := colourBackgroundLight
            )

        # Map:
        if location.coords.isSet():
            elements.add img(path, "Kartenausschnitt kann nicht angezeigt werden").setClass(locationImageMapPreview)

        html.addToBody(contentBox elements)

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
    html.applyStylesheet("../" & css.file)
    html.setOgImage(location)
    html.generate()

proc generateLocations*(locations: seq[Location]) =
    ## Generates all html sites for all locations
    # Separated for better logging:
    for location in locations:
        location.generateLocationHtml()
    for location in locations:
        location.generateLocationMap()
    stdout.write "\r📌 Finished generating all SVGs for every locations\n"
    stdout.flushFile()


    # Write lookup-table to disk:
    locationLookupTableFile.writeFile($%locationLookupTable)
