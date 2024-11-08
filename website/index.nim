## Main index module
## =================
##
## This module generates the `index.html` file. As it is a complex site with many components, it has its own module.

import std/[options, strutils, algorithm]
import globals, generator, styles, typedefs, locations as locationModule, snippets

# Parse locations from json and create html pages:
let locations: seq[Location] = getLocations()
locations.generateLocations()

var html: HtmlDocument = newPage(
    "",
    "index.html",
    "HzgShowAround ermöglicht dir eine digitale Rundschau rund um die Mühle."
)

html.addToHead importScript("javascript/index.js")#.add(attr("defer"))


# -----------------------------------------------------------------------------
# Introduction
# -----------------------------------------------------------------------------

# Disclaimer:
#[
addToBody(
    hr(),
    h3("Diese Website ist eine noch Baustelle!"),
    pc($small("Informationen sind unvollständig, Platzhalter oder falsch. Dies dient nur als Prototyp. Danke :)")),
    hr()
)
]#

html.addToBody(
    `div`(
        img(urlIconLargeSVG, "Icon kann nicht geladen werden :(").addattr(
            "style", "max-width: 200px; max-height: 200px;"
        ).setClass(
            iconImageClass
        ),
    ).addStyle(
        "max-width" := "100px",
        "max-height" := "100px",
        # ^ Does not work as intended but looks cool as fuck :D (it is a feature)
        dropShadow
    ).setClass(centerClass),
    ih1("HzgShowAround").addStyle(
        "position" := "relative"
    ),
    pc("Diese Website soll dir helfen, dich besser in der Herzogsägmühle zurecht zu finden!")
)


# -----------------------------------------------------------------------------
# Newsfeed and Articles
# -----------------------------------------------------------------------------

html.addToBody(
    ih2("Newsfeed und Artikel"),
    insertButtons(
        hrefNewsfeed,
        hrefArticles
    )
)


# -----------------------------------------------------------------------------
# Offerings
# -----------------------------------------------------------------------------

html.add(
    ih2("Freizeitangebote"),
    pc(
        "Verschiedene Freizeitangebote werden in der Mühle und im nahen Umfeld angeboten.",
        "Hier kannst du eine Liste von Angeboten einsehen."
    ),
    insertButtons(hrefOfferings)
)


# -----------------------------------------------------------------------------
# Locations
# -----------------------------------------------------------------------------

html.addToBody(
    ih2("Orte"),
    pc("Schau dir die " & $b("interaktive Karte") & " der Herzogsägmühle an und/oder führe die " & $b("digitale Tour") & " durch..."),
    insertButtons(
        hrefMap,
        hrefTour
    )
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
    result = cmp(toLower($x), toLower($y))

locationOptions = @[
    option("none", "-- Bitte auswählen --").add(attr("selected"))
] & locationOptions

html.addToBody(
    # Clean drop-down list:
    pc(
        label(indexLocationDropDownId, "... oder stöbere dich durch jeden Ort einzeln:"),
        select(indexLocationDropDownId, indexLocationDropDownId, locationOptions).add(
            attr("onchange", "changeToLocationPage();"),
            attr("onfocus", "this.selectedIndex = 0;"),
            attr("id", indexLocationDropDownId)
        ).addattr("title", "Drop-Down Menü mit allen Orten")
    )
)


# -----------------------------------------------------------------------------
# Other stuff
# -----------------------------------------------------------------------------

html.addToBody(
    ih2("Sonstiges"),
    insertButtons(
        hrefContact,
        hrefContributors,
        hrefChangelog
    )
)


# -----------------------------------------------------------------------------
# Generate stuff beep boop
# -----------------------------------------------------------------------------

html.setStylesheet(css)
html.generate()
