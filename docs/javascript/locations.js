/*

    Javascript for each location page
    =================================

*/

const idLocationNameId = "newsfeed-location-id";
const idNewsfeedEnclave = "newsfeed-enclave";

/**
 * @type {NewsFeedElement[]}
 */
let locationNews = [];

/**
 * Returns the current location name, that is set in a `var` html element
 * @returns {string | undefined}
 */
function getLocationName() {
    let element = document.getElementById(idLocationNameId)
    if(element == null) {
        debug("Element does not exist", idLocationNameId)
        return undefined
    }
    return element.getHTML()
}

function getEnclave() {
    return document.getElementById(idNewsfeedEnclave);
}
function insertIntoEnclave(html) {
    let enclave = getEnclave();
    if(enclave == null) {

    }
    enclave.insertAdjacentHTML("beforeend", html);
}

function filteredLocationNews() {
    debug("Filtering news");
    let locationName = getLocationName();
    relevantNews.forEach(newsElement => {
        try {
            if(newsElement.locations == undefined) {return}
            let alreadyFound = false;
            newsElement.locations.forEach(location => {
                if(alreadyFound) {return}
                if(location == locationName) {
                    locationNews.push(newsElement);
                    alreadyFound = true;
                }
            });
        } catch(e) {
            debug("Failed to filter location on news element", newsElement);
        }
    });
}

function injectIntoEnclave() {
    insertIntoEnclave("<h2><a href='../newsfeed.html'>Relevante Neuigkeiten</a></h2>")
    locationNews.forEach(element => {
        insertIntoEnclave(generateElementHtml(element))
    });
}

window.onload = async() => {
    debug("Running newsfeed enclave script on location: " + getLocationName());
    await refreshNews();
    filteredLocationNews();
    debug("Location news", locationNews);
    injectIntoEnclave();
    console.log(locationNews)
}
