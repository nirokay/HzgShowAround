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
    if(element == null) {
        console.log("Failed to find '" + locationDropDownId + "'...");
        alert("Irgendwas ist schief gelaufen... :(");
        return;
    }
    if(element.index <= 0) {
        return;
    }
    window.location.href = element.value;
}
