import std/[strutils, strformat, options]
import client, locations as locationModule, globals

const
    viewbox: int = 200 # Hard-coded viewbox width/height, just like the gods intended
    colour: string = "#ff000088"

let scale: float = float(viewbox) / float(mapResolution)

type
    Rect* = object
        id*: string
        x*, y*, width*, height*: float
        fill*: string = colour
        stroke*: string = "#000000"
    Layer* = object
        name*: string
        opacity*: float = 1.0
        shapes*: seq[Rect]

proc `:=`[T](id: string, value: T): string = id & "=\"" & $value & "\""

proc `$`*(rect: Rect): string =
    # Tag:
    result = "<rect\n"

    result &= @[
        "style" := &"fill:{rect.fill};stroke-width:0.25",
        "id" := rect.id,
        "width" := rect.width,
        "height" := rect.height,
        "x" := rect.x,
        "y" := rect.y
    ].join("\n")

    # Tag:
    result &= " />"

proc `$`*(layer: Layer): string =
    # Header:
    result = @[
        "inkscape:groupmode" := "layer",
        "id" := &"layer_{layer.name}",
        "inkscape:label" := layer.name,
        "style" := &"opacity:{layer.opacity};fill:{colour}"
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

const
    svgExportPath*: string = "resources/map.svg"


var svg: tuple[data: string, locations: seq[Rect]]
svg.data = getMapSvg().strip()


for location in getLocations().withCoords():
    let c: Coords = get location.coords
    var rect: Rect = Rect(
        id: &"rect_location_{location.name}",
        x: c[0].toFloat() * scale,
        y: c[1].toFloat() * scale,
        width: toFloat(c[2] - c[0]) * scale,
        height: toFloat(c[3] - c[1]) * scale
    )
    svg.locations.add(rect)

proc beautify() =
    ## Splits closing and opening tags with a newline
    var data: string = svg.data.replace("><", ">\n<")
    svg.data = data

proc addLocationOverlay() =
    # Generate new layer:
    var layer: Layer = Layer(
        name: "Location Highlight Layer",
        opacity: 0.2
    )
    for rect in svg.locations:
        layer.shapes.add rect

    # Beautify svg and add layer:
    beautify()
    svg.data.insert($layer, svg.data.find("</svg>"))



proc writeSvg() =
    svgExportPath.writeFile(svg.data)


proc generateSvg*() =
    addLocationOverlay()
    writeSvg()
