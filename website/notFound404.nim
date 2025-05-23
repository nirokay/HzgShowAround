## Not Found 404
## =============
##
## This module generates a custom `404.html` file. Github uses it for displaying... well 404 pages...

import std/[strutils]

import generator
import globals, styles, snippets

let stylesheetCompressed: HtmlElement = newHtmlElement("style", ($css).dedent(4).replace("\n", "").replace(" {", "{"))

# Default 404 page:
# -----------------

var default404: HtmlDocument = newPage(
    "404 - Not Found",
    "404.html",
    "Diese Seite kann nicht erreicht werden..."
)

default404.addToHead stylesheetCompressed

default404.addToBody(
    h1("404: Not found"),
    pc("Das Gewässer, das du erforschen willst, ist zu tief und gruselig, du wirst aufgehalten!"),
    `div`(
        img(urlImages & "404.svg", "Ironisch... dieses Bild kann nicht angezeigt werden...").add(
            attr("style", "max-width: 500px; width: 50%; border-radius: 10px;")
        )
    ).setClass(centerClass),

    h2("Zum Ufer zurückkehren"),
    pc("Diese Gewässer sind sicher, schau doch da mal vorbei. :)"),
    insertButtons(
        hrefIndex,
        hrefNewsfeed,
        hrefMap,
        hrefArticles
    )
)

default404.generate()


# Location 404 page:
# ------------------

var location404: HtmlDocument = newPage(
    "404 - Not Found",
    "location/404.html",
    "Dieser Ort kann nicht gefunden werden..."
)

location404.addToHead stylesheetCompressed

location404.addToBody(
    h1("404: Not Found"),
    pc("Der aufgerufene Ort kann nicht aufgerufen werden."),
    insertButtons(
        hrefIndex,
        hrefMap
    )
)

location404.generate()
