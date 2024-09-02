/**
 * String that is HTML
 */
type HtmlString = string;

/**
 * location name -> {
 *     names: string[],
 *     path: string
 * },
 * ...
 */
type LocationLookupDictionary = object;

const urlLocationLookupTable: string = "https://raw.githubusercontent.com/nirokay/HzgShowAround/master/docs/resources/location_lookup.json";

let locationLookupTable: LocationLookupDictionary = {};
async function getLocationLookupTable() {
    try {
        let response = await fetch(urlLocationLookupTable);
        let raw = await response.text();
        locationLookupTable = JSON.parse(raw);
        debug("Got locationLookupTable!", locationLookupTable);
    } catch (error) {
        debug("Could not fetch or parse location lookup table", error);
        locationLookupTable = {};
    }
}
getLocationLookupTable()


/**
 * Adds a disclaimer to the title (called by `htmlHeader` function)
 */
function htmlDisclaimer(element: NewsFeedElement, cssClass: string): HtmlString {
    let result = [];
    if(cssClass.endsWith("happened")) {
        result.push("Event vergangen")
    }
    if(element.isHappening) {
        result.push("<b>Heute!</b>")
    }
    return result.length == 0 ? "" : "<small>(" + result.join(", ") + ")</small>"
}
/**
 * Generates the html header (event title/name, etc.)
 */
function htmlHeader(element: NewsFeedElement, disclaimer: string): HtmlString {
    let text = "";
    if(disclaimer != undefined || disclaimer == "") {
        text = disclaimer;
    }
    if(text != "") {
        text = " " + text;
    }
    return "<h3 style='margin-bottom:2px;'>" + element.name + text + "</h3>"
}
/**
 * Generates the date section
 */
function htmlDateSection(element: NewsFeedElement): HtmlString {
    const from = displayTime(element.from ?? "?");
    const till = displayTime(element.till ?? "?");
    let result: HtmlString = "";
    if(from == till) {
        // Same day:
        result = "am " + from;
    } else {
        if(
            Date.parse(element.from ?? getToday()) + dayMilliseconds*1.5
            >=
            Date.parse(element.till ?? getToday())
        ) { // Why is it multiplied by 1.5 you ask? Well not having to think about daylight-saving of course! I am a master programmer and I will not tolerate any stupid questions like these about my GODLIKE code! Thank you very much for understanding :)
            // Two days (both dates):
            result = "am " + from + " und am " + till;
        } else {
            // More than two days (span):
            result = "von " + from + " bis " + till;
        }
    }
    return "<small class='generic-center' title='Datum des Events'>" + result + "</small>"
}
/**
 * Generates the details/description section
 */
function htmlDetails(element: NewsFeedElement): HtmlString {
    let lines: HtmlString[] = [];
    let url = element.info;

    // Entire description:
    lines = element.details ?? [];
    let result = "<p>" + lines.join("<br />") + "</p>";

    // Adds a little "more infos" link at the bottom:
    if(url != undefined && url != "") {
        result += "<p class='generic-center'><a href='" + url + "'>mehr Infos</a></p>";
    }
    return result;
}

/**
 * Generates the HTML for the entire element
 */
function generateElementHtml(element: NewsFeedElement): HtmlString {
    let className: string = getElementClass(element);
    let elements: HtmlString[] = [
        htmlHeader(element, htmlDisclaimer(element, className)),
        htmlDateSection(element),
        htmlDetails(element)
    ];
    return "<div class='" + className + "'>" + elements.join("") + "</div>";
}

/**
 * Replaces location substrings with links to the locations
 */
function addLocationLinks(html: HtmlString): HtmlString {
    let result: HtmlString = html;
    // Thank you javascript for being dynamic:
    if(locationLookupTable == undefined || typeof(locationLookupTable) != "object") {
        return result;
    }
    if(Object.keys(locationLookupTable).length == 0) {
        return result;
    }

    // Highly efficient code to replace substrings with, I do not want to go into
    // detail on how great nested loops are :)
    for(const [_name, lookupObject] of Object.entries(locationLookupTable)) {
        if(typeof(lookupObject) != "object") {
            debug("Fuck, why is locationLookupTable[element] not an object?");
            continue;
        }
        let id = lookupObject.path;
        lookupObject.names.forEach((name: string) => {
            // I really like that string.replace("toReplace", "replaceWith") only replaces
            // the first occurrence - really nice of Javascript to do that!
            let toReplace: RegExp = new RegExp(name, "g");
            let replaceWith: string = "<a href='" + id + "'>" + name + "</a>";
            result = result.replace(toReplace, replaceWith);
        });
    }
    return result;
}
