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

proc og(property, content: string): HtmlElement =
    ## Generates an `og` meta tag
    "meta"[
        "property" => "og:" & property,
        "content" => content
    ]

proc addOgTag*(html: var HtmlDocument, property, content: string) =
    ## Adds a single og tag
    html.addToHead(
        og(property, content)
    )

proc addOgTags*(html: var HtmlDocument) =
    ## Adds `og:...` tags to the head of an Html document, that shows when sharing a link
    let metaData: seq[string] = pageMetaDataCache[html.file]
    html.addToHead(
        og("title", metaData[0]),
        og("description", metaData[1])
    )

proc addOgImage*(html: var HtmlDocument, source: string) =
    html.addOgTag(
        "image", source
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
        title(name & " - HzgShowAround"),
        description(desc)
    )

    pageMetaDataCache[path] = @[
        name, desc
    ]

    result.addOgTags()


proc generate*(html: var HtmlDocument) =
    when not defined(js): stdout.write("Generating " & html.file & "...")

    ## Adds a footer before writing html page to disk
    var bottomFooter: HtmlElement = footer($small @[
            "🄯 nirokay",
            "Updated @ " & now().format("yyyy-MM-dd - HH:mm"),
            $a("https://github.com/nirokay/HzgShowAround", "Source"),
            $a(repeat("../", html.file.count('/')) & "terms-of-service.html", "ToS")
        ].join(" | ")
    ).setClass("generic-center-100-width")

    html.addToBody(
        # 1_000_000 IQ move to put a buffer between end of content and footer
        p($br())
    )

    # Vertically center entire HTML body:
    # Ugly ass indentation-feast :(
    if html.file notin pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: # amazing solution, I know... # TODO: actually fix the weird state of map.html
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
        # Footer:
        bottomFooter,

        # Cloudflare analytics:
        rawText( """<!-- Cloudflare Web Analytics --><script defer src='https://static.cloudflareinsights.com/beacon.min.js' data-cf-beacon='{"token": "301cf8a5a1c94af5987a04c936a8d670"}'></script><!-- End Cloudflare Web Analytics -->""")
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

    html.writeFile()

    when not defined(js): stdout.write("\rFinished generation for " & html.file & "!\n")

