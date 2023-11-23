import std/[httpclient, json]
from std/net import TimeoutError
import globals

type
    ConnectionError* = object of HttpRequestError

var http*: HttpClient = newHttpClient()

proc requestRawText*(url: string): string {.raises: ConnectionError.} =
    try:
        result = http.getContent(url)
    except TimeoutError, OSError, Exception:
        raise ConnectionError.newException("You seem to not be connected to the internet. Could not remote data.\n" & getCurrentExceptionMsg())

proc requestJson*(url: string): JsonNode {.raises: [ConnectionError, JsonParsingError].} =
    try:
        result = requestRawText(url).parseJson()
    except JsonParsingError, KeyError, ValueError:
        let msg: string = getCurrentExceptionMsg()
        raise JsonParsingError.newException(msg)
    except TimeoutError, OSError, Exception:
        raise ConnectionError.newException("You seem to not be connected to the internet. Could not fetch remote json data.")


proc getLocationJson*(): JsonNode = urlJsonLocationData.requestJson() ## Gets the json with all locations
proc getTourJson*(): JsonNode = urlJsonTourData.requestJson() ## Gets the json for tour locations
proc getMapSvg*(): string = requestRawText(urlImages & "map.svg") ## Gets the raw map svg
