## Offerings
## =========
##
## This module generates the `offerings.html` page, with all offerings
## displayed for reading.

import std/[json, options, strutils, algorithm]

import generator
import globals, styles, client, typedefs, snippets

var html: HtmlDocument = newPage(
    "Freizeitangebote",
    "offerings.html",
    "Auflistung von freiwilligen Freizeitangeboten."
)

html.add(
    h1(html "Freizeitangebote"),
    pc("Hier findest du freiwillige Freizeitangebote im Ort."),
    insertButtons(hrefIndex),
)

let
    jsonOfferings: JsonNode = getOfferingsJson()
    offerings: seq[Offering] = block:
        var r: seq[Offering] = jsonOfferings.to(seq[Offering])
        proc alphabetically(x, y: Offering): int =
            result = cmp(x.name, y.name)
        r.sort(alphabetically)
        r


var htmlOfferings: seq[HtmlElement]
for offering in offerings:
    var
        elementsTop: seq[HtmlElement]
        elementsBottom: seq[HtmlElement]
    # Name:
    let emoji: string = offering.emoji.get("")
    elementsTop.add ih3(strip offering.name & " " & emoji, offering.name)

    # Description:
    var desc: seq[string]
    if offering.desc.isSome():
        desc = get offering.desc

    # Place:
    if offering.place.isSome():
        let
            place: OfferingPlace = get offering.place
            displayName: string = place.name.get("[Ort] (ups, der fehlt)")
            linkedName: string = (
                if place.id.isSome(): $aNewTab("location/" & getRelativeUrlPath(get place.id), displayName)
                else: displayName
            )
        desc.add("📌 " & linkedName)

    # Add description stuff to `elementsTop`:
    if elementsTop.len() != 0:
        elementsTop.add pc(desc.join($br()))

    # Time(s):
    var times: seq[string]
    if offering.times.isSome():
        times = get offering.times
    elif offering.time.isSome():
        times = @[get offering.time]
    if times.len() != 0:
        var points: seq[HtmlElement]
        for point in times:
            points.add li(html point)
        elementsBottom.add(
            fieldset(
                legend(html "Zeiten"),
                ul(points)
            )
        )

    # Contact:
    if offering.contact.isSome():
        let contact: OfferingContact = get offering.contact
        var contactDetails: seq[HtmlElement]

        # Email:
        if contact.email.isSome():
            let email: string = get contact.email
            contactDetails.add a("mailto:" & email, "E-Mail")

        # Telephone:
        if contact.telephone.isSome():
            let telephone: string = get contact.telephone
            contactDetails.add a("tel:" & telephone, "Telefon")

        # Add to elementsBottom:
        if contactDetails.len() != 0:
            var items: seq[HtmlElement]
            for item in contactDetails:
                items.add li(item)
            elementsBottom.add `div`(
                fieldset(
                    legend(html "Kontakt"),
                    ul(items)
                )
            )

    htmlOfferings.add `div`(
        elementsTop &
        `div`(
            elementsBottom
        ).setClass(flexContainedContainerClass)
    ).setClass(flexElementClass)


html.add(
    `div`(
        htmlOfferings
    ).setClass(flexContainerClass)
)

html.applyStylesheet(css)
html.generate()
