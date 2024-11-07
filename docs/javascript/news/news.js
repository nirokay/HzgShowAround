"use strict";
let date = new Date;
let relevantNews = [];
let normalizedNews = [];
let rawNews = [];
let healthPresentations = [];
let rawHealthPresentations = [];
let holidays = [];
let rawHolidays = {};
let schoolHolidays = [];
let rawSchoolHolidays;
let errorPanicNoInternet = false;
let errorPanicParsingFuckUp = false;
async function fetchNewsFeedElements(url) {
    let json = JSON.parse("[]");
    try {
        let response = await fetch(url);
        let text = await response.text();
        try {
            json = JSON.parse(text);
        }
        catch (error) {
            errorPanicParsingFuckUp = true;
            debug("[JSON Parse] Failed to parse json", text);
        }
    }
    catch (error) {
        errorPanicNoInternet = true;
        debug("[JSON Fetch] Failed to fetch json from " + url);
    }
    console.warn(json);
    let result = json;
    console.warn(result);
    return result;
}
/**
 * Fetches news
 */
async function getNews() {
    rawNews = await fetchNewsFeedElements(urlRemoteNews);
}
/**
 * Fetches health presentations
 */
async function getHealthPresentations() {
    rawHealthPresentations = await fetchNewsFeedElements(urlRemoteHealthPresentations);
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
        }
        catch (error) {
            errorPanicParsingFuckUp = true;
            debug("[Holidays] Failed to parse json", text);
        }
        if (typeof (json) === "object" && json !== null) {
            rawHolidays = json;
        }
        else {
            debug("[Holidays] Json Parsed was not valid? How does this even happen??", json);
            rawHolidays = {};
        }
    }
    catch (error) {
        debug("Failed to fetch holidays", error);
    }
}
/**
 * Fetches school holidays
 */
async function getSchoolHolidays() {
    let currentYear = date.getFullYear();
    async function doThisYear(year) {
        let url = getUrlSchoolHolidayApi(year);
        try {
            let response = await fetch(url);
            let text = await response.text();
            let json = JSON.parse("{}");
            try {
                json = JSON.parse(text);
            }
            catch (error) {
                errorPanicParsingFuckUp = true;
                debug("[School holidays] Failed to parse json", text);
            }
            if (typeof (json) === "object" && json !== null) {
                json.forEach(holiday => {
                    rawSchoolHolidays[rawSchoolHolidays.length] = holiday; // i want to die
                });
            }
            else {
                debug("[School holidays] Json Parsed was not valid? How does this even happen??", json);
            }
        }
        catch (error) {
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
    debug("Fetching complete!");
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
