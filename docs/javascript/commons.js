"use strict";
/*

    Shared logic across all modules
    ===============================

*/
let debugPrintingEnabled = true; // Allows easy debugging in browser console
function debug(message, element = undefined) {
    if (!debugPrintingEnabled) {
        return;
    }
    if (element != undefined && element != "" && element != null) {
        console.log("[DEBUG] " + message + ":", element);
    }
    else {
        console.log("[DEBUG] " + message);
    }
}
// Text -----------------------------------------------------------------------
function replaceAll(input, it, by) {
    let result = input;
    let oldResult = result;
    do {
        oldResult = result;
        result = result.replace(it, by);
    } while (oldResult != result);
    return result;
}
function fixHtmlString(input) {
    let table = [
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
function formatNumber(n) {
    let result = n.toString();
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
function icalTimeToNormal(icalTime) {
    let time = icalTime.split(":").join("");
    while (time.length < 6) {
        time += "0";
    }
    let result = [];
    result.push(time[0] + time[1]);
    result.push(time[2] + time[3]);
    return "<time>" + result.join(":") + " Uhr </time>";
}
// Redirections ---------------------------------------------------------------
const urlRedirectionList = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/json/redirections.json";
async function getRedirectionList() {
    let result = {};
    let response = await fetch(urlRedirectionList);
    let json = JSON.parse(await response.text());
    Object.entries(json).forEach(([oldPage, newPage]) => {
        result[oldPage] = newPage;
    });
    return result;
}
async function redirectToUpdatedPage() {
    let pageNameParts = window.location.href.split("/");
    let pageName = pageNameParts[pageNameParts.length - 1].split("#")[0].split("?")[0].split("&")[0];
    let list = await getRedirectionList();
    if (pageName in list) {
        console.log("Redirecting to updated page: " + list[pageName]);
        window.location.href = list[pageName];
    }
}
redirectToUpdatedPage(); // keep in background
// URI Parameters -------------------------------------------------------------
function getURIParams() {
    let result = {};
    let raw = (window.location.href.split("?")[1] ?? "").split("#")[0] ?? "";
    if (raw == undefined || raw == "")
        return result;
    let parts = raw.split("&");
    parts.forEach((part) => {
        let splits = part.split("=");
        let key = splits[0] ?? "";
        let value = splits[1] ?? "";
        if (key == undefined || key == "")
            return;
        result[key] = value;
    });
    return result;
}
function encodeToURI(params) {
    let result = window.location.href.split("?")[0].split("#")[0];
    let pairs = [];
    Object.entries(params).forEach(([key, value]) => {
        pairs.push(key + "=" + value);
    });
    if (pairs.length > 0)
        result += "?" + pairs.join("&");
    return result;
}
// Metered Connections: -------------------------------------------------------
function clientIsProbablyMobileDevice() {
    // This should probably work? idk:  portrait mode && low width -> probably phone? i know this is hacky qwq
    return window.screen.width < window.screen.height && window.screen.width < 900;
}
function isMeteredConnection() {
    if (!("connection" in navigator))
        return clientIsProbablyMobileDevice();
    // TS is a bit too nerdy here, relying on vibe-based approach of JS:
    let connection = navigator.connection;
    if (connection == undefined)
        return false;
    // Explicit:
    if (connection.saveData === true)
        return true;
    // Implicit:
    if (connection.type == "cellular")
        return true;
    if (["slow-2g", "2g"].includes(connection.effectiveType))
        return true;
    return false;
}
