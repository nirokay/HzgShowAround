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
    var f: HtmlElement = footer(@[
        "🄯 by nirokay",
        $small("Updated at " & now().format("yyyy-MM-dd - HH:mm")),
        $a("https://github.com/nirokay/HzgShowAround", "Source"),
        $a(repeat("../", html.file.count('/')) & "terms-of-service.html", "Terms of Service")
    ].join(" | "))
    f.class = "generic-center-100-width"
    html.addToBody(
        f,
        p($br())# 1_000_000 IQ move to put a buffer between end of content and footer
    )
    html.writeFile()
    when not defined(js): stdout.write("\rFinished generation for " & html.file & "!\n")

