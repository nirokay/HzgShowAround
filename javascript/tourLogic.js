// This script has all logic for the tour

const iframeId = "location-display";

let currentLocation = 0;
let tourLocations = []
let fetching = fetch('https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/tour_locations.json')
    .then((response) => response.json())
    .then((json) => tourLocations = json);

// Changes the source of the iframe:
function setSource() {
    document.getElementById(iframeId).src = ("location/" + tourLocations[currentLocation] + ".html");
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

// document.onload = setSource();
