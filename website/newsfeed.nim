## Newsfeed module
## ===============
##
## This module generates a bare-bones html file. This file is used in browser-runtime to fetch from external JSON
## files and display its elements with `div`s. The displaying of elements and their structure is handles by javascript.

import generator
import globals, styles, snippets

proc explanatoryElement(definition, explanation, col: string, cssProperty: CssElementProperty): HtmlElement =
    var elements: seq[HtmlElement]
    elements.add span(html definition).setStyle(cssProperty)
    elements.add html (" = " & explanation)
    result = html $elements
proc backgroundedSpan(definition, explanation, col: string): HtmlElement =
    result = explanatoryElement(definition, explanation, col, "background-color" := col)
proc underlinedSpan(definition, explanation, col: string): HtmlElement =
    result = explanatoryElement(definition, explanation, col, "text-decoration" := ("5px underline " & col))

const
    tagDotTolerated: string = "☐"
    tagDotFiltered: string = "☑"
    tagDotProhibited: string = "☒"

var html: HtmlDocument = newPage(
    "Newsfeed",
    "newsfeed.html",
    "Neuigkeiten von und rund um die Herzogsägmühle."
)

html.importScripts(
    "javascript/commons.js",
    "javascript/news/tags.js",
    "javascript/news/typedefs.js",
    "javascript/news/ical.js",
    "javascript/news/html.js",
    "javascript/news/news.js",
    "javascript/newsfeed.js"
)

html.addToBody(
    h1(a("https://www.herzogsaegmuehle.de/erleben/veranstaltungen", "Newsfeed").add("target" <=> "_blank")),
    pc(
        "Hier findest du relevante Termine oder Neuigkeiten.",
        "Einzusehen sind Neuigkeiten für die nächsten drei Monate sowie den vergangenen Monat."
    ),
    `div`(
        newHtmlElement("details",
            summary(html "Farberklärungen"),
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
    `div`(
        newHtmlElement("details",
            summary(html "Filtern nach Tags"),
            `div`(
                p(
                    html "Klicke auf die Tags um sie ",
                    b html "zu erlauben (" & tagDotTolerated & ")",
                    html ", ",
                    b html "zu verbieten (" & tagDotProhibited  & ")",
                    html ", oder ",
                    b html "explizit nach ihnen zu suchen (" & tagDotFiltered & ")",
                    html "."
                ),
                `div`(
                    small html "Tags werden geladen..."
                ).setId("newsfeed-tag-toggle-list").setClass(flexContainerGenericClass),
                `div`(
                    smallButtonScript("Link mit Tags kopieren", "copyNewsfeedUrlWithTags()").setTitle("Kopiere einen Link mit den ausgewählten Tags."),
                    smallButtonScript("Tags zurücksetzten", "resetAllNewsfeedTags()").setTitle("Tags auf Standart zurücksetzten."),
                ).setClass(centerClass)
            )
        ).add(attr "open")
    ).setClass(centerClass),
    small(html "Noch nicht aktualisiert").setStyle(
        "margin-top" := "1em"
    ).add(
        "id" <=> "reloaded-time"
    ).setClass(centerClass),
    `div`(
        hrefIndex.toHtmlElement(),
        buttonScript("Neu laden", "refreshNewsfeed()").setTitle("Aktualisiere die Neuigkeiten/Events des Newsfeeds."),
    ).setClass(centerClass),
    `div`(
        p(html "Events werden geladen...")
    ).setClass(newsDivClass).add(
        "id" <=> newsfeedDivId
    )
)

html.applyStylesheet(css)
html.generate()
