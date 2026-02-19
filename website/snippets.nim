## HTML Snippets module
## ====================
##
## Just like the `globals` module but for HTML procs.

import std/[strutils, sequtils, json, options, tables, times]
import generator, globals, styles, client

# =============================================================================
# CSS:
# =============================================================================

proc fullyCenter*(html: seq[HtmlElement]): HtmlElement =
    ## Makes a (actually three divs) fully centered div
    result = `div`(
        `div`(
            `div`(
                html
            ).setClass(divCenterInner)
        ).setClass(divCenterMiddle)
    ).setClass(divCenterOuter)
proc fullyCenter*(html: varargs[HtmlElement]): HtmlElement =
    ## Makes a (actually three divs) fully centered div
    var elements: seq[HtmlElement]
    for element in html:
        elements.add element
    result = elements.fullyCenter()

proc divCenter*(elements: seq[HtmlElement]): HtmlElement = `div`(elements).setClass(centerClass) ## Div with `centerClass` applied
proc divCenter*(elements: varargs[HtmlElement]): HtmlElement = `div`(elements).setClass(centerClass) ## Div with `centerClass` applied


# =============================================================================
# HTML:
# =============================================================================

# -----------------------------------------------------------------------------
# Paragraphs:
# -----------------------------------------------------------------------------

proc pc*(lines: seq[string]): HtmlElement =
    ## Returns a centered paragraph. Joins each line with a `<br />`
    let text: string = lines.join($br())
    result = p(text).setClass(centerClass)

proc pc*(lines: varargs[string]): HtmlElement =
    ## Returns a centered paragraph. Joins each line with a `<br />`
    var s: seq[string]
    for line in lines:
        s.add line
    result = pc(s)

proc pc*(elements: varargs[HtmlElement]): HtmlElement =
    ## Returns a centered paragraph. Joins each line with a `<br />`
    var lines: seq[string]
    for element in elements:
        lines.add $element

    result = pc(lines)


# -----------------------------------------------------------------------------
# Buttons:
# -----------------------------------------------------------------------------

const rootUrl: string = "/HzgShowAround/" ## Root of the hzgshowaround host
type ButtonHref* = tuple[text, title, href: string]
proc `->`(href: string, texts: array[2, string]): ButtonHref =
    result = (
        text: texts[0],
        title: texts[1],
        href: href
    )
const
    hrefIndex*: ButtonHref = "index.html" -> ["Startseite", "Navigiere zur Startseite"]
    hrefMap*: ButtonHref = "map.html" -> ["Karte", "Navigiere zur Karte"]
    hrefArticles*: ButtonHref = "articles.html" -> ["Artikel", "Navigiere zu den Artikeln"]
    hrefNewsfeed*: ButtonHref = "newsfeed.html" -> ["Newsfeed", "Navigiere zum Newsfeed"]
    hrefContact*: ButtonHref = "contact.html" -> ["Kontakt", "Navigiere zur Kontaktseite"]
    hrefOfferings*: ButtonHref = "offerings.html" -> ["Freizeitangebote", "Navigiere zu den Freizeitangeboten"]
    hrefTour*: ButtonHref = "tour.html" -> ["Digitale Tour", "Navigiere zur digitalen Tour"]
    hrefChangelog*: ButtonHref = "changelog.html" -> ["Veränderungen", "Navigiere zu der Seite mit Veränderungen"]
    hrefContributors*: ButtonHref = "contributors.html" -> ["Mitwirkende", "Navigiere zu den Mitwirkenden"]
    hrefTravel*: ButtonHref = "travel.html" -> ["Bus und Taxi", "Navigiere zur Bus- und Taxiübersicht"]


proc toHtmlElement*(button: ButtonHref): HtmlElement =
    ## Converts `ButtonHref` to HTML button
    #[
    result = "a"[
        "href" -= rootUrl & button.href
    ] => button.text -> buttonClass
    ]#
    #[
    result = "button"[
        "onclick" -= "window.location=\"" & rootUrl & button.href & "\";"
    ] => button.text
    ]#
    result = a(rootUrl & button.href, button.text).setTitle(button.title).setClass(buttonClass).addStyle(
        "color" := colourText
    )

    if button.title != "": result.addattr("title", button.title)
proc toHtmlElements*(buttons: varargs[ButtonHref]|seq[ButtonHref]): seq[HtmlElement] =
    ## Converts `ButtonHref`s to HTML buttons
    for button in buttons:
        result.add button.toHtmlElement()

proc insertButtons*(buttons: varargs[ButtonHref]): HtmlElement =
    ## Inserts a centered div with buttons in it
    result = `div`(
        buttons.toHtmlElements()
    ).setClass(centerClass)

proc buttonScript*(text, onclick: string): HtmlElement =
    ## Button with script attached to it
    button(text, onclick) # Use before overwrite lol

proc buttonLink*(content, href: string): HtmlElement =
    ## Styled button-like link
    result = (href -> [content, ""]).toHtmlElement()
    # a(href, content).setClass(buttonClass)

proc buttonList*(table: Table[string, string]|OrderedTable[string, string], additionalSubUrl: string = ""): seq[HtmlElement] =
    ## List of buttons
    for content, href in table:
        result.add buttonLink(content, additionalSubUrl & href)


# -----------------------------------------------------------------------------
# Author bubbles:
# -----------------------------------------------------------------------------

const defaultAuthor*: string = "Anonym" ## Default author, if none is specified

let
    jsonAuthors: JsonNode = getArticleAuthorsJson()
    authors: Table[string, string] = jsonAuthors.to(Table[string, string])

proc authorBubble*(authorName: string, beforeAfterText: array[2, string] = ["", ""], authorDisplayName: string = ""): HtmlElement =
    ## Generates an author bubble.
    ##
    ## `beforeAfterText` puts `array[0]` before the author name and `array[1]` after the author name
    var pictureFile: string = authors[defaultAuthor]
    for key, value in authors:
        if key.toLower() == authorName.toLower():
            pictureFile = value
            break

    let
        authorImage: HtmlElement = img(urlAuthorImages & pictureFile, "Bild nicht verfügbar").setClass(authorPictureClass)
        authorText: HtmlElement = small(
            beforeAfterText[0] &
            $b(
                if authorDisplayName != "": authorDisplayName else: authorName
            ) &
            beforeAfterText[1]
        ).setClass(authorNameClass)

    result = `div`(
        authorImage,
        authorText
    ).setClass(authorDivClass)


# -----------------------------------------------------------------------------
# Formatting:
# -----------------------------------------------------------------------------

proc formatToAscii*(text: string): string =
    ## Formats text using `urlConvertChars` to mainly ascii characters
    result = text
    # Replace using custom rules:
    for chars in urlConvertChars:
        result = result.replace(chars[0], chars[1])

proc getRelativeUrlId*(name: string): string =
    ## Gets the url ID (replacing special characters)
    result = name.strip().toLower().formatToAscii()

proc getRelativeUrlPath*(name: string): string =
    ## Gets the path for an html page
    name.getRelativeUrlId() & ".html"

let pinHeaderId: string = urlPinIdHeader.readFileRawText()
proc iheader(element: HtmlElement, text: string, override: string = ""): HtmlElement =
    var id: string
    result = element
    if override != "":
        id = override.toLower()
    else:
        id = text.toLower().formatToAscii()
        for c in [",", ".", "!", "?", ":", ";", "(", ")", "[", "]", "=", "#", "'", "\"", "§", "$", "€", "%", "/", "{", "}"]: # i should think of making this somehow a smarter system
            id = id.replace(c, "")
    result.addattr("id", id)

    var pin: HtmlElement = a("#" & id, pinHeaderId).setTitle("Pinne diese Überschrift")
    result.children.add pin
proc ih1*(text: string, override: string = ""): HtmlElement = h1(text).iheader(text, override) ## Header element (with ascii-friendly id)
proc ih2*(text: string, override: string = ""): HtmlElement = h2(text).iheader(text, override) ## Header element (with ascii-friendly id)
proc ih3*(text: string, override: string = ""): HtmlElement = h3(text).iheader(text, override) ## Header element (with ascii-friendly id)
proc ih4*(text: string, override: string = ""): HtmlElement = h4(text).iheader(text, override) ## Header element (with ascii-friendly id)
proc ih5*(text: string, override: string = ""): HtmlElement = h5(text).iheader(text, override) ## Header element (with ascii-friendly id)
proc ih6*(text: string, override: string = ""): HtmlElement = h6(text).iheader(text, override) ## Header element (with ascii-friendly id)

proc timeReadable*(dateTime: DateTime): string =
    result = dateTime.format("dd-MM-yyyy").replace("-", ".")
proc timeReadable*(date: string, dateFormat: string = "yyyy-MM-dd"): string =
    result = parse(date, dateFormat).timeReadable()

proc contentBox*(elements: seq[HtmlElement]): HtmlElement =
    ## Puts elements into a box
    `div`(elements).setClass(contentBoxClass)
proc contentBox*(elements: varargs[HtmlElement]): HtmlElement =
    ## Puts elements into a box
    contentBox(elements.toSeq())
proc addContentBox*(document: var HtmlDocument, elements: seq[HtmlElement]) =
    document.add(contentBox(elements))
proc addContentBox*(document: var HtmlDocument, elements: varargs[HtmlElement]) =
    document.addContentBox(elements.toSeq())

proc imageParagraph*(image: HtmlElement, content: seq[HtmlElement]): HtmlElement =
    result = `div`().setClass(imageParagraphClass)
    result.add image
    for item in content:
        result.add item.setClass(imageParagraphContentClass)
proc imageParagraph*(image: HtmlElement, content: varargs[HtmlElement]): HtmlElement =
    result = imageParagraph(image, content.toSeq())

# =============================================================================
# Options:
# =============================================================================

proc isSet*[T](item: Option[T]): bool =
    ## Shortcut to `item.isSome()` and checks against value being the same as the initial initialisation
    ##
    ## Basically: `string == ""; int == 0; seq[T] == @[]; ...`
    var emptyValue: T
    if item.isSome():
        if item.get() != emptyValue:
            result = true


# =============================================================================
# JSON:
# =============================================================================

proc `$%`*[T](toJson: T): string =
    ## Converts to `JsonNode` and then to `string`
    result = $(%toJson)
