## Contact
## =======

import std/[strutils, uri]
import generator, styles, snippets

const emailAddress: string = "nirokay-public+hzgshowaround@protonmail.com"

var html: HtmlDocument = newPage(
    "Kontakt",
    "contact.html",
    "Kontakt zum HzgShowAround Team"
)

html.add(
    h1("Kontakt"),
    pc("Hier kannst du uns kontaktieren."),
    `div`(
        buttonLink("← Startseite", "index.html")
    ).setClass(centerClass),
    h2($a("mailto:" & emailAddress, emailAddress))
)

html.setStyle(css)
html.generate()
