import std/[strutils, tables, options]
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
    urlCustomHtmlArticles*: string = urlResources & "articles/"

    urlArticleImages*: string = urlImages & "articles/"
    urlArticles*: string = urlRemoteRepo & "articles.json"

    urlLocationImages*: string = urlImages & "locations/"

    urlJsonLocationData*: string = urlRemoteRepo & "locations.json"
    urlJsonTourData*: string = urlRemoteRepo & "tour_locations.json"

    urlJsonNewsFeed*: string = urlRemoteRepo & "news.json"


# -----------------------------------------------------------------------------
# Classes:
# -----------------------------------------------------------------------------

type NewsLevel = enum
    Generic = "generic",
    Warning = "warning",
    Alert = "alert"
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
        width("75%"),
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        padding("10px")
    )

    newsElementGeneric* = newsElement(Generic)
    newsElementWarning* = newsElement(Warning)
    newsElementAlert* = newsElement(Alert)

    articlePreviewItem* = newCssClass("article-preview",
        textCenter,
        padding("10px"),
        ["border-style", "solid"],
        ["border-color", $White],
        ["flex", "content"]
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


# HTML stuff:

proc pc*(lines: seq[string]): HtmlElement =
    let text: string = lines.join($br())
    result = p(text).setClass(centerClass)

proc pc*(lines: varargs[string]): HtmlElement =
    ## Returns a centered paragraph. Join each line with a `<br />`
    var s: seq[string]
    for line in lines:
        s.add line
    result = pc(s)

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
    result = name.strip().toLower().replace(' ', '_')
proc getRelativeUrlPath*(name: string): string =
    ## Converts name into html file name
    name.getRelativeUrlId() & ".html"


# Option stuff:

proc isSet*[T](item: Option[T]): bool =
    ## Shortcut to `item.isSome()` and `get(item).len() != 0`
    if item.isSome():
        if item.get().len() != 0:
            result = true

proc getOrDefault*[T](value: Option[T], default: T): T =
    ## Returns the Option's value or a default
    if value.isSome(): return value.get()
    else: return default
