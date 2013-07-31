#!/bin/sh
# Based on git's GIT-VERSION-GEN.

VERSION_TXT=version.txt
VERSION_JS=src/js/version.js
DEFAULT_VERSION="vUNKNOWN ($(date +%Y-%m-%dT%T))"

LF='
'

if test -d .git -o -f .git &&
    # get latest git tag in format: "v0.2.9.5alpha-1-g05a6"
    NEXT_VERSION=$(git describe --abbrev=4 HEAD 2>/dev/null) &&
    case "$NEXT_VERSION" in
    *$LF*) (exit 1) ;;
    [0-9]*)
        # append '+' if "dirty" modified/untracked files exist
        git update-index -q --refresh
        test -z "$(git diff-index --name-only HEAD --)" ||
        NEXT_VERSION="$NEXT_VERSION+" ;;
    esac
then
    # swap first dash with space; remove second dash
    NEXT_VERSION=$(echo "$NEXT_VERSION" | sed -e 's/-/ /' | sed -e 's/-//');
else
    # git version not available; use default
    NEXT_VERSION="$DEFAULT_VERSION"
fi

# strip 'v' chars from beginning
NEXT_VERSION=$(expr "$NEXT_VERSION" : v*'\(.*\)')

# get current version from version file
if test -r $VERSION_TXT
then
    CURR_VERSION=$(sed -e 's/^VERSION=//' <$VERSION_TXT)
else
    CURR_VERSION=unset
fi
# only modify version file if version changed
test "$NEXT_VERSION" = "$CURR_VERSION" || {
    # echo to screen
    echo >&2 "$NEXT_VERSION"
    # echo to version.txt file
    echo "$NEXT_VERSION" >$VERSION_TXT
    # update version.js
    sed --in-place --expression="s/'.*'/'$NEXT_VERSION'/" $VERSION_JS
}
