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
