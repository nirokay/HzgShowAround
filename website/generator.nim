## Generator module
## ================
##
## This module is a "dumbed down" `websitegenerator` module.
## Basically when writing HTML-files it adds a footer to each page as well as modifies the HTML-head.

import std/[strutils, times, tables]
from os import `/`, createDir
export `/`
import websitegenerator
export websitegenerator except newDocument, newHtmlDocument, writeFile

import ../utils/logging


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


# Target directory:
# Stupid thing needs to be docs for some fucking reason, amazing work github pages!!
const target*: string = "docs" ## Target/Output directory
setTargetDirectory(target)

const
    dirs: seq[string] = @[
        "article",
        "location",
        "resources",
        "resources" / "images",
        "resources" / "images" / "map-locations"
    ]
for dir in dirs:
    let path: string = target / dir
    echo "Creating directory '" & path & "'"
    createDir(path)


# Hacky solution to a problem I cannot comprehend:
const pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: seq[string] = @[
    "map.html" # TODO: Fix this someday holy shit # TODO: idk how, maybe later me will know more
]

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

proc newPage*(name, path: string, desc: string = ""): HtmlDocument =
    ## Shortcut to create standardized html pages
    pageMetaDataCache[path] = @[
        name, desc
    ]
    result = newHtmlDocument(path)
    result.addToHead(
        htmlComment("Html and Css generated using website generator: https://github.com/nirokay/websitegenerator "),
        charset("utf-8"),
        viewport("width=device-width, initial-scale=1"),
        (
            if name == "": title("HzgShowAround")
            else: title(name & " | HzgShowAround")
        ),
        description(desc)
    )
    result.addOgTags()


proc generate*(html: var HtmlDocument) =
    ## Adds a header and footer before writing html page to disk
    logger.announceGeneration(html)

    var
        topHeader: HtmlElement = `div`(
            h2(
                $a("/", "nirokay.com").setTitle("Zurück zum Host").addStyle(
                    "color" := "#e8e6e3"
                ) &
                " › " &
                $a("/HzgShowAround", "HzgShowAround").setTitle("").addStyle(
                    "color" := "#e8e6e3"
                )
            ).addStyle(
                "text-align" := "left",
                "text-decoration" := "none",
                "padding-left" := "10px"
            )
        ).setClass("top-page-header")
        bottomFooter: HtmlElement = `div`(
            p($small @[
                "🄯 nirokay",
                "Updated @ " & $time($now().format("yyyy-MM-dd - HH:mm")).addattr("datetime", now().format("yyyy-MM-dd HH:mm")),
                $aNewTab("https://github.com/nirokay/HzgShowAround", "Source").addattr("title", "Quell-Code der Website"),
                $a(repeat("../", html.file.count('/')) & "terms-of-service.html", "ToS").addattr("title", "Nutzungsbedingungen")
            ].join(" | "))
        ).setClass("bottom-page-footer")

    html.addToBody(
        # 1_000_000 IQ move to put a buffer between end of content and footer
        `div`(
            htmlComment("This element is a hack, please ignore my superior HTML/CSS skills")
        ).addStyle(
            "min-height" := 52.px
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
        "link"[
            "rel" => "icon",
            "type" => "image/gif",
            "sizes" => "512x512",
            "href" => faviconUrl
        ],
        # Favicon 2.0:
        "link"[
            "rel" => "apple-touch-icon",
            "href" => faviconUrl
        ]
    )

    # OG image, if none set:
    var hasOGImage: bool = false
    for element in html.head:
        if element.tag != "meta": continue
        for attribute in element.tagAttributes:
            if attribute.name != "property": continue
            if attribute.value == "og:image":
                hasOGImage = true
                break
    if not hasOGImage:
        html.add ogImage("https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/resources/images/icon/icon.png")

    # Global body attributes:
    html.addAttributesToBody(
        "lang" => "de"
    )
    html.addAttributesToHtml(
        "lang" => "de"
    )

    html.writeFile()
    logger.addGenerated(html)

proc generate*(css: var CssStyleSheet) =
    ## Injects logging stuff
    css.writeFile()
    logger.addGenerated(css)
