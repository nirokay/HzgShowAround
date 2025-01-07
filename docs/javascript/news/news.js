"use strict";
var _a;
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
const placeHolderIdentifier = "--{placeholder}--";
let placeholderNewsFeedElement = new NewsFeedElement();
placeholderNewsFeedElement.level = "happened";
placeholderNewsFeedElement.from = "1970-01-01";
placeholderNewsFeedElement.till = "2170-12-31"; // future-proof date (i hope) // !!! remind me in 53378 days to update this variable !!!
placeholderNewsFeedElement.name = placeHolderIdentifier;
placeholderNewsFeedElement.details = [];
placeholderNewsFeedElement = (_a = normalizedElement([], placeholderNewsFeedElement)) !== null && _a !== void 0 ? _a : new NewsFeedElement();
function placePlaceholdersIntoRelevantNews() {
    relevantNews = [
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement,
        placeholderNewsFeedElement // This is my favourite function
    ];
}
async function fetchJson(url, defaultJson, softFail = false) {
    let json = JSON.parse(defaultJson);
    try {
        let response = await fetch(url);
        let text = await response.text();
        try {
            json = JSON.parse(text);
        }
        catch (error) {
            if (!softFail)
                errorPanicParsingFuckUp = true;
            console.warn(url);
            debug("[JSON Parse] Failed to parse json", text);
        }
    }
    catch (error) {
        if (!softFail)
            errorPanicNoInternet = true;
        console.warn(url);
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
    let json = await fetchJson(url, "[]", true);
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
        let json = await fetchJson(getUrlHolidayApi(year), "{}", true);
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
    await Promise.all([
        doThisYear(currentYear - 1),
        doThisYear(currentYear),
        doThisYear(currentYear + 1)
    ]);
}
/**
 * Fetches school holidays
 */
async function getSchoolHolidays() {
    let currentYear = date.getFullYear();
    async function doThisYear(year) {
        let json = await fetchSchoolHolidays(getUrlSchoolHolidayApi(year));
        try {
            json.forEach(holiday => {
                rawSchoolHolidays[rawSchoolHolidays.length] = holiday;
            });
        }
        catch (e) {
            console.error(e);
        }
    }
    await Promise.all([
        doThisYear(currentYear - 1),
        doThisYear(currentYear),
        doThisYear(currentYear + 1)
    ]);
}
/**
 * Reset the news arrays and error variables to an empty/default state
 */
function resetNewsArrays() {
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
}
/**
 * Refreshes news arrays
 */
async function refetchNews() {
    debug("Fetching news...");
    date = new Date;
    resetNewsArrays();
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
    try {
        newsfeed().innerHTML = "";
    }
    catch (e) {
        console.warn("Caught undefined newsfeed() call, ignoring...");
    }
    debug("Rebuild complete!");
}
