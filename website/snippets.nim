## HTML Snippets module
## ====================
##
## Just like the `globals` module but for HTML procs.

import std/[strutils, json, options, tables]
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

proc buttonScript*(text, onclick: string): HtmlElement =
    ## Button with script attached to it
    button(text, onclick) # Use before overwrite lol

proc buttonLink*(content, href: string): HtmlElement = a(href, content).setClass(buttonClass) ## Styled button-like link

proc buttonList*(table: Table[string, string]|OrderedTable[string, string]): seq[HtmlElement] =
    ## List of buttons
    for content, href in table:
        result.add buttonLink(content, href)

proc backToHomeButton*(text: string): HtmlElement = buttonLink(text, "index.html") ## Button that returns to the home page


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
# URL formatting:
# -----------------------------------------------------------------------------

proc getRelativeUrlId*(name: string): string =
    ## Gets the url ID (replacing special characters)
    result = name.strip().toLower()
    for chars in urlConvertChars:
        result = result.replace(chars[0], chars[1])
proc getRelativeUrlPath*(name: string): string =
    ## Gets the path for an html page
    name.getRelativeUrlId() & ".html"



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

