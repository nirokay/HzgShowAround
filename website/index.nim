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
    "Startseite",
    "index.html",
    @[
        "HzgShowAround ermöglicht dir eine digitale Rundschau rund um die Diakonie Herzogsägmühle",
        "in Peiting! Entdecke verschiedene Orte, den NewsFeed, der alle Neuigkeiten für Rehabilitanden",
        "anzeigt, und die interaktive Karte des Ortes."
    ].join(" ")
)

html.addToHead importScript("javascript/news/html.js").add(attr("defer")) # Only used for `getLocationLookupTable()`
html.addToHead importScript("javascript/commons.js").add(attr("defer"))
html.addToHead importScript("javascript/index-autocomplete.js").add(attr("defer"))
html.addToHead importScript("javascript/index.js").add(attr("defer"))

proc locationSearchBar(): HtmlElement =
    # Location search bar:
    result = `div`(
        form(
            h3("Ort-Schnellsuche"),
            `div`(
                input("text", indexLocationSearchBarId, "").add(
                    attr("placeholder", "Name des Ortes")
                ).setClass(locationSearchBar),
                button("Suche", "searchBarButtonClick();").setId(indexLocationSearchBarSubmitButtonId)
            ).setClass("autocomplete"),
        ).setAction("javascript:searchBarButtonClick();")
    ).setClass(locationSearchBarDiv)


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
    locationSearchBar(),
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
    ih1("HzgShowAround für die Diakonie Herzogsägmühle").addStyle(
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
        "Hier kannst du eine Liste von Angeboten einsehen und Kontakt aufnehmen, falls Informationen angegeben sind."
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
        label(indexLocationDropDownId, "... oder stöbere dich durch die Liste der Orte:"),
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
    pc(
        "Diese Seite ist von einem kleinen Team geführt und ist komplett " & $a("https://de.wiktionary.org/wiki/quelloffen", "quelloffen") & ".",
        "Falls du Interesse hast mitzuhelfen, bist du herzlichst eingeladen! Alles was du zum Mithelfen brauchst ist ein " & $a("https://github.com/", "GutHub") & "-Account."
    ),
    ul(@[
        li(a("https://github.com/nirokay/HzgShowAround", "Website Repository")),
        li(a("https://github.com/nirokay/HzgShowAround", "Website-Data Repository"))
    ]),
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
