import generator
import globals, styles

var html: HtmlDocument = newPage(
    "404 - Not Found",
    "404.html",
    "Diese Seite kann nicht erreicht werden..."
)

html.addToBody(
    h1("404 - Not found"),
    pc("Das Gewässer, das du erforschen willst, ist zu tief und gruselig, du wirst aufgehalten!"),
    `div`(
        img(urlImages & "404.svg", "Ironisch... dieses Bild kann nicht angezeigt werden...").add(
            attr("max-width", "500px"),
            attr("width", "50%")
        )
    ).setClass(centerClass),

    h2("Zum Ufer zurückkehren"),
    pc("Diese Gewässer sind sicher, schau doch da mal vorbei. :)"),
    `div`(
        button("Startseite", "index.html"),
        button("Newsfeed", "newsfeed.html"),
        button("Interaktive Karte", "map.html"),
        button("Artikel", "articles.html")
    ).setClass(centerClass)
)

html.setStyle(css)
html.generate()
