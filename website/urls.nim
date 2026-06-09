const
    urlDeploymentSite*: string = "https://www.nirokay.com/HzgShowAround/" ## Target deployment site directory
    urlDeploymentResources*: string = urlDeploymentSite & "resources/" ## Target site resources directory
    urlDeploymentImages*: string = urlDeploymentResources & "images/" ## Target site images directory
    urlDeploymentLocationMaps*: string = urlDeploymentImages & "map-locations/" ## Target site location maps directory

    urlRemoteRepo*: string = "https://raw.githubusercontent.com/nirokay/HzgShowAroundData/master/" ## Data repository
    urlJsons*: string = urlRemoteRepo & "json/"
    urlJsonsContributors*: string = urlJsons & "contributors/"
    urlJsonsLocations*: string = urlJsons & "locations/"
    urlJsonsNews*: string = urlJsons & "news/"
    urlJsonsPages*: string = urlJsons & "pages/"

    urlResources*: string = urlRemoteRepo & "resources/" ## Resources directory
    urlImages*: string = urlResources & "images/" ## Image directory

    urlIcons*: string = urlImages & "icon/" ## Icon/Favicon directory
    urlIconLargeSVG*: string = urlIcons & "icon.svg" ## Large icon (SVG)
    urlIconLargePNG*: string = urlIcons & "icon.png" ## Large icon (PNG)
    urlIconSmallSVG*: string = urlIcons & "icon_small.svg" ## Small icon (SVG)
    urlIconSmallPNG*: string = urlIcons & "icon_small.png" ## Small icon (PNG)

    urlPinIdHeader*: string = urlImages & "header-href-pin.svg" ## SVG icon for headers with IDs, so they can be "pinned"

    urlContributors*: string = urlJsonsContributors & "contributors.json" ## Author JSON file
    urlAuthors*: string = urlJsonsContributors & "authors.json" ## Author JSON file
    urlAuthorImages*: string = urlImages & "authors/" ## Author image directory

    urlArticleImages*: string = urlImages & "articles/" ## Article directory
    urlArticles*: string = urlJsonsPages & "articles.json" ## Articles JSON file
    urlCustomHtmlArticles*: string = urlResources & "articles/" ## Custom HTML articles repository

    urlLocationImages*: string = urlImages & "locations/" ## Location image directory
    urlLocationData*: string = urlJsonsLocations & "locations.json" ## Location JSON file
    urlTourData*: string = urlJsonsLocations & "tour_locations.json" ## Tour location JSON file

    urlNewsFeed*: string = urlJsonsNews & "news.json" ## News JSON file

    urlOfferings*: string = urlJsonsPages & "offerings.json" ## Offerings JSON file

    urlChangelog*: string = urlJsonsPages & "changelog.json" ## Changelog JSON file

    urlTravel*: string = urlJsonsPages & "travel.json" ## Travel JSON file
