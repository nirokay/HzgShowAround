"use strict";
/*

    Javascript for each location page
    =================================

*/
const idLocationNameId = "newsfeed-location-id";
const idNewsfeedEnclave = "newsfeed-enclave";
let locationNews = [];
let locationName = getLocationName();
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
    elements.forEach(element => {
        try {
            if (element.locations == undefined) {
                return;
            }
            let alreadyFound = false;
            element.locations.forEach(location => {
                var _a;
                // Do not add duplicates:
                if (alreadyFound) {
                    return;
                }
                // Add if name matches and event did not already happen:
                if (location == locationName && ((_a = element.importance) !== null && _a !== void 0 ? _a : -99) > -10) {
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
    locationNews.forEach(element => {
        appendToEnclave(generateElementHtml(element));
    });
}
window.onload = async () => {
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
