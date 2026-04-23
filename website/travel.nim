## Travel module
## =============
##
## This module generates the travel page.
import std/[strutils, json, tables]
import globals, client, typedefs, generator, styles, snippets

const
    busPlanUrlSchongau: string = "https://www.herzogsaegmuehle.de/fileadmin/Diakoniedorf/PDFs/Dorf/Hier_findest_Du_uns/Busfahrplan_Herzogsaegmuehle_Schongau_aktuell.pdf"
    busPlanUrlPeiting: string = "https://www.herzogsaegmuehle.de/fileadmin/Diakoniedorf/PDFs/Dorf/Hier_findest_Du_uns/Busfahrplan_Herzogsaegmuehle_Peiting_aktuell.pdf"

let
    jsonTravel: JsonNode = getTravelJson()
    travel: TravelData = jsonTravel.to(TravelData)

var html: HtmlDocument = newPage(
    "Bus und Taxi",
    "travel.html",
    "Bus und Taxi von Herzogsägmühle zu den benachbarten Orten und zurück."
)

proc objectIframeElement(header, url: string): HtmlElement =
    let finishedHeading: string = header & " ↔️ " & "Herzogsägmühle"
    `div`(
        ih3($a(url, finishedHeading).addattr("target", "_blank"), "bus-plan-hsm-" & header.toLower()),
        newHtmlElement("object").add(
            "data" -= url,
            "type" -= $applicationPdf,
            "width" -= "100%",
            "height" -= "100%"
        ).add(
            newHtmlElement("iframe").add(
                "type" -= $applicationPdf,
                "src" -= url,
                "width" -= "500",
                "height" -= "500"
            ).add(
                <$>"Dieser Browser unterstützt keine PDF-Anzeige,",
                a(url, "klicke hier").addattr("target", "_blank"),
                <$>", um es manuell anzusehen."
            )
        )
    ).addStyle(
        "height" := "60vh",
        "min-height" := "300px",
        "margin" := "20px"
    )

html.addToBody(
    ih1("Bus und Taxi zurück in die Herzogsägmühle"),
    pc("Hier findest du Informationen wie du aus benachbarten Orten zurück in die Mühle findest."),
    insertButtons(hrefIndex, hrefMap),

    ih2("Buspläne"),
    objectIframeElement("Schongau", busPlanUrlSchongau),
    objectIframeElement("Peiting", busPlanUrlPeiting)
)


html.add ih2("Routen")
proc routeName(route: TravelRoute): string = route[0] & " ➡️ " & route[1]

var routes: OrderedTable[string, seq[HtmlElement]]

for bus in travel.bus:
    let routeName: string = bus.route.routeName()
    if not routes.hasKey(routeName): routes[routeName] = @[]

    routes[routeName].add fieldSet(
        legend("🚍 Bus"),
        ul(@[li(a(bus.link, "🌐 DB Navigator").addattr("target", "_blank"))])
    )

for taxi in travel.taxi:
    let routeName: string = taxi.route.routeName()
    if not routes.hasKey(routeName): routes[routeName] = @[]

    for firm in taxi.operators:
        routes[routeName].add fieldSet(
            legend("🚖 " & firm.name),
            ul(@[
                li("Erwarteteter Preis: " & $b(taxi.price)),
                li(a("tel:" & firm.number.replace(" ", ""), "📞 Telefon")),
                li(a(firm.web, "🌐 Website").addattr("target", "_blank"))
            ])
        )


for route, data in routes:
    html.add ih3(route)
    html.add `div`(
        `div`(
            `div`(
                data
            ).setClass(flexContainedContainerClass)
        ).setClass(flexElementClass)
    ).setClass(flexContainerClass)

html.setStylesheet(css)
html.generate()
