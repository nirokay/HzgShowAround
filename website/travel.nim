## Travel module
## =============
##
## This module generates the travel page.
import std/[strutils, json, tables]
import globals, client, typedefs, generator, styles, snippets

const busPlanUrl: string = "https://www.herzogsaegmuehle.de/fileadmin/Diakoniedorf/PDFs/Dorf/Hier_findest_Du_uns/Busfahrplan_Herzogsaegmuehle_Peiting_aktuell.pdf"

let
    jsonTravel: JsonNode = getTravelJson()
    travel: TravelData = jsonTravel.to(TravelData)

var html: HtmlDocument = newPage(
    "Bus und Taxi",
    "travel.html",
    "Bus und Taxi von benachbarten Orten zurück in die Herzogsägmühle."
)

html.addToBody(
    ih1("Bus und Taxi zurück in die Herzogsägmühle"),
    pc("Hier findest du Informationen wie du aus benachbarten Orten zurück in die Mühle findest."),
    insertButtons(hrefIndex, hrefMap),

    ih2($a(busPlanUrl, "Busplan").addattr("target", "_blank")),
    pc(
        "Falls der untere Busplan nicht erkennbar ist, " &
        $a(busPlanUrl, "klicke hier oder auf die Überschrift oben") &
        ", um diesen extern aufzurufen."
    ),
    `div`(
        newHtmlElement("object").add(
            "data" -= busPlanUrl,
            "type" -= $applicationPdf,
            "width" -= "100%",
            "height" -= "100%"
        ).add(
            newHtmlElement("iframe").add(
                "type" -= $applicationPdf,
                "src" -= busPlanUrl,
                "width" -= "500",
                "height" -= "500"
            ).add(
                <$>"Dieser Browser unterstützt keine PDF-Anzeige,",
                a(busPlanUrl, "klicke hier"),
                <$>", um es manuell anzusehen."
            )
        )
    ).addStyle(
        "height" := "60vh",
        "min-height" := "300px",
        "margin" := "20px"
    )
)

proc routeName(route: TravelRoute): string = route[0] & " ➡️ " & route[1]
proc routeItem(name: string, elements: seq[HtmlElement]): HtmlElement =
    `div`(
        @[<$>name] &
        `div`(
            elements
        ).setClass(flexContainedContainerClass)
    ).setClass(flexElementClass)

var routes: OrderedTable[string, seq[HtmlElement]]
for bus in travel.bus:
    let routeName: string = bus.route.routeName()
    if not routes.hasKey(routeName): routes[routeName] = @[]

    routes[routeName].add fieldSet(
        legend("🚍 Bus"),
        ul(@[li(a(bus.link, "🌐 Suche").addattr("target", "_blank"))])
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
    html.add ih2(route)
    html.add `div`(
        `div`(
            `div`(
                data
            ).setClass(flexContainedContainerClass)
        ).setClass(flexElementClass)
    ).setClass(flexContainerClass)

html.setStylesheet(css)
html.generate()
