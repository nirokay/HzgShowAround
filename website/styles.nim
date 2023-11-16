import std/[tables]
import websitegenerator ##! Not generator, because I need the writeFile() proc here!
import globals
export globals

# -----------------------------------------------------------------------------
# Buttons:
# -----------------------------------------------------------------------------

proc button*(content, href: string): HtmlElement = a(href, content).setClass(buttonClass) ## Styled button-like link

proc buttonList*(table: Table[string, string]|OrderedTable[string, string]): seq[HtmlElement] =
    ## List of buttons
    for content, href in table:
        result.add button(content, href)

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
        ["position", "fixed"],
        backgroundColour(colBackground),
        width("100%"),
        ["bottom", "0"],
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
    # centerTableClass,

    buttonClass,
    buttonClassHover,

    # Headers:
    newCssElement("h1, h2",
        textCenter,
        textUnderline
    ),
    newCssElement("h3",
        textUnderline
    ),

    # Links:
    link("link", Pink),
    link("visited", HotPink),
    link("hover", LightPink),
    link("active", DeepPink),
]

# Write to disk:
css.writeFile()
