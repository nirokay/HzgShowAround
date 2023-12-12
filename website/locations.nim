import std/[tables, json, options, strutils]
import generator, styles, client

const
    locationHtmlPath*: string = "location/" ## Path to directory with all location HTML files

type
    Pictures* = object
        header*, footer*: Option[string]

    Coords* = seq[int] ## Length of 3 == circle, length of 4 == rect

    Paragraph* = seq[string] ## Lines of a paragraph (will be separated using `<br />` html element, instead of `\n`)

    Description* = OrderedTable[string, Paragraph] ## Collection of paragraphs (html: `<p> ... </p>`) with headers

    OpeningTimes* = OrderedTable[string, string] ## `OrderedTable` of opening times

    Location* = object
        name*: string ## Location name
        link*: Option[string] ## Link to a webpage (if there is one)
        desc*: Description ## Description about a location
        open*: Option[OpeningTimes] ## Optional opening times
        pics*: Option[Pictures] ## Optional header and footer images
        coords*: Option[Coords] ## Optional coordinates -> will be inserted into the map image
        path*: Option[string] ## Optional, because needs not to be inserted into json file
        same*: Option[seq[string]] ## Optional similar locations

iterator withCoords*(locations: seq[Location]): Location =
    ## Filters locations only with coordinates
    for location in locations:
        if location.coords.isNone(): continue
        if location.coords.get().len() == 0: continue
        yield location

proc convert*(desc: Description): seq[HtmlElement] =
    ## Converts a `Location`s description to a sequence of `HtmlElement`
    for header, content in desc:
        var content: string = content.join("\n").replace("\n", $br())
        result.add h2(header) # Table index as header
        result.add p(content) # Table values as paragraph

proc getLocationPath*(name: string): string =
    result = getRelativeUrlId(locationHtmlPath & name & ".html")

proc getLocationPath*(location: Location): string =
    result = location.name.getLocationPath()

var buffer: Option[seq[Location]] = none seq[Location] ## Cache
proc getLocations*(): seq[Location] =
    ## Gets a sequence of all locations
    # Return cache, if present:
    if buffer.isSome():
        return buffer.get()

    # Parse locations from json:
    result = getLocationJson().to(seq[Location])

    # Add path to location html in object:
    for i in 0 .. result.len() - 1:
        var location: Location = result[i]
        location.path = some location.getLocationPath()
        result[i] = location

    # Cache location data:
    buffer = some result

type
    LocationImageType = enum
        imgHeader = "header image",
        imgFooter = "footer image"

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
    result = img(urlLocationImages & src, altText).setClass(textCenterClass)

proc generateLocationsHtmlPages*(locations: seq[Location]) =
    ## Generates all html sites for all locations
    for location in locations:
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
                html.addToBody location.getLocationImage(imgHeader)

        if location.open.isSet():
            let open: OpeningTimes = get location.open
            var elements: seq[HtmlElement]
            for day, time in open:
                elements.add(tr(@[
                    td($b(day & ": ")),
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
                html.addToBody location.getLocationImage(imgFooter)

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

        # Apply css and write to disk:
        html.addToHead(stylesheet("../styles.css"))
        html.generate()
