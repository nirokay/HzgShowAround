"use strict";
const idNewsFeed = "news-div";
const idReloadedTime = "reloaded-time";
let currentlyRefreshing = false;
let refreshLock = false;
let errorMessageAdditional = "";
const errorMessageNoInternet = [
    "Es konnte keine Internetverbindung zum Server hergestellt werden.",
    "Dies kann an einer schlechten oder nicht vorhandenen Internetverbindung liegen.",
    "Überprüfe Diese und versuche es später noch einmal."
];
const errorMessageParsingFuckUp = [
    "Es ist ein Fehler bei der Datenverarbeitung geschehen.",
    "Bitte gib uns Bescheid, indem du <a href='https://github.com/nirokay/HzgShowAroundData/issues/new'>ein Issue auf GitHub eröffnest</a>!"
];
const infoMessageNoNews = [
    "Keine Neuigkeiten vorhanden."
];
const infoMessageNoRelevantNews = [
    "Derzeit keine relevanten Neuigkeiten vorhanden."
];
function newsfeed() {
    let result = document.getElementById(idNewsFeed);
    if (result == null) {
        return new HTMLElement;
    } // wtf is this, lmao
    return result;
}
function addToNewsfeed(content) {
    newsfeed().insertAdjacentHTML("beforeend", content);
}
function addErrorMessage(content) {
    newsfeed().insertAdjacentHTML("afterbegin", "<p>" + content.join("<br />") + "</p>");
}
function updateRefreshedAt(override) {
    let newText = "";
    if (override == "" || override == undefined) {
        date = new Date();
        let time = date.toLocaleTimeString("de-DE");
        newText = "Aktualisiert um " + time;
    }
    else {
        newText = override;
    }
    let reloadTime = document.getElementById(idReloadedTime);
    if (reloadTime == null) {
        debug("Could not find reloadTime element");
        return;
    }
    reloadTime.innerHTML = newText;
}
async function refreshNewsfeed() {
    // Block thingy going twice (or worse: MULTIPLE times)
    if (refreshLock) {
        debug("Blocking refresh due to lock.");
        return;
    }
    refreshLock = true;
    // Fetching:
    debug("Fetching from remote repository");
    updateRefreshedAt("Verbindung zum Server wird hergestellt...");
    try {
        await refetchNews();
    }
    catch (error) {
        updateRefreshedAt(errorMessageNoInternet.join("<br />"));
        return;
    }
    // Updating HTML:
    newsfeed().innerHTML = "";
    updateRefreshedAt("Daten werden verarbeitet...");
    await rebuildNews();
    updateRefreshedAt("Daten werden angezeigt...");
    relevantNews.forEach((element) => {
        let htmlElement = addLocationLinks(generateElementHtml(element));
        addToNewsfeed(htmlElement);
    });
    updateRefreshedAt();
    // Terminator error messages:
    if (errorPanicNoInternet) {
        addErrorMessage(errorMessageNoInternet);
    }
    else if (errorPanicParsingFuckUp) {
        addErrorMessage(errorMessageParsingFuckUp);
    }
    // "Soft" error messages:
    if (normalizedNews.length == 0) {
        addErrorMessage(infoMessageNoNews);
    }
    else if (relevantNews.length == 0) {
        addErrorMessage(infoMessageNoRelevantNews);
    }
    // Release lock, allow next execution:
    refreshLock = false;
}
window.onload = async () => {
    await refreshNewsfeed();
};
