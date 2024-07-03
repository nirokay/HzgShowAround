import std/[strutils]
import generator, styles, typedefs, snippets

type Technology* = object
    name*, link*: string
    desc*: seq[string]

proc newTechnology(name, link: string, desc: seq[string] = @[]): Technology = Technology(
    name: name,
    link: link,
    desc: desc
)

var
    technologies: seq[HtmlElement]

var html: HtmlDocument = newPage(
    "Credits",
    "credits.html",
    "Credits"
)

html.setStyle(css)

html.add(
    `div`(
        buttonLink("← Startseite", "index.html"),
    ).setClass(centerClass),
    h1("Credits"),
    pc("Alle Technologien, die diese Seite benutzt sind hier zur Transparenz verlinkt:"),
    ul(technologies)
)

html.generate()
