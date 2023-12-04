const newsfeedDivId = "news-div";
const remoteRepoNewsJson = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/news.json";
const date = new Date();

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

function normalize(date) {
    /** Converts good format "yyyy-MM-dd" to ugly format "MM/dd/yyyy" */
    const now = new Date();
    let d = date.split("-");
    // Wildcard for every-year events:
    if(d[0] == "*") {
        d[0] = now.getFullYear();
    }
    console.log(d)
    return [d[1], d[2], d[0]].join("/");
}

function readable(date) {
    /** Gets the date in a more readable format "dd.MM.yyyy" from "yyyy-MM-dd" */
    let now = new Date();
    let d = date.split("-");
    let
        year = d[0],
        month = d[1],
        day = d[2]
    if(year == "*") { year = now.getFullYear() }
    return [day, month, year].join(".");
}

function isRelevant(element) {
    /** Filters irrelevant news (depending on the date) */
    let now = new Date();
    let unixFrom = new Date(normalize(element.from)).getTime();
    let unixTill = new Date(normalize(element.till)).getTime() + 86400000;
    let unixNow = now.getTime();
    console.log([unixNow, "----", unixFrom, unixTill].join("\n"))
    return unixNow <= unixTill && unixNow >= unixFrom;
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
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
document.onload =
    refreshNews();
