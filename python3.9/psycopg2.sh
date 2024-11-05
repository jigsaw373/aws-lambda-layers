#!/bin/bash

# Remove any existing files
rm -rf python psycopg2-lambda-layer.zip

# Create the directory structure
mkdir -p python/lib/python3.9/site-packages

# Create and activate virtual environment
python3.9 -m venv venv
source venv/bin/activate

# Install psycopg2-binary and its dependencies
pip install --upgrade pip
pip install psycopg2-binary --target python/lib/python3.9/site-packages/

# Create the ZIP file directly from the python directory
zip -r psycopg2-lambda-layer.zip python/

# Clean up
rm -rf venv python

echo "Layer created as psycopg2-lambda-layer.zip"
