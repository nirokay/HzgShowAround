## HzgShowAround - Articles
## ========================
##
## This module includes everything about articles. The main article page, as well as the user-written articles are generated here.
## For documentation about how articles are written see [the articles documentation](https://github.com/nirokay/HzgShowAroundData#artikel).

import std/[strutils, options, json, algorithm]
import generator
import globals, styles, client

const
    imageTags*: seq[tuple[opening, closing: string]] = @[
        ("<img>", "</img>"),
        ("<img=", ">"),

        ("<bild>", "</bild>"),
        ("<bild=", ">"),

        ("<pic>", "</pic>"),
        ("<pic=", ">")
    ]
    headerTags*: seq[string] = @[
        "#", "##", "###", "####", "#####", "######"
    ]

type
    ArticleBody* = seq[string]

    Article* = object
        title*: string
        author*, date*, desc*: Option[string]
        remote*: Option[string]
        body*: Option[ArticleBody]

var articleNames: seq[string]
proc articleUrl(article: Article): string =
    result = getRelativeUrlId(article.title)
    # Add numbers to article paths:
    if result in articleNames:
        var index: int
        while result notin articleNames:
            result &= $index

    articleNames.add(result)
    return result & ".html"

proc getImageUrl(fileName: string): string = urlArticleImages & fileName
proc formatLine*(line: string): HtmlElement =
    var content: string = line.strip().replace("\n", $br())
    let words: seq[string] = content.split(' ')

    # Check for line-break:
    block CheckForLineBreak:
        if words.len() != 0: break CheckForLineBreak
        return br()

    # Check line for header:
    block CheckForHeader:
        if words.len() <= 1: break CheckForHeader ## Empty `###` headers will be ignored
        if words[0] notin headerTags: break CheckForHeader
        let content: string = words[1 .. ^1].join(" ")
        result =
            case words[0].len():
            of 1: h1(content)
            of 2: h2(content)
            of 3: h3(content)
            of 4: h4(content)
            of 5: h5(content)
            of 6: h6(content)
            else: break CheckForHeader
        return result

    # Check line for image tags:
    block CheckForImage:
        for tag in imageTags:
            if not(content.startsWith(tag.opening) and content.endsWith(tag.closing)): continue

            # Remove tags and strip:
            content.removePrefix(tag.opening)
            content.removeSuffix(tag.closing)
            content = content.strip()

            # Return image:
            let src: string = content.getImageUrl()
            return img(src, "Bild nicht vorhanden").setClass(centerClass)

    # Just returns the line (if no format found)
    return p(content)


proc addArticleHeader(html: var HtmlDocument, article: Article) =
    ## Adds stuff on the top of an article (title, author, etc.)
    var header: seq[HtmlElement] = @[h1(article.title)]

    # Author and date (on the same line):
    var authorAndDate: seq[string]
    if article.author.isSome():
        authorAndDate.add "Autor: " & get article.author
    if article.date.isSome():
        authorAndDate.add "verfasst am " & $time(get article.date)
    header.add pc($small(authorAndDate.join(" | ")))

    # Description/summary:
    if article.desc.isSome():
        header.add summary(get article.desc)

    html.addToBody header(header.join("\n"))


# Generate html sites:
var articles: seq[Article]
proc getArticles() =
    let jsonArticles: JsonNode = getArticlesJson()
    for jsonArticle in jsonArticles.elems:
        try:
            articles.add(jsonArticle.to(Article))
        except CatchableError as e:
            echo "Failed to convert article. Wrong syntax? Skipping...\nMessage: " & e.msg & "\nJson: " & $jsonArticle

proc getRawHtmlArticle(file: string): string =
    let url: string = urlCustomHtmlArticles & file
    result = requestRawText(url)

proc generateArticleHtml(article: Article) =
    ## Generate single article
    var desc: string = "Artikel " & article.title
    if article.desc.isSet():
        desc = get article.desc

    var html: HtmlDocument = newPage(
        "Artikel - " & article.title,
        articlesLocation & article.articleUrl(),
        desc
    )

    # Navigation buttons:
    html.addToBody `div`(
        button("← Startseite", "../index.html"),
        button("← Artikel", "../articles.html")
    ).setClass(centerClass)

    # Article header:
    html.addArticleHeader(article)

    # Article body:
    var body: seq[string]

    # Embed custom html into article:
    try:
        if article.remote.isSome():
            let customHtml: string = getRawHtmlArticle(get article.remote)
            body.add(customHtml)

        # Or generate using json:
        elif article.body.isSome():
            for line in get article.body:
                body.add($line.formatLine())

        # Uhm, should not happen, but maybe someone will forget it...
        else:
            body.add($pc("Dieser Artikel scheint leer zu sein... :("))

    except CatchableError:
        echo "⮿ Failed to write article '" & article.title & "'..."
        body.add($pc("Dieser Artikel konnte leider nicht generiert werden..."))

    html.addToBody(
        hr(),
        article(body.join("\n")),
        hr()
    )

    # Add css and write to disk:
    html.addToHead(stylesheet(articleCssFile))
    html.generate()

proc generateArticlesHtmls() =
    ## Generates all articles
    getArticles()
    for article in articles:
        article.generateArticleHtml()

proc generateHtmlMainPage() =
    ## Generates article landing page
    var html: HtmlDocument = newPage(
        "Artikel",
        "articles.html",
        "Sämtliche Artikel verfasst von verschiedenen Leuten!"
    )

    html.addToBody `div`(
        button("← Startseite", "index.html"),
    ).setClass(centerClass)

    # Sort articles by date:
    var articlesSorted: seq[Article] = articles

    proc reverseDate(date: string): string = date.split('.').reversed().join(".")
    articlesSorted.sort do (x, y: Article) -> int:
        let default: string = "01.01.0000"
        result = cmp(y.date.get(default).reverseDate(), x.date.get(default).reverseDate())

    # Add articles to html:
    var articleElements: seq[HtmlElement]

    for article in articlesSorted:
        var elements: seq[HtmlElement]

        # Article title:
        elements.add a(articlesLocation & article.articleUrl(), $h3(article.title))

        # Description:
        if article.desc.isSome():
            elements.add p(article.desc.get().replace("\n", $br()))

        # Footer: (author and date)
        elements.add(
            small(
                "verfasst von " & article.author.get("Anonym") & (
                    if article.date.isSome(): " | am " & article.date.get() else: ""
                )
            )
        )

        # Add them to html:
        articleElements.add `div`(elements).setClass(articlePreviewItem)

    # Empty articles div, add info:
    if articleElements.len() == 0:
        articleElements.add pc("Derzeit sind keine Artikel vorhanden...")

    html.addToBody(
        h1("Artikel"),
        pc("Hier findest du verschiedene Artikel verfasst von unterschiedlichen Leuten zu Themen, die sie interessieren."),
        `div`(articleElements).setClass(articlePreviewBox)
    )

    html.setStyle(css)
    html.generate()

generateArticlesHtmls()
generateHtmlMainPage()
