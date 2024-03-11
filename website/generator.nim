## Generator module
## ================
##
## This module is a "dumbed down" `websitegenerator` module.
## Basically when writing HTML-files it adds a footer to each page as well as modifies the HTML-head.

import std/[strutils, times, tables]
import websitegenerator
export websitegenerator except newDocument, writeFile

# Hacky solution to a problem I cannot comprehend:
const pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: seq[string] = @[
    "map.html"
]

var pageMetaDataCache: Table[string, seq[string]]

proc og(property, content: string): HtmlElement =
    ## Generates an `og` meta tag
    newElement("meta",
        attr("property", "og:" & property),
        attr("content", content)
    )

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
    result = newDocument(path)
    result.addToHead(
        comment("Html and Css generated using website generator: https://github.com/nirokay/websitegenerator "),
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
    var bottomFooter: HtmlElement = footer(
        @[
            "🄯 nirokay",
            $small("Updated at " & now().format("yyyy-MM-dd - HH:mm")),
            $a("https://github.com/nirokay/HzgShowAround", "Source"),
            $a(repeat("../", html.file.count('/')) & "terms-of-service.html", "Terms of Service")
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
        text( """<!-- Cloudflare Web Analytics --><script defer src='https://static.cloudflareinsights.com/beacon.min.js' data-cf-beacon='{"token": "301cf8a5a1c94af5987a04c936a8d670"}'></script><!-- End Cloudflare Web Analytics -->""")
    )
    html.writeFile()

    when not defined(js): stdout.write("\rFinished generation for " & html.file & "!\n")

