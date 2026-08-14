"use strict";
const urlNewsfeedTags = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/json/news/news-tags.json";
var TagState;
(function (TagState) {
    TagState[TagState["tolerated"] = 0] = "tolerated";
    TagState[TagState["filtered"] = 1] = "filtered";
    TagState[TagState["prohibited"] = 2] = "prohibited";
})(TagState || (TagState = {}));
class NewsTag {
    name = "";
    desc = "";
    color = "";
    state = TagState.tolerated;
}
let newsfeedTags = {};
const tagDotTolerated = "☐";
const tagDotFiltered = "☑";
const tagDotProhibited = "☒";
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
function tagDot(state) {
    let result = "";
    switch (state) {
        case TagState.tolerated:
            result = tagDotTolerated;
            break;
        case TagState.filtered:
            result = tagDotFiltered;
            break;
        case TagState.prohibited:
            result = tagDotProhibited;
            break;
    }
    ;
    return result;
}
function newsfeedTagToHtml(tag, displayState = false) {
    let dotText = displayState ? tagDot(tag.state) : "●";
    let dot = "<span class='newsfeed-element-tag-dot' style='color:" + tag.color + ";'>" + dotText + "</span>";
    let text = "<span class='newsfeed-element-tag-text' title='" + tag.desc + "'>" + tag.name + "</span>";
    let result = "<span class='newsfeed-element-tag shadow' style='" + [
        "border-color:" + tag.color + ";",
        "border-radius:20px;",
        "background:" + tag.color + "33;"
    ].join("") + "'>" + dot + text + "</span>";
    if (displayState) {
        result = "<a href='javascript:cycleTag(\"" + tag.name + "\")'>" + result + "</a>";
    }
    return result;
}
function newsfeedTagsToHtml(element) {
    let tags = element.newsTags;
    if (tags == undefined) {
        console.warn("Empty newsTags field for " + element.name);
        return "";
    }
    if (tags.length == 0)
        return "";
    let results = [];
    tags.forEach((tag) => {
        results.push(newsfeedTagToHtml(tag));
    });
    return "<div class='newsfeed-element-segment-tags generic-center'>" + results.join("") + "</div>";
}
function isOnNewsfeedPage() {
    const id = "newsfeed-tag-toggle-list";
    let element = document.getElementById(id);
    return element != null;
}
function updateTagDisplays() {
    if (!isOnNewsfeedPage())
        return;
    const id = "newsfeed-tag-toggle-list";
    let element = document.getElementById(id);
    if (element == null)
        return; // location page
    element.innerHTML = "";
    Object.entries(newsfeedTags).forEach(([_, tag]) => {
        element.innerHTML += newsfeedTagToHtml(tag, true);
    });
}
function applyTagFiltering() {
    if (!isOnNewsfeedPage())
        return;
    const id = "news-div";
    let element = document.getElementById(id);
    if (element == null) {
        console.warn("Div '" + id + "' was not found, cannot filter results.");
        return;
    }
    for (const c of element.children) {
        const child = c;
        if (!child.hasAttribute("x-tags"))
            continue;
        let tags = (child.getAttribute("x-tags") ?? "").split(" ");
        if (tags.length == 0)
            continue;
        let hidden = false;
        Object.entries(newsfeedTags).forEach(([name, tag]) => {
            if (hidden)
                return;
            switch (tag.state) {
                case TagState.tolerated:
                    break;
                case TagState.filtered:
                    if (!tags.includes(name))
                        hidden = true;
                    break;
                case TagState.prohibited:
                    if (tags.includes(name))
                        hidden = true;
                    break;
            }
        });
        child.style.display = hidden ? "none" : "block";
    }
}
function cycleTag(name) {
    if (newsfeedTags[name] == undefined) {
        console.warn("Could not find tag by name " + name);
        return;
    }
    switch (newsfeedTags[name].state) {
        case TagState.tolerated:
            newsfeedTags[name].state = TagState.filtered;
            break;
        case TagState.filtered:
            newsfeedTags[name].state = TagState.prohibited;
            break;
        case TagState.prohibited:
            newsfeedTags[name].state = TagState.tolerated;
            break;
    }
    updateTagDisplays();
    applyTagFiltering();
}
