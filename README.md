# Tutorhouse Shoppertainment App

A TikTok-style mobile app for discovering tutors through vertical video feeds and booking 1-to-1 tutoring sessions.

## Features

- **TikTok-style Video Feed**: Vertical scrolling video discovery
- **Tutor Profiles**: Enhanced profiles with intro videos, ratings, and availability
- **Live Streaming**: Real-time tutoring sessions using Agora
- **Booking System**: Seamless session booking with Stripe payments
- **Session Management**: Google Meet integration and whiteboard support

## Tech Stack

- **Frontend**: Flutter (iOS + Android)
- **Backend**: Supabase (PostgreSQL, Auth, Real-time, Storage)
- **Live Streaming**: Agora.io SDK
- **Payments**: Stripe API
- **Video Calls**: Google Meet API
- **Whiteboard**: Custom whiteboard.tutorhouse.co.uk integration

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- Supabase account
- Agora.io account
- Stripe account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tutorhouse_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Update the configuration files with your API keys:
   
   - `lib/config/supabase_config.dart` - Add your Supabase URL and anon key
   - `lib/config/agora_config.dart` - Add your Agora App ID
   - `lib/config/stripe_config.dart` - Add your Stripe keys

4. **Set up Supabase database**
   
   Run the SQL schema provided in the project documentation to create the required tables.

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── config/           # Configuration files
├── models/           # Data models
├── services/         # Business logic and API calls
├── screens/          # UI screens
│   ├── auth/         # Authentication screens
│   ├── feed/         # Video feed screens
│   ├── booking/      # Booking flow screens
│   └── profile/      # Profile screens
├── widgets/          # Reusable UI components
└── utils/            # Utility functions
```

## Key Features Implementation

### Video Feed
- Vertical scrolling with PageView
- Auto-play/pause based on visibility
- TikTok-style overlay UI
- Infinite scroll with pagination

### Authentication
- Email/password registration
- Google Sign-In integration
- User type selection (tutor/student/parent)
- Tutor onboarding with video upload

### Booking System
- Calendar integration
- Time slot selection
- Price calculation with platform fees
- Stripe payment processing
- Google Meet link generation

### Live Streaming
- Agora RTC integration
- Real-time viewer count
- Chat functionality
- Stream management

## Development Status

- ✅ Project setup and dependencies
- ✅ Authentication system
- ✅ Video feed UI
- ✅ Sample data service
- ✅ Booking flow UI
- 🔄 Live streaming integration
- 🔄 Payment processing
- 🔄 Tutor profiles
- 🔄 Session management

## Sample Data

The app currently uses sample data for testing. To switch to real Supabase data:

1. Set up your Supabase project
2. Update `lib/services/feed_service.dart` and set `_useSampleData = false`
3. Configure your Supabase credentials

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@tutorhouse.co.uk or join our Discord community.