#!/bin/bash

set -e

ZIP_FILE="lambda_deployment.zip"
FUNCTION_FILE="lambda_function.py"
WORKING_DIR="lambda_package"

echo "Cleaning up old deployment package..."
rm -f  $ZIP_FILE

echo "Creating deployment package..."

python3 -m venv .venv
source .venv/bin/activate

mkdir -p $WORKING_DIR
pip3 install -r requirements.txt -t $WORKING_DIR/

cp $FUNCTION_FILE $WORKING_DIR/
cd $WORKING_DIR
zip -r ../$ZIP_FILE . 
cd ..
rm -rf $WORKING_DIR
deactivate

echo "Deployment package $ZIP_FILE created successfully."

