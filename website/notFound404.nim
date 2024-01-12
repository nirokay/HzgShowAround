## Not Found 404
## =============
##
## This module generates a custom `404.html` file. Github uses it for displaying... well 404 pages...

import std/[strutils]

import generator
import globals, styles

var html: HtmlDocument = newPage(
    "404 - Not Found",
    "404.html",
    "Diese Seite kann nicht erreicht werden..."
)

html.addToHead newElement("style", ($css).dedent(4).replace("\n", "").replace(" {", "{"))

html.addToBody(
    h1("404 - Not found"),
    pc("Das Gewässer, das du erforschen willst, ist zu tief und gruselig, du wirst aufgehalten!"),
    `div`(
        img(urlImages & "404.svg", "Ironisch... dieses Bild kann nicht angezeigt werden...").add(
            attr("style", "max-width: 500px; width: 50%; border-radius: 10px;")
        )
    ).setClass(centerClass),

    h2("Zum Ufer zurückkehren"),
    pc("Diese Gewässer sind sicher, schau doch da mal vorbei. :)"),
    `div`(
        button("Startseite", "index.html"),
        button("Newsfeed", "newsfeed.html"),
        button("Interaktive Karte", "map.html"),
        button("Artikel", "articles.html")
    ).setClass(centerClass)
)

html.generate()
