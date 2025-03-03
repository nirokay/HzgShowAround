## HzgShowAround
## =============
##
## This is the builder for the [HzgShowAround website](https://nirokay.github.io/HzgShowAround).
##
## The project only uses the Nim standard library and my own static HTML/CSS library `websitegenerator`.

{.define: ssl.}
import website/generator

import utils/[logging, xmlSiteMap]

# Sub-modules:
import website/[tos, index, styles, tour, map, newsfeed, articles, contributors, offerings, changelog, contact]
# To make the compiler shut up about unused imports:
export tos, index, styles, tour, map, newsfeed, articles, contributors, offerings, changelog, contact

# Delay importing, because 404 page has css jammed into it to work well depth-independent
import website/[notFound404]
export notFound404

# Write css to disk here, because modules may apply changes to the css var:
css.generate()
cssArticles.generate()

generateXmlSiteMap()
logger.postGenerationLog()
