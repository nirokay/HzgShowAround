"use strict";
/*

    Logic for Tour page
    ===================

    ATTENTION: this script itself does not fully work, I needed a little bit
    of trickery using Nim when generating the HTML. The first location is
    "pre-selected" so to speak.

*/
const urlTourLocations = "https://raw.githubusercontent.com/nirokay/HzgShowAround/refs/heads/master/docs/resources/tour_locations.json";
const iframeId = "location-display";
const progressId = "tour-progress";
let tourLocations = [];
let currentLocation = 0;
async function fetchLocations() {
    let response;
    try {
        response = await fetch(urlTourLocations);
        let a = [];
        console.log(a[2]);
    }
    catch (e) {
        console.error(e);
        alert("Liste der Orte konnte nicht geladen werden :( Überprüfe deine Internetverbindung, und falls das Problem besteht, melde es gerne hier: https://github.com/nirokay/HzgShowAround/issues");
        return;
    }
    let raw = await response.text();
    let json = JSON.parse(raw);
    tourLocations = json;
}
fetchLocations();
function setSource() {
    let iframe = document.getElementById(iframeId);
    let progress = document.getElementById(progressId);
    iframe.src = "location/" + tourLocations[currentLocation] + ".html";
    progress.value = currentLocation + 1;
}
function prevLocation() {
    if (currentLocation <= 0) {
        alert("Du bist am Anfang der Tour, du kannst nicht zurückgehen...");
        currentLocation = 0;
        return;
    }
    currentLocation--;
    setSource();
}
function nextLocation() {
    let max = tourLocations.length - 1;
    if (currentLocation >= max) {
        alert("Du hast die digitale Tour durch Herzogsägmühle abgeschlossen!");
        currentLocation = max;
        return;
    }
    currentLocation++;
    setSource();
}
