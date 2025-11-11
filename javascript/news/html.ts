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
interface LocationLookupDictionary {
    [key: string]: {
        names: string[];
        path: string;
    };
}

const urlImagesDirectory: string =
    "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/resources/images/";
const urlLocationLookupTable: string =
    "https://raw.githubusercontent.com/nirokay/HzgShowAround/master/docs/resources/location_lookup.json";

let locationLookupTable: LocationLookupDictionary = {};
async function getLocationLookupTable() {
    if (Object.keys(locationLookupTable).length > 0) {
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
getLocationLookupTable();

const htmlHeaderPlaceholder: HtmlString =
    "<pre style='background-color: #ffffff22;margin: 0px 25%;border-radius: 10px;'> </pre>";
const htmlDatePlaceholder: HtmlString =
    "<pre style='background-color: #ffffff22;margin: 0px 40%;border-radius: 10px;'> </pre>";
const htmlDescriptionPlaceholder: HtmlString =
    "<div>" +
    [
        "<pre style='background-color: #ffffff22;margin: 20px 10% 10px 10%;border-radius: 10px;'>                                       </pre>",
        "<pre style='background-color: #ffffff22;margin: 0px 10% 20px 10%;border-radius: 10px;'>                       </pre>",
    ].join("") +
    "</div>";

/**
 * Adds a disclaimer to the title (called by `htmlHeader` function)
 */
function htmlDisclaimer(
    element: NewsFeedElement,
    cssClass: string,
): HtmlString {
    if (element.name == placeHolderIdentifier) {
        return "";
    }
    let result = [];
    if (cssClass.endsWith("happened")) {
        result.push("<i>vergangen</i>");
    }
    if (element.isHappening) {
        result.push("<b>heute</b>");
    }

    return result.length == 0
        ? ""
        : "<small>(" + result.join(", ") + ")</small>";
}
/**
 * Generates the html header (event title/name, etc.)
 */
function htmlHeader(element: NewsFeedElement, disclaimer: string): HtmlString {
    let text = "";
    if (disclaimer != undefined || disclaimer == "") {
        text = disclaimer;
    }
    if (text != "") {
        text = " " + text;
    }

    let result: HtmlString;
    if (element.name == placeHolderIdentifier) {
        result = htmlHeaderPlaceholder;
    } else {
        result = "<u>" + element.name + "</u>" + text;
    }
    result = addLocationLinks(result);
    return "<h3 style='margin-bottom:2px;'>" + result + "</h3>";
}
/**
 * Generates a location indication
 */
function htmlLocationSection(element: NewsFeedElement): HtmlString {
    if (element.name == placeHolderIdentifier) {
        return "";
    }
    let result: HtmlString = "";
    if (element.locations != undefined) {
        let locations: Array<string> = element.locations;
        if (locations.length == 0) {
            return "";
        }
        let sep: string = "📌 ";
        result =
            "<p class='center' style='margin-top:2px;' title='Relevante(r) Ort(e)'>" +
            sep +
            locations.join(", " + sep) +
            "</p>";
    }
    result = addLocationLinks(result);
    return result;
}
/**
 * Generates the date section
 */
function htmlDateSection(element: NewsFeedElement): HtmlString {
    let result: HtmlString[] = [];
    let times: HtmlString[] = [];
    element.times?.forEach((time) => {
        const from = displayTime(time.from ?? "?");
        const till = displayTime(time.till ?? "?");
        let lines: HtmlString = "";
        lines += "am " + from;
        /**
        if (from == till) {
            // Same day:
            resultDate = "am " + from;
        } else {
            if (
                Date.parse(time.from ?? getToday()) + dayMilliseconds * 1.5 >=
                Date.parse(time.till ?? getToday())
            ) {
                // Why is it multiplied by 1.5 you ask? Well not having to think about daylight-saving of course! I am a master programmer and I will not tolerate any stupid questions like these about my GODLIKE code! Thank you very much for understanding :)
                // Two days (both dates):
                resultDate = "am " + from + " und am " + till;
            } else {
                // More than two days (span):
                resultDate = "von " + from + " bis " + till;
            }
        }
        */

        if (time.icalTimeStart != "000000" && time.icalTimeEnd != "000000") {
            let resultTime: HtmlString =
                " von " +
                icalTimeToNormal(time.icalTimeStart) +
                " bis " +
                icalTimeToNormal(time.icalTimeEnd);
            lines += resultTime;
        }

        if (element.name == placeHolderIdentifier) {
            lines = htmlDatePlaceholder;
        }
        times.push(lines);
    });
    times.forEach((time) => {
        result.push(
            "<small class='generic-center' title='Zeitraum des Events'>" +
                time +
                "</small>",
        );
    });
    result.push(htmlLocationSection(element));
    return result.join("");
}
/**
 * Generates the details/description section
 */
function htmlDetails(element: NewsFeedElement): HtmlString {
    if (element.name == placeHolderIdentifier) {
        return htmlDescriptionPlaceholder;
    }

    let lines: HtmlString[] = [];

    // Entire description:
    lines = element.details ?? [];
    let result: HtmlString = "";
    if (lines.length != 0) {
        result = "<p>" + lines.join("<br />") + "</p>";
    }

    return result;
}

/**
 * Generates the footer section
 */
function htmlFooter(element: NewsFeedElement): HtmlString {
    let result: HtmlString[] = [];
    let url = element.info;

    // Adds a little "more infos" link at the bottom:
    if (url != undefined && url != "")
        result.push(
            "<a title='Mehr Informationen extern abrufen.' href='" +
                url +
                "' target='_blank'>🌐 mehr Infos</a>",
        );

    // Genuinely what the actual fuck:
    let fromTime: string =
        element.times != undefined ? element.times[0].icalTimeStart : "";
    let tillTime: string =
        element.times != undefined ? element.times[0].icalTimeEnd : "";
    let fromDate: string =
        element.times != undefined ? (element.times[0].from ?? "") : "";
    let tillDate: string =
        element.times != undefined ? (element.times[0].till ?? "") : "";
    let hash: string =
        element.from +
        "_" +
        replaceAll(fromTime ?? "", "00", "-") +
        "_" +
        element.till +
        "_" +
        replaceAll(tillTime ?? "", "00", "-");

    let filename: string = "hzgshowaround-event-" + btoa(hash) + ".ics";

    // Adds a link to save ical file:
    if (
        element.name != htmlHeaderPlaceholder &&
        element.name != placeHolderIdentifier
    )
        result.push(
            "<a title='Im Kalender abspeichern' href='javascript:downloadIcalFile(\"" +
                filename +
                '", "' +
                getIcalFileContent(element) +
                "\")'>📅 im Kalender abspeichern</a>",
        );
    return "<p class='generic-center'>" + result.join(" | ") + "</p>";
}

/**
 * URL -> <img> tag
 */
function htmlImage(element: NewsFeedElement): HtmlString {
    let result: HtmlString = "";
    if (
        element.image != "" &&
        element.image != undefined &&
        element.image != null
    ) {
        let url: string = element.image ?? "";
        // Images from data repository:
        if (!url.startsWith("https://") && !url.startsWith("/")) {
            let subdir: string = "";
            if (!url.includes("/")) subdir = "newsfeed/icons/";
            url = urlImagesDirectory + subdir + url;
        }
        result = "<img class='newsfeed-element-picture' src='" + url + "' />";
    }
    return result;
}

function newDiv(
    className: string,
    elements: HtmlString[],
    attributes: string[] | undefined = undefined,
): HtmlString {
    let result: HtmlString = "<div";
    if (className != "" || className != null || className != undefined) {
        result += " class='" + className + "'";
    }
    if (attributes != undefined && attributes != null) {
        try {
            if (attributes.length != 0) {
                let attributeInjection: HtmlString = " " + attributes.join(" ");
                result += attributeInjection;
            }
        } catch (e) {
            debug(
                "Caught exception in `newDiv` with attributes arg: " +
                    attributes.toString(),
            );
            console.warn(e);
        }
    }
    result += ">";
    elements.forEach((element) => {
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
    let detailsDiv: HtmlString = addLocationLinks(htmlDetails(element));
    let imageDivAttributes: HtmlString[] = [];
    if (detailsDiv == "") {
        imageDivAttributes = ["style='margin:auto;'"];
    }
    let imageDiv: HtmlString = newDiv(
        "newsfeed-element-segment-image",
        [htmlImage(element)],
        imageDivAttributes,
    );

    let elements: HtmlString[] = [
        newDiv("newsfeed-element-segment-header", [
            htmlHeader(element, htmlDisclaimer(element, className)),
            htmlDateSection(element),
        ]),
        newDiv("newsfeed-element-segment-body", [imageDiv, detailsDiv]),
        htmlFooter(element),
    ];
    let attributes: string[] = [];
    if (element.isHappening && element.name != placeHolderIdentifier)
        attributes.push("style='background-color:#2f3139 !important;'");
    return newDiv(className, elements, attributes);
}

/**
 * Replaces location substrings with links to the locations
 */
function addLocationLinks(html: HtmlString): HtmlString {
    let result: HtmlString = html;
    // Thank you javascript for being dynamic:
    if (
        locationLookupTable == undefined ||
        typeof locationLookupTable != "object"
    ) {
        return result;
    }
    if (Object.keys(locationLookupTable).length == 0) {
        return result;
    }

    // Highly efficient code to replace substrings with, I do not want to go into
    // detail on how great nested loops are :)
    for (const [_name, lookupObject] of Object.entries(locationLookupTable)) {
        if (typeof lookupObject != "object") {
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
