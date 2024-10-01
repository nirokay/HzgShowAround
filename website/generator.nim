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
    "map.html"
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
    result = newHtmlDocument(path)
    result.addToHead(
        htmlComment("Html and Css generated using website generator: https://github.com/nirokay/websitegenerator "),
        charset("utf-8"),
        viewport("width=device-width, initial-scale=1"),
        (
            if name == "": title("HzgShowAround")
            else: title(name & " - HzgShowAround")
        ),
        description(desc)
    )

    pageMetaDataCache[path] = @[
        name, desc
    ]

    result.addOgTags()


proc generate*(html: var HtmlDocument) =
    ## Adds a header and footer before writing html page to disk
    stdout.write("Generating " & html.file & "...")

    var
        topHeader: HtmlElement = `div`(
            h2(
                $a("/HzgShowAround", "HzgShowAround").add(
                    attr("style", "color:#e8e6e3;padding-left:10px;"),
                    attr("title", "Zurück zur Startseite")
                )
            ).addStyle(
                "text-align" := "left",
                "text-decoration" := "none"
            )
        ).setClass("top-page-header")
        bottomFooter: HtmlElement = `div`(
            p($small @[
                "🄯 nirokay",
                "Updated @ " & $time($now().format("yyyy-MM-dd - HH:mm")).addattr("datetime", now().format("yyyy-MM-dd HH:mm")),
                $a("https://github.com/nirokay/HzgShowAround", "Source").addattr("title", "Quell-Code der Website"),
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
    html.addToHead(
        # Favicon:
        "link"[
            "rel" => "icon",
            "type" => "image/gif",
            "sizes" => "512x512",
            "href" => "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/resources/images/icon/icon_small.png" # Hardcoded because `globals` depends on this module
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
    stdout.write("\rFinished generation for " & html.file & "!\n")

