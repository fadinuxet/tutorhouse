#!/bin/bash

# Secure way to run the app with environment variables
# This script loads your .env file and passes credentials as build-time variables

echo "🔒 Loading secure credentials from .env file..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found! Please create it with your credentials."
    echo "📝 Copy env.example to .env and fill in your real values."
    exit 1
fi

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

echo "✅ Environment variables loaded"
echo "🚀 Starting Flutter app with secure credentials..."

# Run Flutter with build-time environment variables
flutter run -d chrome \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=GOOGLE_API_KEY="$GOOGLE_API_KEY" \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID"
