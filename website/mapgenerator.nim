import std/[strutils, strformat, options]
import client, locations as locationModule, globals

const
    viewbox: int = 200 # Hard-coded viewbox width/height, just like the gods intended
    colour: string = "#1a1a1aff"
    smoothing: float = 1.0
    opacity: float = 0.25
    svgExportPath*: string = "resources/images/map.svg"

let scale: float = float(viewbox) / float(mapResolution)

type
    Rect* = object
        id*: string
        x*, y*, width*, height*: float
        ry*, rx*: float = 0
        fill*: string = colour
        stroke*: string = colour
    Layer*[T] = object
        name*: string
        opacity*: float = 1.0
        shapes*: seq[T]

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
        "y" := rect.y,
        "rx" := rect.rx,
        "ry" := rect.ry
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


var svg: tuple[data: string, locations: seq[Rect]]
svg.data = getMapSvg().strip()

proc beautify() =
    ## Splits closing and opening tags with a newline
    var data: string = svg.data.replace("><", ">\n<")
    svg.data = data

proc appendData(data: string) =
    beautify()
    svg.data.insert(data, svg.data.find("</svg>"))

proc pin(pinId: string, x, y: float): string =
    var
        scale: float = 0.02 # 3.7795276
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

# 0.01129762
# 0.01076414

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


for location in getLocations().withCoords():
    let c: Coords = get location.coords
    var rect: Rect = Rect(
        id: &"rect_location_{location.name}",
        x: c[0].toFloat() * scale,
        y: c[1].toFloat() * scale,
        width: toFloat(c[2] - c[0]) * scale,
        height: toFloat(c[3] - c[1]) * scale,
        rx: smoothing,
        ry: smoothing
    )
    svg.locations.add(rect)

proc addLocationOverlay() =
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
        markers.shapes.add pin(rect.id[14 .. ^1], rect.x + rect.width/2, rect.y + rect.height/2)
    stdout.write("\n")

    # Add layers:
    appendData($overlays)
    appendData($markers)


proc writeSvg() =
    svgExportPath.writeFile(svg.data)


proc generateSvg*() =
    addLocationOverlay()
    writeSvg()
