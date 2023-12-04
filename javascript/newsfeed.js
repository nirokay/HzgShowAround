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

function getDiv() {
    return document.getElementById(newsfeedDivId);
}

function getHtml(element) {
    let html = "<div class='newsfeed-element'>";

    // Title:
    html += "<h4>" + element.name + "</h4>";
    // Date range:
    html += "<h5>von " + readable(element.from) + " bis " + readable(element.till) + "</h5>";
    // Details:
    html += "<p class='generic-center'>" + element.details.join('<br />') + "</p>";

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
    return time.replace("\*", date.getFullYear())
}

function readable(time) {
    let d = new Date(Date.parse(normalize(time)))
    return d.toLocaleString("de-DE", dateFormatDisplay)
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
    relevantNews.forEach(element => {
        addElement(element);
    });
    if(relevantNews.length == 0) {
        addToDiv(
            "<p>Derzeit sind keine Neuigkeiten vorhanden.<br />" +
            "Klicke auf \"Neu laden\", um zu sehen ob doch Neuigkeiten vorhanden sind!</p>"
        );
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
        let time = date.toLocaleTimeString("de-DE")
        document.getElementById(reloadedTimeId).innerHTML = "Aktualisiert um " + time
    }
    debugPrint();
    updateRefreshedAt();
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
document.onload =
    refreshNews();
