import std/[json]
import generator, globals, styles, client

var html*: HtmlDocument = newPage(
    "Digitale Tour",
    "tour.html",
    "Die Digitale Tour durch Herzogsägmühle."
)

# Import js script:
html.addToHead script(" ").add(attr("src", "javascript/tourLogic.js"))

# Header and description:
html.addToBody(
    h1("Digitale Tour durch Herzogsägmühle"),
    p("").setClass(textCenterClass)
)

proc button(text, onclick: string): HtmlElement =
    newElement("button", text).add(
        attr("onclick", onclick)
    )

# iframe of current location:
var id: string = getTourJson().elems[0].str # Fuck you javascript, this ensures that the starting page is not blank
html.addToBody(
    `div`(
        button("← prev", "prevLocation()"),
        button("next →", "nextLocation()")
    ),
    `div`(
        iframe("location/" & id & ".html")
            .add(attr("id", "location-display"))
            .setClass(centerClass)
    )
)


html.setStyle(css)
html.generate()
