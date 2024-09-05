import std/[json, options, strutils]
import generator, styles, client, typedefs, snippets

const bulletPoint: string = "• "

var html: HtmlDocument = newPage(
    "Mitwirkende",
    "contributors.html",
    "Mitwirkende der Website"
)

html.setStyle(css)

html.add(
    insertButtons(hrefIndex),
    h1("Mitwirkende und Credits")
)


# -----------------------------------------------------------------------------
# Credits to people working on the project:
# -----------------------------------------------------------------------------

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
            (
                if contributor.tasks.isSet():
                    $br() & bulletPoint & contributor.tasks.get().join($br() & bulletPoint)
                else:
                    ""
            )
        ],
        (if contributor.link.isSet(): $a(contributor.link.get(), contributor.name) else: "")
    )

html.add(
    h2("Mitwirkende"),
    pc("Hier siehst du Alle, die diese Website erstellt und bei ihr mitgeholfen haben!"),
    `div`(
        htmlContributors
    ).setClass(centerClass)
)


# -----------------------------------------------------------------------------
# Credits to technologies used:
# -----------------------------------------------------------------------------

type Technology = object
    name*, link*: string
    desc*: seq[string]

proc tech(name, link: string, desc: seq[string] = @[]): Technology = Technology(
    name: name,
    link: link,
    desc: desc
)

var technologies*: seq[Technology] = @[
    tech("Nim", "https://nim-lang.org/", @[
        "HzgShowAround ist fast vollständig in Nim geschrieben - eine sehr coole Programmiersprache!"
    ]),
    tech("WebsiteGenerator", "https://github.com/nirokay/websitegenerator/", @[
        "Meine eigene HTML/CSS library - für HTML und CSS, lol."
    ]),
    tech("Feriertage-API", "https://www.feiertage-api.de/", @[
        "Automatisches Einfügen von Feiertagen in den NewsFeed."
    ]),
    tech("CloudFlare Analytics", "https://www.cloudflare.com/web-analytics/", @[
        "Client-side Web-Analytics."
    ]),
    tech("OpenStreetMap", "https://www.openstreetmap.org/", @[
        "Abpausen der Karte und Informationen über Orte."
    ])
]

proc toHtml(techs: seq[Technology]): seq[HtmlElement] =
    for tech in techs:
        var element: seq[HtmlElement] = @[
            h3($a(tech.link, tech.name)),
        ]
        if tech.desc != @[]:
            element.add p(tech.desc)

        result.add `div`(element).setClass(flexElementClass)

html.add(
    h2("Credits"),
    pc("Alle benuzte Technologien und Resourcen werden hier für Transparenz und \"Shout-Out\" aufgelistet."),
    `div`(
        technologies.toHtml()
    ).setClass(flexContainerClass)
)

html.generate()
