import std/[httpclient, json]
import globals

var http*: HttpClient = newHttpClient()

proc getLocationJson*(): JsonNode = http.getContent(urlJsonLocationData).parseJson()
proc getTourJson*(): JsonNode = http.getContent(urlJsonTourData).parseJson()
