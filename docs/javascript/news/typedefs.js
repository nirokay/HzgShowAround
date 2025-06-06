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
    year: "numeric",
};
let relevancyLookIntoFuture = monthMilliseconds * 2;
let relevancyLookIntoPast = monthMilliseconds;
const urlRemoteNews = urlRemoteRepository + "news.json";
var EventType;
(function (EventType) {
    EventType[EventType["fullDay"] = 0] = "fullDay";
    EventType[EventType["timeSpan"] = 1] = "timeSpan";
})(EventType || (EventType = {}));
class NewsFeedElement {
    name = "Neuigkeit";
    // Display time:
    on;
    from;
    till;
    // ICal times:
    icalEventType = EventType.timeSpan;
    icalDateStart = "19700101";
    icalDateEnd = "19700101";
    icalTimeStart = "000000";
    icalTimeEnd = "235959";
    level = "info"; // Importance as string
    importance = 0; // Importance as number
    details; // Description
    image; // Image
    info; // URL to external resource
    isHappening = false;
    locations = [];
    runtimeAdditionalMessage;
    COMMENT;
}
const urlRemoteHealthPresentations = urlRemoteRepository + "news-health.json";
class HealthPresentation {
    topic = "Gesundheitsbildung: Präsentation";
    desc;
    on;
    by;
    required;
    COMMENT;
}
class Holiday {
    name; // Empty when fetching, will be set right after
    datum;
    hinweis;
    constructor(name, datum, hinweis) {
        this.name = name;
        this.datum = datum;
        this.hinweis = hinweis;
    }
}
function getUrlHolidayApi(year) {
    return "https://feiertage-api.de/api/?nur_land=BY&jahr=" + year.toString();
}
const holidaysToIgnore = ["Augsburger Friedensfest"];
function getUrlSchoolHolidayApi(year) {
    return ("https://ferien-api.maxleistner.de/api/v1/" + year.toString() + "/BY/");
}
class SchoolHoliday {
    start = "1970-01-01T00:00Z";
    end = "1970-01-01T00:00Z";
    year = 1970;
    stateCode = "BY";
    name = "Unbekannte Ferien";
    slug = "unbekannte_ferien-1970-BY";
}
function healthPresentationToNewsfeedElement(presentation) {
    if (presentation.COMMENT != undefined)
        return null;
    if (presentation.topic == "?")
        return null;
    let result = new NewsFeedElement();
    result.name = "Gesundheitsbildung: <q>" + presentation.topic + "</q>";
    result.from = (presentation.on ?? getToday()) + " 13:00";
    result.till = (presentation.on ?? getToday()) + " 14:30";
    result.level = "info";
    result.locations = ["Am Latterbach Haus 13"];
    result.image = "newsfeed/icons/presentation.svg";
    presentation.desc ??= presentation.topic;
    result.details = [
        "von <time datetime='" +
            presentation.on +
            " 13:00'>13.00 - 14.00/14.30 Uhr</time> im <b>Festsaal</b>",
        "zum Thema <q>" + presentation.desc + "</q>",
    ];
    if (presentation.by != undefined)
        result.details.push("<small>Geleitet von " + presentation.by + "</small>");
    if (presentation.required != undefined && presentation.required === true)
        result.details.push("<small><i>⚠️ Dieser Vortrag ist verpflichtend für Anwohner von Am Latterbach Häuser 16 und 18 und Am Latterbach Haus 14.</i></small>");
    result.icalEventType = EventType.timeSpan;
    return result;
}
function healthPresentationsToNewsfeedElements(presentations) {
    let result = [];
    presentations.forEach((presentation) => {
        let converted = healthPresentationToNewsfeedElement(presentation);
        if (converted == null) {
            return;
        }
        result.push(converted);
    });
    return result;
}
function holidayToNewsfeedElement(holiday) {
    // Ignore some irrelevant holidays:
    if (holidaysToIgnore.indexOf(holiday.name ?? "") > -1) {
        return null;
    }
    // Build `NewsFeedElement`:
    let element = new NewsFeedElement();
    element.name = "Feiertag: <q>" + holiday.name + "</q>";
    element.on = holiday.datum;
    element.level = "holiday";
    // Icon:
    element.image = "newsfeed/icons/holidays.svg";
    return element;
}
function holidaysToNewsfeedElements(holidays) {
    let result = [];
    holidays.forEach((holiday) => {
        let element = holidayToNewsfeedElement(holiday);
        if (element != null) {
            result.push(element);
        }
    });
    return result;
}
function schoolHolidayToNewsfeedElement(holiday) {
    let result = new NewsFeedElement();
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
        result.name =
            "Ferien: <q>" +
                holiday.name[0].toUpperCase() +
                holiday.name.substring(1).toLowerCase() +
                "</q>";
    }
    catch (error) {
        result.name = "Ferien: " + holiday.name;
        debug("Failed to rename holiday", error);
    }
    // Icon:
    result.image = "newsfeed/icons/holidays-school.svg";
    return result;
}
function schoolHolidaysToNewsfeedElements(holidays) {
    let result = [];
    holidays.forEach((holiday) => {
        let converted = schoolHolidayToNewsfeedElement(holiday);
        if (converted == null) {
            return;
        }
        result.push(converted);
    });
    return result;
}
function getIcalTimeFromParts(input) {
    let result = input;
    while (result.length < 3) {
        result.push("00");
    }
    result.forEach((number, index) => {
        result[index] = formatNumber(number);
    });
    return result.join("");
}
/**
 * Normalizes an element, so all fields are occupied
 */
function normalizedElement(news, element) {
    // Disregard comments:
    if (element.COMMENT != undefined)
        return null;
    // Begin construction:
    let result = new NewsFeedElement();
    let date = new Date();
    let fromTimes = element.from == undefined ? [] : element.from.split(" ");
    let tillTimes = element.till == undefined ? [] : element.till.split(" ");
    // Single-day events:
    if (element.on != undefined) {
        result.on = element.on;
        result.from = element.on;
        result.till = element.on;
    }
    // Correct wrongly formatted event dates:
    if (element.on == undefined) {
        if (fromTimes[0] == undefined && tillTimes[0] != undefined) {
            // Forgot to assign `from`:
            result.from = tillTimes[0];
        }
        else if (fromTimes[0] != undefined && tillTimes[0] == undefined) {
            // Forgot to assign `till`:
            result.till = fromTimes[0];
        }
        else if (fromTimes[0] == undefined && tillTimes[0] == undefined) {
            // Wtf happened here??
            result.from = "*-01-01";
            result.till = "*-12-31";
            result.runtimeAdditionalMessage =
                "Fehlendes Datum, wird als ganzjährig angezeigt!";
        }
        else {
            result.from = fromTimes[0];
            result.till = tillTimes[0];
        }
    }
    // Single-day event:
    if (result.on == undefined && result.from == result.till) {
        result.on = result.from;
    }
    // Parsing Times:
    let timeStartParts = getIcalTimeFromParts((fromTimes[1] ?? "00:00").split(":"));
    let timeEndParts = getIcalTimeFromParts((tillTimes[1] ?? "00:00").split(":"));
    // Populating ical fields:
    result.icalTimeStart = timeStartParts ?? "000000";
    result.icalTimeEnd = timeEndParts ?? "000000";
    if (result.icalTimeStart == "000000" &&
        (result.icalTimeEnd == "000000" || result.icalTimeEnd == "235959")) {
        result.icalEventType = EventType.fullDay;
    }
    // Other missing fields:
    result.name = element.name ?? "Neuigkeit";
    result.level = element.level ?? "info";
    result.image = element.image ?? "";
    // Details fixes:
    switch (typeof element.details) {
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
    if (typeof element.info != "string") {
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
    // Default images:
    if (result.image == "") {
        switch (getImportance(element)) {
            case 20:
                // Alerts without image:
                result.image = "newsfeed/icons/generic-alert.svg";
                break;
            case 10:
                // Warnings without image:
                result.image = "newsfeed/icons/generic-warning.svg";
                break;
            default:
                break;
        }
    }
    // Who cares about performance anyways? Here the browser will do work, that will be probably discarded.
    // You cannot do anything about it, the browser runtime is MY bitch.
    {
        let from = result.from ?? result.on ?? "";
        let till = result.till ?? result.on ?? "";
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
    if (Date.parse(result.from ?? "") <= date.getTime() &&
        Date.parse(result.till ?? "") + dayMilliseconds >= date.getTime()) {
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
    let date = new Date();
    debug("Generating todays date.");
    return (date.getFullYear().toString() +
        "-" +
        date.getMonth().toString() +
        "-" +
        date.getDate().toString());
}
function normalizeTime(time, offset = 0) {
    let date = new Date();
    let year = date.getFullYear() + offset;
    return time.replace("\*", year.toString());
}
/**
 * Gets the numerical importance of an event
 */
function getImportance(element) {
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
            debug("Weird importance level of '" +
                element.level +
                "' in element (using default)", element);
            break;
    }
    // Special case, if the event occurred in the past:
    let date = new Date();
    let till = element.till ?? element.on ?? element.from ?? getToday();
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
    const classPrefix = "newsfeed-element-relevancy-";
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
    return "newsfeed-element " + classPrefix + classSuffix;
}
/**
 * Determines if the event is relevant based on its time
 */
function isElementRelevant(element) {
    if (typeof element != "object" || element == null) {
        debug("Element relevancy failed, not an object or is null", element);
        return false;
    }
    let date = new Date();
    // Filters irrelevant news:
    let unixFrom = Date.parse(element.from ?? getToday());
    let unixTill = Date.parse(element.till ?? getToday()) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return (unixNow - relevancyLookIntoPast <= unixTill &&
        unixNow + relevancyLookIntoFuture >= unixFrom);
}
/**
 * Filters all events by relevancy (see function `isElementRelevant`)
 */
function getFilteredNews(news) {
    let result = [];
    if (typeof news != "object" || news == null) {
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
    if (typeof news != "object" || news == null) {
        debug("Passed news for sorting by date and relevancy was not an object or is null.", news);
        return [];
    }
    // Date:
    news.sort((a, b) => {
        return (Date.parse(a.from ?? getToday()) - Date.parse(b.from ?? getToday()));
    });
    // Importance:
    news.sort((a, b) => {
        // Normal sorting
        // return (b.importance ?? -99) - (a.importance ?? -99);
        // Actually wtf, anyways: puts "happened" events (-10) to the bottom, puts everything else in place (already sorted by date)
        return (((b.importance ?? -99) > -10 ? 0 : -1) -
            ((a.importance ?? -99) > -10 ? 0 : -1));
    });
    return news;
}
function displayTime(time) {
    let d = new Date(Date.parse(time));
    return ("<time datetime='" +
        time +
        "'>" +
        d.toLocaleString("de-DE", dateFormatDisplay) +
        "</time>");
}
