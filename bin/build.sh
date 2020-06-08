#!/usr/bin/env bash

# To stop if any command fails.
set -e

# To stop on unset variables.
set -u

# To be always in project root.
cd "${0%/*}/.."

# To generate JSON encoders/decoders and TypeScript definitions.
elm-json-interop src/Types/*

# To compile our app.
tsc -p src/_main --outFile dist/main.js
elm make src/Main.elm --optimize --output=dist/elm.js
