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
    return array.join("<br />");
}
function p(array) {
    return "<p>" + multilineText(array) + "</p>";
}

function getDiv() {
    return document.getElementById(newsfeedDivId);
}

function getImportance(element) {
    // Returns 0 .. 2 for severity
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
    return severity;
}

function getHtml(element) {
    let cssClass = "";
    switch(getImportance(element)) {
        case 2:
            cssClass = "alert";
            break;
        case 1:
            cssClass = "warning";
            break;
        case 0:
            cssClass = "generic";
            break;
    }
    let html = "<div class='newsfeed-element-" + cssClass + "'>";

    // Title:
    html += "<h3 style='margin-bottom:2px;'>" + element.name + "</h3>";
    // Date range:
    html += "<small><b>von " + readable(element.from) + " bis " + readable(element.till) + "</b></small>";
    // Details:
    html += "<p class='generic-center'>" + multilineText(element.details) + "</p>";

    return html + "</div>";
}

function addToDiv(content) {
    getDiv().insertAdjacentHTML('beforeend', content);
}

function addElement(element) {
    addToDiv(getHtml(element));
}

function fetchNews() {
    networkingIssuesEncountered = false;
    remoteJsonParsingError = false;

    fetch(remoteRepoNewsJson)
        .then(
            function(response) { return response.json() },
            function(error) { networkingIssuesEncountered = true; return fucked }
        )
        .then(
            function(json) { news = json },
            function(error) { remoteJsonParsingError = true }
        )
        .then(
            console.log("Got stuff!")
        );
    console.log(news)
}

function normalize(time, offset = 0) {
    return time.replace("\*", date.getFullYear() + offset);
}

function readable(time) {
    let d = new Date(Date.parse(normalize(time)));
    return d.toLocaleString("de-DE", dateFormatDisplay);
}

function isRelevant(element) {
    /** Filters irrelevant news (depending on the date ± 7 days) */
    let unixFrom = Date.parse(normalize(element.from));
    let unixTill = Date.parse(normalize(element.till)) + dayMilliseconds; // `+ dayMilliseconds`, so that the whole day is included, not only upto 0:00
    let unixNow = date.getTime();
    return unixNow <= unixTill + weekMilliseconds && unixNow >= unixFrom - weekMilliseconds;
}

function refreshNews() {
    /** Refreshes `news` variable from remote repo */
    let msg = "";
    console.log("Refreshing news from remote repo...");

    // This should hopefully catch any networking issues and display an error message:
    fetchNews();

    getDiv().innerHTML = "";

    // Band-aid solution à la javascript-style:
    if (news === fucked) {
        console.log("Everything is fucked, entering panic mode.")
        networkingIssuesEncountered = true;
        remoteJsonParsingError = true;
    }

    console.log("Issues?:  network: " + networkingIssuesEncountered + "  |  parsing: " + remoteJsonParsingError)

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
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
document.onload =
    refreshNews();
