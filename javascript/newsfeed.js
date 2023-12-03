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

function addElement(element) {
    getDiv().insertAdjacentHTML('beforeend', getHtml(element));
}

function fetchNews() {
    fetch(remoteRepoNewsJson)
        .then((response) => response.json())
        .then((json) => news = json)
        .then(console.log("Got stuff!"));
}

function isRelevant(element) {
    return true
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
}

// Defer this little bad-boy, because otherwise everything goes up in flames:
document.onload =
    refreshNews()
