import std/[json]
import generator, globals, styles, client

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
var id: string = getTourJson().elems[0].str # Fuck you javascript, this ensures that the starting page is not blank
html.addToBody(
    `div`(
        button("← Tour beenden", "index.html"),
    ).setClass(centerClass),
    `div`(
        scriptButton("← zurück", "prevLocation()"),
        scriptButton("weiter →", "nextLocation()")
    ).setClass(centerClass),
    `div`(
        iframe("location/" & id & ".html")
            .add(
                attr("id", "location-display"),
                attr("width", "90%"),
                attr("height", "500vh")
            )
    ).setClass(centerClass)
)


html.setStyle(css)
html.generate()
