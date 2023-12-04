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
    html += "<h5>von " + element.from + " bis " + element.till + "</h5>";

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

function isRelevant(element) {
    let now = new Date();
    function toUgly(time) {
        let temp = time.split("-");
        // Wildcard for every-year events:
        if(temp[2] == "*") {
            temp[2] = now.getFullYear();
        }
        return [temp[1], temp[2], temp[0]].join("/");
    }
    let unixFrom = new Date(toUgly(element.from)).getTime();
    let unixTill = new Date(toUgly(element.till)).getTime();
    let unixNow = now.getTime();
    return unixNow <= unixTill && unixNow >= unixFrom;
}

function refreshNews() {
    console.log("Refreshing news from remote repo...");
    fetchNews();
    getDiv().innerHTML = "";
    console.log(news);
    news.forEach(element => {
        if(isRelevant(element)) {
            addElement(element);
        }
    });
    if(news.length == 0) {
        addToDiv("<p>Derzeit sind keine Neuigkeiten vorhanden.<br />Klicke auf \"Neu laden\", um zu sehen ob doch Neuigkeiten vorhanden sind!</p>");
    }
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
document.onload =
    refreshNews();
