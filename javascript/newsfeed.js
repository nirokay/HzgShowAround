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
function debug(message, element) {
    if(!debugPrintingEnabled) {
        return;
    }
    const separator = "================================================";
    if(! element == undefined || ! element == "" || ! element == null) {
        console.log("===== " + message + " ===== :");
        console.log(element);
        console.log(separator);
    } else {
        console.log("===== " + message + " =====");
    }
}


// ----------------------------------------------------------------------------
// Error "Handling?":
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// HTML IDs:
// ----------------------------------------------------------------------------

const idNewsFeed = "news-div";
const idReloadedTime = "reloaded-time";


// ----------------------------------------------------------------------------
// URLs:
// ----------------------------------------------------------------------------

const urlRemoteRepository = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/news.json";


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

let relevancyLookIntoFuture = monthMilliseconds;
let relevancyLookIntoPast = weekMilliseconds * 2;

function normalizeTime(time, offset = 0) {
    // Replaces `*` with the current year
    return time.replace("\*", date.getFullYear() + offset);
}

function convertToReadable(time) {
    // Transforms time to normal time (german notation)
    let d = new Date(Date.parse(normalizeTime(time)));
    return d.toLocaleString("de-DE", dateFormatDisplay);
}

function getImportance(element) {
    // Returns 0 .. 2 for severity, and -1 for already-happened events
    let severity = 0;
    switch(element.level) {
        case "alert": case "achtung": case "alarm":
            severity = 2;
            break;
        case "warning": case "warn": case "warnung":
            severity = 1;
            break;
        default:
            severity = 0;
            break;
    }

    // Special case, if the event occurred in the past:
    if(Date.parse(normalizeTime(element.till)) + dayMilliseconds < date.getTime()) {
        severity = -1;
    }

    return severity;
}

function normalizeImportance(element) {
    element.importance = getImportance(element);
    return element;
}

// ----------------------------------------------------------------------------
// Global variables:
// ----------------------------------------------------------------------------

let date = new Date(); // Current datetime, gets refreshed with each new refreshNews() call
let news = []; // All news from the remote repository
let relevantNews = []; // Filtered news, that are relevant


// ----------------------------------------------------------------------------
// Html text stuff:
// ----------------------------------------------------------------------------

function getDiv() {
    // Shortcut to get the newsfeed div
    let result = document.getElementById(idNewsFeed);
    if(result == null) {
        console.error("Could not find HTML element by id: " + idNewsFeed)
    }
    return result;
}

function addToDiv(content) {
    // Appends something to the newsfeed div
    getDiv().insertAdjacentHTML('beforeend', content);
}

function addElement(element) {
    // Appends html element to the newsfeed div
    addToDiv(getHtml(element));
}

function multilineText(array) {
    return array.join("<br />");
}
function p(array) {
    // Array of strings joined by `<br />` and wrapped inside `<p> ... </p>` tags
    return "<p>" + multilineText(array) + "</p>";
}

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

function normalizedElement(element) {
    // No need to type-check, because it already was.

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
    if(element.level = "" || element.level == undefined) {
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
            break;
    }

    if(
        Date.parse(element.from) <= date.getTime() &&
        Date.parse(element.till) >= date.getTime()
    ) {
        element.isHappening = true;
    } else {
        element.isHappening = false;
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
    return element;
}

function normalizedNews() {
    // Normalizes the fields for the json fields (pretty much just backwards compatibility and QoL)
    if(typeof(news) != "object" || news === undefined) {
        debug("News is not an object or is undefined", news);
        return [];
    }
    let result = [];
    news.forEach((element) => {
        result.push(normalizedElement(element));
    });
    return result;
}

function isElementRelevant(element) {
    if(typeof(element) != "object" || element != null) {
        debug("Element relevancy failed, not an object or is null", element);
        return false;
    }
    // Filters irrelevant news:
    let unixFrom = Date.parse(element.from);
    let unixTill = Date.parse(element.till) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return (
        unixNow <= unixTill + relevancyLookIntoFuture && // Extend ending date
        unixNow >= unixFrom - relevancyLookIntoPast      // Extend starting date
    )
}

function getFilteredNews() {
    let result = [];
    if(typeof(news) != "object" || news != null) {
        debug("News is not an object or is null", news);
        return [];
    }
    news.forEach(element => {
        if(isElementRelevant(element)) {
            result.push(element);
        }
    });
    return result;
}

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

function displayTime(time) {
    // Transforms time to normal, readable time format (german notation)
    let d = new Date(Date.parse(time));
    return "<b><time>" + d.toLocaleString("de-DE", dateFormatDisplay) + "</time></b>";
}

function getElementClass(element) {
    const classPrefix = "newsfeed-element-";
    let classSuffix = "generic";
    switch(getImportance(element)) {
        case 2:
            classSuffix = "alert";
            break;
        case 1:
            classSuffix = "warning";
            break;
        case 0:
            classSuffix = "generic";
            break;
        case -1:
            classSuffix = "happened";
            break;
        default:
            debug("Weird importance encountered in element, using default.", element);
            break;
    }
    return classPrefix + classSuffix;
}


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
function htmlDateSection(element) {
    const from = displayTime(element.from);
    const till = displayTime(element.till);
    let result = "";
    if(from == till) {
        result = "am " + from;
    } else {
        result = "von " + from + " bis " + till;
    }
    return "<small>" + result + "</small>"
}
function htmlDetails(element) {
    let lines = [];
    let url = element.info;

    lines = element.details;

    if(url != undefined) {
        lines.push("<a href='" + url + "'>mehr Infos</a>");
    }
    return "<p class='generic-center'>" + lines.join("<br />") + "</p>";
}

function generateElementHtml(element) {
    let className = getElementClass(element);
    let result = [
        htmlHeader(element, htmlDisclaimer(element)),
        htmlDateSection(element),
        htmlDetails(element)
    ]
    return "<div class='" + className + "'>" + result.join("") + "</div>"
}

// ----------------------------------------------------------------------------
// Errors:
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
    "Bitte gib uns Bescheid, indem du <a href=\"https://github.com/nirokay/HzgShowAroundData/issues/new\">ein Issue auf GitHub eröffnest</a>!"
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

function someErrorOccurred() {
    return errorPanicNoInternet || errorPanicParsingFuckUp;
}

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

function refreshNews() {
    debug("Fetching from remote repository");
    updateRefreshedAt("Verbindung zum Server wird hergestellt...");

    // Reset error states:
    errorMessageAdditional = "";
    errorPanicNoInternet = false;
    errorPanicParsingFuckUp = false;

    fetch(urlRemoteRepository)
    // Getting raw response:
    .then(
        (response) => {
            return response;
        },
        (error) => {
            errorPanicNoInternet = true;
            debug("Internet connection issues", error);
            return Promise.resolve("[]");
        }
    )
    // Parsing json:
    .then(
        (raw) => {
            return raw.json();
        }
    )
    .catch(
        (error) => {
            errorPanicParsingFuckUp = true;
            debug("Json Parsing error", error);
            return Promise.resolve(JSON.parse("[]"));
        }
    )
    // Applying json to `news`:
    .then(
        (json) => {
            if(typeof(json) == "object" && json != null) {
                news = json;
            } else {
                debug("Json Parsed was not valid? How does this even happen??", json);
                news = [];
            }
        }
    )
    // Main logic after parsing:
    .finally(() => {
        getDiv().innerHTML = "";
        updateRefreshedAt("Daten werden verarbeitet...");

        // Error handling:
        if(someErrorOccurred()) {
            updateRefreshedAt("Datenverarbeitung abgebrochen.");
            if(errorPanicNoInternet) {
                displayErrorMessage(errorMessageNoInternet);
            } else if(errorPanicParsingFuckUp) {
                displayErrorMessage(errorMessageParsingFuckUp);
            } else {
                // This should NEVER happen:
                displayErrorMessage(errorMessageGeneric);
            }
            debug("Displaying error message");
            return;
        }

        // Empty news array:
        if(news.length == 0) {
            debug("No news at all found (normal? doubt it...)");
            displayErrorMessage(infoMessageNoNews);
            return;
        }

        // Normalize all news:
        news = normalizedNews();

        // Reset HTML:
        getDiv().innerHTML = "";

        // Filter news:
        relevantNews = news; //getFilteredNews();

        if(relevantNews.length == 0) {
            // No relevant news:
            debug("No relevant news found.");
            displayErrorMessage(infoMessageNoRelevantNews);
            return;
        } else {
            // Sort:
            relevantNews = sortedElementsByDateAndRelevancy(relevantNews);
            debug("All relevant news", relevantNews)
        }

        // Add all relevant news to HTML:
        relevantNews.forEach((element) => {
            addToDiv(generateElementHtml(element));
        });

        updateRefreshedAt();
    });
}

window.onload = function() {
    refreshNews();
}
