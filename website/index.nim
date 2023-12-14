import std/[options, strutils, algorithm]
import generator, styles, locations as locationModule

# Parse locations from json and create html pages:
let locations: seq[Location] = getLocations()
locations.generateLocationsHtmlPages()

# Create temporary page:
const todoPage: string = "baustelle.html"
block:
    var html: HtmlDocument = newPage(
        "Baustelle",
        todoPage,
        "Ups, dieser Link führt nur zu einer Baustelle..."
    )
    html.addToBody(
        h1("Baustelle"),
        p("Ups, dieser Link führt nur zu einer Baustelle... schau später mal vorbei, vielleicht ist hier dann was Cooles!").setClass(centerClass),
        img(urlImages & "construction.jpg", "Bild einer Baustelle").setClass(centerClass)
    )
    html.setStyle(css)
    html.generate()

# Create terms-of-use page:
block:
    var html: HtmlDocument = newPage(
        "Terms of Service",
        "terms-of-service.html",
        "The terms of service for this website."
    )
    proc text(strings: seq[string]): HtmlElement =
        p(strings.join($br())).setClass(centerClass)
    html.addToBody(
        h1("Terms of service"),
        h2("English [EN]"),
        text(@[
            "By using this website you acknowledge, that:" & $br(),
            "1) this website is not owned nor operated by the owners of " & $a("https://www.herzogsaegmuehle.de", "Herzogsägmühle") & ".",
            "2) the information provided on this website may not be accurate or may include errors."
        ]),
        h2("Deutsch [DE]"),
        text(@[
            "Mit dem Benutzen dieser Website ist Ihnen bewusst, dass:" & $br(),
            "1) diese Website nicht der " & $a("https://www.herzogsaegmuehle.de", "Herzogsägmühle") & " gehört und dass sie Diese nicht betreieben.",
            "2) die Informationen, die hier gefunden werden können, nicht stimmen oder fehlerhaft sein können."
        ])
    )
    html.setStyle(css)
    html.generate()


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
    result = cmp(x.content, y.content)

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
