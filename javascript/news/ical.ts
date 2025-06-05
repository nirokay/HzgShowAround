const CURRENT_TIME = "CURRENT_TIME";
const ID = "ID";
const DATE_START = "DATE_START";
const DATE_END = "DATE_END";
const TIME_START = "TIME_START";
const TIME_END = "TIME_END";
const SUMMARY = "SUMMARY";
const DESCRIPTION = "DESCRIPTION";
const LOCATION = "LOCATION";

const Variables: string[] = [
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

type EnumDictionary<T extends string | symbol | number, U> = {
    [K in T]: U;
};

const icalTemplateHead: string = `BEGIN:VCALENDAR
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
const icalTemplateFoot: string = `END:VCALENDAR`;

const icalTemplateFullDay: string = `BEGIN:VEVENT
DTSTAMP:{CURRENT_TIME}Z
UID:{ID}@hzgshowaround.nirokay.com
DTSTART;VALUE=DATE:{DATE_START}
DTEND;VALUE=DATE:{DATE_END}
SUMMARY:{SUMMARY}
URL:https://www.nirokay.com/HzgShowAround/newsfeed.html
DESCRIPTION:{DESCRIPTION}
LOCATION:{LOCATION}
END:VEVENT`;
const icalTemplateTimeSpan: string = `BEGIN:VEVENT
DTSTAMP:{CURRENT_TIME}Z
UID:{ID}@hzgshowaround.nirokay.com
DTSTART;TZID=Europe/Berlin:{DATE_START}T{TIME_START}
DTEND;TZID=Europe/Berlin:{DATE_END}T{TIME_END}
SUMMARY:{SUMMARY}
URL:https://www.nirokay.com/HzgShowAround/newsfeed.html
DESCRIPTION:{DESCRIPTION}
LOCATION:{LOCATION}
END:VEVENT`;

function getIcalDateFormat(
    time: string,
    reverse: boolean = false,
    sep: string = "-",
): string {
    let components = time.split(sep);
    if (reverse) components.reverse();
    if (components[1].length == 1)
        components[1] = "0" + components[1].toString();
    if (components[2].length == 1)
        components[2] = "0" + components[2].toString();
    return components.join("");
}
function getVariable(name: string): string {
    return "{" + name + "}";
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

function getIcalFileContent(event: NewsFeedElement): string {
    let date: Date = new Date();
    let currentTimeStamp: string = getIcalDateFormat(
        [
            date.getFullYear(),
            formatNumber(date.getMonth()),
            formatNumber(date.getDate()),
        ].join("-"),
    );
    let dateStartString: string =
        event.from ?? event.on ?? event.till ?? "1970-01-01";
    let dateEnd = new Date(
        event.till ?? event.on ?? event.from ?? "1970-01-01",
    );

    let timeStart: string;
    let timeEnd: string;
    switch (event.icalEventType) {
        case EventType.fullDay:
            formatNumber(dateEnd.setDate(dateEnd.getDate() + 1));
            timeStart = "000000";
            timeEnd = "000000";
            break;
        case EventType.timeSpan:
            timeStart = event.icalDateOrTimes[0] ?? "000000";
            timeEnd = event.icalDateOrTimes[1] ?? "235959";
            break;
    }

    let dateEndString: string = [
        dateEnd.getFullYear(),
        formatNumber(date.getMonth()),
        formatNumber(date.getDate()),
    ].join("");

    // Construct template:
    let result: string = icalTemplateHead + "\n";
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
    let dictionary: EnumDictionary<string, string> = {
        SUMMARY: fixHtmlString(event.name),
        DESCRIPTION: fixHtmlString(
            (event.details ?? ["Keine Details vorhanden."]).join("\n"),
        ),
        CURRENT_TIME: currentTimeStamp,
        DATE_START: dateStartString,
        DATE_END: dateEndString,
        ID:
            replaceAll(event.name.toLowerCase(), " ", "") +
            dateStartString +
            "-" +
            dateEndString +
            "-" +
            currentTimeStamp,
        TIME_START: timeStart,
        TIME_END: timeEnd,
        LOCATION: fixHtmlString(
            (event.locations ?? ["Herzogsägmühle"]).join(", "),
        ),
    };

    for (const key in Variables) {
        let variable: string = Variables[key];
        let value: string = dictionary[variable];
        result = replaceAll(result, getVariable(variable), value);
        console.log(key, variable, value);
    }

    console.log(dictionary);

    return btoa(result);
}

function downloadIcalFile(filename: string, content: string) {
    let element = document.createElement("a");
    let actualContent = encodeURI(atob(content));
    element.setAttribute(
        "href",
        "data:text/plain;charset=utf-8," + actualContent,
    );
    element.setAttribute("download", filename);

    element.style.display = "none";
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}
