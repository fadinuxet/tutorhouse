#!/bin/bash

# Secure development script with environment variables
# This script loads credentials from .env file for development

echo "🔒 Running TutorHouse app in development mode with secure credentials..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with your Supabase credentials:"
    echo "SUPABASE_URL=your_supabase_url_here"
    echo "SUPABASE_ANON_KEY=your_supabase_anon_key_here"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Validate required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: SUPABASE_URL or SUPABASE_ANON_KEY not set in .env file"
    exit 1
fi

echo "✅ Environment variables loaded successfully"

# Run the app with secure credentials
echo "🚀 Starting Flutter app..."
flutter run \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --target=lib/main.dart
