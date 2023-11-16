import std/[options]
import generator, styles, locations as locationModule

# Generate locations
let locations: seq[Location] = getLocations()
locations.generateLocationsHtmlPages()

var html: HtmlDocument = newPage("index.html")

html.addToHead(
    title("Home - HzgShowAround"),
    description("HzgShowAround ermöglicht dir eine digitale Rundschau rund um die Mühle.")
)

# -----------------------------------------------------------------------------
# Introduction
# -----------------------------------------------------------------------------

html.addToBody(
    h1("HzgShowAround"),
    p("Diese Website soll dir helfen, dich besser in der Herzogsägmühle zurecht zu finden!").setClass(textCenterClass)
)


# -----------------------------------------------------------------------------
# News-Feed
# -----------------------------------------------------------------------------

html.addToBody(
    h2("News-Feed"),
    p("ToDo!").setClass(textCenterClass)
)

# TODO


# -----------------------------------------------------------------------------
# Locations
# -----------------------------------------------------------------------------

var locationButtons: seq[HtmlElement]
for location in locations:
    locationButtons.add button(location.name, get location.path)

html.addToBody(
    h2("Orte"),
    `div`(locationButtons).setClass(centerClass)
)

html.setStyle(css)
html.generate()
