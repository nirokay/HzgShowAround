## Generator module
## ================
##
## This module is a "dumbed down" `websitegenerator` module.
## Basically when writing HTML-files it adds a footer to each page as well as modifies the HTML-head.

import std/[strutils, times, tables]
from os import `/`, createDir
export `/`
import cattag
export cattag except newHtmlDocument, newXmlDocument, writeFile

import ../utils/logging


proc aNewTab*(href, text: string): HtmlElement = a(href, text).add("target" <=> "_blank")

# -----------------------------------------------------------------------------
# Margins:
# -----------------------------------------------------------------------------

const
    heightBarTop*: int = 72 ## Height of the top bar (offset main div)
    heightBarBottom*: int = 45 ## Height of the top bar (shrink main div)
    heightBarMargins*: int = 5 ## Margins between content and bars

proc newSpacer(height: int): HtmlElement =
    result = `div`(
        newHtmlComment("Ignore this - this is a spacer... I am a GOD at Html/Css")
    ).setStyle(@[
        "min-height" := $height & "px"
    ])

let
    divSpacerTop*: HtmlElement = newSpacer(heightBarTop) ## Hacky solution for some pages to keep space for the header bar
    divSpacerBottom*: HtmlElement = newSpacer(heightBarBottom) ## Hacky solution for some pages to keep space for the footer bar

const
    dirs: seq[string] = @[
        "article",
        "location",
        "resources",
        "resources" / "images",
        "resources" / "images" / "map-locations"
    ]
for dir in dirs:
    let path: string = "docs" / dir
    echo "Creating directory '" & path & "'"
    createDir(path)


# Hacky solution to a problem I cannot comprehend:
const pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: seq[string] = @[
    "map.html" # TODO: Fix this someday holy shit # TODO: idk how, maybe later me will know more
]

#[
proc og*(property, content: string): HtmlElement =
    meta().add(
        "property" <=> property,
        "content" <=> content
    )
proc ogTitle*(content: string): HtmlElement = og("title", content)
proc ogDescription*(content: string): HtmlElement = og("description", content)
proc ogImage*(content: string): HtmlElement = og("image", content)
proc ogLocale*(content: string): HtmlElement = og("locale", content)]
]#

var pageMetaDataCache: Table[string, seq[string]]


proc addOgTags*(html: var HtmlDocument) =
    ## Adds `og:...` tags to the head of an Html document, that shows when sharing a link
    let metaData: seq[string] = pageMetaDataCache[html.file]
    html.addToHead(
        ogTitle(metaData[0]),
        ogDescription(metaData[1])
    )


# -----------------------------------------------------------------------------
# Shortcut procs:
# -----------------------------------------------------------------------------

proc importScripts*(html: var HtmlDocument, paths: varargs[string]) =
    ## Imports JS scripts and defers them
    for path in paths:
        html.addToHead script(@[
            "src" <=> path,
            attr("defer")
        ])

proc newPage*(name, path: string, desc: string = ""): HtmlDocument =
    ## Shortcut to create standardized html pages
    pageMetaDataCache[path] = @[
        name, desc
    ]
    result = newHtmlDocument(path)
    result.addToHead(
        meta("utf-8"),
        metaViewport("width=device-width, height=device-height, user-scalable=yes, initial-scale=0.8"),
        (
            if name == "": title(html "HzgShowAround")
            else: title(html name & " | HzgShowAround")
        ),
        metaDescription(desc),
        newHtmlComment("Html and Css generated using cattag: https://github.com/nirokay/cattag ")
    )
    result.addOgTags()


proc generate*(html: var HtmlDocument) =
    ## Adds a header and footer before writing html page to disk
    logger.announceGeneration(html)

    var
        topHeader: HtmlElement = `div`(
            h2(
                a("/", "nirokay.com").setTitle("Zurück zum Host").setStyle(
                    "color" := "#e8e6e3"
                ),
                html " › ",
                a("/HzgShowAround", "HzgShowAround").setTitle("Startseite").setStyle(
                    "color" := "#e8e6e3"
                )
            ).setStyle(
                "text-align" := "left",
                "text-decoration" := "none",
                "padding-left" := "10px"
            )
        ).setClass("top-page-header")
        bottomFooter: HtmlElement = `div`(
            p(small @[
                html "🄯 nirokay ",
                time("2023").addattr("datetime", "2023-11-13 00:00"),
                html " - ",
                time($now().format("yyyy")).addattr("datetime", now().format("yyyy-MM-dd HH:mm")),
                aNewTab("https://github.com/nirokay/HzgShowAround", "Source").addattr("title", "Quell-Code der Website"),
                a(repeat("../", html.file.count('/')) & "terms-of-service.html", "ToS").addattr("title", "Nutzungsbedingungen")
            ].join(" | "))
        ).setClass("bottom-page-footer")

    html.addToBody(
        # 1_000_000 IQ move to put a buffer between end of content and footer
        `div`(
            newHtmlComment("This element is a hack, please ignore my superior HTML/CSS skills")
        ).setStyle(
            "min-height" := 52'px
        )
    )

    # Crude bug fix for Heading being underneath the top bar:
    if "article/" in html.file:
        html.body = @[divSpacerTop] & html.body & @[divSpacerBottom]

    # Vertically center entire HTML body:
    # Ugly ass indentation-feast :(
    if html.file notin pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: # amazing solution, I know... # TODO: actually fix the weird state of map.html [Note: it has been half a year and i still do not have a clue what the fuck is wrong with it]
        html.body = @[
            `div`(
                `div`(
                    `div`(
                        html.body
                    ).setClass("div-inner")
                ).setClass("div-middle")
            ).setClass("div-outer")
        ]

    html.addToBody(
        # Header:
        topHeader,
        # Footer:
        bottomFooter
    )

    # Html head:
    let faviconUrl: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/resources/images/icon/icon_small.png" # Hardcoded because `globals` depends on this module
    html.addToHead(
        # Favicon:
        link(@[
            "rel" <=> "icon",
            "type" <=> "image/png",
            "sizes" <=> "512x512",
            "href" <=> faviconUrl
        ]),
        # Favicon 2.0:
        link(@[
            "rel" <=> "apple-touch-icon",
            "href" <=> faviconUrl
        ])
    )

    # OG image, if none set:
    var hasOGImage: bool = false
    for element in html.head:
        if element.elementType != typeElement: continue
        if element.tag != "meta": continue
        for attribute in element.attributes:
            if attribute.attribute != "property": continue
            if "og:image" in attribute.values:
                hasOGImage = true
                break
    if not hasOGImage:
        html.addToHead ogImage("https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/resources/images/icon/icon.png")

    # Global attributes:
    html.htmlAttributes = @["lang" <=> "de"]
    html.bodyAttributes = @["lang" <=> "de"]

    html.writeFile()
    logger.addGenerated(html)

proc generate*(css: var CssStyleSheet) =
    ## Injects logging stuff
    css.writeFile()
    logger.addGenerated(css)
