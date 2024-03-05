import std/[strutils, json, options, tables]
import generator, globals, styles, client

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
