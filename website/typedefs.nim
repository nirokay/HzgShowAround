import std/[options, tables, json]
import client, globals

# Location stuff:

const
    locationHtmlPath*: string = "location/" ## Path to directory with all location HTML files

type
    Pictures* = object
        header*: Option[string]
        footer*: Option[seq[string]]

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

    LocationImageType* = enum
        imgHeader = "header image",
        imgFooter = "footer image"

iterator withCoords*(locations: seq[Location]): Location =
    ## Filters locations only with coordinates
    for location in locations:
        if location.coords.isNone(): continue
        if location.coords.get().len() == 0: continue
        yield location

proc getLocationPath*(name: string): string =
    ## Get url path of a location html
    result = getRelativeUrlId(locationHtmlPath & name & ".html")

proc getLocationPath*(location: Location): string =
    ## Get url path of a location html
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


# Map stuff:

const
    mapAreaFillColour*: string = "#1a1a1aff" ## Overlay colour
    locationMapImagePath*: string = "resources/images/map-locations/"

type
    Rect* = object
        ## Rectangle overlay object
        id*: string
        x*, y*, width*, height*: float
        ry*, rx*: float = 0
        fill*: string = mapAreaFillColour
        stroke*: string = mapAreaFillColour ## Does this value even do something? I do not know...
    Layer*[T] = object
        ## Inkscape layer object
        name*: string
        opacity*: float = 1.0
        shapes*: seq[T]

