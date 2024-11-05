# AWS Lambda Psycopg2 Layer Setup Guide

This guide explains how to create a custom AWS Lambda layer for psycopg2, enabling PostgreSQL database connections in Lambda functions.

## Prerequisites

- Ubuntu/Debian system (or similar Linux distribution)
- Python 3.9 installed
- AWS Lambda console access
- Basic understanding of AWS Lambda layers

## Installation Steps

### 1. Install Required Packages

First, ensure you have Python 3.9 and required packages installed:

```bash
# Add Python repository
sudo add-apt-repository ppa:deadsnakes/ppa

# Update package list
sudo apt update

# Install Python 3.9 and required packages
sudo apt install python3.9 python3.9-venv zip
```

### 2. Create Layer Build Script

Create a file named `build_layer.sh` with the following content:

```bash
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
```

### 3. Build the Layer

```bash
# Make script executable
chmod +x build_layer.sh

# Run the script
./build_layer.sh
```

### 4. Create Lambda Layer

1. Go to AWS Lambda Console
2. Navigate to Layers
3. Click "Create layer"
4. Fill in the following details:
   - Name: `psycopg2-layer`
   - Description: "PostgreSQL connector layer for Python 3.9"
   - Upload the `psycopg2-lambda-layer.zip` file
   - Compatible runtimes: Python 3.9

### 5. Attach Layer to Lambda Function

1. Go to your Lambda function
2. Scroll to Layers section
3. Click "Add a layer"
4. Select "Custom layers"
5. Choose the `psycopg2-layer` you created
6. Click "Add"

## Usage Example

Here's a basic Lambda function using the psycopg2 layer:

```python
import json
import psycopg2

def lambda_handler(event, context):
    # Database connection parameters
    DB_PARAMS = {
        "host": "your-db-host",
        "database": "your-db-name",
        "user": "your-username",
        "password": "your-password"
    }
    
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Test connection
        cur.execute("SELECT version();")
        version = cur.fetchone()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Connection successful',
                'version': str(version)
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
    finally:
        if 'conn' in locals():
            conn.close()
```

## Troubleshooting

If you encounter the "No module named 'psycopg2'" error:
1. Verify the layer is properly attached to your function
2. Confirm your function is using Python 3.9 runtime
3. Check the layer's content structure:
   ```bash
   unzip -l psycopg2-lambda-layer.zip
   ```
   The output should show files in `python/lib/python3.9/site-packages/psycopg2/`

## VPC Configuration

If connecting to an RDS instance:
1. Ensure your Lambda function is in the same VPC as your RDS
2. Configure security groups to allow traffic between Lambda and RDS
3. Add necessary IAM permissions for VPC access

## Security Notes

- Always store database credentials in AWS Secrets Manager or Parameter Store
- Use IAM roles and policies to manage access
- Regularly update the psycopg2 version for security patches

## Additional Resources

- [AWS Lambda Layers Documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
- [psycopg2 Documentation](https://www.psycopg.org/docs/)
