## Newsfeed module
## ===============
##
## This module generates a bare-bones html file. This file is used in browser-runtime to fetch from
## [an external JSON file](https://github.com/nirokay/HzgShowAroundData/blob/master/news.json) and
## display its elements with `div`s. The displaying of elements and their structure is handles by javascript.

import generator
import globals, styles

const
    newsfeedDivId*: string = "news-div"

var html: HtmlDocument = newPage(
    "Newsfeed",
    "newsfeed.html",
    "Neuigkeiten von und rund um die Herzogsägmühle."
)

html.addToHead importScript("javascript/newsfeed.js").add(attr("defer"))

html.addToBody(
    h1($a("https://www.herzogsaegmuehle.de/aktuelles/aktuelles-und-termine", "Newsfeed")),
    pc(
        "Hier findest du relevante Termine oder Neuigkeiten.",
        "Einzusehen sind Neuigkeiten ± einer Woche."
    ),
    small("Noch nicht aktualisiert").add(
        attr("id", "reloaded-time")
    ).setClass(centerClass),
    `div`(
        backToHomeButton("← Zurück"),
        scriptButton("Neu laden", "refreshNews()"),
    ).setClass(centerClass),
    `div`(
        p("nothing here...")
    ).setClass(newsDivClass).add(
        attr("id", newsfeedDivId)
    )
)

html.setStyle(css)
html.generate()
