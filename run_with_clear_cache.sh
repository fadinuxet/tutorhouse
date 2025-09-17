#!/bin/bash

# Clear Flutter build cache
echo "🧹 Clearing Flutter build cache..."
flutter clean

# Clear web cache
echo "🧹 Clearing web cache..."
rm -rf build/web/

# Run the app with proper Supabase credentials
echo "🚀 Starting Flutter app with Supabase credentials..."
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://lpjbzkwflyidjbmdrubg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwamJ6a3dmbHlpZGpibWRydWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4NzE5NzEsImV4cCI6MjA3MzQ0Nzk3MX0.7oZipOxgXpeD7FoXBT517giqfVr0akyKZdZyiQrsKdo \
  --web-renderer html
