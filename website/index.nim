## Main index module
## =================
##
## This module generates the `index.html` file. As it is a complex site with many components, it has its own module.

import std/[options, strutils, algorithm]
import generator, styles, locations as locationModule

# Parse locations from json and create html pages:
let locations: seq[Location] = getLocations()
locations.generateLocationsHtmlPages()

var html: HtmlDocument = newPage(
    "Home",
    "index.html",
    "HzgShowAround ermöglicht dir eine digitale Rundschau rund um die Mühle."
)

# -----------------------------------------------------------------------------
# Introduction
# -----------------------------------------------------------------------------

# Disclaimer:
html.addToBody(
    hr(),
    h3("Diese Website ist eine noch Baustelle!"),
    pc($small("Informationen sind unvollständig, Platzhalter oder falsch. Dies dient nur als Prototyp. Danke :)")),
    hr()
)

html.addToBody(
    h1("HzgShowAround"),
    pc("Diese Website soll dir helfen, dich besser in der Herzogsägmühle zurecht zu finden!")
)


# -----------------------------------------------------------------------------
# Newsfeed and Articles
# -----------------------------------------------------------------------------

html.addToBody(
    h2("Newsfeed und Artikel"),
    `div`(
        button("Zum Newsfeed", "newsfeed.html"),
        button("Zu den Artikel", "articles.html")
    ).setClass(centerClass)
)


# -----------------------------------------------------------------------------
# Locations
# -----------------------------------------------------------------------------

var locationButtons: seq[HtmlElement]
for location in locations:
    locationButtons.add button(location.name, get location.path)

locationButtons.sort do (x, y: HtmlElement) -> int:
    result = cmp(x.content.toLower(), y.content.toLower())

html.addToBody(
    h2("Orte"),
    pc("Schau dir die " & $b("interaktive Karte") & " der Herzogsägmühle an und/oder führe die " & $b("digitale Tour") & " durch..."),
    `div`(
        button("Karte", "map.html"),
        button("Tour starten", "tour.html")
    ).setClass(centerClass),
    pc("... oder stöbere dich durch jeden Ort einzelnd:"),
    `div`(locationButtons).setClass(centerClass)
)

html.setStyle(css)
html.generate()
