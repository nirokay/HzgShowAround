## Contact
## =======

import generator, styles, snippets

const emailAddress: string = "nirokay-public+hzgshowaround@protonmail.com"

var html: HtmlDocument = newPage(
    "Kontakt",
    "contact.html",
    "Kontakt zum HzgShowAround Team"
)

html.add(
    h1(html "Kontakt"),
    pc("Hier kannst du uns kontaktieren."),
    insertButtons(hrefIndex),
    h2(a("mailto:" & emailAddress, emailAddress))
)

html.applyStylesheet(css)
html.generate()
