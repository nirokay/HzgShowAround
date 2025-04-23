"use strict";
/*

    Logic for Index page
    ====================

    This script basically only handles the drop-down menu.

*/
const locationDropDownId = "index-location-drop-down";
function getElement() {
    return document.getElementById(locationDropDownId);
}
function changeToLocationPage() {
    let element = getElement();
    if (element == null) {
        console.log("Failed to find '" + locationDropDownId + "'...");
        alert("Irgendwas ist schief gelaufen... :(");
        return;
    }
    if (element.index <= 0) {
        return;
    }
    window.location.href = element.value;
}
// Location search with auto-completion:
const locationSearchBarId = "index-location-search-bar";
const locationSearchBarSubmitButtonId = "index-location-search-bar-submit-button";
let locationArray;
function populateLocationArray() {
    let result = [];
    for (let locationName in locationLookupTable) {
        // Add human-readable names to list:
        let obj = locationLookupTable[locationName];
        let alias = obj.names;
        let humanNames = [locationName].concat(alias);
        result = result.concat(humanNames);
    }
    // Deduplicate entries:
    result.forEach((item) => {
        let newItem = item.toLowerCase();
        if (locationArray.includes(newItem))
            return;
        locationArray = locationArray.concat([newItem]);
    });
}
function getPathFor(location) {
    if (!locationArray.includes(location))
        return null;
    let result = null;
    for (let locationName in locationLookupTable) {
        let obj = locationLookupTable[locationName];
        let alias = [];
        obj.names.forEach((name) => {
            alias = alias.concat([name.toLowerCase()]);
        });
        let path = obj.path;
        if (location.toLowerCase() == locationName.toLowerCase() ||
            alias.includes(location)) {
            result = path;
            return result;
        }
    }
    return result;
}
function getPathForSelectedLocation() {
    let searchBar = document.getElementById(locationSearchBarId);
    if (searchBar == null)
        return null;
    let locationName = searchBar.value;
    return locationName.toLowerCase();
}
function searchBarButtonClick() {
    let locationName = getPathForSelectedLocation();
    if (locationName == null)
        return;
    let path = getPathFor(locationName);
    if (path == null)
        return;
    window.location.href = path;
}
window.onload = async () => {
    await getLocationLookupTable();
    locationArray = [];
    populateLocationArray();
    autocompleteLocationSearchBar(document.getElementById(locationSearchBarId), locationArray);
};
