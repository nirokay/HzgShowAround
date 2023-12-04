import std/[tables]
import generator

# -----------------------------------------------------------------------------
# Colours:
# -----------------------------------------------------------------------------

const
    colBackground*: string = rgb(23, 25, 33)

    colButton*: string = rgb(50, 30, 58)
    colButtonHover*: string = rgb(60, 40, 68)


# -----------------------------------------------------------------------------
# Variables:
# -----------------------------------------------------------------------------

const
    mapResolution*: int = 2000
    mapScaleTo*: int = 1000

const
    textUnderline* = ["text-decoration", "underline"]
    textNoDecoration* = ["text-decoration", "none"]
    # textTransparentBackground = ["background-color", "transparent"]

# Urls:
const
    urlRemoteRepo*: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/"

    urlResources*: string = urlRemoteRepo & "resources/"
    urlImages*: string = urlResources & "images/"
    urlLocationImages*: string = urlImages & "locations/"

    urlJsonLocationData*: string = urlRemoteRepo & "locations.json"
    urlJsonTourData*: string = urlRemoteRepo & "tour_locations.json"
    urlJsonNewsFeed*: string = urlRemoteRepo & "news.json"

# -----------------------------------------------------------------------------
# Classes:
# -----------------------------------------------------------------------------

const
    textCenter* = ["text-align", "center"]
    textCenterClass* = newCssClass("center",
        textCenter
    )

    centerWidth100Class* = newCssClass("generic-center-100-width",
        textCenter,
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["width", "100%"]
    )

    centerClass* = newCssClass("generic-center",
        textCenter,
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["width", "90%"]
    )

    centerTableClass* = newCssElement("table-center",
        ["margin-left", "auto"],
        ["margin-right", "auto"]
    )

    buttonClass* = newCssClass("button",
        backgroundColour(rgb(50, 30, 58)), # backgroundColour(rgb(60, 60, 60)),
        colour(White),
        ["border", "none"],
        padding("20px 34px"),
        textCenter,
        textNoDecoration,
        display(inlineBlock),
        fontSize(20.px),
        ["margin", "4px 2px"],
        ["cursor", "pointer"],
        # ["transition", "0.3s"],
        ["border-radius", 6.px]
    )

    buttonClassHover* = newCssClass("button:hover",
        backgroundColour(colButtonHover)
    )

    mapElement* = newCssClass("map-element",
        outlineColour(LightPink),
        display(inline),
        backgroundColour(Pink),
        colour(Pink)
    )

    newsDivClass* = newCssClass("news-div-class",
        textCenter,
        width("50%"),
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"]
    )

    newsElement* = newCssClass("newsfeed-element",
        textCenter,
        border("solid White 2px")
    )


proc scriptButton*(text, onclick: string): HtmlElement =
    ## Button with script attached to it
    newElement("button", text).add(
        attr("onclick", onclick)
    )

proc button*(content, href: string): HtmlElement = a(href, content).setClass(buttonClass) ## Styled button-like link

proc buttonList*(table: Table[string, string]|OrderedTable[string, string]): seq[HtmlElement] =
    ## List of buttons
    for content, href in table:
        result.add button(content, href)

proc backToHomeButton*(text: string): HtmlElement = button(text, "index.html") ## Button that returns to the home page
