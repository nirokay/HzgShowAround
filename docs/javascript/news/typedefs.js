"use strict";
const urlRemoteRepository = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/";
// Date stuff:
const dayMilliseconds = 86400000;
const weekMilliseconds = dayMilliseconds * 7;
const monthMilliseconds = weekMilliseconds * 4;
const dateFormatDisplay = {
    weekday: "long",
    day: "2-digit",
    month: "2-digit",
    year: "numeric"
};
let relevancyLookIntoFuture = monthMilliseconds * 2;
let relevancyLookIntoPast = monthMilliseconds;
const urlRemoteNews = urlRemoteRepository + "news.json";
class NewsFeedElement {
    constructor() {
        this.name = "Neuigkeit";
        this.level = "info"; // Importance as string
        this.importance = 0; // Importance as number
        this.isHappening = false;
        this.locations = [];
    }
}
const urlRemoteHealthPresentations = urlRemoteRepository + "news-health.json";
class HealthPresentation {
    constructor() {
        this.topic = "Gesundheitsbildung: Präsentation";
    }
}
const urlHolidayApi = "https://feiertage-api.de/api/?nur_land=BY";
const holidaysToIgnore = [
    "Augsburger Friedensfest"
];
function getUrlSchoolHolidayApi(year) {
    return "https://ferien-api.maxleistner.de/api/v1/" + year.toString() + "/BY/";
}
class SchoolHoliday {
    constructor() {
        this.start = "1970-01-01T00:00Z";
        this.end = "1970-01-01T00:00Z";
        this.year = 1970;
        this.stateCode = "BY";
        this.name = "Unbekannte Ferien";
        this.slug = "unbekannte_ferien-1970-BY";
    }
}
function healthPresentationToNewsfeedElement(presentation) {
    var _a, _b;
    if (presentation.COMMENT != undefined) {
        return null;
    }
    if (presentation.topic == "?") {
        return null;
    }
    let result = new NewsFeedElement;
    result.name = "Gesundheitsbildung: <q>" + presentation.topic + "</q>";
    result.on = (_a = presentation.on) !== null && _a !== void 0 ? _a : getToday();
    result.level = "info";
    result.locations = ["Am Latterbach Haus 13"];
    (_b = presentation.desc) !== null && _b !== void 0 ? _b : (presentation.desc = presentation.topic);
    result.details = [
        "von <time datetime='" + presentation.on + " 13:00'>13.00 - 14.00 Uhr</time> im <b>Festsaal</b>",
        "zum Thema <q>" + presentation.desc + "</q>"
    ];
    if (presentation.by != undefined) {
        result.details.push("<small>Geleitet von " + presentation.by + "</small>");
    }
    return result;
}
function healthPresentationsToNewsfeedElements(presentations) {
    let result = [];
    presentations.forEach(presentation => {
        let converted = healthPresentationToNewsfeedElement(presentation);
        if (converted == null) {
            return;
        }
        result.push(converted);
    });
    return result;
}
function holidaysToNewsfeedElements(holidays) {
    let result = [];
    for (const [name, details] of Object.entries(holidays)) {
        // Skip some holidays:
        if (holidaysToIgnore.indexOf(name) > -1) {
            continue;
        }
        let event = new NewsFeedElement;
        event.name = "Feiertag: <q>" + name + "</q>";
        event.on = details.datum;
        event.level = "holiday";
        result.push(event);
    }
    return result;
}
function schoolHolidayToNewsfeedElement(holiday) {
    let result = new NewsFeedElement;
    result.level = "holiday";
    // Start and end dates:
    let startDate = "1970-01-01";
    let endDate = "1970-01-01";
    try {
        startDate = holiday.start.split("T")[0];
        endDate = holiday.end.split("T")[0];
    }
    catch (error) {
        debug("Failed to convert school holiday", error);
    }
    // Shift end date one day back (API returns midnight of the next working day):
    try {
        let unix = Date.parse(endDate).valueOf();
        unix -= dayMilliseconds + 1;
        let dayBefore = new Date(unix);
        let parts = dayBefore.toLocaleDateString("de-DE").split(".");
        endDate = parts[2] + "-" + parts[1] + "-" + parts[0]; // ignore this beauty
    }
    catch (error) {
        debug("Failed to shift day back", error);
    }
    if (startDate == endDate) {
        // This is a workaround for "Buß- und Bettag":
        return null;
    }
    result.from = startDate;
    result.till = endDate;
    // Name:
    try {
        result.name = "Ferien: <q>" + holiday.name[0].toUpperCase() + holiday.name.substring(1).toLowerCase() + "</q>";
    }
    catch (error) {
        result.name = "Ferien: " + holiday.name;
        debug("Failed to rename holiday", error);
    }
    return result;
}
function schoolHolidaysToNewsfeedElements(holidays) {
    let result = [];
    holidays.forEach(holiday => {
        let converted = schoolHolidayToNewsfeedElement(holiday);
        if (converted == null) {
            return;
        }
        result.push(converted);
    });
    return result;
}
/**
 * Normalizes an element, so all fields are occupied
 */
function normalizedElement(news, element) {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    // Disregard comments:
    if (element.COMMENT != undefined) {
        return null;
    }
    // Begin construction:
    let result = new NewsFeedElement();
    let date = new Date();
    // Single-day events:
    if (element.on != undefined) {
        result.on = element.on;
        result.from = element.on;
        result.till = element.on;
    }
    // Correct wrongly formatted event dates:
    if (element.on == undefined) {
        if (element.from == undefined && element.till != undefined) {
            // Forgot to assign `from`:
            result.from = element.till;
        }
        else if (element.from != undefined && element.till == undefined) {
            // Forgot to assign `till`:
            result.till = element.from;
        }
        else if (element.from == undefined && element.till == undefined) {
            // Wtf happened here??
            result.from = "*-01-01";
            result.till = "*-12-31";
            result.runtimeAdditionalMessage = "Fehlendes Datum, wird als ganzjährig angezeigt!";
        }
        else {
            result.from = element.from;
            result.till = element.till;
        }
    }
    // Single-day event:
    if (result.on == undefined && result.from == result.till) {
        result.on = result.from;
    }
    // Other missing fields:
    result.name = (_a = element.name) !== null && _a !== void 0 ? _a : "Neuigkeit";
    result.level = (_b = element.level) !== null && _b !== void 0 ? _b : "info";
    // Details fixes:
    switch (typeof (element.details)) {
        case "string":
        case "number":
            // Forgot to make it an array, oops:
            result.details = [element.details];
            break;
        case "undefined":
            // Forgot to add it, no big deal, i will do it for you:
            result.details = [];
            break;
        case "object":
            // Expected result:
            result.details = element.details;
            break;
        default:
            debug("Element details field is weird...", element);
            result.details = [];
    }
    // Prevent empty links, apply link if not empty:
    if (typeof (element.info) != "string") {
        result.info = undefined;
    }
    else if (element.info === "") {
        result.info = undefined;
    }
    else {
        result.info = element.info;
    }
    // Location IDs:
    result.locations = element.locations;
    // Add importance:
    result.importance = getImportance(element);
    // Who cares about performance anyways? Here the browser will do work, that will be probably discarded.
    // You cannot do anything about it, the browser runtime is MY bitch.
    {
        let from = (_d = (_c = result.from) !== null && _c !== void 0 ? _c : result.on) !== null && _d !== void 0 ? _d : "";
        let till = (_f = (_e = result.till) !== null && _e !== void 0 ? _e : result.on) !== null && _f !== void 0 ? _f : "";
        if (from.includes("*") || till.includes("*")) {
            // Duplicates the event for the next and previous year
            let year = date.getFullYear();
            function duplicate(offset) {
                let e = result;
                let y = year + offset;
                e.from = from.replace("\*", y.toString());
                e.till = till.replace("\*", y.toString());
                return e;
            }
            news.push(duplicate(1));
            news.push(duplicate(-1));
        }
    }
    // Is happening now:
    if (Date.parse((_g = result.from) !== null && _g !== void 0 ? _g : "") <= date.getTime() &&
        Date.parse((_h = result.till) !== null && _h !== void 0 ? _h : "") + dayMilliseconds >= date.getTime()) {
        result.isHappening = true;
    }
    else {
        result.isHappening = false;
    }
    // Finally done:
    // debug(result);
    return result;
}
/**
 * Normalizes elements, so all fields are occupied
 */
function normalizedElements(news) {
    let result = [];
    if (!Array.isArray(news)) {
        debug("News array is not an array", news);
        return [];
    }
    news.forEach((element) => {
        let newElement = normalizedElement(news, element);
        if (newElement == null) {
            return;
        }
        result.push(newElement);
    });
    return result;
}
/**
 * Gets todays timestamp
 */
function getToday() {
    let date = new Date;
    debug("Generating todays date.");
    return date.getFullYear().toString() + "-" + date.getMonth().toString() + "-" + date.getDate().toString();
}
function normalizeTime(time, offset = 0) {
    let date = new Date;
    let year = date.getFullYear() + offset;
    return time.replace("\*", year.toString());
}
/**
 * Gets the numerical importance of an event
 */
function getImportance(element) {
    var _a, _b, _c;
    let result = 0;
    switch (element.level) {
        case "alert":
        case "achtung":
        case "alarm":
            result = 20;
            break;
        case "warning":
        case "warn":
        case "warnung":
            result = 10;
            break;
        case "holiday":
        case "feiertag":
            result = -5;
            break;
        case "happened":
            // this should never be triggered
            result = -10;
            break;
        case "info":
            result = 0;
            break;
        default:
            debug("Weird importance level of '" + element.level + "' in element (using default)", element);
            break;
    }
    // Special case, if the event occurred in the past:
    let date = new Date;
    let till = (_c = (_b = (_a = element.till) !== null && _a !== void 0 ? _a : element.on) !== null && _b !== void 0 ? _b : element.from) !== null && _c !== void 0 ? _c : getToday();
    if (Date.parse(normalizeTime(till)) + dayMilliseconds < date.getTime()) {
        result = -10;
    }
    element.importance = result;
    return result;
}
/**
 * Gets the Css class of an event
 */
function getElementClass(element) {
    const classPrefix = "newsfeed-element-";
    let classSuffix = "generic";
    switch (getImportance(element)) {
        case 20:
            classSuffix = "alert";
            break;
        case 10:
            classSuffix = "warning";
            break;
        case 0:
            classSuffix = "generic";
            break;
        case -5:
            classSuffix = "holiday";
            break;
        case -10:
            classSuffix = "happened";
            break;
        default:
            debug("Weird importance encountered in element, using default.", element);
            break;
    }
    return classPrefix + classSuffix;
}
/**
 * Determines if the event is relevant based on its time
 */
function isElementRelevant(element) {
    var _a, _b;
    if (typeof (element) != "object" || element == null) {
        debug("Element relevancy failed, not an object or is null", element);
        return false;
    }
    let date = new Date;
    // Filters irrelevant news:
    let unixFrom = Date.parse((_a = element.from) !== null && _a !== void 0 ? _a : getToday());
    let unixTill = Date.parse((_b = element.till) !== null && _b !== void 0 ? _b : getToday()) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return (unixNow - relevancyLookIntoPast <= unixTill &&
        unixNow + relevancyLookIntoFuture >= unixFrom);
}
/**
 * Filters all events by relevancy (see function `isElementRelevant`)
 */
function getFilteredNews(news) {
    let result = [];
    if (typeof (news) != "object" || news == null) {
        debug("News is not an object or is null", news);
        return [];
    }
    news.forEach((element) => {
        if (isElementRelevant(element)) {
            result.push(element);
        }
    });
    return result;
}
/**
 * Sorts events based on their time and then importance
 */
function sortedElementsByDateAndRelevancy(news) {
    if (typeof (news) != "object" || news == null) {
        debug("Passed news for sorting by date and relevancy was not an object or is null.", news);
        return [];
    }
    // Date:
    news.sort((a, b) => {
        var _a, _b;
        return Date.parse((_a = a.from) !== null && _a !== void 0 ? _a : getToday()) - Date.parse((_b = b.from) !== null && _b !== void 0 ? _b : getToday());
    });
    // Importance:
    news.sort((a, b) => {
        // Normal sorting
        // return (b.importance ?? -99) - (a.importance ?? -99);
        var _a, _b;
        // Actually wtf, anyways: puts "happened" events (-10) to the bottom, puts everything else in place (already sorted by date)
        return (((_a = b.importance) !== null && _a !== void 0 ? _a : -99) > -10 ? 0 : -1) - (((_b = a.importance) !== null && _b !== void 0 ? _b : -99) > -10 ? 0 : -1);
    });
    return news;
}
function displayTime(time) {
    let d = new Date(Date.parse(time));
    return "<time datetime='" + time + "'>" + d.toLocaleString("de-DE", dateFormatDisplay) + "</time>";
}
