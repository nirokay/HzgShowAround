import std/[httpclient, json]
from std/net import TimeoutError
import globals

type
    ConnectionError* = object of HttpRequestError

var http*: HttpClient = newHttpClient()

proc requestJson*(url: string): JsonNode {.raises: [ConnectionError, JsonParsingError].} =
    try:
        result = http.getContent(url).parseJson()
    except JsonParsingError, KeyError, ValueError:
        let msg: string = getCurrentExceptionMsg()
        raise JsonParsingError.newException(msg)
    except TimeoutError, OSError, Exception:
        raise ConnectionError.newException("You seem to not be connected to the internet. Could not fetch remote json data.")


proc getLocationJson*(): JsonNode = urlJsonLocationData.requestJson()
proc getTourJson*(): JsonNode = urlJsonTourData.requestJson()
