## TOS module
## ==========
##
## This module generates the TOS page (`terms-of-service.html`).

import generator, globals, styles

var html: HtmlDocument = newPage(
    "Nutzungsbedingungen",
    "terms-of-service.html",
    "Nutzungsbedingungen der Website."
)
proc list(items: seq[string]): string =
    var listItems: seq[HtmlElement]
    for item in items:
        listItems.add li(item)
    result = $ul(listItems)

proc list(items: varargs[string]): string =
    var buffer: seq[string]
    for item in items:
        buffer.add item
    result = list(buffer)

html.addToBody(
    h1("HzgShowAround"),

    h2("Nutzungsbedingungen"),
    pc(
        "Mit dem Benutzen dieser Website sind Sie sich über Folgendem im Klaren:"
    ),

    h3("Generell"),
    pc(
        "Inhalte, die auf dieser Website zu finden sind, können fehlerhaft oder unvollständig sein.\nDa wir nur ein kleines Team sind, übernehmen wir keine Haftung."
    ),

    h3("Datensammlung"),
    pc(
        "Diese Website verwendet client-side CloudFlare Analytics, um grobes Nutzungsverhalten zu sammeln (z.B. aufgerufene Seiten, verwendete Browser).",
        "Sie behalten ihr Recht diese Anfragen mit Hilfe z.B. eines AdBlockers zu verhindern/blockieren."
    ),

    h2("Lizenz"),
    pc(
        "Diese Website und alle ihre Inhalte sind unter der GPL-3.0 Lizenz freigegeben.",
        "Damit haben Sie die Rechte, Inhalte frei zu ...",
        list("verwenden...", "verändern ...", "verbreiten..."),
        "... solange Diese unter der selben Lizenz lizensiert sind.",
        "Eine vollständige Fassung der Lizenz ist " & $a("https://www.gnu.org/licenses/gpl-3.0.en.html", "hier auf Englisch") &
        " und " & $a("https://www.gnu.de/documents/gpl-3.0.de.html", "hier auf Deutsch") & "aufrufbar."
    )
)

html.setStyle(css)
html.generate()
