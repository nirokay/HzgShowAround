## Generator module
## ================
##
## This module is a "dumbed down" `websitegenerator` module.
## Basically when writing HTML-files it adds a footer to each page as well as modifies the HTML-head.

import std/[strutils, times]
import websitegenerator
export websitegenerator except newDocument, writeFile

# -----------------------------------------------------------------------------
# Shortcut procs:
# -----------------------------------------------------------------------------

proc newPage*(name, path: string, desc: string = ""): HtmlDocument =
    ## Shortcut to create standardized html pages
    result = newDocument(path)
    result.addToHead(
        charset("utf-8"),
        viewport("width=device-width, initial-scale=1"),
        title(name & " - HzgShowAround"),
        description(desc)
    )

proc generate*(html: var HtmlDocument) =
    when not defined(js): stdout.write("Generating " & html.file & "...")

    ## Adds a footer before writing html page to disk
    var bottomFooter: HtmlElement = footer(
        @[
            "🄯 by nirokay",
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

