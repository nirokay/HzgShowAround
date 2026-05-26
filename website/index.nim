## Main index module
## =================
##
## This module generates the `index.html` file. As it is a complex site with many components, it has its own module.

import std/[options, strutils]
import globals, generator, styles, typedefs, locations as locationModule, snippets

# Parse locations from json and create html pages:
let locations: seq[Location] = getLocationsSorted()
locations.generateLocations()

var html: HtmlDocument = newPage(
    "Startseite",
    "index.html",
    @[
        "HzgShowAround ermöglicht dir eine digitale Rundschau rund um die Diakonie Herzogsägmühle",
        "in Peiting! Entdecke Orte, den NewsFeed und die interaktive Karte des Ortes."
    ].join(" ")
)

html.importScripts(
    "javascript/news/html.js", # Only used for `getLocationLookupTable()`
    "javascript/commons.js",
    "javascript/index-autocomplete.js",
    "javascript/index.js"
)

proc locationSearchBar(): HtmlElement =
    # Location search bar:
    result = `div`(
        form(
            h3(html "Ort-Schnellsuche"),
            `div`(
                input("text", indexLocationSearchBarId, "").add(
                    "placeholder" <=> "Name des Ortes"
                ).setClass(locationSearchBar),
                button("button", "searchBarButtonClick();", "Suche").setId(indexLocationSearchBarSubmitButtonId)
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
    ).setStyle(
        "max-width" := "100px",
        "max-height" := "100px",
        # ^ Does not work as intended but looks cool as fuck :D (it is a feature)
        dropShadow
    ).setClass(centerClass),

    ih1("HzgShowAround für die Diakonie Herzogsägmühle").setStyle(
        "position" := "relative"
    ),
    pc("Diese inoffizielle Website, für das Diakoniedorf Herzogsägmühle, soll dir helfen, dich besser in der Herzogsägmühle zurecht zu finden!")
)


# -----------------------------------------------------------------------------
# Newsfeed and Articles
# -----------------------------------------------------------------------------

html.addContentBox(
    ih2("Newsfeed und Artikel"),
    p(
        html "Im Newsfeed sind alle, für Rehabilitanden relevanten, Events und Neuigkeiten eingetragen! Du kannst da gerne regelmäßig vorbeischauen, denn neue Events werden regelmäßig eingetragen.",
        html "Auch bei den Artikeln kannst du gerne vorbeischauen. Diese sind von Rehabilitanden geschrieben, die wichtig erscheinen, etwas mit der Mühle zu tun haben, oder einfach nur zum Spaß geschrieben wurden!"
    ),
    insertButtons(
        hrefNewsfeed,
        hrefArticles
    )
)


# -----------------------------------------------------------------------------
# Locations
# -----------------------------------------------------------------------------

var locationSortedOptions: seq[HtmlElement]
for location in locations:
    locationSortedOptions.add option(get location.path, location.name)

locationSortedOptions = @[
    option("none", "-- Bitte auswählen --").add(attr("selected"))
] & locationSortedOptions

html.addContentBox(
    ih2("Orte"),
    imageParagraph(
        # Inline image:
        a(hrefMap.href, $img("https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/resources/images/map.svg", "Ortskarte").setStyle("max-width" := "200px")),
        # Text:
        p(
            html "Alle wichtigen Orte sind online abrufbar; Es gibt eine interaktive Karte von der Diakonie Herzogsägmühle, wo die eingetragenen Orte anklickbar sind.",
            html "Keine Lust selbstständig dir Orte anzuschauen? Dann führe doch die Digitale Tour durch den Ort durch. Da siehst du die wichtigsten Orte und deren Beschreibungen."
        ),
    ),
    # Clean drop-down list:
    p(
        label(indexLocationDropDownId).add(u html "Drop-Down Liste aller Orte:"),
        br(),
        select(indexLocationDropDownId).add(
            "name" <=> indexLocationDropDownId,
            "onchange" <=> "changeToLocationPage();",
            "onfocus" <=> "this.selectedIndex = 0;",
            "title" <=> "Drop-Down Menü mit allen Orten"
        ).add(locationSortedOptions),
    ),
    insertButtons(
        hrefMap,
        hrefTravel,
        hrefTour
    )
)


# -----------------------------------------------------------------------------
# Offerings
# -----------------------------------------------------------------------------

html.addContentBox(
    ih2("Freizeitangebote"),
    p(
        html "Verschiedene Freizeitangebote werden in der Herzogsägmühle und im nahen Umfeld angeboten.",
        html "Hier kannst du eine Liste von Angeboten einsehen und ggf. Kontakt mit den Anbietern aufnehmen, falls diese Informationen angegeben sind."
    ),
    insertButtons(hrefOfferings)
)


# -----------------------------------------------------------------------------
# Other stuff
# -----------------------------------------------------------------------------

html.addContentBox(
    ih2("Sonstiges"),
    p(
        html "Diese Seite ist von einem kleinen Team geführt und ist komplett ",
        a("https://de.wiktionary.org/wiki/quelloffen", "quelloffen"),
        html ".",
        html "Falls du Interesse hast mitzuhelfen, bist du herzlichst eingeladen! Alles was du zum Mithelfen brauchst ist einen ",
        a("https://github.com/", "GitHub"),
        html " Account."
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

html.applyStylesheet(css)
html.generate()
