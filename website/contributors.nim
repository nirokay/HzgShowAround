import std/[json, options, strutils]
import generator, styles, client, typedefs, htmlsnippets

var html: HtmlDocument = newPage(
    "Mitwirkende",
    "contributors.html",
    "Mitwirkende der Website"
)

html.setStyle(css)

html.add(
    `div`(
        button("← Startseite", "index.html"),
    ).setClass(centerClass),
    h1("Mitwirkende"),
    pc("Hier siehst du Alle, die diese Website erstellt und bei ihr mitgeholfen haben!")
)

let
    jsonContributors: JsonNode = getContributorsJson()
    contributors: seq[Contributor] = jsonContributors.to(seq[Contributor])
var htmlContributors: seq[HtmlElement]
for contributor in contributors:
    # Holy fuck, this is so ugly:
    htmlContributors.add authorBubble(
        contributor.name,
            [
            "",
            (if contributor.tasks.isSet(): $br() & contributor.tasks.get().join("; ") else: "")
        ],
        (if contributor.link.isSet(): $a(contributor.link.get(), contributor.name) else: "")
    )

html.add `div`(
    htmlContributors
).setClass(centerClass)

html.generate()
