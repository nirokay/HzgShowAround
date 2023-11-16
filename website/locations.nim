import std/[tables, json, options, strutils]
import websitegenerator
import styles

const
    locationHtmlPath*: string = "location/"
    locationsJsonPath*: string = "resources/locations.json"

type
    Pictures* = object
        header*, footer*: Option[string]

    Coords* = seq[int] ## Length of 3 == circle, length of 4 == rect

    Paragraph* = seq[string] ## Lines of a paragraph (will be separated using `<br />` html element, instead of `\n`)

    Description* = OrderedTable[string, Paragraph] ## Collection of paragraphs (html: `<p> ... </p>`) with headers

    OpeningTimes* = OrderedTable[string, string]

    Location* = object
        name*: string
        desc*: Description
        open*: Option[OpeningTimes]
        pics*: Option[Pictures]
        coords*: Option[Coords]
        path*: Option[string] ## Optional, because needs not to be inserted into json file
        same*: Option[seq[string]] ## Optional similar locations


proc convert*(desc: Description): seq[HtmlElement] =
    ## Converts a `Location`s description to a sequence of `HtmlElement`
    for header, content in desc:
        var content: string = content.join("\n").replace("\n", $br())
        result.add h2(header) # Table index as header
        result.add p(content) # Table values as paragraph

proc getLocationPath(name: string): string =
    result = locationHtmlPath & name.strip().toLower().replace(' ', '_') & ".html"
proc getLocationPath(location: Location): string =
    result = location.name.getLocationPath()

var buffer: Option[seq[Location]] ## Cache
proc getLocations*(): seq[Location] =
    ## Gets a sequence of all locations
    # Return cache, if present:
    if buffer.isSome():
        return buffer.get()

    # Parse locations from json:
    result = readFile(locationsJsonPath)
        .parseJson()
        .to(seq[Location])

    # Add path to location html in object:
    for i in 0 .. result.len() - 1:
        var location: Location = result[i]
        location.path = some location.getLocationPath()
        result[i] = location

    # Cache location data:
    buffer = some result

proc generateLocationsHtmlPages*(locations: seq[Location]) =
    ## Generates all html sites for all locations
    for location in locations:
        var html: HtmlDocument = newDocument(location.getLocationPath())

        # Add header:
        html.addToBody h1(location.name)

        # Add header image:
        if location.pics.isSome():
            let pics = get location.pics
            if pics.header.isSome():
                html.addToBody img(get pics.header, location.name & " header image").setClass(textCenterClass)

        # Add opening/closing times:
        if location.open.isSome():
            let open: OpeningTimes = get location.open
            var elements: seq[HtmlElement]
            for day, time in open:
                elements.add(tr(@[
                    td($b(day & ": ")),
                    td(time)
                ]))
            html.addToBody(
                h2("Öffnungszeiten"),
                table(elements)
            )

        # Add paragraphs:
        html.addToBody location.desc.convert()

        # Add footer image:
        if location.pics.isSome():
            let pics = get(location.pics)
            if pics.footer.isSome():
                html.addToBody img(get pics.footer, location.name & " footer image").setClass(textCenterClass)

        # Add similar places as links:
        if location.same.isSome():
            var
                same: seq[string] = get location.same
                table: OrderedTable[string, string]
            for name in same:
                table[name] = name.getLocationPath()
            

        # Apply css and write to disk:
        html.addToHead(stylesheet("../styles.css"))
        html.writeFile()





