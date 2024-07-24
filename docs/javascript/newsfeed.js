/*

    Logic for the Newsfeed page
    ===========================

    Do not ask me how this works please, I really do not remember, because this has been
    such a fucking pain to code. At least now it (kinda) works :)

*/

// ----------------------------------------------------------------------------
// Debug:
// ----------------------------------------------------------------------------

let debugPrintingEnabled = true; // Allows easy debugging in browser console
/**
 * Fancy debug printing
 * @param {string} message
 * @param {any?} element
 */
function debug(message, element) {
    if(!debugPrintingEnabled) {
        return;
    }
    const separator = "================================================";
    if(element != undefined && element != "" && element != null) {
        console.log("===== " + message + " ===== :");
        console.log(element);
        console.log(separator);
    } else {
        console.log("===== " + message + " =====");
    }
}


// ----------------------------------------------------------------------------
// HTML IDs:
// ----------------------------------------------------------------------------

const idNewsFeed = "news-div";
const idReloadedTime = "reloaded-time";


// ----------------------------------------------------------------------------
// URLs:
// ----------------------------------------------------------------------------

const urlHolidayApi = "https://feiertage-api.de/api/?nur_land=BY"
const urlRemoteRepository = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/";
const urlRemoteNews = urlRemoteRepository + "news.json";
const urlRemoteHealthPresentations = urlRemoteRepository + "news-health.json";
const urlLocationLookupTable = urlRemoteRepository + "docs/resources/location_lookup.json";


// ----------------------------------------------------------------------------
// Error messages:
// ----------------------------------------------------------------------------

let errorMessageAdditional = "";

let errorPanicNoInternet = false;
const errorMessageNoInternet = [
    "Es konnte keine Internetverbindung zum Server hergestellt werden.",
    "Dies kann an einer schlechten oder nicht vorhandenen Internetverbindung liegen.",
    "Überprüfe Diese und versuche es später noch einmal."
];

let errorPanicParsingFuckUp = false;
const errorMessageParsingFuckUp = [
    "Es ist ein Fehler bei der Datenverarbeitung geschehen.",
    "Bitte gib uns Bescheid, indem du <a href='https://github.com/nirokay/HzgShowAroundData/issues/new'>ein Issue auf GitHub eröffnest</a>!"
];

const errorMessageGeneric = [
    "Es ist ein Fehler geschehen..."
];

const infoMessageNoNews = [
    "Keine Neuigkeiten vorhanden."
];
const infoMessageNoRelevantNews = [
    "Derzeit keine relevanten Neuigkeiten vorhanden."
];


// ----------------------------------------------------------------------------
// Dates and times:
// ----------------------------------------------------------------------------

const dayMilliseconds = 86400000;
const weekMilliseconds = dayMilliseconds * 7;
const monthMilliseconds = weekMilliseconds * 4;
const dateFormatDisplay = {
    year: "numeric",
    month: "numeric",
    day: "numeric"
};

let relevancyLookIntoFuture = monthMilliseconds * 2;
let relevancyLookIntoPast = monthMilliseconds;

/**
 * Replaces `*` with the current year
 * @param {string} time yyyy-MM-dd date-stamp
 * @param {number} offset yearly offset
 * @returns {string}
 */
function normalizeTime(time, offset = 0) {
    return time.replace("\*", date.getFullYear() + offset);
}

/**
 * Returns a readable date-stamp
 * @param {string} time
 * @returns {string}
 */
function convertToReadable(time) {
    // Transforms time to normal time (german notation)
    let d = new Date(Date.parse(normalizeTime(time)));
    return d.toLocaleString("de-DE", dateFormatDisplay);
}

/**
 * Returns 0, 10, 20 for importance, -5 for holidays and -10 for already-happened events
 * @param {NewsFeedElement} element
 * @returns {number}
 */
function getImportance(element) {
    let severity = 0;
    switch(element.level) {
        case "alert": case "achtung": case "alarm":
            severity = 20;
            break;
        case "warning": case "warn": case "warnung":
            severity = 10;
            break;
        case "holiday": case "feiertag":
            severity = -5;
            break;
        case "happened":
            // this should never be triggered
            severity = -10;
            break;
        case "info":
            severity = 0;
            break;
        default:
            debug("Weird importance level of '" + element.level + "' in element (using default)", element);
            break;
    }

    // Special case, if the event occurred in the past:
    if(Date.parse(normalizeTime(element.till)) + dayMilliseconds < date.getTime()) {
        severity = -10;
    }

    element.importance = severity;
    return severity;
}

/**
 * Updates `element.importance`
 * @param {NewsFeedElement} element
 * @returns {NewsFeedElement}
 */
function normalizeImportance(element) {
    element.importance = getImportance(element);
    return element;
}

// ----------------------------------------------------------------------------
// Global variables:
// ----------------------------------------------------------------------------

let date = new Date(); // Current datetime, gets refreshed with each new refreshNews() call
/**
 * @type {NewsFeedElement[]}
 */
let news = []; // All news from the remote repository
/**
 * @type {NewsFeedElement[]}
 */
let relevantNews = []; // Filtered news, that are relevant
/**
 * @type {LocationLookUpObject[]}
 */
let locationLookupTable = {};

/**
 * Array of holidays to ignore.
 * @type {string[]}
 */
const holidaysToIgnore = [
    "Augsburger Friedensfest"
];


// ----------------------------------------------------------------------------
// Html text stuff:
// ----------------------------------------------------------------------------

/**
 * Gets the newsfeed div
 * @returns {HTMLElement | null}
 */
function getDiv() {
    // Shortcut to get the newsfeed div
    let result = document.getElementById(idNewsFeed);
    if(result == null) {
        console.error("Could not find HTML element by id: " + idNewsFeed)
    }
    return result;
}

/**
 * Adds HTML string to the div
 * @param {string} content
 */
function addToDiv(content) {
    getDiv().insertAdjacentHTML('beforeend', content);
}

/**
 * Converts `element` to HTML string and appends it to the newsfeed div
 * @param {NewsFeedElement} element
 */
function addElement(element) {
    addToDiv(getHtml(element));
}

/**
 * Joins all strings with `<br />`
 * @param {string[]} array
 * @returns {string}
 */
function multilineText(array) {
    return array.join("<br />");
}
/**
 * Calls `multilineText(array)` and adds `<p> ... </p>` around the text
 * @param {string[]} array
 * @returns {string}
 */
function p(array) {
    // Array of strings joined by `<br />` and wrapped inside `<p> ... </p>` tags
    return "<p>" + multilineText(array) + "</p>";
}

/**
 * Updates the "Refreshed at" timestamp, optionally overrides the timestamp
 * @param {string?} override
 */
function updateRefreshedAt(override) {
    let newText = ""
    if(override == "" || override == undefined) {
        date = new Date();
        let time = date.toLocaleTimeString("de-DE");
        newText = "Aktualisiert um " + time;
    } else {
        newText = override;
    }
    document.getElementById(idReloadedTime).innerHTML = newText;
}


// ----------------------------------------------------------------------------
// News stuff:
// ----------------------------------------------------------------------------

/**
 * Normalises a NewsFeedElement
 * @param {NewsFeedElement} element
 * @returns {NewsFeedElement}
 */
function normalizedElement(element) {
    // No need to type-check, because it already was by GitHub actions (hopefully).
    // Element is just a comment:
    if(element.COMMENT != undefined) {
        return [];
    }

    // Single-day event:
    if(element.on != undefined) {
        element.from = element.on;
        element.till = element.on;
    }
    // Wrongly formatted events, correcting to single-day event:
    if(element.from == undefined && element.till != undefined) {
        // Forgot to assign `from`:
        element.from = element.till;
    } else if(element.from != undefined && element.till == undefined) {
        // Forgot to assign `till`:
        element.till = element.from;
    } else if(element.from == undefined && element.till == undefined) {
        // What even were you doing?!
        element.from = "*-01-01";
        element.till = "*-12-31";
        element.runtimeAdditionalMessage = "Fehlendes Datum, wird als ganzjährig angezeigt.";
    }

    // Other missing fields:
    if(element.name == "" || element.name == undefined) {
        element.name = "Neuigkeit";
    }
    if(typeof(element.level) != "string") {
        element.level = "info";
    }

    // QoL type fixes and fields:
    switch (typeof(element.details)) {
        case "string": case "number":
            element.details = [element.details];
            break;
        case "undefined":
            element.details = [];
            break;
        case "object":
            // Normal/Expected behaviour
            break;
        default:
            debug("Element details field is weird...", element)
            element.details = [];
            break;
    }

    // Prevent empty links:
    if(typeof(element.info) != "string") {
        element.info = undefined;
    }
    if((element.info) === "") {
        element.info = undefined;
    }

    element.importance = getImportance(element);

    // Who cares about performance anyways? Here the browser will do work, that will be probably discarded.
    // You cannot do anything about it, the browser runtime is MY bitch.
    if(element.from.includes("*") || element.till.includes("*")) {
        // Duplicates the event for the next and previous year
        let year = date.getFullYear();
        function duplicate(offset) {
            let e = element;
            let y = year + offset;
            e.from = element.from.replace("\*", y);
            e.till = element.till.replace("\*", y);
        }
        news.push(duplicate(1))
        news.push(duplicate(-1))
    }

    if(
        Date.parse(element.from) <= date.getTime() &&
        Date.parse(element.till) + dayMilliseconds >= date.getTime()
    ) {
        element.isHappening = true;
    } else {
        element.isHappening = false;
    }

    return element;
}

/**
 * Gets all NewsFeedElements in a normalized state
 * @param {NewsFeedElement[]} news
 * @returns {NewsFeedElement[]}
 */
function normalizedNews(news) {
    // Normalizes the fields for the json fields (pretty much just backwards compatibility and QoL)
    if(typeof(news) != "object" || news === undefined) {
        debug("News is not an object or is undefined", news);
        return [];
    }
    let result = [];
    news.forEach((element) => {
        let newElement = normalizedElement(element);
        if(newElement != []) {
            result.push(newElement);
        }
    });
    return result;
}

/**
 * Determines if the element is relevant or not (based on time)
 * @param {NewsFeedElement} element
 * @returns {boolean}
 */
function isElementRelevant(element) {
    if(typeof(element) != "object" || element == null) {
        debug("Element relevancy failed, not an object or is null", element);
        return false;
    }
    // Filters irrelevant news:
    let unixFrom = Date.parse(element.from);
    let unixTill = Date.parse(element.till) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return (
        unixNow - relevancyLookIntoPast <= unixTill &&
        unixNow + relevancyLookIntoFuture >= unixFrom
    )
}

/**
 * Filters out only the relevant elements
 * @returns {NewsFeedElement[]}
 */
function getFilteredNews() {
    let result = [];
    if(typeof(news) != "object" || news == null) {
        debug("News is not an object or is null", news);
        return [];
    }
    news.forEach((element) => {
        if(isElementRelevant(element)) {
            result.push(element);
        }
    });
    return result;
}

/**
 * Sorts the elements firstly by date, then by relevancy
 * @param {NewsFeedElement[]} array
 * @returns {NewsFeedElement[]}
 */
function sortedElementsByDateAndRelevancy(array) {
    if(typeof(array) != "object" || array == null) {
        debug("Passed array for sorting by date and relevancy was not an object or is null.", array);
        return [];
    }
    // Date:
    array.sort((a, b) => {
        return Date.parse(a.from) - Date.parse(b.from);
    });
    // Importance:
    array.sort((a, b) => {
        return b.importance - a.importance;
    });
    return array;
}

/**
 * Transforms time to normal, readable time format (german notation)
 * @param {string} time
 * @returns {HtmlString}
 */
function displayTime(time) {
    let d = new Date(Date.parse(time));
    return "<b><time>" + d.toLocaleString("de-DE", dateFormatDisplay) + "</time></b>";
}

/**
 * Gets the css class according to the elements importance
 * @param {NewsFeedElement} element
 * @returns {string}
 */
function getElementClass(element) {
    const classPrefix = "newsfeed-element-";
    let classSuffix = "generic";
    switch(getImportance(element)) {
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
 * Gets the disclaimer for the Html element
 * @param {NewsFeedElement} element
 * @param {string} cssClass Css class of News
 * @returns {HtmlString}
 */
function htmlDisclaimer(element, cssClass) {
    let result = [];
    if(cssClass == "happened") {
        result.push("Event vergangen")
    }
    if(element.isHappening) {
        result.push("<b>Heute!</b>")
    }
    return result.length == 0 ? "" : "<small>(" + result.join(", ") + ")</small>"
}
/**
 * Gets the header for an element
 * @param {NewsFeedElement} element
 * @param {string} disclaimer Optional disclaimer (with `htmlDisclaimer(element, cssClass)`)
 * @returns {HtmlString}
 */
function htmlHeader(element, disclaimer) {
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
 * Gets the HTML for the date section
 * @param {NewsFeedElement} element
 * @returns {HtmlString}
 */
function htmlDateSection(element) {
    const from = displayTime(element.from);
    const till = displayTime(element.till);
    let result = "";
    if(from == till) {
        result = "am " + from;
    } else {
        result = "von " + from + " bis " + till;
    }
    return "<small class='generic-center'>" + result + "</small>"
}
/**
 * Gets the details section for the element
 * @param {NewsFeedElement} element
 * @returns {HtmlString}
 */
function htmlDetails(element) {
    let lines = [];
    let url = element.info;

    lines = element.details;
    let result = "<p>" + lines.join("<br />") + "</p>";

    if(url != undefined && url != "") {
        result += "<p class='generic-center'><a href='" + url + "'>mehr Infos</a></p>";
    }
    return result;
}

/**
 * Converts `element` to HTML text
 * @param {NewsFeedElement} element
 * @returns {HtmlString}
 */
function generateElementHtml(element) {
    let className = getElementClass(element);
    let elements = [
        htmlHeader(element, htmlDisclaimer(element)),
        htmlDateSection(element),
        htmlDetails(element)
    ]
    return "<div class='" + className + "'>" + elements.join("") + "</div>";
}

/**
 * Injects location links, mentioned in the news element
 * @param {HtmlString} html
 * @returns {HtmlString}
 */
function addLocationLinks(html) {
    let result = html;
    // Thank you javascript for being dynamic:
    if(locationLookupTable == undefined || typeof(locationLookupTable) != "object") {
        return result;
    }
    if(locationLookupTable.length == 0) {
        return result;
    }

    // Highly efficient code to replace substrings with, I do not want to go into
    // detail on how great nested loops are :)
    for(const [_, lookupObject] of Object.entries(locationLookupTable)) {
        if(typeof(lookupObject) != "object") {
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

/**
 * Injects holidays from the holiday API.
 * @returns {Promise<void>}
 */
async function injectHolidays() {
    debug("Injecting holidays");
    return new Promise(async(resolve, reject) => {
        for(let yearModifier = -1; yearModifier < 2; yearModifier++) {
            const year = date.getFullYear() + yearModifier;
            debug("Injecting holidays for year " + year);
            let rawHolidays = {};
            try {
                let response = await fetch(urlHolidayApi + "&jahr=" + year);
                let raw = await response.text();
                let json = JSON.parse(raw);
                rawHolidays = json;
            } catch(error) {
                debug("Failed to fetch/parse holidays json", error);
            }

            // Parse holidays to proper elements to be injected:
            debug("Raw holidays", rawHolidays);
            for (const [name, details] of Object.entries(rawHolidays)) {
                // Skip some holidays:
                if(holidaysToIgnore.indexOf(name) > -1) {
                    continue;
                }
                let event = {};
                event.name = name + " <small>(Feiertag)</small>";
                event.on = details.datum;
                event.info = undefined;
                event.level = "holiday";

                news.push(event);
            }
        }
        resolve();
    });
}

/**
 * Injects health presentations as news elements from remote json.
 * @returns {Promise<void>}
 */
async function injectHealthPresentations() {
    debug("Injecting health presentations");
    return new Promise(async(resolve, reject) => {
        let presentations = [];
        try {
            let response = await fetch(urlRemoteHealthPresentations);
            let raw = await response.text();
            let json = JSON.parse(raw);
            presentations = json;
        } catch(error) {
            debug("Failed to fetch/parse health presentations json", error);
        }
        if(presentations.length == 0) {
            reject("Failed to fetch/parse");
        }

        presentations.forEach((presentation) => {
            let event = {
                name: "Gesundheitsbildung: " + presentation.topic,
                on: presentation.on,
                level: "info"
            }
            // Description:
            let desc = [];

            event.desc = desc;
            news.push(event);
        });
        resolve();
    });
}


// ----------------------------------------------------------------------------
// Errors:
// ----------------------------------------------------------------------------

/**
 * Checks if any errors occurred during runtime
 * @returns {boolean}
 */
function someErrorOccurred() {
    return errorPanicNoInternet || errorPanicParsingFuckUp;
}

/**
 * Displays an error message in the HTML div
 * @param {string} errorMessage
 */
function displayErrorMessage(errorMessage) {
    let msg = errorMessage;
    if(errorMessageAdditional != "" || errorMessageAdditional == undefined){
        msg.push(errorMessageAdditional);
    }
    let fullMessage = msg.join("<br />");
    addToDiv(fullMessage);
    updateRefreshedAt();
}


// ----------------------------------------------------------------------------
// Main:
// ----------------------------------------------------------------------------

/**
 * Main function called on `document.onload` and when the refresh button is clicked
 */
async function refreshNews() {
    // Feedback: ==============================================================
    debug("Fetching from remote repository");
    updateRefreshedAt("Verbindung zum Server wird hergestellt...");

    // Reset error states: ====================================================
    errorMessageAdditional = "";
    errorPanicNoInternet = false;
    errorPanicParsingFuckUp = false;

    // Fetching news: =========================================================
    try {
        let response = await fetch(urlRemoteNews);
        let raw = await response.text();
        let json = JSON.parse(raw);

        if (typeof(json) === "object" && json !== null) {
            news = json;
        } else {
            debug("Json Parsed was not valid? How does this even happen??", json);
            news = [];
        }
    } catch (error) {
        errorPanicNoInternet = true;
        debug("Internet connection issues", error);
        news = [];
    }

    // Injecting holidays into `news`: ========================================
    try {
        await injectHolidays();
    } catch (error) {
        debug("Failed to inject holidays", error);
    }
    // Injecting health presentations into `news`: ============================
    try {
        await injectHealthPresentations();
    } catch (error) {
        debug("Failed to inject holidays", error);
    }

    // Reset the html stuff: ==================================================
    getDiv().innerHTML = "";
    updateRefreshedAt("Daten werden verarbeitet...");

    // Error handling: ========================================================
    // Apparent issues: -------------------------------------------------------
    if (someErrorOccurred()) {
        updateRefreshedAt("Datenverarbeitung abgebrochen.");
        if (errorPanicNoInternet) {
            displayErrorMessage(errorMessageNoInternet);
        } else if (errorPanicParsingFuckUp) {
            displayErrorMessage(errorMessageParsingFuckUp);
        } else {
            // This should NEVER happen:
            displayErrorMessage(errorMessageGeneric);
        }
        debug("Displaying error message");
        return;
    }

    // Empty news array encountered: ------------------------------------------
    if (news.length === 0) {
        debug("No news at all found (normal? doubt it...)");
        displayErrorMessage(infoMessageNoNews);
        return;
    }

    // Modify `news`: =========================================================
    // Normalize news to have all fields in common:
    news = normalizedNews(news);
    debug("Normalized news", news);

    // Filter news based on date:
    relevantNews = getFilteredNews();

    // Sorting news:
    if (relevantNews.length === 0) {
        // No relevant news:
        debug("No relevant news found.");
        displayErrorMessage(infoMessageNoRelevantNews);
        return;
    } else {
        // Sort:
        relevantNews = sortedElementsByDateAndRelevancy(relevantNews);
        debug("All relevant news", relevantNews);
    }

    // Fetch lookup table to inject hyperlinks into text: =====================
    try {
        let response = await fetch(urlLocationLookupTable);
        let raw = await response.text();
        locationLookupTable = JSON.parse(raw);
        debug("Got locationLookupTable!", locationLookupTable);
    } catch (error) {
        debug("Could not fetch or parse location lookup table", error);
        locationLookupTable = {};
    }

    // Add all elements to html and inject links: =============================
    debug("Running replacement stuff on html elements.");
    relevantNews.forEach((element) => {
        let htmlElement = addLocationLinks(generateElementHtml(element));
        addToDiv(htmlElement);
    });

    updateRefreshedAt();
}

window.onload = function() {
    refreshNews();
}
