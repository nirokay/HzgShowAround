## TOS module
## ==========
##
## This module generates the TOS page (`terms-of-service.html`).

import generator, styles, snippets

var html: HtmlDocument = newPage(
    "Nutzungsbedingungen",
    "terms-of-service.html",
    "Nutzungsbedingungen der Website."
)

html.addToBody(
    ih1("HzgShowAround"),

    insertButtons(hrefIndex),

    ih2("Über"),
    p(
        html "Diese Website soll eine einfachere, mehr lightweight (mit weniger unnötigeren Schnick-Schnack), mehr Rehabilitanden-orientierte, " &
        "und schnellere Alternative zu der ",
        a("https://www.herzogsaegmuehle.de/", "offiziellen Herzogsägmühle Website"),
        html " sein.",
        br(),
        html "Vorallem Neuankömmlinge können durch die Karte und Ortsbeschreibungen profitieren, und lernen sich hier auszukennen.",

        html "Die Geschwindigkeit wird durch vor-generierten Seiten mit minimalen Javascript erreicht. Das heißt, dein Browser muss " &
        "weniger stark arbeiten, um Informationen anzuzeigen."
    ),

    ih2("Nutzungsbedingungen"),
    p(
        html "Mit dem Benutzen dieser Website sind Sie sich über Folgendem im Klaren:"
    ),

    ih3("Generell"),
    p(
        html "Inhalte, die auf dieser Website zu finden sind, können fehlerhaft oder unvollständig sein.",
        br(),
        html "Da wir nur ein kleines Team sind, übernehmen wir keine Haftung.",
        html "Diese Website ist gehört nicht den Betreibern der ",
        a("https://www.herzogsaegmuehle.de/", "offiziellen Herzogsägmühler Website"),
        html " und ist von Diesen unabhängig."
    ),

    ih3("Datensammlung"),
    p(
        html "Diese Website verwendet client-side CloudFlare Analytics, um grobes Nutzungsverhalten zu sammeln (z.B. aufgerufene Seiten, verwendeter Browser).",
        html "Sie behalten ihr Recht diese Anfragen mit Hilfe z.B. eines AdBlockers zu verhindern/blockieren."
    ),

    ih2("Lizenz"),
    p(
        html "Diese Website und alle ihre Inhalte, außer explizit erwähnt, sind unter der GPL-3.0 Lizenz freigegeben.",
        html "Damit haben Sie die Rechte, Inhalte frei zu ..."
    ),
    ul(@[
        li html"verwenden...",
        li html"verändern...",
        li html"verbreiten..."
    ]),

    p(
        html "... solange Diese unter der selben Lizenz lizenziert sind.",
        html "Eine vollständige Fassung der Lizenz ist ",
        a("https://www.gnu.org/licenses/gpl-3.0.en.html", "hier auf Englisch"),
        html " und " & $a("https://www.gnu.de/documents/gpl-3.0.de.html", "hier auf Deutsch") & " aufrufbar."
    )
)

html.applyStylesheet(css)
html.generate()
