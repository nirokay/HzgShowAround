"use strict";
const urlNewsfeedTags = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/json/news/news-tags.json";
class NewsTag {
    name = "";
    desc = "";
    color = "";
}
let newsfeedTags = {};
async function fetchNewsfeedTags() {
    newsfeedTags = {};
    const response = await fetch(urlNewsfeedTags);
    if (!response.ok) {
        console.error("Failed to fetch newsfeed tags", response);
        return;
    }
    const text = await response.text();
    let json = JSON.parse("[]");
    try {
        json = JSON.parse(text);
    }
    catch (error) {
        console.error("Failed to parse newsfeed tag JSON", error, text);
        return;
    }
    Object.entries(json).forEach(([_, item]) => {
        let result = new NewsTag();
        result.name = item.name ?? "";
        result.desc = item.desc ?? "<i>Beschreibung nicht vorhanden.</i>";
        result.color = item.color ?? "#e8e6e3";
        if (result.name == "")
            return;
        newsfeedTags[result.name] = result;
    });
}
function newsfeedTagsToAttribute(tags) {
    let result = "x-tags='";
    let tagNames = [];
    if (tags != undefined) {
        tags.forEach((tag) => {
            tagNames.push(tag.name);
        });
    }
    let joinedTags = tagNames.join(" ");
    result += joinedTags != "" ? joinedTags : "/";
    result += "'";
    return result;
}
function newsfeedTagToHtml(tag) {
    let dot = "<span style='color:" + tag.color + ";margin-left:6px;margin-right:2px;' >🞄</span>";
    let text = "<span style='margin-left:2px;margin-right:6px;' title='" + tag.desc + "'>" + tag.name + "</span>";
    let result = "<span style='" + [
        "border:2px solid " + tag.color + ";",
        "border-radius:20px;",
        "background:" + tag.color + "33;",
        "margin:5px;"
    ].join("") + "'>" + dot + text + "</span>";
    return result;
}
function newsfeedTagsToHtml(element) {
    let tags = element.newsTags;
    if (tags == undefined) {
        console.log("Empty newsTags field for " + element.name);
        return "";
    }
    if (tags.length == 0)
        return "";
    let results = [];
    tags.forEach((tag) => {
        results.push(newsfeedTagToHtml(tag));
    });
    return "<div class='newsfeed-element-segment-tags'>" + results.join("") + "</div>";
}
