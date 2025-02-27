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

html.addToBody(
    locationSearchBar(),
    `div`(
        img(urlIconLargeSVG, "Icon kann nicht geladen werden :(").addattr(
            "style", "max-width: 190px; max-height: 190px;"
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

html.addContentBox(
    ih2("Newsfeed und Artikel"),
    p(
        "Im Newsfeed sind alle, für Rehabilitanden relevanten, Events und Neuigkeiten eingetragen! Du kannst da gerne regelmäßig vorbeischauen, denn neue Events werden regelmäßig eingetragen.",
        "Auch bei den Artikeln kannst du gerne vorbeischauen. Diese sind von Rehabilitanden geschrieben, die wichtig erscheinen, etwas mit der Mühle zu Tun haben, oder einfach nur zum Spaß geschrieben wurden!"
    ),
    insertButtons(
        hrefNewsfeed,
        hrefArticles
    )
)


# -----------------------------------------------------------------------------
# Locations
# -----------------------------------------------------------------------------

var locationOptions: seq[HtmlElement]
for location in locations:
    locationOptions.add option(get location.path, location.name)

locationOptions.sort do (x, y: HtmlElement) -> int:
    result = cmp(toLower($x), toLower($y))

locationOptions = @[
    option("none", "-- Bitte auswählen --").add(attr("selected"))
] & locationOptions

html.addContentBox(
    ih2("Orte"),
    imageParagraph(
        # Inline image:
        a(hrefMap.href, $img("https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/resources/images/map.svg", "Ortskarte").addStyle("max-width" := "200px")),
        # Text:
        p(
            "Alle wichtigen Orte sind online abrufbar; Es gibt eine interaktive Karte von der Diakonie Herzogsägmühle, wo die eingetragenen Orte anklickbar sind.",
            "Keine Lust selbstständig dir Orte anzuschauen? Dann führe doch die Digitale Tour durch den Ort durch. Da siehst du die wichtigsten Orte und deren Beschreibungen."
        ),
    ),
    # Clean drop-down list:
    p(
        label(indexLocationDropDownId, $u"Drop-Down Liste aller Orte:"),
        br(),
        select(indexLocationDropDownId, indexLocationDropDownId, locationOptions).add(
            attr("onchange", "changeToLocationPage();"),
            attr("onfocus", "this.selectedIndex = 0;"),
            attr("id", indexLocationDropDownId)
        ).addattr("title", "Drop-Down Menü mit allen Orten"),
    ),
    insertButtons(
        hrefMap,
        hrefTour
    )
)


# -----------------------------------------------------------------------------
# Offerings
# -----------------------------------------------------------------------------

html.addContentBox(
    ih2("Freizeitangebote"),
    p(
        "Verschiedene Freizeitangebote werden in der Herzogsägmühle und im nahen Umfeld angeboten.",
        "Hier kannst du eine Liste von Angeboten einsehen und ggf. Kontakt mit den Anbietern aufnehmen, falls diese Informationen angegeben sind."
    ),
    insertButtons(hrefOfferings)
)


# -----------------------------------------------------------------------------
# Other stuff
# -----------------------------------------------------------------------------

html.addContentBox(
    ih2("Sonstiges"),
    p(
        "Diese Seite ist von einem kleinen Team geführt und ist komplett " & $a("https://de.wiktionary.org/wiki/quelloffen", "quelloffen") & ".",
        "Falls du Interesse hast mitzuhelfen, bist du herzlichst eingeladen! Alles was du zum Mithelfen brauchst ist ein " & $a("https://github.com/", "GitHub") & "-Account."
    ),
    ul(@[
        li(a("https://github.com/nirokay/HzgShowAround", "Website Repository")),
        li(a("https://github.com/nirokay/HzgShowAroundData", "Website-Data Repository"))
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
