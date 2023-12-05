import std/[tables]
import websitegenerator ##! Not generator, because I need the writeFile() proc here!
import globals
export globals

# -----------------------------------------------------------------------------
# Buttons:
# -----------------------------------------------------------------------------

proc link(which: string, colour: CssColour|string): CssElement =
    ## Css link stuff
    newCssElement("a:" & which,
        ["color", $colour],
        textNoDecoration
    )


# -----------------------------------------------------------------------------
# Css:
# ----------------------------------------------------------------------------

var css*: CssStyleSheet = newCssStyleSheet("styles.css")
css.elements = @[
    # Body:
    newCssElement("body",
        backgroundColour(colBackground),
        colour(White),
        fontFamily("Verdana, Geneva, Tahoma, sans-serif"),
    ),

    newCssElement("footer",
        position(fixed),
        backgroundColour(colBackground),
        width("100%"),
        bottom(0),
        ["box-sizing" ,"border-box"]
    ),

    newCssElement("table, th, td",
        ["border", 1.px],
        ["border-collapse", "collapse"]
    ),


    # Classes:
    centerClass,

    textCenterClass,
    centerWidth100Class,

    mapElement,

    newsDivClass,
    newsElementGeneric,
    newsElementWarning,
    newsElementAlert,

    buttonClass,
    buttonClassHover,

    newCssElement("button", buttonClass.properties),
    newCssElement("button:hover", buttonClassHover.properties),

    # Headers:
    newCssElement("h1, h2",
        textCenter,
        textUnderline
    ),
    newCssElement("h3",
        textUnderline
    ),

    # Links:
    link("link", HotPink),
    link("visited", HotPink),
    link("hover", LightPink),
    link("active", WhiteSmoke),
]
