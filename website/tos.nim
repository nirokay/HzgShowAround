## TOS module
## ==========
##
## This module generates the TOS page (`terms-of-service.html`).

import generator, globals, styles

var html: HtmlDocument = newPage(
    "Terms of Service",
    "terms-of-service.html",
    "The terms of service for this website."
)

html.addToBody(
    h1("Terms of service"),

    h2("English [EN]"),
    pc(
        "By using this website you acknowledge, that:" & $br(),
        "1) this website is not owned nor operated by the owners of " & $a("https://www.herzogsaegmuehle.de", "Herzogsägmühle") & ".",
        "2) the information provided on this website may not be accurate or may include errors.",
        "3) this website uses client-side CloudFlare Analytics to analyse traffic and page lookups. You remain the right to block these requests with an ad-blocker."
    ),

    h2("Deutsch [DE]"),
    pc(
        "Mit dem Benutzen dieser Website ist Ihnen bewusst, dass:" & $br(),
        "1) diese Website nicht der " & $a("https://www.herzogsaegmuehle.de", "Herzogsägmühle") & " gehört und dass sie Diese nicht betreieben.",
        "2) die Informationen, die hier gefunden werden können, nicht stimmen oder fehlerhaft sein können.",
        "3) diese Website client-side CloudFlare Analytics benutzt, um Seitenaufrufe zu analysieren. Ihre Rechte diese, mit z.B. einem Ad-BLocker, zu blockieren behalten Sie bei."
    )
)

html.setStyle(css)
html.generate()
