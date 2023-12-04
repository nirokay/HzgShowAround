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
    backToHomeButton("← Zurück"),
    scriptButton("Neu laden", "refreshNews()"),
    `div`(
        p("nothing here...")
    ).setClass(newsDivClass).add(
        attr("id", newsfeedDivId)
    )
)

html.setStyle(css)
html.generate()
