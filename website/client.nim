## Http Client module
## ==================
##
## This module is used to fetch data over the network during run-time.

import std/[json, strutils]
import globals

const submodule: string = "./HzgShowAroundData/"

proc write(text: string) =
    try:
        stdout.write(text)
        stdout.flushFile()
    except IOError:
        echo "Failed to write to stdout"


proc readFileRawText*(path: string): string =
    ## Reads raw text from git submodule file
    let actualPath: string = path.replace(urlRemoteRepo, submodule) # silly backwards-compatibility hacking :3
    write("📖 Reading file... " & actualPath)
    result = readFile(actualPath)
    write("\r📖 Successfully read file " & actualPath & "\n")

proc readFileJson*(path: string): JsonNode =
    ## Reads JSON from git submodule file
    let raw: string = path.readFileRawText()

    result = raw.parseJson()


proc getLocationJson*(): JsonNode = urlLocationData.readFileJson() ## Gets the json with all locations
proc getTourJson*(): JsonNode = urlTourData.readFileJson() ## Gets the json for tour locations
proc getArticlesJson*(): JsonNode = urlArticles.readFileJson() ## Gets the json with all article information
proc getArticleAuthorsJson*(): JsonNode = urlAuthors.readFileJson() ## Gets the json with article authors
proc getContributorsJson*(): JsonNode = urlContributors.readFileJson() ## Gets the json with all contributors
proc getMapSvg*(): string = readFileRawText(urlImages & "map.svg") ## Gets the raw map svg
proc getOfferingsJson*(): JsonNode = urlOfferings.readFileJson() ## Gets the json with offerings
proc getChangelogJson*(): JsonNode = urlChangelog.readFileJson() ## Gets the json with the changelog
