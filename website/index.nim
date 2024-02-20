## Main index module
## =================
##
## This module generates the `index.html` file. As it is a complex site with many components, it has its own module.

import std/[options, strutils, algorithm]
import globals, generator, styles, typedefs, locations as locationModule

# Parse locations from json and create html pages:
let locations: seq[Location] = getLocations()
locations.generateLocations()

var html: HtmlDocument = newPage(
    "Home",
    "index.html",
    "HzgShowAround ermöglicht dir eine digitale Rundschau rund um die Mühle."
)

html.addToHead importScript("javascript/index.js")#.add(attr("defer"))


# -----------------------------------------------------------------------------
# Introduction
# -----------------------------------------------------------------------------

# Disclaimer:
#[
html.addToBody(
    hr(),
    h3("Diese Website ist eine noch Baustelle!"),
    pc($small("Informationen sind unvollständig, Platzhalter oder falsch. Dies dient nur als Prototyp. Danke :)")),
    hr()
)
]#

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

html.addToBody(
    h2("Orte"),
    pc("Schau dir die " & $b("interaktive Karte") & " der Herzogsägmühle an und/oder führe die " & $b("digitale Tour") & " durch..."),
    `div`(
        button("Karte", "map.html"),
        button("Tour starten", "tour.html")
    ).setClass(centerClass),
)

#[
    #! DISABLED in favor of drop-down menu
    var locationButtons: seq[HtmlElement]

    for location in locations:
        locationButtons.add button(location.name, get location.path)

    locationButtons.sort do (x, y: HtmlElement) -> int:
        result = cmp(x.content.toLower(), y.content.toLower())

    html.addToBody(
        # Massive wall of buttons:
        pc("... oder stöbere dich durch jeden Ort einzelnd:"),
        `div`(locationButtons).setClass(centerClass)
    )
]#

var locationOptions: seq[HtmlElement]

for location in locations:
    locationOptions.add option(get location.path, location.name)

locationOptions.sort do (x, y: HtmlElement) -> int:
    result = cmp(x.content.toLower(), y.content.toLower())

locationOptions = @[
    option("none", "-- Bitte auswählen --").add(attr("selected"))
] & locationOptions

html.addToBody(
    # Clean drop-down list:
    pc(
        label(indexLocationDropDownId, "... oder stöbere dich durch jeden Ort einzelnd:"),
        select(indexLocationDropDownId, indexLocationDropDownId, locationOptions).add(
            attr("onchange", "changeToLocationPage();"),
            attr("onfocus", "this.selectedIndex = 0;"),
            attr("id", indexLocationDropDownId)
        )
    )
)

html.setStyle(css)
html.generate()
