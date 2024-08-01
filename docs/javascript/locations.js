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

/**
 * Gets the newsfeed enclave
 * @returns {HTMLElement | null}
 */
function getEnclave() {
    return document.getElementById(idNewsfeedEnclave);
}
/**
 * Appends HTML strings to enclave
 * @param {string} html
 * @returns {void}
 */
function insertIntoEnclave(html) {
    let enclave = getEnclave();
    if(enclave == null) {
        debug("Fuck, where did the enclave go??");
        return;
    }
    enclave.insertAdjacentHTML("beforeend", html);
}
/**
 * Filters the news and pushes them to `locationNews`.
 * @returns {void}
 */
function filteredLocationNews() {
    debug("Filtering news");
    let locationName = getLocationName();
    relevantNews.forEach(newsElement => {
        try {
            // Yippie, type checking:
            if(newsElement.locations == undefined) {return}
            let alreadyFound = false;
            newsElement.locations.forEach(location => {
                // Do not add duplicates:
                if(alreadyFound) {return}
                // Add if name matches and event did not already happen:
                if(location == locationName && newsElement.importance > -10) {
                    locationNews.push(newsElement);
                    alreadyFound = true;
                }
            });
        } catch(e) {
            debug("Failed to filter location on news element", newsElement);
        }
    });
}

/**
 * Injects all HTML into the newsfeed enclave.
 * @returns {void}
 */
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
