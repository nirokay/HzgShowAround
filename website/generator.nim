import std/[strutils]
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
    ## Adds a footer before writing html page to disk
    var f: HtmlElement = footer(@[
        "🄯 by nirokay",
        $a("https://github.com/nirokay/HzgShowAround", "Source"),
        $a(repeat("../", html.file.count('/')) & "terms-of-service.html", "Terms of Service")
    ].join(" | "))
    f.class = "generic-center-100-width"
    html.addToBody(
        f,
        p($br())# 1_000_000 IQ move to put a buffer between end of content and footer
    )
    html.writeFile()

