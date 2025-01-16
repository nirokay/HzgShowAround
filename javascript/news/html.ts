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
    if(Object.keys(locationLookupTable).length > 0) {
        return;
    }
    try {
        let response = await fetch(urlLocationLookupTable);
        let raw = await response.text();
        locationLookupTable = JSON.parse(raw);
        debug("Got locationLookupTable!");
    } catch (error) {
        debug("Could not fetch or parse location lookup table", error);
        locationLookupTable = {};
    }
}
getLocationLookupTable()


const htmlHeaderPlaceholder: HtmlString = "<pre style='background-color: #ffffff22;margin: 0px 25%;border-radius: 10px;'> </pre>";
const htmlDatePlaceholder: HtmlString = "<pre style='background-color: #ffffff22;margin: 0px 40%;border-radius: 10px;'> </pre>";
const htmlDescriptionPlaceholder: HtmlString = [
    "<pre style='background-color: #ffffff22;margin: 20px 10% 10px 10%;border-radius: 10px;'>              </pre>",
    "<pre style='background-color: #ffffff22;margin: 0px 10% 20px 10%;border-radius: 10px;'>              </pre>"
].join(" ");

/**
 * Adds a disclaimer to the title (called by `htmlHeader` function)
 */
function htmlDisclaimer(element: NewsFeedElement, cssClass: string): HtmlString {
    if(element.name == placeHolderIdentifier) {return ""}
    let result = [];
    if(cssClass.endsWith("happened")) {
        result.push("<i>Event vergangen</i>")
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

    let result: HtmlString
    if(element.name == placeHolderIdentifier) {
        result = htmlHeaderPlaceholder;
    } else {
        result = "<u>" + element.name + "</u>" + text;
    }
    return "<h3 style='margin-bottom:2px;'>" + result + "</h3>"
}
/**
 * Generates a location indication
 */
function htmlLocationSection(element: NewsFeedElement): HtmlString {
    if(element.name == placeHolderIdentifier) {return ""}
    let result: HtmlString = "";
    if(element.locations != undefined) {
        let locations: Array<string> = element.locations;
        if(locations.length == 0) {return ""}
        let sep: string = "📌 ";
        result = "<p class='center' style='margin-top:2px;' title='Relevant(e) Ort(e)'>" + sep + locations.join(", " + sep) + "</p>";
    }
    return result;
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
    if(element.name == placeHolderIdentifier) {
        result = htmlDatePlaceholder;
    }
    return "<small class='generic-center' title='Datum des Events'>" + result + "</small>" + htmlLocationSection(element);
}
/**
 * Generates the details/description section
 */
function htmlDetails(element: NewsFeedElement): HtmlString {
    if(element.name == placeHolderIdentifier) {
        return htmlDescriptionPlaceholder;
    }

    let lines: HtmlString[] = [];
    let url = element.info;

    // Entire description:
    lines = element.details ?? [];
    let result = "<p>" + lines.join("<br />") + "</p>";

    // Adds a little "more infos" link at the bottom:
    if(url != undefined && url != "") {
        result += "<p class='generic-center'><a href='" + url + "' target='_blank'>mehr Infos</a></p>";
    }
    return result;
}

/**
 * URL -> <img> tag
 */
function htmlImage(element: NewsFeedElement): HtmlString {
    let result: HtmlString = "";
    if(element.image != "" && element.image != undefined && element.image != null) {
        let url: string = element.image ?? "";
        // Locally hosted image:
        if(!url.startsWith("https://") && !url.startsWith("/")) {
            let subdir: string = "";
            if(!url.includes("/")) subdir = "newsfeed/";
            url = "../resources/images/" + subdir + url;
        }
        result = "<img class='newsfeed-element-picture' src='" + url + "' />"
    }
    return result;
}

function newDiv(className: string, elements: HtmlString[]): HtmlString {
    var result: HtmlString = "<div";
    if(className != "" || className != null || className != undefined) {
        result += " class='" + className + "'";
    }
    result += ">";
    elements.forEach(element => {
        result += element;
    });

    result += "</div>";
    return result;
}

/**
 * Generates the HTML for the entire element
 */
function generateElementHtml(element: NewsFeedElement): HtmlString {
    let className: string = getElementClass(element);
    let elements: HtmlString[] = [
        newDiv("newsfeed-element-segment-header", [
            htmlHeader(element, htmlDisclaimer(element, className)),
            htmlDateSection(element),
        ]),
        newDiv("newsfeed-element-segment-body", [
            newDiv("newsfeed-element-segment-image", [htmlImage(element)]),
            htmlDetails(element)
        ])
    ];
    return newDiv(className, elements);
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
