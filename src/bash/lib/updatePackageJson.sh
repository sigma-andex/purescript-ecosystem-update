#!/usr/bin/env bash

function updatePackageJson::main {
  if [ -f "package.json" ]; then
    local TMP_FILE=package.json.new
    jq '
        if has("devDependencies") then
          .devDependencies |= (
            if has("purescript-psa") then ."purescript-psa" = "^0.8.2" else . end |
            if has("pulp") then ."pulp" = "16.0.0-0" else . end
          )
        else . end
      ' package.json > $TMP_FILE && mv $TMP_FILE package.json
    git add package.json
    git commit -m "Update pulp to 16.0.0-0 and psa to 0.8.2"
  fi
}
