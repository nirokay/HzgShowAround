import std/[times]
import logging, ../website/[generator]
from websitegenerator import newHtmlDocument

let currentTimeStamp: string = now().format("yyyy-MM-dd")

const
    urlPage: string = "https://www.nirokay.com/HzgShowAround/"
    sitemapPath: string = "sitemap.xml"

proc urlEntry(url: string): HtmlElement =
    result = newHtmlElement("url").add(
        newHtmlElement("loc", urlPage & url.escapeHtmlText()),
        newHtmlElement("lastmod", currentTimeStamp)
    )
proc urlEntries(urls: seq[string]): seq[HtmlElement] =
    for url in urls:
        result.add urlEntry(url)

proc generateXmlSiteMap*() =
    var document: HtmlDocument = newHtmlDocument(sitemapPath)
    logger.announceGeneration(document)
    document.add(
        rawText"<?xml version='1.0' encoding='UTF-8'?>",
        "urlset"[
            "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9"
        ].add(
            urlEntries(logger.generatedHtml)
        )
    )
    writeFile("docs/" & sitemapPath, $document.body)
    logger.addGenerated(document)
