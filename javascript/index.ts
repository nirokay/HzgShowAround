/*

    Logic for Index page
    ====================

    This script basically only handles the drop-down menu.

*/

const locationDropDownId = "index-location-drop-down";

function getElement(): HTMLOptionElement {
    return document.getElementById(locationDropDownId) as HTMLOptionElement;
}

function changeToLocationPage(): void {
    let element: HTMLOptionElement = getElement();
    if(element.index <= 0) {
        return;
    }
    window.location.href = element.value;
}
