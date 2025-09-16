#!/bin/bash

echo "🚀 Starting Tutorhouse Shoppertainment App Demo..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Please run this script from the tutorhouse_app directory"
    exit 1
fi

echo "📱 Flutter version:"
flutter --version
echo ""

echo "🔧 Getting dependencies..."
flutter pub get
echo ""

echo "🔍 Running analysis..."
flutter analyze --no-fatal-infos
echo ""

echo "🧪 Running tests..."
flutter test
echo ""

echo "🏗️ Building app..."
flutter build apk --debug
echo ""

echo "✅ Demo setup complete!"
echo ""
echo "📖 To run the app:"
echo "   flutter run"
echo ""
echo "📱 To run on specific device:"
echo "   flutter devices"
echo "   flutter run -d <device-id>"
echo ""
echo "📚 For more information, see demo_instructions.md"
