#!/bin/bash
# Codacy Environment Variables
export CODACY_CLI_PATH="/home/drj/ice-webapp/tools/codacy"
export PATH="/home/drj/ice-webapp/tools:$PATH"

# Test if Codacy CLI is working
echo "Testing Codacy CLI..."
"/home/drj/ice-webapp/tools/codacy" version

echo "Codacy environment is set up. If you have issues with Cursor, please restart Cursor."
