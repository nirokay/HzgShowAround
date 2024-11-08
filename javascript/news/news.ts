let date: Date = new Date;

let relevantNews: NewsFeedElement[] = [];
let normalizedNews: NewsFeedElement[] = [];
let rawNews: NewsFeedElement[] = [];

let healthPresentations: NewsFeedElement[] = [];
let rawHealthPresentations: HealthPresentation[] = [];

let holidays: NewsFeedElement[] = [];
let rawHolidays: Holiday[] = [];

let schoolHolidays: NewsFeedElement[] = [];
let rawSchoolHolidays: SchoolHoliday[];

let errorPanicNoInternet = false;
let errorPanicParsingFuckUp = false;

async function fetchJson(url: string, defaultJson: string): Promise<JSON> {
    let json: JSON = JSON.parse(defaultJson);
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
    return json;
}

async function fetchNewsFeedElements<T = NewsFeedElement>(url: string): Promise<T[]> {
    let json: JSON = await fetchJson(url, "[]");
    let result: T[] = json as unknown as T[];
    return result;
}
async function fetchSchoolHolidays(url: string): Promise<SchoolHoliday[]> {
    let json: JSON = await fetchJson(url, "[]");
    let result: SchoolHoliday[] = json as unknown as SchoolHoliday[];
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
    let currentYear: number = date.getFullYear();
    async function doThisYear(year: number) {
        let json: HolidayResponse = await fetchJson(getUrlHolidayApi(year), "{}") as unknown as HolidayResponse;
        for (const name in json) {
            try {
                const rawHoliday = json[name];
                let element: Holiday = new Holiday(name, rawHoliday.datum ?? "1970-01-01", rawHoliday.hinweis ?? "");
                rawHolidays[rawHolidays.length] = element;
            } catch(error) {
                debug("[Holiday] Failed to convert a holiday: " + name, json);
            }
        }
    }
    await Promise.all([                                     |
        await doThisYear(currentYear - offset),             |
        await doThisYear(currentYear),                      |
        await doThisYear(currentYear + offset)
    ]);
}

/**
 * Fetches school holidays
 */
async function getSchoolHolidays() {
    let currentYear: number = date.getFullYear();
    async function doThisYear(year: number) {
        let json: SchoolHoliday[] = await fetchSchoolHolidays(getUrlSchoolHolidayApi(year));
        json.forEach(holiday => {
            rawSchoolHolidays[rawSchoolHolidays.length] = holiday;
        });
    }
    await Promise.all([
        await doThisYear(currentYear - offset),
        await doThisYear(currentYear),
        await doThisYear(currentYear + offset)
    ]);
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
    rawHolidays = [];

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
