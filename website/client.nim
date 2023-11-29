import std/[os, httpclient, json]
from std/net import TimeoutError
import globals

type
    ConnectionError* = object of HttpRequestError
    FetchError* = object of CatchableError

var http*: HttpClient = newHttpClient()


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


proc requestRawText*(url: string, backupPath: string = ""): string {.raises: FetchError.} =
    ## Requests raw text from a source or a fallback
    result = url.tryNetworkOrPath(backupPath)

proc requestJson*(url: string, backupPath: string = ""): JsonNode {.raises: [FetchError, JsonParsingError].} =
    ## Requests json from a source or a fallback
    try:
        result = requestRawText(url, backupPath).parseJson()

    # This does not handle FetchError, it just panics :)
    # Handle json shenanigans:
    except JsonParsingError, KeyError, ValueError, IOError, OSError:
        let msg: string = getCurrentExceptionMsg()
        raise JsonParsingError.newException(msg)


proc getLocationJson*(): JsonNode = urlJsonLocationData.requestJson(path("locations.json")) ## Gets the json with all locations
proc getTourJson*(): JsonNode = urlJsonTourData.requestJson(path("tour_locations.json")) ## Gets the json for tour locations
proc getMapSvg*(): string = requestRawText(urlImages & "map.svg", path("resources/images/map.svg")) ## Gets the raw map svg
