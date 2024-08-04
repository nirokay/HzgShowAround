let date: Date = new Date;

let relevantNews: NewsFeedElement[] = [];
let rawNews: NewsFeedElement[] = [];

let healthPresentations: NewsFeedElement[] = [];
let rawHealthPresentations: HealthPresentation[] = [];

let holidays: NewsFeedElement[] = [];
let rawHolidays: object = {};


/**
 * Fetches news
 */
async function getNews() {
    try {
        let response = await fetch(urlRemoteNews);
        let text = await response.text();
        let json = JSON.parse(text);

        if(typeof(json) === "object" && json !== null) {
            rawNews = json;
        } else {
            debug("[News] Json Parsed was not valid? How does this even happen??", json);
            rawNews = [];
        }
    } catch(error) {
        debug("Failed to fetch news", error);
    }
}

/**
 * Fetches holidays
 */
async function getHolidays() {
    try {
        let response = await fetch(urlHolidayApi);
        let text = await response.text();
        let json = JSON.parse(text);

        if(typeof(json) === "object" && json !== null) {
            rawNews = json;
        } else {
            debug("[News] Json Parsed was not valid? How does this even happen??", json);
            rawNews = [];
        }
    } catch(error) {
        debug("Failed to fetch holidays", error);
    }
}

/**
 * Fetches health presentations
 */
async function getHealthPresentations() {
    try {
        let response = await fetch(urlRemoteHealthPresentations);
        let text = await response.text();
        let json = JSON.parse(text);

        if(typeof(json) === "object" && json !== null) {
            rawHealthPresentations = json;
        } else {
            debug("[Health Presentations] Json Parsed was not valid? How does this even happen??", json);
            rawHealthPresentations = [];
        }
    } catch(error) {
        debug("Failed to fetch health presentations", error);
    }
}

/**
 * Refreshes news arrays
 */
async function refetchNews() {
    date = new Date;

    await getNews();
    await getHealthPresentations();
    await getHolidays();}

/**
 * Rebuild news arrays
 */
async function rebuildNews() {
    rawNews = normalizedElements(rawNews);
    holidays = normalizedElements(holidaysToNewsfeedElements(rawHolidays))
    healthPresentations = normalizedElements(healthPresentationsToNewsfeedElements(rawHealthPresentations))

    let newsfeedElements: NewsFeedElement[] = rawNews.concat(healthPresentations, holidays)
    relevantNews = sortedElementsByDateAndRelevancy(newsfeedElements);

}
