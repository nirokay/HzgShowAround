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
    let result: string[] = [];
    for (let locationName in locationLookupTable) {
        // Add human-readable names to list:
        let obj = locationLookupTable[locationName];
        let alias: string[] = obj.names;
        let humanNames: string[] = [locationName].concat(alias);
        result = result.concat(humanNames);
    }

    // Deduplicate entries:
    result.forEach(item => {
        let newItem: string = item.toLowerCase();
        if(locationArray.includes(newItem)) return;
        locationArray = locationArray.concat([newItem]);
    });
}

function getPathFor(location: string): string|null {
    if (! locationArray.includes(location)) return null;
    let result: string|null = null;
    for (let locationName in locationLookupTable) {
        let obj = locationLookupTable[locationName];
        let alias: string[] = [];
        obj.names.forEach(name => {
            alias = alias.concat([name.toLowerCase()]);
        });
        let path: string = obj.path;
        if (location.toLowerCase() == locationName.toLowerCase() || alias.includes(location)) {
            result = path;
            return result;
        }
    }
    return result;
}
function getPathForSelectedLocation(): string|null {
    let searchBar: HTMLInputElement|null = document.getElementById(locationSearchBarId) as HTMLInputElement;
    if(searchBar == null) return null;
    let locationName: string = searchBar.value;
    return locationName.toLowerCase();
}

function searchBarButtonClick() {
    let locationName: string|null = getPathForSelectedLocation();
    if(locationName == null) return;
    let path: string|null = getPathFor(locationName);
    if(path == null) return;
    window.location.href = path;
}

window.onload = async() => {
    await getLocationLookupTable();
    locationArray = [];
    populateLocationArray();
    autocompleteLocationSearchBar(document.getElementById(locationSearchBarId), locationArray);
}
