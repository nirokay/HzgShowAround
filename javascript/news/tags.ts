const urlNewsfeedTags: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/json/news/news-tags.json";

enum TagState {
    tolerated,
    filtered,
    prohibited
}
class NewsTag {
    name: string = "";
    desc: string = "";
    color: string = "";
    state: TagState = TagState.tolerated;
}
let newsfeedTags: Record<string, NewsTag> = {};

const newsfeedTagUriEntry: string = "tags";
const newsfeedTagUriTolerated: string = "o";
const newsfeedTagUriFiltered: string = "v";
const newsfeedTagUriProhibited: string = "x";

const tagDotTolerated: string = "☐";
const tagDotFiltered: string = "☑";
const tagDotProhibited: string = "☒";

async function fetchNewsfeedTags() {
    newsfeedTags = {};

    const response: Response = await fetch(urlNewsfeedTags)
    if (!response.ok) {
        console.error("Failed to fetch newsfeed tags", response);
        return;
    }

    const text: string = await response.text();
    let json: JSON = JSON.parse("[]");
    try {
        json = JSON.parse(text)
    } catch (error) {
        console.error("Failed to parse newsfeed tag JSON", error, text);
        return;
    }

    Object.entries(json).forEach(([_, item]) => {
        let result: NewsTag = new NewsTag()
        result.name = item.name ?? "";
        result.desc = item.desc ?? "<i>Beschreibung nicht vorhanden.</i>";
        result.color = item.color ?? "#e8e6e3";

        if (result.name == "") return;
        newsfeedTags[result.name] = result;
    })
}

function newsfeedTagsToAttribute(tags: NewsTag[]): string {
    let result = "x-tags='";
    let tagNames: string[] = [];
    if (tags != undefined) {
        tags.forEach((tag: NewsTag) => {
            tagNames.push(tag.name);
        })
    }
    let joinedTags: string = tagNames.join(" ");
    result += joinedTags != "" ? joinedTags : "/"
    result += "'";
    return result;
}

function tagDot(state: TagState): HtmlString {
    let result: HtmlString = "";
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
    };
    return result;
}
function newsfeedTagToHtml(tag: NewsTag, displayState: boolean = false): HtmlString {
    let dotText: HtmlString = displayState ? tagDot(tag.state) : "●"
    let dot: HtmlString = "<span class='newsfeed-element-tag-dot' style='color:" + tag.color + ";'>" + dotText + "</span>"
    let text: HtmlString = "<span class='newsfeed-element-tag-text' title='" + tag.desc + "'>" + tag.name + "</span>"

    let result: HtmlString = "<span class='newsfeed-element-tag shadow' style='" + [
        "border-color:" + tag.color + ";",
        "border-radius:20px;",
        "background:" + tag.color + "33;"
    ].join("") + "'>" + dot + text + "</span>";

    if (displayState) result = "<a style='margin:8px 2px;' href='javascript:cycleTag(\"" + tag.name + "\")'>" + result + "</a>"
    return result;
}
function newsfeedTagsToHtml(element: NewsFeedElement): HtmlString {
    let tags: NewsTag[] = element.newsTags;
    if (tags == undefined) {
        console.warn("Empty newsTags field for " + element.name);
        return "";
    }
    if (tags.length == 0) return "";
    let results: HtmlString[] = [];
    tags.forEach((tag) => {
        results.push(newsfeedTagToHtml(tag));
    })
    return "<div class='newsfeed-element-segment-tags generic-center'>" + results.join("") + "</div>";
}

function isOnNewsfeedPage(): boolean {
    const id: string = "newsfeed-tag-toggle-list";
    let element: HTMLDivElement | null = document.getElementById(id) as HTMLDivElement;
    return element != null;
}

function updateTagDisplays() {
    if (!isOnNewsfeedPage()) return;
    const id: string = "newsfeed-tag-toggle-list";
    let element: HTMLDivElement | null = document.getElementById(id) as HTMLDivElement;
    if (element == null) return; // location page

    element.innerHTML = "";
    Object.entries(newsfeedTags).forEach(([_, tag]) => {
        element.innerHTML += newsfeedTagToHtml(tag, true);
    });

    // Internet failure:
    if (element.innerHTML == "") element.innerHTML = "<small>Es konnte keine Internetverbindung zum Server hergestellt werden.</small>"
}

function applyTagFiltering() {
    if (!isOnNewsfeedPage()) return;
    const id: string = "news-div";
    let element: HTMLDivElement | null = document.getElementById(id) as HTMLDivElement;
    if (element == null) {
        console.warn("Div '" + id + "' was not found, cannot filter results.");
        return;
    }
    for (const c of element.children) {
        const child = c as HTMLDivElement;
        if (!child.hasAttribute("x-tags")) continue;
        let tags: string[] = (child.getAttribute("x-tags") ?? "").split(" ");
        if (tags.length == 0) continue;

        let hidden: boolean = false;

        Object.entries(newsfeedTags).forEach(([name, tag]) => {
            if (hidden) return;
            switch (tag.state) {
                case TagState.tolerated:
                    break;
                case TagState.filtered:
                    if (!tags.includes(name)) hidden = true;
                    break;
                case TagState.prohibited:
                    if (tags.includes(name)) hidden = true;
                    break;
            }
        });

        child.style.display = hidden ? "none" : "block"
    }
}

function cycleTag(name: string) {
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

function resetAllNewsfeedTags() {
    Object.entries(newsfeedTags).forEach(([name, tag]) => {
        let updated: NewsTag = tag;
        updated.state = TagState.tolerated;
        newsfeedTags[name] = updated;
    });

    updateTagDisplays();
    applyTagFiltering();
}

function getNewsfeedTagStateUri(tag: NewsTag): string {
    let result: string = "";
    switch (tag.state) {
        case TagState.tolerated:
            result = newsfeedTagUriTolerated;
            break;
        case TagState.filtered:
            result = newsfeedTagUriFiltered;
            break;
        case TagState.prohibited:
            result = newsfeedTagUriProhibited;
            break;
    }
    return result;
}
function getNewsfeedTagStateFromUri(state: string): TagState | null {
    let result: TagState | null = null;
    switch (state) {
        case newsfeedTagUriTolerated:
            result = TagState.tolerated;
            break;
        case newsfeedTagUriFiltered:
            result = TagState.filtered;
            break;
        case newsfeedTagUriProhibited:
            result = TagState.prohibited;
            break;
        default:
            result = null;
            break;
    }
    return result;
}
function copyNewsfeedUrlWithTags() {
    let uri: string = window.location.href.split("?")[0].split("#")[0];
    let parts: string[] = [];
    Object.entries(newsfeedTags).forEach(([name, tag]) => {
        if (tag.state == TagState.tolerated) return;
        let state: string = getNewsfeedTagStateUri(tag);
        parts.push(name + "-" + state);
    });
    let tagStates: string = parts.join(",");
    let completeUri: string = tagStates != "" ? uri + "?tags=" + tagStates : uri
    navigator.clipboard.writeText(completeUri);
}

// example: https://www.nirokay.com/HzgShowAround/newsfeed.html?tags=Gesundheitsvortrag-v,Verpflichtend-x[..]
function applyNewsfeedTagsFromUri() {
    let paramsRaw: string = window.location.href.split("?")[1];
    if (paramsRaw == undefined || paramsRaw == "") return;
    let tags: string[] = [];
    paramsRaw.split("&").forEach((param) => {
        let parts: string[] = param.split("=");
        if (parts.length < 2) return;
        let key: string = parts[0];
        let values: string = parts[1];
        if (key != newsfeedTagUriEntry) return;
        tags = values.split(",");
    });
    tags.forEach((decl) => {
        let parts: string[] = decl.split("-");
        if (parts.length != 2) return;
        let name: string = parts[0];
        let stateStr: string = parts[1];
        let state: TagState | null = getNewsfeedTagStateFromUri(stateStr);
        if (state == null) return;
        newsfeedTags[name].state = state;
    });
}

function initNewsfeedTags() {
    applyNewsfeedTagsFromUri();
    updateTagDisplays();
    applyTagFiltering();
}
