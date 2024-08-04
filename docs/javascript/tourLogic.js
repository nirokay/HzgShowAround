/*

    Logic for Tour page
    ===================

    ATTENTION: this script itself does not fully work, I needed a little bit
    of trickery using Nim when generating the HTML. The first location is
    "pre-selected" so to speak.

*/


const iframeId = "location-display";
const progressId = "tour-progress";

let currentLocation = 0;
let tourLocations = []
let fetching = fetch('https://nirokay.github.io/HzgShowAround/resources/tour_locations.json')
    .then((response) => response.json())
    .then((json) => tourLocations = json);

// Changes the source of the iframe:
function setSource() {
    document.getElementById(iframeId).src = ("location/" + tourLocations[currentLocation] + ".html");
    document.getElementById(progressId).value = currentLocation + 1;
}

// Previous button function:
function prevLocation() {
    if(currentLocation <= 0) {
        alert("Du bist am Anfang der Tour, du kannst nicht zurückgehen...");
        currentLocation = 0;
        return;
    }

    currentLocation--;
    setSource();
}

// Next button function:
function nextLocation() {
    if(currentLocation >= tourLocations.length - 1) {
        alert("Du hast die digitale Tour durch Herzogsägmühle abgeschlossen!");
        currentLocation = tourLocations.length - 1;
        return;
    }

    currentLocation++;
    setSource();
}
