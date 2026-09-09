#!/bin/sh
set -e
cd "$CI_WORKSPACE"
echo "SPOTIFY_CLIENT_ID = $SPOTIFY_CLIENT_ID" > Secrets.xcconfig
echo "SPOTIFY_CLIENT_SECRET = $SPOTIFY_CLIENT_SECRET" >> Secrets.xcconfig
echo "=== Verifying ==="
ls -la Secrets.xcconfig
cat Secrets.xcconfig