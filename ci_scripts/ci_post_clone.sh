#!/bin/sh
set -e
echo "CI_PRIMARY_REPOSITORY_PATH is: $CI_PRIMARY_REPOSITORY_PATH"
cd "$CI_PRIMARY_REPOSITORY_PATH"
echo "Now in: $(pwd)"
echo "SPOTIFY_CLIENT_ID = $SPOTIFY_CLIENT_ID" > Secrets.xcconfig
echo "SPOTIFY_CLIENT_SECRET = $SPOTIFY_CLIENT_SECRET" >> Secrets.xcconfig
ls -la Secrets.xcconfig