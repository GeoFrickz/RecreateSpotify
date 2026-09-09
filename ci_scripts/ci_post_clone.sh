#!/bin/sh
set -e
echo "CI_WORKSPACE is: $CI_WORKSPACE"
cd "$CI_WORKSPACE"
echo "Now in: $(pwd)"
echo "SPOTIFY_CLIENT_ID = $SPOTIFY_CLIENT_ID" > Secrets.xcconfig
echo "SPOTIFY_CLIENT_SECRET = $SPOTIFY_CLIENT_SECRET" >> Secrets.xcconfig
ls -la Secrets.xcconfig