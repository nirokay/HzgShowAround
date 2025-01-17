/*

    Logic for Index page
    ====================

    This script basically only handles the drop-down menu.

*/

const locationDropDownId = "index-location-drop-down";

function getElement(): HTMLOptionElement | null {
    return document.getElementById(locationDropDownId) as HTMLOptionElement;
}

function changeToLocationPage(): void {
    let element: HTMLOptionElement | null = getElement();
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

const locationSearchBarId: string = "index-location-search-bar";
const locationSearchBarSubmitButtonId: string = "index-location-search-bar-submit-button";

let locationArray: string[];

function populateLocationArray() {
    for (let locationName in locationLookupTable) {
        // Add human-readable names to list:
        let obj = locationLookupTable[locationName];
        let alias: string[] = obj.names;
        let humanNames: string[] = [locationName].concat(alias);
        locationArray.concat(humanNames);
    }
}

function getPathFor(location: string): string|null {
    if (! locationArray.includes(location)) return null;
    let result: string = "";
    for (let locationName in locationLookupTable) {
        let obj = locationLookupTable[locationName];
        let alias: string[] = obj.names;
        let path: string = obj.path;
        if (location == locationName || alias.includes(location)) {
            result = path;
            return path;
        }
    }
    return result;
}

function searchBarButtonClick() {}

window.onload = async() => {
    await getLocationLookupTable();
    populateLocationArray();
    autocompleteLocationSearchBar(document.getElementById(locationSearchBarId), locationArray);
}
