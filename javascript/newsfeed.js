const newsfeedDivId = "news-div";
const reloadedTimeId = "reloaded-time";
const remoteRepoNewsJson = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/news.json";
const dayMilliseconds = 86400000;
const weekMilliseconds = dayMilliseconds * 7;
const dateFormatDisplay = {
    year: "numeric",
    month: "numeric",
    day: "numeric"
};

let date = new Date();
let news = [];

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
    let level = element.level.trim().toLowerCase();
    console.log(level)
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
    fetch(remoteRepoNewsJson)
        .then((response) => response.json())
        .then((json) => news = json)
        .then(console.log("Got stuff!"));
}

function normalize(time) {
    return time.replace("\*", date.getFullYear());
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
    console.log("Refreshing news from remote repo...");
    fetchNews();
    getDiv().innerHTML = "";

    let relevantNews = news.filter(element => isRelevant(element));
    for(let i = 0; i < news.length - 1; i++) { // why do i have to do `- 1`??
        console.log(relevantNews[i])
        relevantNews[i].importance = getImportance(relevantNews[i]);
        console.log(relevantNews[i])
    }

    relevantNews.sort(function(a, b) {
        return b.importance - a.importance;
    });

    relevantNews.forEach(element => {
        addElement(element);
    });

    // Add "error" message:
    if(relevantNews.length == 0) {
        let msg = "";
        // There are no relevant news:
        if(news.length != 0) {
            msg = p(["Derzeit keine relevanten Neuigkeiten vorhanden."]);
        }
        // There are NO news (probably a network error):
        else {
            msg = p([
                "Derzeit keine Neuigkeiten vorhanden.",
                "Klicke auf den \"Neu laden\" Knopf, um nochmals nach Neuigkeiten zu suchen.",
                "Diese Fehlermeldung kann ein auf eine schlechte/nicht vorhandene Internetverbindung deuten."
            ]);
        }
        addToDiv(msg);
    }

    // Debug:
    function debugPrint() {
        const infos = [
            "All news: ",
            news,
            "---------",
            "Relevant news: ",
            relevantNews
        ];
        infos.forEach(element => {
            console.log(element)
        });
    }
    // Update "refreshed at `time`" text:
    function updateRefreshedAt() {
        date = new Date();
        let time = date.toLocaleTimeString("de-DE");
        document.getElementById(reloadedTimeId).innerHTML = "Aktualisiert um " + time;
    }
    debugPrint();
    updateRefreshedAt();
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
document.onload =
    refreshNews();