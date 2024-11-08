## Globals module
## ==============
##
## This module includes some global values. Some CSS and HTML attributes are included here instead of `website/styles`, so
## that they can be used type-safely.

import std/[tables, strformat]
import generator

from std/os import `/`
export `/`
export target


# -----------------------------------------------------------------------------
# HTML IDs:
# -----------------------------------------------------------------------------

const
    indexLocationDropDownId*: string = "index-location-drop-down" ## Element id on `index.html` (drop down menu)
    newsfeedDivId*: string = "news-div"
    locationNewsfeedEnclaveDivId*: string = "newsfeed-enclave"
    locationNewsfeedEnclaveVarId*: string = "newsfeed-location-id"


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

    urlIcons*: string = urlImages & "icon/" ## Icon/Favicon directory
    urlIconLargeSVG*: string = urlIcons & "icon.svg" ## Large icon (SVG)
    urlIconLargePNG*: string = urlIcons & "icon.png" ## Large icon (PNG)
    urlIconSmallSVG*: string = urlIcons & "icon_small.svg" ## Small icon (SVG)
    urlIconSmallPNG*: string = urlIcons & "icon_small.png" ## Small icon (PNG)

    urlContributors*: string = urlRemoteRepo & "contributors.json" ## Author JSON file
    urlAuthors*: string = urlRemoteRepo & "authors.json" ## Author JSON file
    urlAuthorImages*: string = urlImages & "authors/" ## Author image directory

    urlArticleImages*: string = urlImages & "articles/" ## Article directory
    urlArticles*: string = urlRemoteRepo & "articles.json" ## Articles JSON file
    urlCustomHtmlArticles*: string = urlResources & "articles/" ## Custom HTML articles repository

    urlLocationImages*: string = urlImages & "locations/" ## Location image directory
    urlLocationData*: string = urlRemoteRepo & "locations.json" ## Location JSON file
    urlTourData*: string = urlRemoteRepo & "tour_locations.json" ## Tour location JSON file

    urlNewsFeed*: string = urlRemoteRepo & "news.json" ## News JSON file

    urlOfferings*: string = urlRemoteRepo & "offerings.json" ## Offerings JSON file

    urlChangelog*: string = urlRemoteRepo & "changelog.json" ## Changelog JSON file


# -----------------------------------------------------------------------------
# Export paths:
# -----------------------------------------------------------------------------

const
    articlesLocation*: string = "article/" ## Local article export path
    articleCssFile*: string = "article-styles.css" ## Local article css export path
    locationLookupTableFile*: string = target / "resources" / "location_lookup.json" ## Lookup table for location names to ID


# -----------------------------------------------------------------------------
# Colours:
# -----------------------------------------------------------------------------

const
    # Backgrounds:
    colourBackgroundDark* = rgb(23, 25, 33) # Stolen from Nim doc generator with love <s3
    colourBackgroundMiddle* = "#23252c"
    colourBackgroundLight* = "#2f3139"

    colourContentBox* {.deprecated: "use `colourBackgroundMiddle` instead".} = colourBackgroundMiddle #rgba(255, 255, 255, 0.05)
    colourAuthorBubble* {.deprecated: "use `colourBackgroundMiddle` instead".} = colourBackgroundMiddle

    colourButton* = colourBackgroundLight # rgba(255, 100, 255, 0.1)
    colourButtonHover* = colourBackgroundMiddle # rgba(255, 100, 255, 0.2)
    colourButtonClick* = colourBackgroundDark

    # Text:
    colourText* = "#e8e6e3" # Stolen from DarkReader with love <3
    colourTextUnfocused* = "#464544" # Darker text, used for unfocus/deleted elements
    colourAuthorNameText* = Gainsboro

    colourLinkDefault* = "#FFB6C1"
    colourLinkVisited* = colourLinkDefault
    colourLinkHover* = "#FFC1CA"
    colourLinkClick* = "#FFD7DD"

    # Outlines:
    colourMapElementOutline* = colourLinkDefault

    # Progress bars:
    colourProgressBarForeground* = colourText
    colourProgressBarBackground* = colourLinkDefault

    # Borders:
    colourEventGeneric* = colourText
    colourEventHoliday* = "#3399FF" # $CornflowerBlue
    colourEventWarning* = "#FFFF33" # $Gold
    colourEventAlert* = "#FF3333"   # $Tomato
    colourEventHappened* = colourBackgroundLight

    # Deprecation notices:
    colourDeprecationNoticeText* = "#000000"
    colourDeprecationNoticeHeader* = colourEventAlert
    colourDeprecationNoticeBackground* = "#ffffb3"


# -----------------------------------------------------------------------------
# Common CSS values:
# -----------------------------------------------------------------------------

const
    # Text stuff:
    textUnderline*: CssAttribute = "text-decoration" := "underline"
    textNoDecoration*: CssAttribute = "text-decoration" := "none"
    textCenter*: CssAttribute = "text-align" := "center"

const
    # Drop shadow and highlights:
    dropShadow*: CssAttribute = block:
        const
            offX: int = 5
            offY: int = 5
            diffusion: int = 5
            colShadow: string = rgba(0, 0, 0, 0.5)
            colHighlight: string = rgba(0, 0, 0, 0.2) # rgba(255, 255, 255, 0.1)
        "filter" := &"drop-shadow(-{offX / 2}px -{offY / 2}px {diffusion / 2}px {colHighlight}) drop-shadow({offX}px {offY}px {diffusion}px {colShadow})"


# -----------------------------------------------------------------------------
# Map:
# -----------------------------------------------------------------------------

const
    mapResolution*: int = 2000 ## Rectangle `mapResolution x mapResolution`
    mapScaleTo*: int = 1000


# -----------------------------------------------------------------------------
# Margins:
# -----------------------------------------------------------------------------

const
    heightBarTop*: int = 72 ## Height of the top bar (offset main div)
    heightBarBottom*: int = 45 ## Height of the top bar (shrink main div)
    heightBarMargins*: int = 5 ## Margins between content and bars

proc newSpacer(height: string|int): HtmlElement =
    result = `div`(
        htmlComment("Ignore this - this is a spacer... I am a GOD at Html/Css")
    ).addStyle(
        "min-height" := $height & "px"
    )

let
    divSpacerTop*: HtmlElement = newSpacer(heightBarTop) ## Hacky solution for some pages to keep space for the header bar
    divSpacerBottom*: HtmlElement = newSpacer(heightBarBottom) ## Hacky solution for some pages to keep space for the footer bar

# -----------------------------------------------------------------------------
# CSS classes:
# -----------------------------------------------------------------------------

type NewsLevel = enum
    ## News relevance/importance levels
    Happened = "happened"
    Generic = "generic",
    Holiday = "holiday",
    Warning = "warning",
    Alert = "alert"

proc newsElement(level: NewsLevel): CssElement =
    result = (".newsfeed-element-" & $level){
        "border-style" := "solid",
        "border-width" := "5px",
        "border-radius" := "20px",
        "margin" := "20px auto 30px auto",
        "background-color" := colourBackgroundMiddle
    }
    result.properties["border-color"] = case(level):
        of Happened: colourEventHappened
        of Generic: colourEventGeneric
        of Holiday: colourEventHoliday
        of Warning: colourEventWarning
        of Alert: colourEventAlert

proc locationImage(className, width, maxWidth, marginTopBottom, marginSides: string): CssElement =
    result = newCssClass(className,
        width(width),
        ["display", "block"],
        ["max-width", maxWidth],
        ["border-radius", "10px"],
        "margin" := marginTopBottom & " " & marginSides
    )

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
        backgroundColour(colourButton),
        colour(colourText),
        ["border", "none"],
        padding("10px 20px"),
        textCenter,
        ["text-decoration", "none"],
        display($inlineBlock),
        fontSize("1.2em"),
        ["margin", "8px 4px"],
        ["cursor", "pointer"],
        ["transition", "0.3s"],
        ["border-radius", 6.px],
        dropShadow
    )

    buttonClassHover* = newCssClass("button:hover",
        backgroundColour(colourButtonHover),
        ["transition", "0.1s"]
    )

    buttonClassClick* = ".button:active"{
        "background-color" := colourButtonClick
    }

    # Stuff inside a box (looks cool i guess):
    contentBoxClass* = newCssClass("content-box",
        width("100%"),
        maxWidth("1000px"),
        backgroundColour(colourBackgroundMiddle),
        ["border-radius", "20px"],
        ["padding", "5px"],
        ["margin", "30px auto"],
        dropShadow
    )

    iconImageClass* = "icon-display"{
        "width" := "50%",
        "max-width" := "500px",
        "margin" := "auto"
    }

    mapElement* = newCssClass("map-element",
        outlineColour(colourMapElementOutline),
        display($inline)
    )

    divCenterOuter* = newCssClass("div-outer",
        display($table),
        position($absolute),
        top(px(heightBarTop + heightBarMargins)),
        left($0),
        height("calc(100vh - " & heightBarTop.px & " - " & heightBarBottom.px & " - " & px(heightBarMargins * 2) & ")"), # idk what im doing
        width("100%")
    )
    divCenterMiddle* = newCssClass("div-middle",
        display($tableCell),
        ["vertical-align", "middle"]
    )
    divCenterInner* = newCssClass("div-inner",
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        width("90%")
    )

    topPageHeaderClass* = ".top-page-header"{
        "left" := "0px",
        "top" := "0px",
        "height" := heightBarTop.px,
        "width" := "100%",
        "margin" := "auto",
        "position" := "fixed",
        "text-align" := "center",
        "background-color" := colourBackgroundMiddle
    }

    bottomPageFooterClass* = ".bottom-page-footer"{
        "left" := "0px",
        "bottom" := "-10px",
        "height" := px(heightBarBottom + 10),
        "width" := "100%",
        "margin" := "auto",
        "position" := "fixed",
        "text-align" := "center",
        "background-color" := colourBackgroundMiddle
    }

    flexContainerClass*: CssElement = ".flex-container"{
        "align-items" := "normal",
        "display" := "flex",
        "flex-wrap" := "wrap",
        "justify-content" := "center",
        dropShadow
    }
    flexContainedContainerClass*: CssElement = ".flex-contained-container"{
        "display" := "flex",
        "justify-content" := "center",
        "flex-wrap" := "wrap",
        dropShadow
    }
    flexElementClass*: CssElement = ".flex-element"{
        "display" := "inline-block",
        "margin" := "20px",
        "padding" := "5px",
        "width" := "30%",
        "max-width" := "500px",
        "min-width" := "300px",
        "background" := colourBackgroundMiddle,
        "border-radius" := "10px",
        "padding" := "10px",
        dropShadow
    }

    newsDivClass* = newCssClass("news-div-class",
        width("75%"),
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        padding("10px"),
        dropShadow
    )

    newsElementHappened* = newsElement(Happened)
    newsElementGeneric* = newsElement(Generic)
    newsElementHoliday* = newsElement(Holiday)
    newsElementWarning* = newsElement(Warning)
    newsElementAlert* = newsElement(Alert)

    articlePreviewItem* = newCssClass("article-preview",
        textCenter,
        padding("10px"),
        ["border-style", "solid"],
        ["border-color", colourText],
        ["flex", "content"], # Thanks Ika! :3
        "background-color" := colourBackgroundMiddle,
        dropShadow
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
        ["background-color", colourBackgroundMiddle],
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
        ["flex-basis", "auto"],
        dropShadow
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
        ["color", $colourAuthorNameText],
        ["width", "50%"],
        ["flex", "content"],
        ["display", "inline-block"],
        ["margin-right", "10px"],
        ["margin-top", "10px"],
        ["margin-bottom", "10px"],
        ["align-self", "center"],
    )

    locationDeprecationDisclaimerHeaderClass* = newCssClass("location-deprecation-notice-header",
        "color" := colourDeprecationNoticeHeader
    )
    locationDeprecationDisclaimerDivClass* = newCssClass("location-deprecation-notice-div",
        "color" := colourDeprecationNoticeText,
        "background-color" := colourDeprecationNoticeBackground,
        "border-radius" := "10px",
        "padding" := "10px"
    )

    locationImageHeader* = locationImage("location-image-header", "90%", "1000px", "20px", "auto")
    locationImageFooter* = locationImage("location-image-footer", "45%", "400px", "20px", "5px")
    locationImageMapPreview* = locationImage("location-image-map-preview", "50%", "500px", "20px", "auto")

    locationImageFooterDiv* = newCssClass("location-image-footer-div",
        width("90%"),
        ["max-width", "1000px"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["display", "flex"],
        ["justify-content", "space-around"],
        ["flex-wrap", "wrap"]
    )
