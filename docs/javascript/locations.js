"use strict";
/*

    Javascript for each location page
    =================================

*/
const idLocationNameId = "newsfeed-location-id";
const idNewsfeedEnclave = "newsfeed-enclave";
const classDeprecationDiv = "location-deprecation-notice-div";
const classDeprecationHeader = "location-deprecation-notice-header";
let locationNews = [];
let locationName = getLocationName();
let locationIsDeprecated = true;
function getLocationName() {
    let variable = document.getElementById(idLocationNameId);
    if (variable == null) {
        debug("Missing location variable " + idLocationNameId);
        return "";
    }
    return variable.innerText;
}
function appendToEnclave(html) {
    let enclave = document.getElementById(idNewsfeedEnclave);
    if (enclave == null) {
        debug("Missing newsfeed enclave " + idNewsfeedEnclave);
        return;
    }
    enclave.insertAdjacentHTML("beforeend", html);
}
function filteredLocationNews(elements) {
    debug("Filtering location news...");
    let result = [];
    elements.forEach((element) => {
        try {
            if (element.locations == undefined) {
                return;
            }
            let alreadyFound = false;
            element.locations.forEach((location) => {
                // Do not add duplicates:
                if (alreadyFound) {
                    return;
                }
                // Add if name matches and event did not already happen:
                if (location == locationName &&
                    (element.importance ?? -99) > -10) {
                    result.push(element);
                    alreadyFound = true;
                }
            });
        }
        catch (error) {
            debug("Failed to filter location on news element ", element);
        }
    });
    debug("Finished filtering.");
    return result;
}
function injectIntoEnclave() {
    appendToEnclave("<h2><a href='../newsfeed.html'>Relevante Neuigkeiten</a></h2>");
    locationNews.forEach((element) => {
        appendToEnclave(generateElementHtml(element));
    });
}
function displayDeprecationNotice() {
    appendToEnclave("<div class='" +
        classDeprecationDiv +
        "'>" +
        "<h2 class='" +
        classDeprecationHeader +
        "'>Nicht aktuelle Seite</h2>" +
        "<p>" +
        [
            "Diese Seite ist nicht mehr aktuell und ist nur für Abwärtskompatibilität da.",
            "Informationen können hier veraltet oder inkorrekt sein.",
            "In den meisten Fällen gibt es eine überarbeitete Seite mit aktuellen Informationen, schau doch mal bei der <a href='../index.html#orte'>Übersicht der Orte</a> vorbei! :)",
        ].join("<br>") +
        "</p>" +
        "</div>");
}
window.onload = async () => {
    // Deprecated location notice:
    await getLocationLookupTable();
    for (const [name, _] of Object.entries(locationLookupTable)) {
        if (name == getLocationName()) {
            locationIsDeprecated = false;
            debug("Site is not deprecated, not showing alert.");
            break;
        }
    }
    if (locationIsDeprecated) {
        debug("Site is deprecated, showing alert.");
        displayDeprecationNotice();
        // alert(
        //     "Diese Seite ist nicht mehr aktuell, schau nach ob es eine Überarbeitete gibt, " +
        //     "oder sei im Klaren, dass Informationen sehr veraltet und/oder fehlerhaft sein können! :)"
        // );
    }
    // Newsfeed:
    debug("Running newsfeed enclave script on location: " + getLocationName());
    await refetchNews();
    await rebuildNews();
    locationNews = filteredLocationNews(relevantNews);
    if (locationNews.length != 0) {
        debug("Location news", locationNews);
        injectIntoEnclave();
    }
    debug("Finished newsfeed enclave script.");
};
