#!/usr/bin/env bash

# Uses a combination of `lebab`, `sed`
# and a Node script to update all FFI
# to ES modules. This will work 95%
# of the time, but still needs to be verified.
function migrateFfiToEs6::main {
  local MIGRATION_MSG="Migrated FFI to ES modules via 'lebab'"
  local EXPORT_UPDATE_MSG="Replaced 'export var' with 'export const'"
  local STRICT_FIX_MSG="Removed '\"use strict\";' in FFI files"
  if [ -d "src" ] && [ -d "test" ]; then
    echo "Using lebab to transform CJS to ES - both"
    # Transform to ES 6
    lebab --replace src --transform commonjs
    lebab --replace test --transform commonjs
    git add src test
    git commit -m "$MIGRATION_MSG"
    # Replace 'export var' with 'export const'
    find src -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
    find test -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
    git add src test
    git commit -m "$EXPORT_UPDATE_MSG"
    # Remove `"use strict";\n\n`
    find src -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
    find test -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
    git add src test
    git commit -m "$STRICT_FIX_MSG"
  elif [ -d "src" ]; then
    echo "Using lebab to transform CJS to ES - source"
    lebab --replace src --transform commonjs
    git add src
    git commit -m "$MIGRATION_MSG"

    find src -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
    git add src
    git commit -m "$EXPORT_UPDATE_MSG"

    find src -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
    git add src
    git commit -m "$STRICT_FIX_MSG"
  fi
}
