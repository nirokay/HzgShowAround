"use strict";
const urlImagesDirectory = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/resources/images/";
const urlLocationLookupTable = "https://raw.githubusercontent.com/nirokay/HzgShowAround/master/docs/resources/location_lookup.json";
let locationLookupTable = {};
async function getLocationLookupTable() {
    if (Object.keys(locationLookupTable).length > 0) {
        return;
    }
    try {
        let response = await fetch(urlLocationLookupTable);
        let raw = await response.text();
        locationLookupTable = JSON.parse(raw);
        debug("Got locationLookupTable!");
    }
    catch (error) {
        debug("Could not fetch or parse location lookup table", error);
        locationLookupTable = {};
    }
}
getLocationLookupTable();
const htmlHeaderPlaceholder = "<pre style='background-color: #ffffff22;margin: 0px 25%;border-radius: 10px;'> </pre>";
const htmlDatePlaceholder = "<pre style='background-color: #ffffff22;margin: 0px 40%;border-radius: 10px;'> </pre>";
const htmlDescriptionPlaceholder = "<div>" +
    [
        "<pre style='background-color: #ffffff22;margin: 20px 10% 10px 10%;border-radius: 10px;'>                        </pre>",
        "<pre style='background-color: #ffffff22;margin: 0px 10% 20px 10%;border-radius: 10px;'>                                                        </pre>",
    ].join("") +
    "</div>";
/**
 * Adds a disclaimer to the title (called by `htmlHeader` function)
 */
function htmlDisclaimer(element, cssClass) {
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
function htmlHeader(element, disclaimer) {
    let text = "";
    if (disclaimer != undefined || disclaimer == "") {
        text = disclaimer;
    }
    if (text != "") {
        text = " " + text;
    }
    let result;
    if (element.name == placeHolderIdentifier) {
        result = htmlHeaderPlaceholder;
    }
    else {
        result = "<u>" + element.name + "</u>" + text;
    }
    result = addLocationLinks(result);
    return "<h3 style='margin-bottom:2px;'>" + result + "</h3>";
}
/**
 * Generates a location indication
 */
function htmlLocationSection(element) {
    if (element.name == placeHolderIdentifier) {
        return "";
    }
    let result = "";
    if (element.locations != undefined) {
        let locations = element.locations;
        if (locations.length == 0) {
            return "";
        }
        let sep = "📌 ";
        result =
            "<p class='center' style='margin-top:2px;' title='Relevant(e) Ort(e)'>" +
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
function htmlDateSection(element) {
    var _a, _b, _c, _d;
    const from = displayTime((_a = element.from) !== null && _a !== void 0 ? _a : "?");
    const till = displayTime((_b = element.till) !== null && _b !== void 0 ? _b : "?");
    let result = "";
    if (from == till) {
        // Same day:
        result = "am " + from;
    }
    else {
        if (Date.parse((_c = element.from) !== null && _c !== void 0 ? _c : getToday()) + dayMilliseconds * 1.5 >=
            Date.parse((_d = element.till) !== null && _d !== void 0 ? _d : getToday())) {
            // Why is it multiplied by 1.5 you ask? Well not having to think about daylight-saving of course! I am a master programmer and I will not tolerate any stupid questions like these about my GODLIKE code! Thank you very much for understanding :)
            // Two days (both dates):
            result = "am " + from + " und am " + till;
        }
        else {
            // More than two days (span):
            result = "von " + from + " bis " + till;
        }
    }
    if (element.name == placeHolderIdentifier) {
        result = htmlDatePlaceholder;
    }
    return ("<small class='generic-center' title='Datum des Events'>" +
        result +
        "</small>" +
        htmlLocationSection(element));
}
/**
 * Generates the details/description section
 */
function htmlDetails(element) {
    var _a;
    if (element.name == placeHolderIdentifier) {
        return htmlDescriptionPlaceholder;
    }
    let lines = [];
    // Entire description:
    lines = (_a = element.details) !== null && _a !== void 0 ? _a : [];
    let result = "";
    if (lines.length != 0) {
        result = "<p>" + lines.join("<br />") + "</p>";
    }
    return result;
}
/**
 * Generates the footer section
 */
function htmlFooter(element) {
    let result = [];
    let url = element.info;
    // Adds a little "more infos" link at the bottom:
    if (url != undefined && url != "")
        result.push("<a title='Mehr Informationen extern abrufen.' href='" +
            url +
            "' target='_blank'>🌐 mehr Infos</a>");
    // Adds a link to save ical file:
    if (element.name != htmlHeaderPlaceholder &&
        element.name != placeHolderIdentifier)
        result.push("<a title='Im Kalender abspeichern' href='javascript:downloadIcalFile(" +
            '"hzgshowaround.ical", \"' +
            getIcalFileContent(element) +
            "\")'>📅 im Kalender abspeichern</a>");
    return "<p class='generic-center'>" + result.join(" | ") + "</p>";
}
/**
 * URL -> <img> tag
 */
function htmlImage(element) {
    var _a;
    let result = "";
    if (element.image != "" &&
        element.image != undefined &&
        element.image != null) {
        let url = (_a = element.image) !== null && _a !== void 0 ? _a : "";
        // Images from data repository:
        if (!url.startsWith("https://") && !url.startsWith("/")) {
            let subdir = "";
            if (!url.includes("/"))
                subdir = "newsfeed/";
            url = urlImagesDirectory + subdir + url;
        }
        result = "<img class='newsfeed-element-picture' src='" + url + "' />";
    }
    return result;
}
function newDiv(className, elements, attributes = undefined) {
    let result = "<div";
    if (className != "" || className != null || className != undefined) {
        result += " class='" + className + "'";
    }
    if (attributes != undefined && attributes != null) {
        try {
            if (attributes.length != 0) {
                let attributeInjection = " " + attributes.join(" ");
                result += attributeInjection;
            }
        }
        catch (e) {
            debug("Caught exception in `newDiv` with attributes arg: " +
                attributes.toString());
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
function generateElementHtml(element) {
    let className = getElementClass(element);
    let detailsDiv = addLocationLinks(htmlDetails(element));
    let imageDivAttributes = [];
    if (detailsDiv == "") {
        imageDivAttributes = ["style='margin:auto;'"];
    }
    let imageDiv = newDiv("newsfeed-element-segment-image", [htmlImage(element)], imageDivAttributes);
    let elements = [
        newDiv("newsfeed-element-segment-header", [
            htmlHeader(element, htmlDisclaimer(element, className)),
            htmlDateSection(element),
        ]),
        newDiv("newsfeed-element-segment-body", [imageDiv, detailsDiv]),
        htmlFooter(element),
    ];
    return newDiv(className, elements);
}
/**
 * Replaces location substrings with links to the locations
 */
function addLocationLinks(html) {
    let result = html;
    // Thank you javascript for being dynamic:
    if (locationLookupTable == undefined ||
        typeof locationLookupTable != "object") {
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
        lookupObject.names.forEach((name) => {
            // I really like that string.replace("toReplace", "replaceWith") only replaces
            // the first occurrence - really nice of Javascript to do that!
            let toReplace = new RegExp(name, "g");
            let replaceWith = "<a href='" + id + "'>" + name + "</a>";
            result = result.replace(toReplace, replaceWith);
        });
    }
    return result;
}
