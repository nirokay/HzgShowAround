import std/[tables]
import websitegenerator
import colours

const
    textUnderline* = ["text-decoration", "underline"]
    textNoDecoration* = ["text-decoration", "none"]
    # textTransparentBackground = ["background-color", "transparent"]

    textCenter* = ["text-align", "center"]
    textCenterClass* = newCssClass("center",
        textCenter
    )

    centerClass* = newCssClass("generic-center",
        textCenter,
        ["display", "block"],
        ["margin-left", "auto"],
        ["margin-right", "auto"],
        ["width", "90%"]
    )

    buttonClass* = newCssClass("button",
        backgroundColour(rgb(60, 60, 60)),
        ["border", "none"],
        padding("20px 34px"),
        textCenter,
        textNoDecoration,
        display(inlineBlock),
        fontSize(20.px),
        ["margin", "4px 2px"],
        ["cursor", "pointer"],
        # ["transition", "0.3s"],
        ["border-radius", 6.px]
    )

    buttonClassHover* = newCssClass("button:hover",
        backgroundColour(colButtonHover)
    )

#[footer {
    position: fixed;
    width: 100%;
    bottom: 0;
    box-sizing: border-box;
}]#
proc button*(content, href: string): HtmlElement = a(href, content).setClass(buttonClass) ## Styled button-like link

proc buttonList*(table: Table[string, string]|OrderedTable[string, string]): seq[HtmlElement] =
    for content, href in table:
        result.add button(content, href)

proc link(which: string, colour: CssColour|string): CssElement =
    newCssElement("a:" & which,
        ["color", $colour],
        textNoDecoration
    )

var css*: CssStyleSheet = newCssStyleSheet("styles.css")
css.elements = @[
    # Body:
    newCssElement("body",
        backgroundColour(colBackground),
        colour(White),
        fontFamily("Verdana, Geneva, Tahoma, sans-serif"),
    ),

    newCssElement("footer",
        ["position", "fixed"],
        backgroundColour(colBackground),
        width("100%"),
        ["bottom", "0"],
        ["box-sizing" ,"border-box"]
    ),

    # Classes:
    textCenterClass,
    centerClass,
    buttonClass,

    # Headers:
    newCssElement("h1",
        textCenter,
        textUnderline
    ),
    newCssElement("h2",
        textCenter,
        textUnderline
    ),
    newCssElement("h3",
        textUnderline
    ),

    # Links:
    link("link", Pink),
    link("visited", HotPink),
    link("hover", DeepPink),
    link("active", DarkMagenta),
]

css.writeFile()
