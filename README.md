# HzgShowAround

## About

This project is a website (in german) for the sake of showing your way around
[Herzogsägmühle](https://www.herzogsaegmuehle.de/).

## Generation

All html and css files are generated at build-time and should not be edited, as when rebuilding it will be overwritten.

The map in `resources/images/map.svg` is also generated at build-time using a [template svg](https://github.com/nirokay/HzgShowAroundData/blob/master/resources/images/map.svg).

The build-executable fetches changes from the [data repository](https://github.com/nirokay/HzgShowAroundData), so an internet connection is required to build the website.

## Deployment

This website is deployed using github pages to [my homepage](https://nirokay.github.io/HzgShowAround).
