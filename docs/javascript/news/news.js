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
/**
 * Fetches news
 */
async function getNews() {
    try {
        let response = await fetch(urlRemoteNews);
        let text = await response.text();
        let json = JSON.parse("[]");
        try {
            json = JSON.parse(text);
        }
        catch (error) {
            errorPanicParsingFuckUp = true;
            debug("[News] Failed to parse json", text);
        }
        if (typeof (json) === "object" && json !== null) {
            rawNews = json;
        }
        else {
            debug("[News] Json Parsed was not valid? How does this even happen??", json);
            rawNews = [];
        }
    }
    catch (error) {
        errorPanicNoInternet = true;
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
 * Fetches health presentations
 */
async function getHealthPresentations() {
    try {
        let response = await fetch(urlRemoteHealthPresentations);
        let text = await response.text();
        let json = JSON.parse("[]");
        try {
            json = JSON.parse(text);
        }
        catch (error) {
            errorPanicParsingFuckUp = true;
            debug("[Health Presentations] Failed to parse json", text);
        }
        if (typeof (json) === "object" && json !== null) {
            rawHealthPresentations = json;
        }
        else {
            debug("[Health Presentations] Json Parsed was not valid? How does this even happen??", json);
            rawHealthPresentations = [];
        }
    }
    catch (error) {
        debug("Failed to fetch health presentations", error);
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
