"use strict";
const CURRENT_TIME = "CURRENT_TIME";
const ID = "ID";
const DATE_START = "DATE_START";
const DATE_END = "DATE_END";
const TIME_START = "TIME_START";
const TIME_END = "TIME_END";
const SUMMARY = "SUMMARY";
const DESCRIPTION = "DESCRIPTION";
const LOCATION = "LOCATION";
const Variables = [
    CURRENT_TIME,
    ID,
    DATE_START,
    DATE_END,
    TIME_START,
    TIME_END,
    SUMMARY,
    DESCRIPTION,
    LOCATION,
];
const icalTemplateHead = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//www.nirokay.com//HzgShowAround
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:Europe/Berlin
LAST-MODIFIED:{CURRENT_TIME}Z
TZURL:https://www.tzurl.org/zoneinfo-outlook/Europe/Berlin
X-LIC-LOCATION:Europe/Berlin
BEGIN:DAYLIGHT
TZNAME:CEST
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
DTSTART:19700329T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
END:DAYLIGHT
BEGIN:STANDARD
TZNAME:CET
TZOFFSETFROM:+0200
TZOFFSETTO:+0100
DTSTART:19701025T030000
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
END:STANDARD
END:VTIMEZONE`;
const icalTemplateFoot = `END:VCALENDAR`;
const icalTemplateFullDay = `BEGIN:VEVENT
DTSTAMP:{CURRENT_TIME}Z
UID:{ID}@hzgshowaround.nirokay.com
DTSTART;VALUE=DATE:{DATE_START}
DTEND;VALUE=DATE:{DATE_END}
SUMMARY:{SUMMARY}
URL:https://www.nirokay.com/HzgShowAround/newsfeed.html
DESCRIPTION:{DESCRIPTION}
LOCATION:{LOCATION}
END:VEVENT`;
const icalTemplateTimeSpan = `BEGIN:VEVENT
DTSTAMP:{CURRENT_TIME}Z
UID:{ID}@hzgshowaround.nirokay.com
DTSTART;TZID=Europe/Berlin:{DATE_START}T{TIME_START}
DTEND;TZID=Europe/Berlin:{DATE_END}T{TIME_END}
SUMMARY:{SUMMARY}
URL:https://www.nirokay.com/HzgShowAround/newsfeed.html
DESCRIPTION:{DESCRIPTION}
LOCATION:{LOCATION}
END:VEVENT`;
function getVariable(name) {
    return "{" + name + "}";
}
function getIcalDateFormat(time, reverse = false, sep = "-") {
    let components = time.split(sep);
    if (reverse)
        components.reverse();
    if (components[1].length == 1)
        components[1] = "0" + components[1].toString();
    if (components[2].length == 1)
        components[2] = "0" + components[2].toString();
    return components.join("");
}
function getCleanedArray(input) {
    let result = undefined;
    if (input != undefined && input != null) {
        if (input.length != 0) {
            result = input;
        }
        else {
            result = undefined;
        }
    }
    else {
        result = undefined;
    }
    return result;
}
function getIcalFileContent(event) {
    var _a, _b, _c, _d, _e, _f, _g;
    let now = new Date();
    let currentTimeStamp = [
        now.getFullYear(),
        formatNumber(now.getMonth() + 1),
        formatNumber(now.getDate()),
    ].join("");
    let dateStartString = replaceAll((_c = (_b = (_a = event.from) !== null && _a !== void 0 ? _a : event.on) !== null && _b !== void 0 ? _b : event.till) !== null && _c !== void 0 ? _c : "1970-01-01", "-", "");
    let dateEnd = new Date((_f = (_e = (_d = event.till) !== null && _d !== void 0 ? _d : event.on) !== null && _e !== void 0 ? _e : event.from) !== null && _f !== void 0 ? _f : "1970-01-01");
    let timeStart;
    let timeEnd;
    switch (event.icalEventType) {
        case EventType.fullDay:
            formatNumber(dateEnd.setDate(dateEnd.getDate() + 1));
            timeStart = "000000";
            timeEnd = "000000";
            break;
        case EventType.timeSpan:
            timeStart = event.icalTimeStart;
            timeEnd = event.icalTimeEnd;
            break;
    }
    let dateEndString = [
        dateEnd.getFullYear(),
        formatNumber(dateEnd.getMonth() + 1),
        formatNumber(dateEnd.getDate()),
    ].join("");
    let cleanedLocations = getCleanedArray(event.locations);
    let cleanedDetails = getCleanedArray((_g = event.details) !== null && _g !== void 0 ? _g : []);
    // Construct template:
    let result = icalTemplateHead + "\n";
    switch (event.icalEventType) {
        case EventType.fullDay:
            result += icalTemplateFullDay;
            break;
        case EventType.timeSpan:
            result += icalTemplateTimeSpan;
            break;
    }
    result += "\n" + icalTemplateFoot;
    // Replace all variables:
    let dictionary = {
        SUMMARY: fixHtmlString(event.name),
        DESCRIPTION: fixHtmlString((cleanedDetails !== null && cleanedDetails !== void 0 ? cleanedDetails : ["Keine Details vorhanden."]).join("\n")),
        CURRENT_TIME: currentTimeStamp,
        DATE_START: dateStartString,
        DATE_END: dateEndString,
        ID: replaceAll(event.name.toLowerCase(), " ", "") +
            dateStartString +
            "-" +
            dateEndString +
            "-" +
            currentTimeStamp,
        TIME_START: timeStart,
        TIME_END: timeEnd,
        LOCATION: fixHtmlString((cleanedLocations !== null && cleanedLocations !== void 0 ? cleanedLocations : ["Herzogsägmühle"]).join(", ")),
    };
    for (const key in Variables) {
        let variable = Variables[key];
        let value = dictionary[variable];
        result = replaceAll(result, getVariable(variable), value);
        console.log("Replaced " + variable + " with " + value);
    }
    console.log(dictionary);
    return btoa(encodeURI(result));
}
function downloadIcalFile(filename, content) {
    let element = document.createElement("a");
    let actualContent = atob(content);
    element.setAttribute("href", "data:text/plain;charset=utf-8," + actualContent);
    element.setAttribute("download", filename);
    element.style.display = "none";
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
}
