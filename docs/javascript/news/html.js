"use strict";
const urlLocationLookupTable = "https://raw.githubusercontent.com/nirokay/HzgShowAround/master/docs/resources/location_lookup.json";
let locationLookupTable = {};
async function getLocationLookupTable() {
    try {
        let response = await fetch(urlLocationLookupTable);
        let raw = await response.text();
        locationLookupTable = JSON.parse(raw);
        debug("Got locationLookupTable!", locationLookupTable);
    }
    catch (error) {
        debug("Could not fetch or parse location lookup table", error);
        locationLookupTable = {};
    }
}
getLocationLookupTable();
/**
 * Adds a disclaimer to the title (called by `htmlHeader` function)
 */
function htmlDisclaimer(element, cssClass) {
    let result = [];
    if (cssClass.endsWith("happened")) {
        result.push("Event vergangen");
    }
    if (element.isHappening) {
        result.push("<b>Heute!</b>");
    }
    return result.length == 0 ? "" : "<small>(" + result.join(", ") + ")</small>";
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
    return "<h3 style='margin-bottom:2px;'>" + element.name + text + "</h3>";
}
/**
 * Generates the date section
 */
function htmlDateSection(element) {
    var _a, _b;
    const from = displayTime((_a = element.from) !== null && _a !== void 0 ? _a : "?");
    const till = displayTime((_b = element.till) !== null && _b !== void 0 ? _b : "?");
    let result = "";
    if (from == till) {
        result = "am " + from;
    }
    else {
        result = "von " + from + " bis " + till;
    }
    return "<small class='generic-center'>" + result + "</small>";
}
/**
 * Generates the details/description section
 */
function htmlDetails(element) {
    var _a;
    let lines = [];
    let url = element.info;
    // Entire description:
    lines = (_a = element.details) !== null && _a !== void 0 ? _a : [];
    let result = "<p>" + lines.join("<br />") + "</p>";
    // Adds a little "more infos" link at the bottom:
    if (url != undefined && url != "") {
        result += "<p class='generic-center'><a href='" + url + "'>mehr Infos</a></p>";
    }
    return result;
}
/**
 * Generates the HTML for the entire element
 */
function generateElementHtml(element) {
    let className = getElementClass(element);
    let elements = [
        htmlHeader(element, htmlDisclaimer(element, className)),
        htmlDateSection(element),
        htmlDetails(element)
    ];
    return "<div class='" + className + "'>" + elements.join("") + "</div>";
}
/**
 * Replaces location substrings with links to the locations
 */
function addLocationLinks(html) {
    let result = html;
    // Thank you javascript for being dynamic:
    if (locationLookupTable == undefined || typeof (locationLookupTable) != "object") {
        return result;
    }
    if (Object.keys(locationLookupTable).length == 0) {
        return result;
    }
    // Highly efficient code to replace substrings with, I do not want to go into
    // detail on how great nested loops are :)
    for (const [_name, lookupObject] of Object.entries(locationLookupTable)) {
        if (typeof (lookupObject) != "object") {
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
