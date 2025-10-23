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
        "Infos zum Ort '" & name & "' in der Diakonie Herzogsägmühle."
    )

    html.addToHead importScript("../javascript/commons.js").add(attr("defer"))
    html.addToHead importScript("../javascript/news/typedefs.js").add(attr("defer"))
    html.addToHead importScript("../javascript/news/ical.js").add(attr("defer"))
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
        let openTable: OrderedTable[string, OpeningTimes] = get location.open
        var tables: seq[HtmlElement]
        for headingText, open in openTable:
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

            # Add heading, if `headingText` is not `""` or if `headingText` is `""` but also there are multiple entries (defaults to location name)
            if headingText != "": tables.add h3(headingText)
            elif unlikely openTable.len() >= 2: tables.add h3(name)

            tables.add table(elements).setClass(centerTableClass)
        html.addToBody contentBox(ih2("Öffnungszeiten") & tables)

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
                    b("Anschrift: "),
                    <$>street,
                    <$>", ",
                    i(area)
                ).setClass(locationContactElementDiv)
            # Telephone:
            if contact.tels.isSet():
                let tels: OrderedTable[string, string] = get contact.tels
                if tels.hasKey(""):
                    contactElements.add `div`(
                        b("Telefonnummer: "),
                        a("tel:" & tels[""], tels[""])
                    ).setClass(locationContactElementDiv)
                else:
                    var children: seq[HtmlElement]
                    for name, number in tels:
                        children.add li(@[
                            i(name & ": "),
                            a("tel:" & number, number)
                        ])
                    contactElements.add `div`(
                        b("Telefonnummern: "),
                        ul(children).addStyle("margin-top" := "0")
                    ).setClass(locationContactElementDiv)

            # Email:
            if contact.emails.isSet():
                let emails: OrderedTable[string, string] = get contact.emails
                if emails.hasKey(""):
                    contactElements.add `div`(
                        b("Email-Adresse: "),
                        a("mailto:" & emails[""], emails[""])
                    ).setClass(locationContactElementDiv)
                else:
                    var children: seq[HtmlElement]
                    for name, address in emails:
                        children.add li(@[
                            i(name & ": "),
                            a("mailto:" & address, address)
                        ])
                    contactElements.add `div`(
                        b("Email-Adressen: "),
                        ul(children).addStyle("margin-top" := "0")
                    ).setClass(locationContactElementDiv)

            elements.add `div`(contactElements).setClass(contentBoxClass).addStyle(
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
    html.addToHead(stylesheet("../styles.css"))
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
