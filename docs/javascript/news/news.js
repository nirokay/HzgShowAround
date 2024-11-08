"use strict";
let date = new Date;
let relevantNews = [];
let normalizedNews = [];
let rawNews = [];
let healthPresentations = [];
let rawHealthPresentations = [];
let holidays = [];
let rawHolidays = [];
let schoolHolidays = [];
let rawSchoolHolidays;
let errorPanicNoInternet = false;
let errorPanicParsingFuckUp = false;
async function fetchJson(url, defaultJson) {
    let json = JSON.parse(defaultJson);
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
    return json;
}
async function fetchNewsFeedElements(url) {
    let json = await fetchJson(url, "[]");
    let result = json;
    return result;
}
async function fetchSchoolHolidays(url) {
    let json = await fetchJson(url, "[]");
    let result = json;
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
    let currentYear = date.getFullYear();
    async function doThisYear(year) {
        var _a, _b;
        let json = await fetchJson(getUrlHolidayApi(year), "{}");
        for (const name in json) {
            try {
                const rawHoliday = json[name];
                let element = new Holiday(name, (_a = rawHoliday.datum) !== null && _a !== void 0 ? _a : "1970-01-01", (_b = rawHoliday.hinweis) !== null && _b !== void 0 ? _b : "");
                rawHolidays[rawHolidays.length] = element;
            }
            catch (error) {
                debug("[Holiday] Failed to convert a holiday: " + name, json);
            }
        }
    }
    for (let offset = -1; offset <= 1; offset++) {
        await doThisYear(currentYear + offset);
    }
}
/**
 * Fetches school holidays
 */
async function getSchoolHolidays() {
    let currentYear = date.getFullYear();
    async function doThisYear(year) {
        let json = await fetchSchoolHolidays(getUrlSchoolHolidayApi(year));
        json.forEach(holiday => {
            rawSchoolHolidays[rawSchoolHolidays.length] = holiday;
        });
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
    rawHolidays = [];
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
