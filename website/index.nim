import std/[options, strutils]
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
        img("resources/images/construction.jpg", "Bild einer Baustelle").setClass(centerClass)
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
    h2("Diese Website ist eine noch Baustelle!"),
    p("Informationen sind unvollständig, Platzhalter oder falsch. Dies dient nur als Prototyp. Danke :)").setClass(textCenterClass),
    hr()
)

html.addToBody(
    h1("HzgShowAround"),
    p("Diese Website soll dir helfen, dich besser in der Herzogsägmühle zurecht zu finden!").setClass(textCenterClass)
)

# -----------------------------------------------------------------------------
# Tour
# -----------------------------------------------------------------------------

html.addToBody(
    button("Tour starten →", "tour.html").setClass(centerClass)
)


# -----------------------------------------------------------------------------
# News-Feed
# -----------------------------------------------------------------------------

html.addToBody(
    h2("News-Feed"),
    p("ToDo!").setClass(textCenterClass)
)

# TODO: News-Feed


# -----------------------------------------------------------------------------
# Locations
# -----------------------------------------------------------------------------

var locationButtons: seq[HtmlElement]
for location in locations:
    locationButtons.add button(location.name, get location.path)

# TODO: Map with clickable map areas
html.addToBody(
    h2("Orte"),
    p($a(todoPage, "Klicke hier") & " für eine Karte von der Mühle!" & $br() & "Oder schau dir jeden Ort einzelnd an:").setClass(centerClass),
    `div`(locationButtons).setClass(centerClass)
)

html.setStyle(css)
html.generate()
