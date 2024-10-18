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
