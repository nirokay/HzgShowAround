/*

    Logic for Tour page
    ===================

    ATTENTION: this script itself does not fully work, I needed a little bit
    of trickery using Nim when generating the HTML. The first location is
    "pre-selected" so to speak.

*/

const urlTourLocations: string =
    "https://raw.githubusercontent.com/nirokay/HzgShowAround/refs/heads/master/docs/resources/tour_locations.json";

const iframeId: string = "location-display";
const progressId: string = "tour-progress";

let tourLocations: string[] = [];
let currentLocation: number = 0;

async function fetchLocations() {
    let response: Response;
    try {
        response = await fetch(urlTourLocations);
    } catch (e) {
        console.error(e);
        alert(
            "Liste der Orte konnte nicht geladen werden :( Überprüfe deine Internetverbindung, " +
                "und falls das Problem besteht, melde es gerne hier: https://github.com/nirokay/HzgShowAround/issues",
        );
        return;
    }
    let raw: string = await response.text();
    let json = JSON.parse(raw) as string[];
    tourLocations = json;
}
fetchLocations();

function setSource() {
    let iframe: HTMLIFrameElement = document.getElementById(
        iframeId,
    ) as HTMLIFrameElement;
    let progress: HTMLProgressElement = document.getElementById(
        progressId,
    ) as HTMLProgressElement;

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
    let max: number = tourLocations.length - 1;
    if (currentLocation >= max) {
        alert("Du hast die digitale Tour durch Herzogsägmühle abgeschlossen!");
        currentLocation = max;
        return;
    }
    currentLocation++;
    setSource();
}
