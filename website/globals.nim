## Globals module
## ==============
##
## This module includes some global values. Some CSS and HTML attributes are included here instead of `website/styles`, so
## that they can be used type-safely.

import std/[strutils, tables, options]
import generator

# -----------------------------------------------------------------------------
# Constants:
# -----------------------------------------------------------------------------

const urlConvertChars: seq[array[2, string]] = @[
    [" ", "_"],
    ["ä", "ae"],
    ["ö", "oe"],
    ["ü", "ue"],
    ["ß", "ss"]
]

const indexLocationDropDownId*: string = "index-location-drop-down"


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

    urlArticleImages*: string = urlImages & "articles/"
    urlArticles*: string = urlRemoteRepo & "articles.json"
    urlCustomHtmlArticles*: string = urlResources & "articles/"

    urlLocationImages*: string = urlImages & "locations/"
    urlJsonLocationData*: string = urlRemoteRepo & "locations.json"
    urlJsonTourData*: string = urlRemoteRepo & "tour_locations.json"

    urlJsonNewsFeed*: string = urlRemoteRepo & "news.json"

# Resource locations:
const
    articlesLocation*: string = "article/"
    articleCssFile*: string = "article-styles.css"


# -----------------------------------------------------------------------------
# Classes:
# -----------------------------------------------------------------------------

type NewsLevel = enum
    Generic = "generic",
    Warning = "warning",
    Alert = "alert",
    Happened = "happened"

proc newsElement(level: NewsLevel): CssElement =
    result = newCssClass("newsfeed-element-" & $level,
        ["border-style", "solid"],
        ["border-width", "10px"],
        ["margin-top", "10px"],
        ["margin-bottom", "10px"]
    )
    result.properties["border-color"] = case(level):
        of Warning: $Yellow
        of Alert: $Red
        of Generic: $White
        of Happened: $Grey

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

    centerTableClass* = newCssClass("table-center",
        ["text-align", "left"],
        ["margin", "10px auto"]
    )

    buttonClass* = newCssClass("button",
        backgroundColour(rgb(50, 30, 58)), # backgroundColour(rgb(60, 60, 60)),
        colour(White),
        ["border", "none"],
        padding("10px 20px"),
        textCenter,
        textNoDecoration,
        display(inlineBlock),
        fontSize(20.px),
        ["margin", "4px 2px"],
        ["cursor", "pointer"],
        ["transition", "0.3s"],
        ["border-radius", 6.px]
    )

    buttonClassHover* = newCssClass("button:hover",
        backgroundColour(colButtonHover),
        ["transition", "0.1s"]
    )

    mapElement* = newCssClass("map-element",
        outlineColour(LightPink),
        display(inline),
        backgroundColour(Pink),
        colour(Pink)
    )

    newsDivClass* = newCssClass("news-div-class",
        textCenter,
        width("75%"),
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        padding("10px")
    )

    newsElementGeneric* = newsElement(Generic)
    newsElementWarning* = newsElement(Warning)
    newsElementAlert* = newsElement(Alert)
    newsElementHappened* = newsElement(Happened)

    articlePreviewItem* = newCssClass("article-preview",
        textCenter,
        padding("10px"),
        ["border-style", "solid"],
        ["border-color", $White],
        ["flex", "content"] # Thanks Ika! :3
    )

    articlePreviewBox* = newCssClass("article-preview-box",
        width("75%"),
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["display", "flex"],
        ["justify-content", "center"],
        ["justify-items", "stretch"],
        ["flex-wrap", "wrap"]
    )

    locationImageHeader* = newCssClass("location-image-header",
        width("75%"),
        ["display", "block"],
        ["max-width", "1000px"],
        ["border-radius", "10px"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
    )
    locationImageFooter* = newCssClass("location-image-footer",
        width("50%"),
        ["display", "block"],
        ["max-width", "700px"],
        ["border-radius", "10px"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
    )


# HTML stuff:

proc pc*(lines: seq[string]): HtmlElement =
    let text: string = lines.join($br())
    result = p(text).setClass(centerClass)

proc pc*(lines: varargs[string]): HtmlElement =
    ## Returns a centered paragraph. Joins each line with a `<br />`
    var s: seq[string]
    for line in lines:
        s.add line
    result = pc(s)

proc pc*(elements: varargs[HtmlElement]): HtmlElement =
    ## Returns a centered paragraph. Joins each element with a `<br />`
    var lines: seq[string]
    for element in elements:
        lines.add $element

    result = pc(lines)

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


# Url formatting:

proc getRelativeUrlId*(name: string): string =
    ## Gets the url ID (replacing special characters)
    result = name.strip().toLower()
    for chars in urlConvertChars:
        result = result.replace(chars[0], chars[1])
proc getRelativeUrlPath*(name: string): string =
    ## Gets the path for an html page
    name.getRelativeUrlId() & ".html"


# Option stuff:

proc isSet*[T](item: Option[T]): bool =
    ## Shortcut to `item.isSome()` and `get(item).len() != 0`
    var emptyValue: T
    if item.isSome():
        if item.get() != emptyValue:
            result = true

proc getOrDefault*[T](value: Option[T], default: T): T {.deprecated: "use normal `get` instead".} =
    ## Returns the Option's value or a default
    return value.get(default)
