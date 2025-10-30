## Newsfeed module
## ===============
##
## This module generates a bare-bones html file. This file is used in browser-runtime to fetch from
## [an external JSON file](https://github.com/nirokay/HzgShowAroundData/blob/master/news.json) and
## display its elements with `div`s. The displaying of elements and their structure is handles by javascript.

import generator
import globals, styles, snippets

proc explanatoryElement(definition, explanation, col: string, cssAttribute: CssAttribute): HtmlElement =
    var elements: seq[HtmlElement]
    elements.add span(<$>definition).addStyle(cssAttribute)
    elements.add <$>(" = " & explanation)
    result = <$>($elements) # wtf am i doing
proc backgroundedSpan(definition, explanation, col: string): HtmlElement =
    result = explanatoryElement(definition, explanation, col, "background-color" := col)
proc underlinedSpan(definition, explanation, col: string): HtmlElement =
    result = explanatoryElement(definition, explanation, col, "text-decoration" := ("5px underline " & col))

var html: HtmlDocument = newPage(
    "Newsfeed",
    "newsfeed.html",
    "Neuigkeiten von und rund um die Herzogsägmühle."
)

html.addToHead importScript("javascript/commons.js").add(attr("defer"))
html.addToHead importScript("javascript/news/typedefs.js").add(attr("defer"))
html.addToHead importScript("javascript/news/ical.js").add(attr("defer"))
html.addToHead importScript("javascript/news/html.js").add(attr("defer"))
html.addToHead importScript("javascript/news/news.js").add(attr("defer"))
html.addToHead importScript("javascript/newsfeed.js").add(attr("defer"))

html.addToBody(
    h1($a("https://www.herzogsaegmuehle.de/erleben/veranstaltungen", "Newsfeed").addattr("target", "_blank")),
    pc(
        "Hier findest du relevante Termine oder Neuigkeiten.",
        "Einzusehen sind Neuigkeiten für die nächsten drei Monate sowie den vergangenen Monat."
    ),
    `div`(
        newHtmlElement("details",
            summary("Farberklärungen"),
            p(
                backgroundedSpan("Hellerer Hintergrund", "Veranstaltung findet heute statt", colourEventHappened),
                br(),
                underlinedSpan("Weißer Rahmen", "Normale Veranstaltung", colourEventGeneric),
                br(),
                underlinedSpan("Grauer Rahmen", "Vergangene Veranstaltung", colourEventHappened),
                br(),
                underlinedSpan("Blauer Rahmen", "Feiertage und Schulferien", colourEventHoliday),
                br(),
                underlinedSpan("Gelber Rahmen", "Warnung oder hervorgehobene Veranstaltung", colourEventWarning),
                br(),
                underlinedSpan("Roter Rahmen", "Alarm", colourEventAlert)
            )
        )
    ).setClass(centerClass),
    small("Noch nicht aktualisiert").add(
        attr("id", "reloaded-time")
    ).setClass(centerClass),
    `div`(
        hrefIndex.toHtmlElement(),
        buttonScript("Neu laden", "refreshNewsfeed()"),
    ).setClass(centerClass),
    `div`(
        p("Events werden geladen...")
    ).setClass(newsDivClass).add(
        attr("id", newsfeedDivId)
    )
)

html.setStylesheet(css)
html.generate()
