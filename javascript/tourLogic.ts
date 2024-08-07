/*

    Logic for Tour page
    ===================

    ATTENTION: this script itself does not fully work, I needed a little bit
    of trickery using Nim when generating the HTML. The first location is
    "pre-selected" so to speak.

*/

const iframeId: string = "location-display";
const progressId: string = "tour-progress";

let tourLocations: string[] = [];
let currentLocation: number = 0;

async function fetchLocations() {
    await fetch("https://nirokay.github.io/HzgShowAround/resources/tour_locations.json")
        .then((response) => response.json())
        .then((json) => tourLocations = json);
}
fetchLocations();

function setSource() {
    let iframe: HTMLIFrameElement = document.getElementById(iframeId) as HTMLIFrameElement;
    let progress: HTMLProgressElement = document.getElementById(progressId) as HTMLProgressElement;

    iframe.src = "location/" + tourLocations[currentLocation] + ".html";
    progress.value = currentLocation + 1;
}

function prevLocation() {
    if(currentLocation <= 0) {
        alert("Du bist am Anfang der Tour, du kannst nicht zurückgehen...");
        currentLocation = 0;
        return;
    }
    currentLocation--;
    setSource();
}

function nextLocation() {
    let max: number = tourLocations.length - 1;
    if(currentLocation >= max) {
        alert("Du hast die digitale Tour durch Herzogsägmühle abgeschlossen!");
        currentLocation = max;
        return;
    }
    currentLocation++;
    setSource();
}
