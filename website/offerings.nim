## Offerings
## =========
##
## This module generates the `offerings.html` page, with all offerings
## displayed for reading.

import std/[json]

import generator
import globals, styles, client, typedefs, snippets

var html: HtmlDocument = newPage(
    "Freizeitangebote",
    "offerings.html",
    "Auflistung von freiwilligen Freizeitangeboten."
)

html.add(
    h1("Freizeitangebote"),
    pc("Hier findest du freiwillige Freizeitangebote im Ort."))

let
    jsonOfferings: JsonNode = getOfferingsJson()
    offerings: seq[Offering] = jsonOfferings.to(seq[Offering])

html.setStyle(css)
html.generate()
