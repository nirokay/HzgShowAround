/*

    Shared logic across all modules
    ===============================

*/

let debugPrintingEnabled: boolean = true; // Allows easy debugging in browser console

function debug(message: string, element: any = undefined): void {
    if (!debugPrintingEnabled) {
        return;
    }
    if (element != undefined && element != "" && element != null) {
        console.log("[DEBUG] " + message + ":", element);
    } else {
        console.log("[DEBUG] " + message);
    }
}


// Text -----------------------------------------------------------------------

function replaceAll(input: string, it: string, by: string): string {
    let result = input;
    let oldResult = result;
    do {
        oldResult = result;
        result = result.replace(it, by);
    } while (oldResult != result);
    return result;
}

function fixHtmlString(input: string): string {
    let table: Array<string[]> = [
        ["<q>", "„"],
        ["</q>", "“"],
        ["<i>", ""],
        ["</i>", ""],
    ];

    let result = input;
    for (const id in table) {
        result = replaceAll(result, table[id][0], table[id][1]);
    }
    return result;
}


// Time -----------------------------------------------------------------------

function formatNumber(n: number | string): string {
    let result: string = n.toString();
    switch (result.length) {
        case 0:
            result = "00";
            break;
        case 1:
            result = "0" + result;
            break;
        default:
            break;
    }
    return result;
}

function icalTimeToNormal(icalTime: string): string {
    let time: string = icalTime.split(":").join("");
    while (time.length < 6) {
        time += "0";
    }

    let result: string[] = [];
    result.push(time[0] + time[1]);
    result.push(time[2] + time[3]);
    return "<time>" + result.join(":") + " Uhr </time>";
}


// Redirections ---------------------------------------------------------------

const urlRedirectionList: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/json/redirections.json";
async function getRedirectionList(): Promise<Record<string, string>> {
    let result: Record<string, string> = {}
    let response: Response = await fetch(urlRedirectionList)
    let json: JSON = JSON.parse(await response.text())

    Object.entries(json).forEach(([oldPage, newPage]) => {
        result[oldPage] = newPage;
    });

    return result;
}
async function redirectToUpdatedPage() {
    let pageNameParts: string[] = window.location.href.split("/")
    let pageName: string = pageNameParts[pageNameParts.length - 1].split("#")[0].split("?")[0].split("&")[0];
    let list: Record<string, string> = await getRedirectionList();
    if (pageName in list) {
        console.log("Redirecting to updated page: " + list[pageName]);
        window.location.href = list[pageName];
    }
}
redirectToUpdatedPage(); // keep in background


// URI Parameters -------------------------------------------------------------

function getURIParams(): Record<string, string> {
    let result: Record<string, string> = {};

    let raw: string = (window.location.href.split("?")[1] ?? "").split("#")[0] ?? "";
    if (raw == undefined || raw == "") return result;

    let parts: string[] = raw.split("&")
    parts.forEach((part: string) => {
        let splits: string[] = part.split("=");
        let key: string = splits[0] ?? "";
        let value: string = splits[1] ?? "";

        if (key == undefined || key == "") return;
        result[key] = value;
    });

    return result;
}
function encodeToURI(params: Record<string, string>): string {
    let result = window.location.href.split("?")[0].split("#")[0];

    let pairs: string[] = [];
    Object.entries(params).forEach(([key, value]) => {
        pairs.push(key + "=" + value);
    });

    if (pairs.length > 0) result += "?" + pairs.join("&");
    return result;
}


// Metered Connections --------------------------------------------------------

const dynamicResolutionClass: string = "dynamic-resolution";

function clientIsProbablyMobileDevice(): boolean {
    // This should probably work? idk:  portrait mode && low width -> probably phone? i know this is hacky qwq
    return window.screen.width < window.screen.height && window.screen.width < 900;
}
function isMeteredConnection(): boolean {
    if (!("connection" in navigator)) return clientIsProbablyMobileDevice();
    // TS is a bit too nerdy here, relying on vibe-based approach of JS:
    let connection: any = navigator.connection;
    if (connection == undefined) return false;
    // Explicit:
    if (connection.saveData === true) return true;
    // Implicit:
    if (connection.type == "cellular") return true;
    if (["slow-2g", "2g"].includes(connection.effectiveType)) return true;

    return false;
}

function restoreImageResolutions() {
    let collection: HTMLCollectionOf<Element> = document.getElementsByClassName(dynamicResolutionClass);
    if (collection.length == 0) return;
    debug("Restoring quality of images with class: " + dynamicResolutionClass);
    Array.from(collection).forEach((element: Element) => {
        let image: HTMLImageElement = element as HTMLImageElement;
        let src: string = image.src;
        let ending: string = src.split("_")[1] ?? ".webp";
        switch (ending) {
            case "nano.webp":
                src = src.replace("_nano.webp", "_mini.webp");
                break;
            case "mini.webp":
                src = src.replace("_mini.webp", ".webp");
                break;
            case ".webp":
                // why would i make this dynamic, if its already full-res?
                break;
            default:
                // oopsie, something really fucked up
                debug("FUCK, why is element dynamic-resolution?", image);
                break;
        }
        if (image.src != src) debug("Dynamic resolution, replacing '" + image.src + "' with '" + src + "'.")
        else debug("Keeping resolution for '" + src + "'...")
        image.src = src;

    })
}
function displayFullResolutionImages() {
    if (isMeteredConnection()) {
        debug("Metered connection, keeping low-resolution images")
        return;
    }
    debug("Non-metered connection, restoring full-resolution location images")
    restoreImageResolutions();
}

window.addEventListener("load", displayFullResolutionImages);
