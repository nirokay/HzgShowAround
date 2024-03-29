## Globals module
## ==============
##
## This module includes some global values. Some CSS and HTML attributes are included here instead of `website/styles`, so
## that they can be used type-safely.

import std/[strutils, tables]
import generator

# -----------------------------------------------------------------------------
# HTML IDs:
# -----------------------------------------------------------------------------

const
    indexLocationDropDownId*: string = "index-location-drop-down" ## Element id on `index.html` (drop down menu)
    newsfeedDivId*: string = "news-div"


# -----------------------------------------------------------------------------
# URLs:
# -----------------------------------------------------------------------------

const urlConvertChars*: seq[array[2, string]] = @[
    [" ", "_"],
    ["ä", "ae"],
    ["ö", "oe"],
    ["ü", "ue"],
    ["ß", "ss"]
] ## List of characters to convert [0] and their final conversion [1]

const
    urlDeploymentSite*: string = "https://nirokay.github.io/HzgShowAround/" ## Target deployment site directory
    urlDeploymentResources*: string = urlDeploymentSite & "resources/" ## Target site resources directory
    urlDeploymentImages*: string = urlDeploymentResources & "images/" ## Target site images directory
    urlDeploymentLocationMaps*: string = urlDeploymentImages & "map-locations/" ## Target site location maps directory

    urlRemoteRepo*: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/" ## Data repository

    urlResources*: string = urlRemoteRepo & "resources/" ## Resources directory
    urlImages*: string = urlResources & "images/" ## Image directory

    urlContributors*: string = urlRemoteRepo & "contributors.json" ## Author JSON file
    urlAuthors*: string = urlRemoteRepo & "authors.json" ## Author JSON file
    urlAuthorImages*: string = urlImages & "authors/" ## Author image directory

    urlArticleImages*: string = urlImages & "articles/" ## Article directory
    urlArticles*: string = urlRemoteRepo & "articles.json" ## Articles JSON file
    urlCustomHtmlArticles*: string = urlResources & "articles/" ## Custom HTML articles repository

    urlLocationImages*: string = urlImages & "locations/" ## Location image directory
    urlJsonLocationData*: string = urlRemoteRepo & "locations.json" ## Location JSON file
    urlJsonTourData*: string = urlRemoteRepo & "tour_locations.json" ## Tour location JSON file

    urlJsonNewsFeed*: string = urlRemoteRepo & "news.json" ## News JSON file


# -----------------------------------------------------------------------------
# Export paths:
# -----------------------------------------------------------------------------

const
    articlesLocation*: string = "article/" ## Local article export path
    articleCssFile*: string = "article-styles.css" ## Local article css export path


# -----------------------------------------------------------------------------
# Colours:
# -----------------------------------------------------------------------------

const
    colBackground*: string = rgb(23, 25, 33)

    colButton*: string = rgb(50, 30, 58)
    colButtonHover*: string = rgb(60, 40, 68)


# -----------------------------------------------------------------------------
# Map:
# -----------------------------------------------------------------------------

const
    mapResolution*: int = 2000
    mapScaleTo*: int = 1000


# -----------------------------------------------------------------------------
# CSS classes:
# -----------------------------------------------------------------------------

type NewsLevel = enum
    ## News relevance/importance levels
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

proc locationImage(className, width, maxWidth, marginSides, marginTopBottom: string): CssElement =
    result = newCssClass(className,
        width(width),
        ["display", "block"],
        ["max-width", maxWidth],
        ["border-radius", "10px"],
        ["margin-top", marginTopBottom],
        ["margin-bottom", marginTopBottom],
        ["margin-left", marginSides],
        ["margin-right", marginSides]
    )


const
    textUnderline* = ["text-decoration", "underline"]
    textNoDecoration* = ["text-decoration", "none"]
    textCenter* = ["text-align", "center"]


const
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
        ["text-decoration", "none"],
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

    divCenterOuter* = newCssClass("div-outer",
        display(table),
        position(absolute),
        top(0),
        left(0),
        height("100%"),
        width("100%")
    )
    divCenterMiddle* = newCssClass("div-middle",
        display(tableCell),
        ["vertical-align", "middle"]
    )
    divCenterInner* = newCssClass("div-inner",
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        width("90%")
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

    authorDivClass* = newCssClass("author-div",
        ["background-color", rgb(36, 39, 46)],
        ["max-width", "350px"],
        ["display", "flex"],
        ["justify-content", "center"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["margin-top", "10px"],
        ["margin-bottom", "10px"],
        ["border-radius", "900px"],
        ["flex", "content"],
        ["flex-wrap", "nowrap"],
        ["justify-content", "left"],
        ["flex-basis", "auto"]
    )

    authorPictureClass* = newCssClass("author-picture",
        ["max-width", "48px"],
        ["min-width", "32px"],
        ["flex", "content"],
        ["border-radius", "100px"],
        ["display", "inline-block"],
        ["margin-left", "10px"],
        ["margin-top", "10px"],
        ["margin-bottom", "10px"],
        ["align-self", "center"]
    )
    authorNameClass* = newCssClass("author-name-div",
        ["color", $Gainsboro],
        ["width", "50%"],
        ["flex", "content"],
        ["display", "inline-block"],
        ["margin-right", "10px"],
        ["margin-top", "10px"],
        ["margin-bottom", "10px"],
        ["align-self", "center"],
    )

    locationImageHeader* = locationImage("location-image-header", "90%", "1000px", "auto", "auto")
    locationImageFooter* = locationImage("location-image-footer", "50%", "175px", "2px", "2px")
    locationImageMapPreview* = locationImage("location-image-map-preview", "50%", "500px", "auto", "auto")

    locationImageFooterDiv* = newCssClass("location-image-footer-div",
        width("90%"),
        ["max-width", "1000px"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["display", "flex"],
        ["justify-content", "space-around"],
        ["flex-wrap", "wrap"]
    )
