/*

    Logic for the Newsfeed page
    ===========================

    Do not ask me how this works please, I really do not remember, because this has been
    such a fucking pain to code. At least now it (kinda) works :)

*/

// ----------------------------------------------------------------------------
// Debug:
// ----------------------------------------------------------------------------

let debugPrintingEnabled = false; // Allows easy debugging in browser console
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

function convertToReadable(time) {
    // Transforms time to normal time (german notation)
    let d = new Date(Date.parse(normalize(time)));
    return d.toLocaleString("de-DE", dateFormatDisplay);
}

function normalizeTime(time, offset = 0) {
    // Replaces `*` with the current year
    return time.replace("\*", date.getFullYear() + offset);
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
    if (Date.parse(normalize(element.till)) + dayMilliseconds < date.getTime()) {
        severity = -1;
    }
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
    document.getElementById(reloadedTimeId).innerHTML = newText;
}


// ----------------------------------------------------------------------------
// News stuff:
// ----------------------------------------------------------------------------

function normalizeNews() {
    // Normalizes the fields for the json fields (pretty much just backwards compatibility and QoL)
    if(typeof(news) != "object" || news === undefined) {
        debug("News is not an object or is undefined", news);
        return [];
    }
}

function isElementRelevant(element) {
    // Filters irrelevant news
    let unixFrom = Date.parse(normalize(element.from));
    let unixTill = Date.parse(normalize(element.till)) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return (
        unixNow <= unixTill + relevancyLookIntoFuture && // Extend ending date
        unixNow >= unixFrom - relevancyLookIntoPast      // Extend starting date
    )
}

function getFilteredNews() {
    let result = [];
    if(typeof(news) != "object" || news === undefined) {
        debug("News is not an object or is undefined", news);
        return [];
    }
    news.forEach(element => {
        if(isElementRelevant(element)) {
            result.push(element);
        }
    });
    return result;
}

function sortElementsByDateAndRelevancy(array) {
    // Date:
    array.sort((a, b) => {
        return Date.parse(a.from) - Date.parse(b.from);
    });

    // Importance:
    array.sort((a, b) => {
        return b.importance - a.importance;
    });
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
    let fullMessage = msg.join("<br />")
    addToDiv(fullMessage);
}


// ----------------------------------------------------------------------------
// Main:
// ----------------------------------------------------------------------------

function refreshNews() {
    debug("Fetching from remote repository")
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
        normalizeNews();

        // Reset HTML:
        getDiv().innerHTML = "";

        // Filter news:
        relevantNews = getFilteredNews();

        // No relevant news:
        if(relevantNews.length == 0) {
            debug("No relevant news found.");
            displayErrorMessage(infoMessageNoRelevantNews);
        }
    })
}



window.onload = function() {
    refreshNews();
}
