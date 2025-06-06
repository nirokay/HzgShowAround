/*

    Shared logic across all modules
    ===============================

*/

let debugPrintingEnabled: boolean = true; // Allows easy debugging in browser console

function debug(message: string, element: any = undefined): void {
    if (!debugPrintingEnabled) {
        return;
    }
    const separator: string =
        "================================================";
    if (element != undefined && element != "" && element != null) {
        console.log("===== " + message + " ===== :");
        console.log(element);
        console.log(separator);
    } else {
        console.log("===== " + message + " =====");
    }
}

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
