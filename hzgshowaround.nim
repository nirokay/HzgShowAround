## HzgShowAround
## =============
##
## This is the builder for the [HzgShowAround website](https://nirokay.github.io/HzgShowAround).
##
## The project only uses the Nim standard library and my own static HTML/CSS library `websitegenerator`.

{.define: ssl.}

from websitegenerator import writeFile

# Sub-modules:
import website/[notFound404, tos, index, styles, tour, map, newsfeed, articles]
# To make the compiler shut up about unused imports:
export notFound404, tos, index, styles, tour, map, newsfeed, articles

# Write css to disk here, because modules may apply changes to the css var:
css.writeFile()
cssArticles.writeFile()
