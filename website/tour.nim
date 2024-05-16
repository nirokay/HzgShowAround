## Tour module
## ===========
##
## This module generates the `tour.html` file. It is rather bare-bones, as the javascript handles all interactivity.

import std/[json]
import generator, globals, styles, client, snippets

let rawTourJson*: JsonNode = getTourJson()
var tourIds*: seq[string] = rawTourJson.to(seq[string])

for i, v in tourIds:
    tourIds[i] = getRelativeUrlId(v)

writeFile(target / "resources/tour_locations.json", $(% tourIds))

var html*: HtmlDocument = newPage(
    "Digitale Tour",
    "tour.html",
    "Die Digitale Tour durch Herzogsägmühle."
)

# Import js script:
html.addToHead importScript("javascript/tourLogic.js")

# Header and description:
html.addToBody(
    h1("Digitale Tour durch Herzogsägmühle"),
    p("").setClass(textCenterClass)
)

# iframe of current location:
var startingPageBecauseFuckYouJavascript: string = tourIds[0] # Fuck you javascript, this ensures that the starting page is not blank
html.addToBody(
    `div`(
        backToHomeButton("← Tour beenden")
    ).setClass(centerClass),
    `div`(
        buttonScript("← zurück", "prevLocation()"),
        buttonScript("weiter →", "nextLocation()")
    ).setClass(centerClass),
    `div`(
        progress("tour-progress", tourIds.len()).add(attr("value", "1"))
    ).setClass(centerClass),
    `div`(
        iframe("location/" & startingPageBecauseFuckYouJavascript & ".html")
            .add(
                attr("id", "location-display"),
                attr("width", "90%"),
                attr("height", "500vh")
            )
    ).setClass(centerClass)
)


html.setStyle(css)
html.generate()
