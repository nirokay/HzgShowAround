## Changelog module
## ================
##
## This module generates an HTML site with changelogs

import std/[json, tables]
import generator
import globals, client, typedefs, styles, snippets

let
    jsonChangelog: JsonNode = getChangelogJson()
    changelog: seq[Changelog] = jsonChangelog.to(seq[Changelog])

var html: HtmlDocument = newPage(
    "Veränderungen",
    "changelog.html",
    "Auflistung von Veränderungen der HzgShowAround Seite."
)

html.add(
    h1("Veränderungen"),
    pc("Hier werden Veränderungen an der HzgShowAround Website aufgelistet."),
    insertButtons(hrefIndex)
)

var changes: seq[HtmlElement]

for change in changelog:
    # Bullet point list:
    var list: seq[HtmlElement]
    for header, points in change.text:
        if header != "": list.add h3(header).addStyle("text-align" := "left")
        var allPoints: seq[HtmlElement]
        for point in points:
            allPoints.add li(point)
        list.add ul(allPoints).addStyle("margin-top" := "5px")

    # Div:
    let header: string = block:
        try:
            change.date.timeReadable()
        except CatchableError:
            change.date
    var elements: seq[HtmlElement] = @[
        h2($time(header).addattr("datetime", change.date)),
        `div`(list)
    ]

    changes.add `div`(elements).setClass(flexElementClass)

html.add(
    `div`(
        changes
    ).setClass(flexContainerClass)
)

html.setStyle(css)
html.generate()
