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
    if(element.selectedIndex == 0) {
        return;
    }
    window.location.href = element.value;
}
