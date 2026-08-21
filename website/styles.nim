## Styles module
## =============
##
## This module generates CSS for the general site as well as a specialised one for articles.

import cattag ##! Not generator, because I need the writeFile() proc here!
import globals
export globals

proc copyProperty(origin: CssElement, property: string): CssElementProperty =
    for p in origin.properties:
        if p.property == property:
            return p
    raise ValueError.newException("Failed to find " & property & " property in element: " & $origin)

# -----------------------------------------------------------------------------
# Css:
# ----------------------------------------------------------------------------

var
    globalCss: CssStyleSheet = newCssStylesheet("global-styles.css") ## Not written to disk, only inherited from
    css*: CssStyleSheet = newCssStylesheet("styles.css") ## Main CSS file
    cssArticles*: CssStyleSheet = newCssStylesheet(articlesLocation & articleCssFile) ## CSS file for articles

globalCss.add(
    # Global stuff:
    "html"{
        "background-color" := colourBackgroundDark,
        "color" := colourText,
        "font-family" := "Verdana, Geneva, Tahoma, sans-serif"
    },

    "::selection, ::-moz-selection, ::-webkit-selection"{
        "background-color" := colourHighlightBackground
    },

    "p"{
        "margin" := "10px"
    },

    "article > p"{
        "text-align" := "left",
        "padding" := "10px"
    },

    # Bottom footer:
    "footer"{
        "position" := "fixed",
        "backgroundColour" := colourBackgroundDark,
        "width" := "100%",
        "bottom" := "0",
        "box-sizing" := "border-box"
    },

    # Tables:
    "table"{
        "background-color" := colourBackgroundLight,
        "padding" := "10px",
        "margin" := "8px",
        "border-radius" := "10px",
        "border-spacing" := "20px 5px", # yippie, this fixed a funky annoying thing i was doing hehe
        dropShadow
    },
    "tbody"{
        "border" := "1px",
        "border-collapse" := "collapse"
    },

    # Progress bars:
    "progress"{
        "width" := "90%",
        "margin" := "auto 1px",
        "border-radius" := "10px",
        dropShadow
    },
    "progress::-webkit-progress-bar"{
        "background-color" := colourProgressBarForeground,
        "border-radius" := "10px"
    },
    "progress::-webkit-progress-value"{
        "background-color" := colourProgressBarBackground,
        "border-radius" := "10px"
    },
    "progress::-moz-progress-bar"{
        "background-color" := colourProgressBarBackground,
        "border-radius" := "10px"
    },

    "q"{
        "font-style" := "italic"
    },
    "time"{
        "font-weight" := "bold"
    },

    "del"{
        "color" := colourTextUnfocused,
        "text-decoration-color" := colourText,
        "font-style" := "italic"
    },

    # Fieldset:
    "fieldset"{
        "background-color" := colourBackgroundLight,
        "border-color" := colourText,
        "border-radius" := "10px",
        "border-width" := "2.5px",
        "display" := "inline-flex",
        "min-width" := "100px",
        "margin" := "10px 5px",
        "justify-self" := "center",
        "flex-wrap" := "wrap",
        "flex-basis" := "max-content",
        dropShadow
    },
    "fieldset > legend"{
        "text-decoration" := "underline"
    },
    "fieldset > p"{
        "margin-top" := "2px",
        "margin-bottom" := "2px"
    },

    # Lists:
    "ul"{
        "padding-left" := "20px"
    },

    # Images:
    "img"{
        # width("50%"),
        # "max-width" := "700px",
        "border-radius" := "10px",
        "margin" := "10px",
        # "background-color" := colourBackgroundLight, # useful for images, that dont load
        dropShadow
    },


    # Classes:
    centerClass,

    dropShadowClass,

    textCenterClass,

    buttonClass,
    buttonClassHover,
    buttonClassClick,

    smallButtonClass,
    smallButtonClassHover,
    smallButtonClassClick,

    newCssElement("button", buttonClass.properties),
    newCssElement("button:hover", buttonClassHover.properties),
    newCssElement("button:active", buttonClassClick.properties),

    "input"{
        buttonClass.copyProperty("background-color"),
        buttonClass.copyProperty("color"),
        buttonClass.copyProperty("border-radius"),
        "border" := "none",
        "padding" := "5px",
        dropShadow
    },

    centerTableClass,

    iconImageClass,

    flexContainerClass,
    flexContainedContainerClass,
    flexElementClass,

    # Author:
    authorDivClass,
    authorPictureClass,
    authorNameClass,

    # Content box:
    contentBoxClass,

    # Image paragraph:
    imageParagraphClass,
    imageParagraphContentClass,

    # Location:
    locationDeprecationDisclaimerHeaderClass,
    locationDeprecationDisclaimerDivClass,
    locationContactElementDiv,

    # Bars:
    topPageHeaderClass,
    bottomPageFooterClass
)

proc addLinkColour(stylesheet: var CssStylesheet, action, col, decor: string) =
    let element: CssElement = newCssElement("a:" & action,
        "color" := col,
        "text-decoration" := decor
    )
    stylesheet.add element

globalCss.addLinkColour(
    "link",
    colourLinkDefault,
    "none"
)
globalCss.addLinkColour(
    "visited",
    colourLinkVisited,
    "none"
)
globalCss.addLinkColour(
    "hover",
    colourLinkHover,
    "underline"
)
globalCss.addLinkColour(
    "active",
    colourLinkClick,
    "underline"
)


css.children = globalCss.children
css.add(
    # Classes:
    #   Map:
    mapElement,

    #   Vertical-Horizontal Centering:
    divCenterOuter,
    divCenterMiddle,
    divCenterInner,

    #   News:
    newsDivClass,
    newsElementBasis,

    newsElementPicture,

    newsElementHeaderSegment,
    newsElementBodySegment,
        newsElementTextSegment,
        newsElementPictureSegment,

    ".newsfeed-element-segment-body > p"{
        "max-width" := "95%"
    },

    newsElementGeneric,
    newsElementHoliday,
    newsElementWarning,
    newsElementAlert,
    newsElementHappened,

    newsElementTag,
    newsElementTagDot,
    newsElementTagText,

    #   Articles:
    articlePreviewItem,
    articlePreviewBox,

    #   Clickable headings:
    clickableHeaderClass,

    # Headers:
    "h1, h2"{
        textCenter,
        "text-decoration" := "underline",
        "margin-bottom" := "0px"
    },
    "h3, h4, h5, h6"{
        textCenter,
        "margin-bottom" := "0px"
    },

    "summary:hover"{
        "text-decoration" := "underline"
    },

    "select"{
        "padding" := "4px 8px",
        "margin" := "8px 4px",
        "transition" := "0.3s",
        "background-color" := colourBackgroundLight,
        "color" := colourText,
        "border-radius" := "10px",
        "border-style" := "none",
        dropShadow
    },
    "select:hover"{
        "transition" := "0.1s",
        "background-color" := colourBackgroundMiddle
    },

    # Search Bar:
    locationSearchBarAutocomplete,
    locationSearchBarAutocompleteItems,
    locationSearchBarAutocompleteActive,

    locationSearchBarDiv,
    locationSearchBar,

    newCssElement(".autocomplete-items div",
        "padding" := "10px",
        "cursor" := "pointer",
        "background-color" := colourBackgroundMiddle
    ),
    newCssElement(".autocomplete-items div:hover",
        "background-color" := colourBackgroundLight
    ),

    # Images (for locations):
    locationImageHeader,
    locationImageFooter,
    locationImageFooterDiv,
    locationImageMapPreview
)

cssArticles.children = globalCss.children
cssArticles.add(
    # Center everything in `body`:
    "body"{
        "background-color" := colourBackgroundDark,
        "display" := "block",
        "margin-left" := "auto",
        "margin-right" := "auto",
        "width" := "90%"
    },

    # Headers and paragraph:
    "h1, h2"{
        textUnderline,
        textCenter
    },
    "h3, h4, h5, h6, summary, time"{
        textCenter
    },
    "img"{
        "margin" := "20px",
        "max-height" := "70vh",
        "max-width" := "90%"
    }
)
