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
    const separator = "================================================";
    if (element != undefined && element != "" && element != null) {
        console.log("===== " + message + " ===== :");
        console.log(element);
        console.log(separator);
    }
    else {
        console.log("===== " + message + " =====");
    }
}
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
