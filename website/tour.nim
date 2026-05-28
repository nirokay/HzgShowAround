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

writeFile(targetDir / "resources/tour_locations.json", $(% tourIds))

var html*: HtmlDocument = newPage(
    "Digitale Tour",
    "tour.html",
    "Die Digitale Tour durch Herzogsägmühle."
)

# Import js script:
html.importScripts("javascript/tourLogic.js")

# Header and description:
html.addToBody(
    h1(html "Digitale Tour durch Herzogsägmühle"),
    p(html "").setClass(textCenterClass)
)

# iframe of current location:
let startingPageBecauseFuckYouJavascript: string = tourIds[0] # Fuck you javascript, this ensures that the starting page is not blank
html.addToBody(
    insertButtons(hrefIndex),
    `div`(
        buttonScript("← zurück", "prevLocation()"),
        buttonScript("weiter →", "nextLocation()")
    ).setClass(centerClass),
    `div`(
        progress().add(
            "id" <=> "tour-progress",
            "value" <=> "1",
            "max" <=> $tourIds.len()
        )
    ).setClass(centerClass),
    `div`(
        iframe("location/" & startingPageBecauseFuckYouJavascript & ".html").add(
            "id" <=> "location-display",
            "width" <=> "90%",
            "height" <=> "500vh"
        )
    ).setClass(centerClass)
)


html.applyStylesheet(css)
html.generate()
