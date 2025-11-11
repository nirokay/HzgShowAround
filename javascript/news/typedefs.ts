const urlRemoteRepository: string =
    "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/";

// Date stuff:
const dayMilliseconds: number = 86400000;
const weekMilliseconds: number = dayMilliseconds * 7;
const monthMilliseconds: number = weekMilliseconds * 4;
const dateFormatDisplay: Intl.DateTimeFormatOptions = {
    weekday: "long",
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
};

let relevancyLookIntoFuture: number = monthMilliseconds * 3;
let relevancyLookIntoPast: number = monthMilliseconds;

const urlRemoteNewsLegacy: string = urlRemoteRepository + "news.json";
const urlRemoteNewsRepeat: string = urlRemoteRepository + "news-repeat.json";
function urlRemoteNewsYear(year: number): string {
    return urlRemoteRepository + "news-" + year.toString() + ".json";
}
enum EventType {
    fullDay,
    timeSpan,
}
class NewsEventTime {
    on?: string;
    from?: string;
    till?: string;

    // ICal times:
    icalEventType: EventType = EventType.timeSpan;
    icalDateStart: string = "19700101";
    icalDateEnd: string = "19700101";
    icalTimeStart: string = "000000";
    icalTimeEnd: string = "235959";
}
function newTimeSpan(from: string, till: string): NewsEventTime {
    let result = new NewsEventTime();
    result.from = from;
    result.till = till;
    return result;
}
class NewsFeedElement {
    name: string = "Neuigkeit";

    // Display time:
    on?: string;
    from?: string;
    till?: string;
    times?: NewsEventTime[];

    level: string = "info"; // Importance as string
    importance: number = 0; // Importance as number
    details?: string[]; // Description
    image?: string; // Image
    info?: string; // URL to external resource
    isHappening: boolean = false;
    locations: string[] = [];
    runtimeAdditionalMessage?: string;

    COMMENT?: string;
}

const IMPORTANCE_ALERT = 20;
const IMPORTANCE_WARNING = 10;
const IMPORTANCE_DEFAULT = 0;
const IMPORTANCE_HOLIDAY = -5;
const IMPORTANCE_HAPPENED = -10;

const urlRemoteHealthPresentations: string =
    urlRemoteRepository + "news-health.json";
class HealthPresentation {
    topic: string = "Gesundheitsbildung: Präsentation";
    desc?: string;
    on?: string;
    by?: string;
    required?: boolean;

    COMMENT?: string;
}

class Holiday {
    name?: string; // Empty when fetching, will be set right after
    datum?: string;
    hinweis?: string;

    constructor(name: string, datum: string, hinweis: string) {
        this.name = name;
        this.datum = datum;
        this.hinweis = hinweis;
    }
}
interface HolidayResponse {
    [key: string]: Holiday;
}
function getUrlHolidayApi(year: number): string {
    return "https://feiertage-api.de/api/?nur_land=BY&jahr=" + year.toString();
}
const holidaysToIgnore: string[] = ["Augsburger Friedensfest"];

function getUrlSchoolHolidayApi(year: number): string {
    return (
        "https://ferien-api.maxleistner.de/api/v1/" + year.toString() + "/BY/"
    );
}
class SchoolHoliday {
    start: string = "1970-01-01T00:00Z";
    end: string = "1970-01-01T00:00Z";
    year: Number = 1970;
    stateCode: string = "BY";
    name: string = "Unbekannte Ferien";
    slug: string = "unbekannte_ferien-1970-BY";
}

function healthPresentationToNewsfeedElement(
    presentation: HealthPresentation,
): NewsFeedElement | null {
    if (presentation.COMMENT != undefined) return null;
    if (presentation.topic == "?") return null;
    let result = new NewsFeedElement();

    result.name = "Gesundheitsbildung: <q>" + presentation.topic + "</q>";
    result.times = [
        newTimeSpan(
            (presentation.on ?? getToday()) + " 13:00",
            (presentation.on ?? getToday()) + " 14:30",
        ),
    ];
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
        result.details.push(
            "<small>Geleitet von " + presentation.by + "</small>",
        );
    if (presentation.required != undefined && presentation.required === true)
        result.details.push(
            "<small><i>⚠️ Dieser Vortrag ist verpflichtend für Anwohner von Am Latterbach Häuser 16 und 18 und Am Latterbach Haus 14.</i></small>",
        );

    // result.icalEventType = EventType.timeSpan;
    return result;
}
function healthPresentationsToNewsfeedElements(
    presentations: HealthPresentation[],
): NewsFeedElement[] {
    let result: NewsFeedElement[] = [];
    presentations.forEach((presentation) => {
        let converted: NewsFeedElement | null =
            healthPresentationToNewsfeedElement(presentation);
        if (converted == null) {
            return;
        }
        result.push(converted);
    });
    return result;
}

function holidayToNewsfeedElement(holiday: Holiday): NewsFeedElement | null {
    // Ignore some irrelevant holidays:
    if (holidaysToIgnore.indexOf(holiday.name ?? "") > -1) {
        return null;
    }
    // Build `NewsFeedElement`:
    let element = new NewsFeedElement();
    let time = new NewsEventTime();
    time.on = holiday.datum;

    element.name = "Feiertag: <q>" + holiday.name + "</q>";
    element.on = holiday.datum;
    element.times = [time];
    element.level = "holiday";

    // Icon:
    element.image = "newsfeed/icons/holidays.svg";

    return element;
}
function holidaysToNewsfeedElements(holidays: Holiday[]): NewsFeedElement[] {
    let result: NewsFeedElement[] = [];
    holidays.forEach((holiday) => {
        let element: NewsFeedElement | null = holidayToNewsfeedElement(holiday);
        if (element != null) {
            result.push(element);
        }
    });
    return result;
}

function schoolHolidayToNewsfeedElement(
    holiday: SchoolHoliday,
): NewsFeedElement | null {
    let result = new NewsFeedElement();
    result.level = "holiday";

    // Start and end dates:
    let startDate: string = "1970-01-01";
    let endDate: string = "1970-01-01";
    try {
        startDate = holiday.start.split("T")[0];
        endDate = holiday.end.split("T")[0];
    } catch (error) {
        debug("Failed to convert school holiday", error);
    }
    // Shift end date one day back (API returns midnight of the next working day):
    try {
        let unix: number = Date.parse(endDate).valueOf();
        unix -= dayMilliseconds + 1;
        let dayBefore: Date = new Date(unix);
        let parts: string[] = dayBefore.toLocaleDateString("de-DE").split(".");
        endDate = parts[2] + "-" + parts[1] + "-" + parts[0]; // ignore this beauty
    } catch (error) {
        debug("Failed to shift day back", error);
    }
    if (startDate == endDate) {
        // This is a workaround for "Buß- und Bettag":
        return null;
    }

    result.times = [newTimeSpan(startDate, endDate)];

    // Name:
    try {
        result.name =
            "Ferien: <q>" +
            holiday.name[0].toUpperCase() +
            holiday.name.substring(1).toLowerCase() +
            "</q>";
    } catch (error) {
        result.name = "Ferien: " + holiday.name;
        debug("Failed to rename holiday", error);
    }

    // Icon:
    result.image = "newsfeed/icons/holidays-school.svg";

    return result;
}
function schoolHolidaysToNewsfeedElements(
    holidays: SchoolHoliday[],
): NewsFeedElement[] {
    let result: NewsFeedElement[] = [];
    holidays.forEach((holiday) => {
        let converted: NewsFeedElement | null =
            schoolHolidayToNewsfeedElement(holiday);
        if (converted == null) {
            return;
        }
        result.push(converted);
    });
    return result;
}

function getIcalTimeFromParts(input: string[]): string {
    let result: string[] = input;
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
function normalizedElement(
    news: NewsFeedElement[],
    element: NewsFeedElement,
): NewsFeedElement | null {
    // Disregard comments:
    if (element.COMMENT != undefined) return null;

    // Begin construction:
    let result: NewsFeedElement = new NewsFeedElement();
    result.times = element.times ?? [];
    let date: Date = new Date();

    // Legacy time stuff (not really legacy but yeah):
    if (
        element.from != undefined ||
        element.till != undefined ||
        element.on != undefined
    ) {
        let time = new NewsEventTime();
        time.on = element.on;
        time.from = element.from;
        time.till = element.till;
        result.times.push(time);
    }
    // No longer needed:
    result.on = undefined;
    result.from = undefined;
    result.till = undefined;

    // Parsing Times:
    result.times.forEach((time, index) => {
        if (result.times == undefined) result.times = []; // should not happen, however this makes the compiler happy

        // Single-day events with 'on':
        if (time.on != undefined) {
            time.from = time.on;
            time.till = time.on;
        }

        let partsStart: string[] = (time.on ?? time.from ?? "1970-01-01").split(
            " ",
        );
        let partsEnd: string[] = (time.on ?? time.till ?? "1970-12-31").split(
            " ",
        );
        let timeStartParts: string = getIcalTimeFromParts(
            (partsStart[1] ?? "00:00").split(":"),
        );
        let timeEndParts: string = getIcalTimeFromParts(
            (partsEnd[1] ?? "00:00").split(":"),
        );

        // Populating ical fields:
        time.icalTimeStart = timeStartParts ?? "000000";
        time.icalTimeEnd = timeEndParts ?? "000000";
        if (
            time.icalTimeStart == "000000" &&
            (time.icalTimeEnd == "000000" || time.icalTimeEnd == "235959")
        ) {
            time.icalEventType = EventType.fullDay;
        } else {
            time.icalEventType = EventType.timeSpan;
        }

        if (time.till == undefined && time.from == undefined) {
        }

        result.times[index] = time;
    });

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
    } else if (element.info === "") {
        result.info = undefined;
    } else {
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

    // Is happening today:
    result.isHappening = false;
    result.times.forEach((time) => {
        if (result.isHappening) return;
        if (
            Date.parse(time.from ?? "") <= date.getTime() &&
            Date.parse(time.till ?? "") + dayMilliseconds >= date.getTime()
        ) {
            result.isHappening = true;
        }
    });

    // Who cares about performance anyways? Here the browser will do work, that will be probably discarded.
    // You cannot do anything about it, the browser runtime is MY bitch.
    let containsStars: boolean = false;
    result.times.forEach((time) => {
        if (containsStars) return;
        if (
            time.on?.includes("*") ||
            time.from?.includes("*") ||
            time.till?.includes("*")
        )
            containsStars = true;
    });
    if (containsStars) {
        let y = date.getFullYear();
        [y - 1, y, y + 1].forEach((year) => {
            let borrowed = result;
            if (borrowed.times == undefined) borrowed.times = []; // should not happen, makes the compiler happy
            borrowed.times.forEach((time, index) => {
                // Skip if no stars included (also wtf does my formatter do here?!):
                if (
                    !time.on?.includes("*") ||
                    !time.from?.includes("*") ||
                    !time.till?.includes("*")
                )
                    return;

                // Replace values with year variable:
                if (time.on != undefined)
                    time.on = time.on.replace("*", year.toString());
                if (time.from != undefined)
                    time.from = time.from.replace("*", year.toString());
                if (time.till != undefined)
                    time.till = time.till.replace("*", year.toString());

                if (borrowed.times == undefined) borrowed.times = []; // why does TS need this AGAIN??
                borrowed.times[index] = time;
            });

            news.push(borrowed);
        });
        return null; // remove this event (already duplicated into news array)
    }

    // Finally done:
    // debug(result);
    return result;
}

/**
 * Normalizes elements, so all fields are occupied
 */
function normalizedElements(news: NewsFeedElement[]): NewsFeedElement[] {
    let result: NewsFeedElement[] = [];

    if (!Array.isArray(news)) {
        debug("News array is not an array", news);
        return [];
    }
    news.forEach((element) => {
        let newElement: NewsFeedElement | null = normalizedElement(
            news,
            element,
        );
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
function getToday(): string {
    let date: Date = new Date();
    debug("Generating todays date.");
    return (
        date.getFullYear().toString() +
        "-" +
        date.getMonth().toString() +
        "-" +
        date.getDate().toString()
    );
}

function normalizeTime(time: string, offset: number = 0) {
    let date: Date = new Date();
    let year: number = date.getFullYear() + offset;
    return time.replace("\*", year.toString());
}

/**
 * Gets the numerical importance of an event
 */
function getImportance(element: NewsFeedElement): number {
    let result: number = 0;
    switch (element.level) {
        case "alert":
        case "achtung":
        case "alarm":
            result = IMPORTANCE_ALERT;
            break;
        case "warning":
        case "warn":
        case "warnung":
            result = IMPORTANCE_WARNING;
            break;
        case "holiday":
        case "feiertag":
            result = IMPORTANCE_HOLIDAY;
            break;
        case "happened":
            // this should never be triggered
            result = IMPORTANCE_HAPPENED;
            break;
        case "info":
            result = IMPORTANCE_DEFAULT;
            break;
        default:
            debug(
                "Weird importance level of '" +
                    element.level +
                    "' in element (using default)",
                element,
            );
            break;
    }

    // Special case, if the event occurred in the past:
    let date: Date = new Date();
    let willStillHappen: boolean = false;
    element.times?.forEach((time) => {
        if (willStillHappen) return;
        let till: string = time.till ?? time.on ?? time.from ?? getToday();
        if (
            Date.parse(normalizeTime(till)) + dayMilliseconds >
            date.getTime()
        ) {
            willStillHappen = true;
        }
    });
    if (!willStillHappen) result = IMPORTANCE_HAPPENED;

    element.importance = result;
    return result;
}

/**
 * Gets the Css class of an event
 */
function getElementClass(element: NewsFeedElement): string {
    const classPrefix: string = "newsfeed-element-relevancy-";
    let classSuffix: string = "generic";
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
            classSuffix = "generic";
            break;
    }
    return "newsfeed-element " + classPrefix + classSuffix;
}

/**
 * Determines if the event is relevant based on its time
 */
function isElementRelevant(element: NewsFeedElement): boolean {
    let result: boolean = false;
    if (typeof element != "object" || element == null) {
        debug("Element relevancy failed, not an object or is null", element);
        return false;
    }

    let date: Date = new Date();
    // Filters irrelevant news:
    element.times?.forEach((time) => {
        if (result) return; // Skip if already relevant
        let unixFrom = Date.parse(time.from ?? time.on ?? getToday());
        let unixTill =
            Date.parse(time.till ?? time.on ?? getToday()) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
        let unixNow = date.getTime();
        let isRelevant: boolean =
            unixNow - relevancyLookIntoPast <= unixTill &&
            unixNow + relevancyLookIntoFuture >= unixFrom;
        if (isRelevant) result = true;
    });
    return result;
}

/**
 * Filters all events by relevancy (see function `isElementRelevant`)
 */
function getFilteredNews(news: NewsFeedElement[]): NewsFeedElement[] {
    let result: NewsFeedElement[] = [];
    if (typeof news != "object" || news == null) {
        debug("News is not an object or is null", news);
        return [];
    }
    news.forEach((element) => {
        try {
            if (isElementRelevant(element)) {
                result.push(element);
            }
        } catch (e) {
            console.error("Failed to do relevancy check on event", e, element);
        }
    });
    return result;
}

/**
 * Sorts events based on their time and then importance
 */
function sortedElementsByDateAndRelevancy(
    news: NewsFeedElement[],
): NewsFeedElement[] {
    if (typeof news != "object" || news == null) {
        debug(
            "Passed news for sorting by date and relevancy was not an object or is null.",
            news,
        );
        return [];
    }
    // Date:
    news.sort((a, b) => {
        let aEarliest: string =
            (a.times != undefined ? a.times[0].from : undefined) ??
            a.from ??
            getToday();
        let bEarliest: string =
            (b.times != undefined ? b.times[0].from : undefined) ??
            b.from ??
            getToday();
        return Date.parse(aEarliest) - Date.parse(bEarliest);
    });
    // Importance:
    news.sort((a, b) => {
        // Normal sorting
        // return (b.importance ?? -99) - (a.importance ?? -99);

        // Actually wtf, anyways: puts "happened" events (-10) to the bottom, puts everything else in place (already sorted by date)
        return (
            ((b.importance ?? -99) > -10 ? 0 : -1) -
            ((a.importance ?? -99) > -10 ? 0 : -1)
        );
    });
    return news;
}

function displayTime(time: string) {
    let d = new Date(Date.parse(time));
    return (
        "<time datetime='" +
        time +
        "'>" +
        d.toLocaleString("de-DE", dateFormatDisplay) +
        "</time>"
    );
}
