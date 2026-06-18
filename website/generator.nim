## Generator module
## ================
##
## This module is a "dumbed down" `websitegenerator` module.
## Basically when writing HTML-files it adds a footer to each page as well as modifies the HTML-head.

import std/[strutils, times, tables, json]
from os import `/`, createDir
export `/`
import cattag
export cattag except newHtmlDocument, newXmlDocument, writeFile

import urls
import ../utils/logging

const keywordTags: seq[string] = @[
    "Herzogsägmühle", "Herzogsaegmuehle",
    "Peiting", "Schongau",
    "Diakonie", "Diakoniedorf",
    "Reha", "Rehabilitation", "rehab", "rehabilitation",
    "Karte", "map",
    "Neuigkeiten", "news", "events"
]

proc aNewTab*(href, text: string): HtmlElement = a(href, text).add("target" <=> "_blank")

# -----------------------------------------------------------------------------
# Margins:
# -----------------------------------------------------------------------------

const
    heightBarTop*: int = 72 ## Height of the top bar (offset main div)
    heightBarBottom*: int = 45 ## Height of the top bar (shrink main div)
    heightBarMargins*: int = 5 ## Margins between content and bars

proc newSpacer(height: int): HtmlElement =
    result = `div`(
        newHtmlComment("Ignore this - this is a spacer... I am a GOD at Html/Css")
    ).setStyle(@[
        "min-height" := $height & "px"
    ])

let
    divSpacerTop*: HtmlElement = newSpacer(heightBarTop) ## Hacky solution for some pages to keep space for the header bar
    divSpacerBottom*: HtmlElement = newSpacer(heightBarBottom) ## Hacky solution for some pages to keep space for the footer bar

const
    dirs: seq[string] = @[
        "article",
        "location",
        "resources",
        "resources" / "images",
        "resources" / "images" / "map-locations"
    ]
for dir in dirs:
    let path: string = "docs" / dir
    echo "Creating directory '" & path & "'"
    createDir(path)


# Hacky solution to a problem I cannot comprehend:
const pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: seq[string] = @[
    "map.html" # TODO: Fix this someday holy shit # TODO: idk how, maybe later me will know more
]


var pageMetaDataCache: Table[string, seq[string]]


proc addOgTags*(html: var HtmlDocument) =
    ## Adds `og:...` tags to the head of an Html document, that shows when sharing a link
    let metaData: seq[string] = pageMetaDataCache[html.file]
    html.addToHead(
        ogType("website"),
        twitterCard(),
        ogTitle(metaData[0] & " | HzgShowAround"),
        twitterTitle(metaData[0] & " | HzgShowAround"),
        ogDescription(metaData[1]),
        twitterDescription(metaData[1]),
        ogSiteName("HzgShowAround"),
        ogLocale("de_DE")
    )


# -----------------------------------------------------------------------------
# Shortcut procs:
# -----------------------------------------------------------------------------

proc importScripts*(html: var HtmlDocument, paths: varargs[string]) =
    ## Imports JS scripts and defers them
    for path in paths:
        html.addToHead script(@[
            "src" <=> path,
            attr("defer")
        ])

proc newPage*(name, path: string, desc: string = "", customSchema: JsonNode = %* {}): HtmlDocument =
    pageMetaDataCache[path] = @[
        name, desc
    ]
    let pageName: string = (
        if name == "": "HzgShowAround"
        else: name & " | HzgShowAround"
    )
    result = newHtmlDocument(path)
    result.addToHead(
        meta("utf-8"),
        metaViewport("width=device-width, height=device-height, user-scalable=yes, initial-scale=0.8"),
        title(html pageName),
        metaDescription(desc),
        newHtmlComment("Html and Css generated using cattag: https://github.com/nirokay/cattag ")
    )

    let schema: JsonNode = block:
        if customSchema == %* {}:
            %* {
                "@context": "https://schema.org",
                "@type": "WebPage",
                "name": pageName,
                "description": desc
            }
        else:
            customSchema
    result.addToHead script(@["type" <=> "application/ld+json"]).add(html pretty(schema, 4))

    result.addOgTags()

proc generate*(html: var HtmlDocument) =
    ## Adds a header and footer before writing html page to disk
    logger.announceGeneration(html)

    let
        sep: HtmlElement = html " | "
        topHeader: HtmlElement = `div`(
            h2(
                a("/", "nirokay.com").setTitle("Zurück zum Host").setStyle(
                    "color" := "#e8e6e3"
                ),
                html " › ",
                a("/HzgShowAround", "HzgShowAround").setTitle("Startseite").setStyle(
                    "color" := "#e8e6e3"
                )
            ).setStyle(
                "text-align" := "left",
                "text-decoration" := "none",
                "padding-left" := "10px"
            )
        ).setClass("top-page-header")
        bottomFooter: HtmlElement = `div`(
            p(small(
                html "🄯 nirokay ",
                sep,
                time(html "2023").add("datetime" <=> "2023-11-13 00:00"),
                html " - ",
                time(html $now().format("yyyy")).add("datetime" <=> now().format("yyyy-MM-dd HH:mm")),
                sep,
                aNewTab("https://github.com/nirokay/HzgShowAround", "Source").add("title" <=> "Quell-Code der Website"),
                sep,
                a(repeat("../", html.file.count('/')) & "terms-of-service.html", "ToS").add("title" <=> "Nutzungsbedingungen")
            ))
        ).setClass("bottom-page-footer")

    html.addToBody(
        # 1_000_000 IQ move to put a buffer between end of content and footer
        `div`(
            newHtmlComment("This element is a hack, please ignore my superior HTML/CSS skills")
        ).setStyle(
            "min-height" := 52'px
        )
    )

    # Crude bug fix for Heading being underneath the top bar:
    if "article/" in html.file:
        html.body = @[divSpacerTop] & html.body & @[divSpacerBottom]

    # Vertically center entire HTML body:
    # Ugly ass indentation-feast :(
    if html.file notin pagesThatShouldIgnoreTheDivsUsedForVerticalCentering: # amazing solution, I know... # TODO: actually fix the weird state of map.html [Note: it has been half a year and i still do not have a clue what the fuck is wrong with it]
        html.body = @[
            `div`(
                `div`(
                    `div`(
                        html.body
                    ).setClass("div-inner")
                ).setClass("div-middle")
            ).setClass("div-outer")
        ]

    html.addToBody(
        # Header:
        topHeader,
        # Footer:
        bottomFooter
    )

    # Html head:
    proc newFavicon(url, mimetype: string, size = ""): HtmlElement =
        result = link(@[
            "rel" <=> "icon",
            "type" <=> mimetype,
            "href" <=> url
        ])
        if size != "":
            result.add "sizes" <=> size

    let pageUrl: string = "https://www.nirokay.com/HzgShowAround/" & html.file
    html.addToHead(
        # Favicon:
        newFavicon(urlIconSmallSVG, "image/svg+xml"),
        newFavicon(urlIconSmallPNG, "image/png", "512x512"),
        # Favicon 2.0:
        link(@[
            "rel" <=> "apple-touch-icon",
            "href" <=> urlIconSmallPNG
        ]),
        # URLs:
        link(@[
            "rel" <=> "canonical",
            "href" <=> pageUrl
        ]),
        ogUrl(pageUrl),
        ogSecureUrl(pageUrl),
        # Manifest:
        link(@[
            "rel" <=> "manifest",
            "href" <=> "hzgshowaround.webmanifest"
        ]),
        # Colours:
        meta().add(
            "name" <=> "theme-color",
            "content" <=> "#b3485f"
        ),
        meta().add(
            "name" <=> "background-color",
            "content" <=> "#171921"
        ),
        # Keywords/Tags:
        meta().add(
            "name" <=> "keywords",
            "content" <=> keywordTags.join(", ")
        )
    )

    # OG image, if none set:
    var hasOGImage: bool = false
    let replacementImage: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/resources/images/icon/icon.png"
    for element in html.head:
        if element.elementType != typeElement: continue
        if element.tag != "meta": continue
        for attribute in element.attributes:
            if attribute.attribute != "property": continue
            if "og:image" in attribute.values:
                hasOGImage = true
                break
    if not hasOGImage:
        html.addToHead(
            ogImage(replacementImage),
            ogImageAlt("HzgShowAround Logo"),
            twitterImage(replacementImage),
            twitterImageAlt("HzgShowAround Logo")
        )

    # Global attributes:
    html.htmlAttributes = @["lang" <=> "de"]
    html.bodyAttributes = @["lang" <=> "de"]

    html.writeFile()
    logger.addGenerated(html)

proc generate*(css: var CssStyleSheet) =
    ## Injects logging stuff
    css.writeFile()
    logger.addGenerated(css)
