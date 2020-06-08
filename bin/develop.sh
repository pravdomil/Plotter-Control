#!/usr/bin/env bash

# To stop if any command fails.
set -e

# To stop on unset variables.
set -u

# To be always in project root.
cd "${0%/*}/.."

# To start development server.
tsc -w -p src/_main --outFile dist/main.js &
elm-live src/Main.elm --open --dir dist -- --output=dist/elm.js
