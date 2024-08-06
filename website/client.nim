## Http Client module
## ==================
##
## This module is used to fetch data over the network during run-time.

import std/[os, httpclient, json]
from std/net import TimeoutError
import globals

type
    ConnectionError* = object of HttpRequestError
    FetchError* = object of CatchableError

proc initClient(): HttpClient =
    stdout.write "Setting up http client"
    result = newHttpClient()
    stdout.write "\rSuccessfully set up http client\n"
var http*: HttpClient = initClient()


proc path(path: string): string = "../HzgShowAroundData/" & path


proc fetch(url: string): string {.raises: ConnectionError.} =
    ## Tries to fetch remote data
    try:
        result = http.getContent(url)
    except CatchableError, Exception:
        raise ConnectionError.newException("You do not seem to be connected to the internet. Could not fetch remote data.")

proc tryNetworkOrPath(url: string, backupPath: string): string {.raises: FetchError.} =
    ## Tries to fetch remote data, and falls back to filesystem, when connection issues are present
    proc msg(reason: string): string = "No internet connection. Could not fetch file from backup path (" & reason & ")!"

    # Attempt over network:
    try:
        result = fetch(url)

    # Fall back to filesystem, for **BLAZINGLY FAST** development
    except ConnectionError:
        if not backupPath.fileExists():
            raise FetchError.newException(msg("file '" & backupPath & "' does not exist"))
        try:
            result = backupPath.readFile()
        except CatchableError:
            raise FetchError.newException("could not read file")

proc write(text: string) =
    try:
        stdout.write(text)
        stdout.flushFile()
    except IOError:
        echo "Failed to write to stdout"

proc requestRawText*(url: string, backupPath: string = ""): string {.raises: FetchError.} =
    ## Requests raw text from a source or a fallback
    write("Awaiting network... Fetching " & url)
    result = url.tryNetworkOrPath(backupPath)
    write("\r✓ Finished fetching from URL: " & url & "\n")

proc requestJson*(url: string, backupPath: string = ""): JsonNode {.raises: [FetchError, JsonParsingError].} =
    ## Requests json from a source or a fallback
    try:
        result = requestRawText(url, backupPath).parseJson()

    # This does not handle FetchError, it just panics :)
    # Handle json shenanigans:
    except JsonParsingError, KeyError, ValueError, IOError, OSError:
        let msg: string = getCurrentExceptionMsg()
        raise JsonParsingError.newException(msg)


proc getLocationJson*(): JsonNode = urlLocationData.requestJson(path("locations.json")) ## Gets the json with all locations
proc getTourJson*(): JsonNode = urlTourData.requestJson(path("tour_locations.json")) ## Gets the json for tour locations
proc getArticlesJson*(): JsonNode = urlArticles.requestJson(path("articles.json")) ## Gets the json with all article informations
proc getArticleAuthorsJson*(): JsonNode = urlAuthors.requestJson(path("authors.json")) ## Gets the json with article authors
proc getContributorsJson*(): JsonNode = urlContributors.requestJson(path("contributors.json")) ## Gets the json with all contributors
proc getMapSvg*(): string = requestRawText(urlImages & "map.svg", path("resources/images/map.svg")) ## Gets the raw map svg
proc getOfferingsJson*(): JsonNode = urlOfferings.requestJson(path("offerings.json")) ## Gets the json with offerings
proc getChangelogJson*(): JsonNode = urlChangelog.requestJson(path("changelog.json")) ## Gets the json with the changelog
