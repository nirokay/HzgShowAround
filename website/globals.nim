import generator

# -----------------------------------------------------------------------------
# Colours:
# -----------------------------------------------------------------------------

const
    colBackground*: string = rgb(23, 25, 33)

    colButton*: string = rgb(60, 60, 60)
    colButtonHover*: string = rgb(180, 180, 180)


# -----------------------------------------------------------------------------
# Variables:
# -----------------------------------------------------------------------------

const
    textUnderline* = ["text-decoration", "underline"]
    textNoDecoration* = ["text-decoration", "none"]
    # textTransparentBackground = ["background-color", "transparent"]


# -----------------------------------------------------------------------------
# Classes:
# -----------------------------------------------------------------------------

const
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

    centerTableClass* = newCssElement("table-center",
        ["margin-left", "auto"],
        ["margin-right", "auto"]
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
