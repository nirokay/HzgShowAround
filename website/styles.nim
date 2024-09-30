## Styles module
## =============
##
## This module generates CSS for the general site as well as a specialised one for articles.

import std/[tables]
import websitegenerator ##! Not generator, because I need the writeFile() proc here!
import globals
export globals


# -----------------------------------------------------------------------------
# Css:
# ----------------------------------------------------------------------------

var
    globalCss: CssStyleSheet = newCssStyleSheet("global-styles.css") ## Not written to disk, only inherited from
    css*: CssStyleSheet = newCssStyleSheet("styles.css") ## Main CSS file
    cssArticles*: CssStyleSheet = newCssStyleSheet(articlesLocation & articleCssFile) ## CSS file for articles

globalCss.add(
    # Global stuff:
    "html"{
        backgroundColour(colourBackgroundDark),
        colour(colourText),
        fontFamily("Verdana, Geneva, Tahoma, sans-serif"),
    },

    "p"{
        "margin" := "10px"
    },

    "article > p"{
        textAlign("left"),
        padding("10px")
    },

    # Bottom footer:
    "footer"{
        position($fixed),
        backgroundColour(colourBackgroundDark),
        width("100%"),
        bottom($0),
        "box-sizing" := "border-box"
    },

    # Tables:
    "table"{
        "background-color" := colourBackgroundLight,
        "padding" := "10px",
        "margin" := "8px",
        "border-radius" := "10px",
        dropShadow
    },
    "tbody"{
        "border" := "1px",
        "border-collapse" := "collapse"
    },
    "tr:first-child *"{
        "maargin-right" := "10px"
    },

    # Progress bars:
    "progress"{
        width("90%"),
        "margin" := "auto 1px",
        "border-radius" := "10px",
        dropShadow
    },
    "progress::-webkit-progress-bar"{
        backgroundColour(colourProgressBarForeground),
        "border-radius" := "10px"
    },
    "progress::-webkit-progress-value"{
        backgroundColour(colourProgressBarBackground),
        "border-radius" := "10px"
    },
    "progress::-moz-progress-bar"{
        backgroundColour(colourProgressBarBackground),
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


    # Classes:
    centerClass,

    textCenterClass,
    centerWidth100Class,

    buttonClass,
    buttonClassHover,
    buttonClassClick,

    newCssElement("button", buttonClass.properties),
    newCssElement("button:hover", buttonClassHover.properties),
    newCssElement("button:active", buttonClassClick.properties),

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

    topPageHeaderClass,
    bottomPageFooterClass
)

globalCss.addLinkColour(
    "link", colourLinkDefault,
    @["text-decoration" := "none"]
)
globalCss.addLinkColour(
    "visited", colourLinkVisited,
    @["text-decoration" := "none"]
)
globalCss.addLinkColour(
    "hover", colourLinkHover,
    @["text-decoration" := "underline"]
)
globalCss.addLinkColour(
    "active", colourLinkClick,
    @["text-decoration" := "underline"]
)
#[
globalCss.addLinkColours(
    colourLinkDefault,
    colourLinkVisited,
    colourLinkHover,
    colourLinkClick,
    @[
        "text-decoration" := "none"
    ]
)
]#

css.elements = globalCss.elements
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
    newsElementGeneric,
    newsElementHoliday,
    newsElementWarning,
    newsElementAlert,
    newsElementHappened,

    #   Articles:
    articlePreviewItem,
    articlePreviewBox,

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

    # Images (for locations):
    locationImageHeader,
    locationImageFooter,
    locationImageFooterDiv,
    locationImageMapPreview
)

cssArticles.elements = globalCss.elements
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
    "h3, h4, h5, h6, p, summary, time"{
        textCenter
    },

    # Images:
    "img"{
        width("50%"),
        "max-width" := "700px",
        "border-radius" := "10px",
        "margin" := "10px",
        dropShadow
    }
)


# Misc.:

proc contentBox*[T: varargs[HtmlElement]|seq[HtmlElement]](elements: T): HtmlElement =
    ## Puts elements into a box
    `div`(elements).setClass(contentBoxClass)
