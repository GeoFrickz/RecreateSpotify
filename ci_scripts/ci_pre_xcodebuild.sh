#!/bin/sh

# Navigate to the root folder of your project on the cloud server
cd $CI_WORKSPACE

# Create the Secrets.xcconfig file and write the first variable
echo "SPOTIFY_CLIENT_ID = $SPOTIFY_CLIENT_ID" > Secrets.xcconfig

# Append the second variable on a new line
echo "SPOTIFY_CLIENT_SECRET = $SPOTIFY_CLIENT_SECRET" >> Secrets.xcconfig

echo "Successfully generated Secrets.xcconfig"
