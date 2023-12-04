import generator
import globals, styles

const
    newsfeedDivId*: string = "news-div"

var html: HtmlDocument = newPage(
    "NewsFeed",
    "newsfeed.html",
    "Neuigkeiten von und rund um die Herzogsägmühle."
)

html.addToHead importScript("javascript/newsfeed.js").add(attr("defer"))

html.addToBody(
    h1("Newsfeed"),
    pc(
        "Hier findest du relevante Termine oder Neuigkeiten.",
        "Einzusehen sind Neuigkeiten ± einer Woche.",
        "Wenn keine Neuigkeiten angezeigt werden, klicke auf den \"Neu laden\" Knopf."
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
