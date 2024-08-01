/*

    Javascript for each location page
    =================================

*/
const debugPrintingEnabled = true;

const idLocationNameId = "newsfeed-location-id";
const idNewsfeedEnclave = "newsfeed-enclave";

function debug(message, element) {
    if(!debugPrintingEnabled) {
        return;
    }
    const separator = "================================================";
    if(element != undefined && element != "" && element != null) {
        console.log("===== " + message + " ===== :");
        console.log(element);
        console.log(separator);
    } else {
        console.log("===== " + message + " =====");
    }
}

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

window.onload = () => {
    debug("Running newsfeed enclave script on location: " + getLocationName());
}
