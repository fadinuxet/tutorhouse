#!/bin/bash

# Load environment variables and run Flutter app
# This script loads your .env file and runs the app with the real credentials

echo "🔑 Loading environment variables from .env file..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found! Please create it with your credentials."
    echo "📝 Copy env.example to .env and fill in your real values."
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

echo "✅ Environment variables loaded"
echo "🚀 Starting Flutter app..."

# Run Flutter with environment variables
flutter run -d chrome --dart-define-from-file=.env
