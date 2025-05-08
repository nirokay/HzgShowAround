"use strict";
var Variable;
(function (Variable) {
    Variable["currentTime"] = "CURRENT_TIME";
    Variable["id"] = "ID";
    Variable["dateStart"] = "DATE_START";
    Variable["dateEnd"] = "DATE_END";
    Variable["timeStart"] = "TIME_START";
    Variable["timeEnd"] = "TIME_END";
    Variable["summary"] = "SUMMARY";
    Variable["description"] = "DESCRIPTION";
    Variable["location"] = "LOCATION";
})(Variable || (Variable = {}));
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
function getVariable(name) {
    return "{" + name.toString() + "}";
}
function getIcalFileContent(event) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
    let date = new Date();
    let currentTimeStamp = getIcalDateFormat([date.getFullYear(), date.getMonth(), date.getDate()].join("-"));
    let dateStartString = (_c = (_b = (_a = event.from) !== null && _a !== void 0 ? _a : event.on) !== null && _b !== void 0 ? _b : event.till) !== null && _c !== void 0 ? _c : "1970-01-01";
    let dateEnd = new Date((_f = (_e = (_d = event.till) !== null && _d !== void 0 ? _d : event.on) !== null && _e !== void 0 ? _e : event.from) !== null && _f !== void 0 ? _f : "1970-01-01");
    let timeStart;
    let timeEnd;
    switch (event.icalEventType) {
        case EventType.fullDay:
            dateEnd.setDate(dateEnd.getDate() + 1);
            timeStart = "000000";
            timeEnd = "000000";
            break;
        case EventType.timeSpan:
            timeStart = (_g = event.icalDateOrTimes[0]) !== null && _g !== void 0 ? _g : "000000";
            timeEnd = (_h = event.icalDateOrTimes[1]) !== null && _h !== void 0 ? _h : "235959";
            break;
    }
    let dateEndString = [
        dateEnd.getFullYear(),
        date.getMonth(),
        date.getDate(),
    ].join("");
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
        [Variable.summary]: event.name,
        [Variable.description]: ((_j = event.details) !== null && _j !== void 0 ? _j : ["Keine Details vorhanden."]).join("\n"),
        [Variable.currentTime]: currentTimeStamp,
        [Variable.dateStart]: dateStartString,
        [Variable.dateEnd]: dateEndString,
        [Variable.id]: event.name.toLowerCase().replace(" ", "") +
            dateStartString +
            "-" +
            dateEndString +
            "-" +
            currentTimeStamp,
        [Variable.timeStart]: timeStart,
        [Variable.timeEnd]: timeEnd,
        [Variable.location]: ((_k = event.locations) !== null && _k !== void 0 ? _k : ["Herzogsägmühle"]).join(", "),
    };
    for (const key in [
        Variable.currentTime,
        Variable.dateEnd,
        Variable.dateStart,
        Variable.description,
        Variable.id,
        Variable.location,
        Variable.summary,
        Variable.timeEnd,
        Variable.timeStart,
    ]) {
        let variable = getVariable(key.toString());
        let value = dictionary[key];
        result.replace(variable, value);
        console.log(key, variable, value);
    }
    return encodeURIComponent(result);
}
function downloadIcalFile(filename, content) {
    var element = document.createElement("a");
    element.setAttribute("href", "data:text/plain;charset=utf-8," + content);
    element.setAttribute("download", filename);
    element.style.display = "none";
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
}
