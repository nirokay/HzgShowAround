import websitegenerator
export websitegenerator except newDocument, writeFile

# -----------------------------------------------------------------------------
# Shortcut procs:
# -----------------------------------------------------------------------------

proc newPage*(path: string): HtmlDocument =
    ## Shortcut to create standardized html pages
    result = newDocument(path)
    result.addToHead(
        charset("utf-8"),
        viewport("width=device-width, initial-scale=1"),
    )

proc generate*(html: var HtmlDocument) =
    ## Adds a footer before writing html page to disk
    var f: HtmlElement = footer("🄯 by nirokay | " & $a("https://github.com/nirokay/HzgShowAround", "Source"))
    f.class = "generic-center"
    html.addToBody f
    html.writeFile()

