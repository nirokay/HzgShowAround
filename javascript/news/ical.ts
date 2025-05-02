enum Variable {
    currentTime = "CURRENT_TIME",
    id = "ID",
    dateStart = "DATE_START",
    dateEnd = "DATE_END",
    timeStart = "TIME_START",
    timeEnd = "TIME_END",
    summary = "SUMMARY",
    description = "DESCRIPTION",
    location = "LOCATION",
}

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
function variable(name: Variable): string {
    return "{" + name.toString() + "}";
}

function getIcalFileContent(event: NewsFeedElement): string {
    let date: Date = new Date();
    let currentTimeStamp: string = getIcalDateFormat(
        [date.getFullYear(), date.getMonth(), date.getDate()].join("-"),
    );
    let dateStartString: string =
        event.from ?? event.from ?? event.till ?? "1970-01-01";
    let dateEnd = new Date(
        event.till ?? event.from ?? event.on ?? "1970-01-01",
    );
    if (event.icalEventType == EventType.fullDay)
        dateEnd.setDate(dateEnd.getDate() + 1);
    let dateEndString: string = [
        dateEnd.getFullYear(),
        date.getMonth(),
        date.getDate(),
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
    let dictionary: EnumDictionary<Variable, string> = {
        [Variable.summary]: event.name,
        [Variable.description]: (
            event.details ?? ["Keine Details vorhanden."]
        ).join("\n"),
        [Variable.currentTime]: currentTimeStamp,
        [Variable.dateStart]: dateStartString,
        [Variable.dateEnd]: dateEndString,
        [Variable.id]:
            event.name.toLowerCase().replace(" ", "") +
            dateStartString +
            "-" +
            dateEndString +
            "-" +
            currentTimeStamp,
    };

    return result;
}
