import std/[options]
import websitegenerator
import styles, locations as locationModule

# Generate locations
let locations: seq[Location] = getLocations()
locations.generateLocationsHtmlPages()

var html: HtmlDocument = newDocument("index.html")



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


# -----------------------------------------------------------------------------
# Footer
# -----------------------------------------------------------------------------

html.addToBody(
    footer("Hi")
)


html.setStyle(css)
html.writeFile()
