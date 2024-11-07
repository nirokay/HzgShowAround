let date: Date = new Date;

let relevantNews: NewsFeedElement[] = [];
let normalizedNews: NewsFeedElement[] = [];
let rawNews: NewsFeedElement[] = [];

let healthPresentations: NewsFeedElement[] = [];
let rawHealthPresentations: HealthPresentation[] = [];

let holidays: NewsFeedElement[] = [];
let rawHolidays: object = {};

let schoolHolidays: NewsFeedElement[] = [];
let rawSchoolHolidays: SchoolHoliday[];

let errorPanicNoInternet = false;
let errorPanicParsingFuckUp = false;

async function fetchNewsFeedElements<T = NewsFeedElement>(url: string): Promise<T[]> {
    let json: JSON = JSON.parse("[]");
    try {
        let response: Response = await fetch(url);
        let text: string = await response.text();
        try {
            json = JSON.parse(text);
        } catch(error) {
            errorPanicParsingFuckUp = true;
            debug("[JSON Parse] Failed to parse json", text);
        }
    } catch(error) {
        errorPanicNoInternet = true;
        debug("[JSON Fetch] Failed to fetch json from " + url);
    }
    console.warn(json);
    let result: T[] = json as unknown as T[];
    console.warn(result);
    return result;
}

/**
 * Fetches news
 */
async function getNews() {
    rawNews = await fetchNewsFeedElements<NewsFeedElement>(urlRemoteNews);
}

/**
 * Fetches health presentations
 */
async function getHealthPresentations() {
    rawHealthPresentations = await fetchNewsFeedElements<HealthPresentation>(urlRemoteHealthPresentations);
}

/**
 * Fetches holidays
 */
async function getHolidays() {
    try {
        let response = await fetch(urlHolidayApi);
        let text = await response.text();
        let json = JSON.parse("{}");
        try {
            json = JSON.parse(text);
        } catch(error) {
            errorPanicParsingFuckUp = true;
            debug("[Holidays] Failed to parse json", text);
        }

        if(typeof(json) === "object" && json !== null) {
            rawHolidays = json;
        } else {
            debug("[Holidays] Json Parsed was not valid? How does this even happen??", json);
            rawHolidays = {};
        }
    } catch(error) {
        debug("Failed to fetch holidays", error);
    }
}

/**
 * Fetches school holidays
 */
async function getSchoolHolidays() {
    let currentYear: number = date.getFullYear();

    async function doThisYear(year: number) {
        let url: string = getUrlSchoolHolidayApi(year);
        try {
            let response = await fetch(url);
            let text = await response.text();
            let json: SchoolHoliday[] = JSON.parse("{}");
            try {
                json = JSON.parse(text);
            } catch (error) {
                errorPanicParsingFuckUp = true;
                debug("[School holidays] Failed to parse json", text);
            }

            if (typeof (json) === "object" && json !== null) {
                json.forEach(holiday => {
                    rawSchoolHolidays[rawSchoolHolidays.length] = holiday; // i want to die
                });
            } else {
                debug("[School holidays] Json Parsed was not valid? How does this even happen??", json);
            }
        } catch (error) {
            debug("Failed to fetch school holidays", error);
        }
    }

    for (let offset = -1; offset <= 1; offset++) {
        await doThisYear(currentYear + offset);
    }
}


/**
 * Refreshes news arrays
 */
async function refetchNews() {
    debug("Fetching news...");
    date = new Date;
    errorPanicNoInternet = false;
    errorPanicParsingFuckUp = false;

    relevantNews = [];
    normalizedNews = [];
    rawNews = [];

    healthPresentations = [];
    rawHealthPresentations = [];

    holidays = [];
    rawHolidays = {};

    schoolHolidays = [];
    rawSchoolHolidays = [];

    await Promise.all([
        getNews(),
        getHealthPresentations(),
        getHolidays(),
        getSchoolHolidays()
    ]);

    debug("Fetching complete!")
}

/**
 * Rebuild news arrays
 */
async function rebuildNews() {
    debug("Rebuilding news...");
    normalizedNews = normalizedElements(rawNews);
    holidays = normalizedElements(holidaysToNewsfeedElements(rawHolidays));
    schoolHolidays = normalizedElements(schoolHolidaysToNewsfeedElements(rawSchoolHolidays));
    healthPresentations = normalizedElements(healthPresentationsToNewsfeedElements(rawHealthPresentations));

    relevantNews = relevantNews.concat(normalizedNews, healthPresentations, holidays, schoolHolidays);
    relevantNews = getFilteredNews(relevantNews);
    relevantNews = sortedElementsByDateAndRelevancy(relevantNews);
    debug("Rebuild complete!");
}
