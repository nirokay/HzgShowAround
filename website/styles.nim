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

var
    globalCss: CssStyleSheet = newCssStyleSheet("global-styles.css") ## Not written to disk, only inherited from
    css*: CssStyleSheet = newCssStyleSheet("styles.css") ## Main CSS file
    cssArticles*: CssStyleSheet = newCssStyleSheet(articlesLocation & articleCssFile) ## CSS file for articles

globalCss.add(
    # Global stuff:
    newCssElement("html",
        backgroundColour(colBackground),
        colour(White),
        fontFamily("Verdana, Geneva, Tahoma, sans-serif"),
    ),

    # Bottom footer:
    newCssElement("footer",
        position(fixed),
        backgroundColour(colBackground),
        width("100%"),
        bottom(0),
        ["box-sizing" ,"border-box"]
    ),

    # Tables:
    newCssElement("tbody",
        ["border", 1.px],
        ["border-collapse", "collapse"]
    ),
    newCssElement("td",
        ["margin-right", "5px"]
    ),

    # Progress bars:
    newCssElement("progress",
        width("90%"),
        ["margin", "auto 1px"],
        ["border-radius", "10px"]
    ),
    newCssElement("progress::-webkit-progress-bar",
        backgroundColour(White),
        ["border-radius", "10px"]
    ),
    newCssElement("progress::-webkit-progress-value",
        backgroundColour(HotPink),
        ["border-radius", "10px"]
    ),
    newCssElement("progress::-moz-progress-bar",
        backgroundColour(HotPink),
        ["border-radius", "10px"]
    ),

    #[
        # Does not work??
        newCssElement("progress::-moz-progress-value",
            backgroundColour(HotPink),
            ["border-radius", "10px"]
        ),
    ]#


    # Links:
    link("link", HotPink),
    link("visited", HotPink),
    link("hover", LightPink),
    link("active", WhiteSmoke),

    # Classes:
    centerClass,

    textCenterClass,
    centerWidth100Class,

    buttonClass,
    buttonClassHover,

    newCssElement("button", buttonClass.properties),
    newCssElement("button:hover", buttonClassHover.properties),

    centerTableClass
)

css.elements = globalCss.elements
css.add(
    # Classes:
    #   Map:
    mapElement,

    #   News:
    newsDivClass,
    newsElementGeneric,
    newsElementWarning,
    newsElementAlert,

    #   Articles:
    articlePreviewItem,
    articlePreviewBox,

    # Headers:
    newCssElement("h1, h2",
        textCenter,
        textUnderline
    ),
    newCssElement("h3",
        textCenter
    ),

    # Images (for locations):
    locationImageHeader,
    locationImageFooter
)

cssArticles.elements = globalCss.elements
cssArticles.add(
    # Center everything in `body`:
    newCssElement("body",
        backgroundColour(colBackground),
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["width", "90%"]
    ),

    # Headers and paragraph:
    newCssElement("h1, h2",
        textUnderline,
        textCenter
    ),
    newCssElement("h3, h4, h5, h6, p",
        textCenter
    ),

    # Images:
    newCssElement("img",
        width("50%"),
        ["max-width", "700px"],
        ["border-radius", "10px"],
        ["margin", "10px"]
    )
)
