const urlNewsfeedTags: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/refs/heads/master/json/news/news-tags.json";

class NewsTag {
    name: string = "";
    desc: string = "";
    color: string = ""
}
let newsfeedTags: Record<string, NewsTag> = {};

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

function newsfeedTagToHtml(tag: NewsTag): HtmlString {
    let dot: HtmlString = "<span class='newsfeed-element-tag-dot' style='color:" + tag.color + ";'>●</span>"
    let text: HtmlString = "<span class='newsfeed-element-tag-text' title='" + tag.desc + "'>" + tag.name + "</span>"

    let result: HtmlString = "<span class='newsfeed-element-tag shadow' style='" + [
        "border-color:" + tag.color + ";",
        "border-radius:20px;",
        "background:" + tag.color + "33;"
    ].join("") + "'>" + dot + text + "</span>";
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
