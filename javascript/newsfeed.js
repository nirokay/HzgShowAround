/*

    Logic for the Newsfeed page
    ===========================

    Do not ask me how this works please, I really do not remember, because this has been
    such a fucking pain to code. At least now it (kinda) works :)

*/

let printDebug = false;

// HTML IDs:
const newsfeedDivId = "news-div";
const reloadedTimeId = "reloaded-time";

// URLs:
const remoteRepoNewsJson = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/news.json";

// Dates and times:
const dayMilliseconds = 86400000;
const weekMilliseconds = dayMilliseconds * 7;
const dateFormatDisplay = {
    year: "numeric",
    month: "numeric",
    day: "numeric"
};

// `news` gets set to `fucked` if everything is fucked
const fucked = "fucked";

// Global variables:
let date = new Date();
let news = [];

// Global error variables:
let networkingIssuesEncountered = false;
let remoteJsonParsingError = false;

function multilineText(array) {
    // Array of strings joined by `<br />`
    return array.join("<br />");
}
function p(array) {
    // Array of strings joined by `<br />` and wrapped inside `<p> ... </p>` tags
    return "<p>" + multilineText(array) + "</p>";
}

function getDiv() {
    // Shortcut to get the newsfeed div
    return document.getElementById(newsfeedDivId);
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

    return severity;
}

function getHtml(element) {
    // Gets an html object for a single event
    const classAlert = "alert";
    const classWarning = "warning";
    const classGeneric = "generic";
    const classHappened = "happened";

    let cssClassPrefix = "newsfeed-element-";
    let cssClass = classGeneric;
    switch(getImportance(element)) {
        case 2:
            cssClass = classAlert;
            break;
        case 1:
            cssClass = classWarning;
            break;
        case 0:
            cssClass = classGeneric;
            break;
        case -1:
            cssClass = classHappened;
            break;
        default:
            console.log("Weird importance level of '" + getImportance(element) + "' encountered. Using generic class.");
    }
    let html = "<div class='" + cssClassPrefix + cssClass + "'>";

    // Additional disclaimer, if the event has already passed:
    let disclaimer = (cssClass == classHappened) ? " <small>(Event vergangen)</small>" : "";

    // Title:
    html += "<h3 style='margin-bottom:2px;'>" + element.name + disclaimer + "</h3>";

    // Dates:
    const readableFrom = readable(element.from);
    const readableTill = readable(element.till);
    if (readableFrom != readableTill) {
        // Actual range:
        html += "<small><b>von " + readableFrom + " bis " + readableTill + "</b></small>";
    } else {
        // Just one day:
        html += "<small><b>am " + readableFrom + "</b></small>"
    }

    // Details:
    if(element.info != undefined) {
        // Add link to external resource for more information:
        element.details[element.details.length] = "<a href='" + element.info + "'>mehr Infos</a>";
    }
    html += "<p class='generic-center'>" + multilineText(element.details) + "</p>";

    return html + "</div>";
}

function addToDiv(content) {
    // Appends something to the newsfeed div
    getDiv().insertAdjacentHTML('beforeend', content);
}

function addElement(element) {
    // Appends html element to the newsfeed div
    addToDiv(getHtml(element));
}

function normalizeNews() {
    // Normalizes the fields for the json fields (pretty much just backwards compatibility and QoL)
    for(let i = 0; i < news.length; i++) {
        let element = news[i];

        // Override `from` and `till` with `on`, if defined:
        if(element.on != undefined) {
            element.from = element.on;
            element.till = element.on;
        }

        // Override missing `from` or `till` fields (assume it is only on one day):
        if(element.from == undefined) {
            element.from = element.till;
        } else if(element.till == undefined) {
            element.till = element.from;
        }

        news[i] = element;
    }
}

function normalize(time, offset = 0) {
    // Replaces `*` with the current year
    return time.replace("\*", date.getFullYear() + offset);
}

function readable(time) {
    // Transforms time to normal time (german notation)
    let d = new Date(Date.parse(normalize(time)));
    return d.toLocaleString("de-DE", dateFormatDisplay);
}

function isRelevant(element) {
    // Filters irrelevant news (depending on the date ± 7 days)
    let unixFrom = Date.parse(normalize(element.from));
    let unixTill = Date.parse(normalize(element.till)) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return unixNow <= unixTill + weekMilliseconds && unixNow >= unixFrom - weekMilliseconds;
}

function refreshNews() {
    // Refreshes `news` variable from remote repo
    let msg = "";
    console.log("Refreshing news from remote repo...");

    // This should hopefully catch any networking issues and display an error message:
    networkingIssuesEncountered = false;
    remoteJsonParsingError = false;

    fetch(remoteRepoNewsJson)
        .then(
            function(response) {
                return response.json()
            },
            function(error) {
                networkingIssuesEncountered = true;
                console.error("Network error encountered: " + error);
                return Promise.reject(fucked);
            }
        )
        .then(function(json) {
            news = json;
            console.log("Successfully got JSON!");
        })
        .catch(function(error) {
            remoteJsonParsingError = true;
            console.error("JSON Parsing error encountered: " + error);
        })
        .finally(function() {
            // Normalize news and get the HTML ready to be edited:
            normalizeNews();
            getDiv().innerHTML = "";

            // Band-aid solution à la javascript-style:
            if (news === fucked) {
                console.log("Everything is fucked, entering panic mode.")
                networkingIssuesEncountered = true;
                remoteJsonParsingError = true;
            }

            console.log("Issues?:  network: " + networkingIssuesEncountered + "  |  parsing: " + remoteJsonParsingError)

            if(printDebug) {

                console.log("Raw news from remote repository:");
                console.log(news);
                console.log("--------------------------------");
            }

            // No networking errors, so continue with handling news:
            if (!networkingIssuesEncountered && !remoteJsonParsingError) {
                // Filtering news:
                let relevantNews = news.filter(element => isRelevant(element));
                for(let i = 0; i < relevantNews.length; i++) {
                    relevantNews[i].importance = getImportance(relevantNews[i]);
                }

                // Sorting news by date relevance:
                relevantNews.sort(function(a, b) {
                    return b.importance - a.importance;
                });

                // Adding news:
                relevantNews.forEach(element => {
                    addElement(element);
                });

                // Display placeholder message, if no relevant news are there:
                if(relevantNews.length == 0) {
                    // There are no relevant news:
                    if(news.length != 0) {
                        msg = p(["Derzeit keine relevanten Neuigkeiten vorhanden."]);
                    }
                    // There are NO news (should not happen?):
                    else {
                        msg = p([
                            "Derzeit keine Neuigkeiten vorhanden.",
                            "Dies ist wahrscheinlich ein Fehler, versuche es erneut indem du auf den \"Neu laden\" Knopf drückst!"
                        ]);
                    }
                }
                if (printDebug){
                    console.log("Relevant news:");
                    console.log(relevantNews);
                    console.log("--------------------------------");
                }
            }

            // Networking error, so just throw an error message on the screen and let the user handle it:
            else if(networkingIssuesEncountered) {
                msg = p([
                    "Es konnte keine Verbindung zum externen Server hergestellt werden.",
                    "Dies kann ein einer schlechten oder nicht vorhandenen Internetverbindung liegen.",
                    "Versuche es später noch einmal!"
                ]);
            }

            // Network is fine, but the json was fucked in some way:
            else if(remoteJsonParsingError) {
                msg = p([
                    "Es ist ein Fehler bei der Datenverarbeitung passiert. JSON konnte nicht korrekt gelesen werden.",
                    "Bitte gib uns Bescheid, indem du <a href=\"https://github.com/nirokay/HzgShowAroundData/issues/new\">ein Issue auf GitHub eröffnest</a>!"
                ])
            }

            // This literally cannot happen, but i am paranoid because it is javascript after all...:
            else {
                msg = p([
                    "Ein Fehler ist geschehen."
                ])
            }

            // Add `msg`, if set:
            if (msg != "") {
                addToDiv(msg);
            }

            // Update "refreshed at `time`" text:
            function updateRefreshedAt() {
                date = new Date();
                let time = date.toLocaleTimeString("de-DE");
                document.getElementById(reloadedTimeId).innerHTML = "Aktualisiert um " + time;
            }
            updateRefreshedAt();
        });
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
window.onload = function() {
    refreshNews();
}
