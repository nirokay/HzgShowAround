import std/[times]
import logging, ../website/[generator]
from cattag import newXmlDocument

let currentTimeStamp: string = now().format("yyyy-MM-dd")

const
    urlPage: string = "https://www.nirokay.com/HzgShowAround/"
    sitemapPath: string = "sitemap.xml"

proc urlEntry(url: string): XmlElement =
    result = newXmlElement("url").add(
        newXmlElement("loc", xml urlPage & url),
        newXmlElement("lastmod", xml currentTimeStamp)
    )
proc urlEntries(urls: seq[string]): seq[XmlElement] =
    for url in urls:
        result.add urlEntry(url)

proc generateXmlSiteMap*() =
    var document: XmlDocument = newXmlDocument(sitemapPath)
    logger.announceGeneration(document)
    document.add(
        newXmlElement("urlset", @[
            "xmlns" <=> "http://www.sitemaps.org/schemas/sitemap/0.9"
        ]).add(
            urlEntries(logger.generatedHtml)
        )
    )
    writeFile("docs/" & sitemapPath, $document.body)
    logger.addGenerated(document)
