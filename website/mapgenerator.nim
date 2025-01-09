## Map generator module
## ====================
##
## This module genuinely hurts my eyes, so here is your trigger-warning for magic value, hardcoded SVG and many more.
## The reasoning behind generating a SVG file on the fly is, so that you can dynamically add location markers/pins
## and rectangle as overlays for clickable areas (because who needs to visualise the `<area>` tag anyways... right?).

import std/[strutils, strformat, options]
import client, globals, typedefs, snippets

const
    viewbox: int = 200 ## Hard-coded viewbox width/height, just like the gods intended
    smoothing: float = 1.0 ## Overlay rectangle corner smoothing value
    opacity: float = 0.25 ## Overlay opacity
    svgExportPath*: string = "resources/images/map.svg" ## Where the modified map is exported to

let scale: float = float(viewbox) / 2000 # wtf does this do??

proc `:=`[T](id: string, value: T): string = id & "=\"" & $value & "\"" ## Shortcut to add quotes to `value`

proc `$`*(rect: Rect): string =
    ## Stringifies the rect object to a SVG rectangle
    # Tag:
    result = "<rect\n"

    result &= @[
        "style" := &"fill:{rect.fill};stroke-width:0.25",
        "id" := rect.id,
        "width" := rect.width,
        "height" := rect.height,
        "x" := rect.x,
        "y" := rect.y,
        "rx" := rect.rx,
        "ry" := rect.ry
    ].join("\n")

    # Tag:
    result &= " />"

proc `$`*(layer: Layer): string =
    ## Stringifies the layer object to a SVG layer
    # Header:
    result = @[
        "inkscape:groupmode" := "layer",
        "id" := &"layer_{layer.name}",
        "inkscape:label" := layer.name,
        "style" := &"opacity:{layer.opacity};fill:{mapAreaFillColour}"
    ].join("\n")

    # Tag:
    result = "<g\n" & result & ">"

    # Shapes:
    var rects: seq[string]
    for rect in layer.shapes:
        rects.add $rect
    result &= rects.join("\n")

    # Tag:
    result &= "</g>"


let templateSvgData: string = getMapSvg().strip()

type SvgFile* = tuple[data: string, locations: seq[Rect]]
proc newSvgFile*(): SvgFile =
    ## Sets `data` to `templateSvgData`
    result.data = templateSvgData

var fullMap: SvgFile = newSvgFile()

proc beautify(svg: var SvgFile) =
    ## Splits closing and opening tags with a newline
    var data: string = svg.data.replace("><", ">\n<")
    svg.data = data

proc appendData(svg: var SvgFile, data: string) =
    ## Appends data before the closing `</svg>` tag
    svg.beautify()
    let index: int = svg.data.find("</svg>")
    if index < 0:
        echo "Svg data: ```\n" & svg.data
        echo "```\nOops, wtf happened to the svg map? Human, please debug this fuckery..."
        # quit QuitFailure
    svg.data.insert(data, index)

proc pin(pinId: string, x, y: float, scale: float): string =
    ## Gets svg for adding a location pin
    var
        view: float = float(viewbox) * scale * 12.5
        x: float = x * view
        y: float  = y * view
        # textSize: float = 20
    result = &"""<g
    id="Location_marker_{pinId}"
    transform="matrix({scale},0,0,{scale},0,0)">
    <g id="pin_{pinId}" transform="matrix(0,0,0,0,0)" >
        <path
            id="pin_body_{pinId}"
            d="m {x},{y} c -0.2729,-0.7794 -1.645,-6.0275 -3.049,-11.662 -4.441,-17.823 -12.122,-36.988 -22.546,-56.255 -5.9844,-11.061 -7.0667,-12.824 -24.551,-40 -28.252,-43.911 -33.217,-56.241 -32.173,-79.89 0.9573,-21.672 8.2717,-37.909 24.149,-53.61 13.179,-13.032 27.807,-20.549 45.601,-23.432 44.097,-7.1446 86.878,21.883 95.546,64.828 2.0208,10.012 1.5723,27.243 -0.95271,36.604 -2.77,10.269 -13.883,31.045 -29.589,55.315 -28.348,43.807 -39.082,65.687 -47.119,96.05 -3.1117,11.755 -4.3985,14.673 -5.3161,12.052 z"
            style="fill:#f41922;stroke:#5a0000;stroke-width:5.7"
            inkscape:connector-curvature="0"
        />
        <ellipse
            id="pin_ellipse_{pinId}"
            style="fill:#0e232e;stroke-width:0"
            cx="{x + 2}"
            cy="{y - 180}"
            rx="34.5"
            ry="35.5"
        />
    </g>
</g>"""

# Text for location (removed because of ugly/unreadable overlaying)
#[
    <text
        xml:space="preserve"
        transform="matrix({textSize},0,0,{textSize},0,0)"
        id="text_{pinId}"
        style="font-size:4px;white-space:pre;display:inline;fill:#000000">
        <tspan
            x="5"
            y="-5"
            id="tspan_{pinId}">{pinId}
        </tspan>
    </text>
]#


proc toRect(location: Location): Rect =
    ## Converts `Location` to `Rect`
    let c: Coords = get location.coords
    result = Rect(
        id: &"rect_location_{location.name}",
        x: c[0].toFloat() * scale,
        y: c[1].toFloat() * scale,
        width: toFloat(c[2] - c[0]) * scale,
        height: toFloat(c[3] - c[1]) * scale,
        rx: smoothing,
        ry: smoothing
    )
proc toRects*(locations: seq[Location]): seq[Rect] =
    ## Converts `Location`s to `Rect`s
    for location in locations.withCoords():
        result.add location.toRect()

proc addLocationOverlay(svg: var SvgFile, pinScale: float = 0.02) =
    ## Adds location overlays and pins
    # Generate new layer:
    var
        overlays: Layer[Rect] = Layer[Rect](
            name: "Location Highlight Layer",
            opacity: opacity
        )
        markers: Layer[string] = Layer[string](
            name: "Location Markers",
            opacity: 1.0
        )

    for i, rect in svg.locations:
        stdout.write(&"\rWriting svg data {i + 1}/{svg.locations.len()}")
        overlays.shapes.add rect
        markers.shapes.add pin(rect.id[14 .. ^1], rect.x + rect.width/2, rect.y + rect.height/2, pinScale)
    stdout.write("\n")

    # Add layers:
    svg.appendData($overlays)
    svg.appendData($markers)


proc writeSvg(svg: SvgFile, path: string) =
    ## Writes svg file to disk
    try:
        writeFile(target / path, svg.data)
    except IOError as e:
        echo "FUCK " & e.msg

proc generateFullSvgMap*() =
    ## External proc to generate new, modified global svg map for all locations
    fullMap.locations = getLocations().toRects()
    fullMap.addLocationOverlay()
    fullMap.writeSvg(svgExportPath)

proc getLocationSvgMapPath*(location: Location): string = locationMapImagePath & getRelativeUrlId(location.name) & ".svg"

proc generateLocationSvgMap*(location: Location) =
    ## External proc to generate new svg map for a location (only the location itself is highlighted)
    var svg: SvgFile = newSvgFile()

    for l in @[location].withCoords():
        # 100000000 IQ move, looks stupid and is stupid, as it will only run once, ...
        # HOWEVER! I can reuse `withCoords()` this way
        svg.locations = @[l.toRect()]
    if svg.locations.len() == 0:
        return

    # "Zoom in" on the location:
    # This code hurts my eyes, please send help

    let
        filepath: string = location.getLocationSvgMapPath()
        rect = svg.locations[0]

    let
        viewBoxSubString: string = "viewBox=\""
        viewBoxIndex: int = svg.data.find(viewBoxSubString)

    var viewBoxInitialStateRaw: string
    for c in svg.data[viewBoxIndex + viewBoxSubString.len() .. ^1]:
        if c == '"': break
        viewBoxInitialStateRaw.add c

    var viewBoxInitialState: seq[int]
    for number in viewBoxInitialStateRaw.split(" "):
        viewBoxInitialState.add number.parseInt()

    let
        maxBoundary: int = viewbox
        wantedScale: int = 75
    var viewBox: seq[int] = viewBoxInitialState

    let
        x: int = int(rect.x / scale + rect.width / scale / 2) div 10
        y: int = int(rect.y / scale + rect.height / scale / 2) div 10

    viewBox[0] = x - wantedScale div 2
    viewBox[1] = y - wantedScale div 2

    for i in [0, 1]:
        if viewBox[i] < 0: viewBox[i] = 0
        if viewBox[i] > maxBoundary - wantedScale: viewBox[i] = maxBoundary - wantedScale

    for i in [2, 3]:
        viewBox[i] = wantedScale

    svg.data = svg.data.replace(viewBoxSubString & viewBoxInitialStateRaw, viewBoxSubString & viewBox.join(" "))

    # Add overlay stuff and write to disk:
    svg.addLocationOverlay()
    svg.writeSvg(filepath)

