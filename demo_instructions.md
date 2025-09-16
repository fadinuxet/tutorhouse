# Tutorhouse App Demo Instructions

## 🚀 Quick Start

1. **Run the app:**
   ```bash
   cd tutorhouse_app
   flutter run
   ```

2. **Test the authentication flow:**
   - The app will start with the authentication screen
   - Try signing up with a test email (e.g., `test@example.com`)
   - Select "STUDENT" as user type
   - Use any password (6+ characters)

3. **Explore the video feed:**
   - After authentication, you'll see the TikTok-style video feed
   - Swipe up/down to navigate between videos
   - Tap on videos to play/pause
   - Try the "Book Now" button to see the booking flow

## 🎯 Key Features to Test

### 1. Video Feed (TikTok-style)
- **Vertical scrolling** with PageView
- **Auto-play/pause** based on visibility
- **Overlay UI** with tutor info and action buttons
- **Sample videos** with different subjects (Math, Physics, Chemistry, etc.)

### 2. Authentication System
- **Email/password registration**
- **User type selection** (Student/Tutor/Parent)
- **Form validation** with error messages
- **Smooth transitions** between sign-in/sign-up

### 3. Booking Flow
- **Tutor selection** from video feed
- **Calendar picker** for date selection
- **Time slot selection** with available times
- **Duration selection** (30, 60, 90, 120 minutes)
- **Price calculation** with platform fees (15%)
- **Booking confirmation** with success dialog

### 4. UI/UX Features
- **Dark theme** with TikTok-inspired colors
- **Smooth animations** and transitions
- **Responsive design** for different screen sizes
- **Loading states** and error handling
- **Modern typography** with Google Fonts

## 📱 Sample Data

The app uses sample data for demonstration:

### Sample Tutors:
- **GCSE Math Expert** - £25/hour, 4.8★ rating
- **A-Level Physics Specialist** - £35/hour, 4.9★ rating  
- **Chemistry Teacher** - £28/hour, 4.7★ rating
- **English Literature Tutor** - £30/hour, 4.6★ rating
- **Biology & Medicine Prep** - £32/hour, 4.9★ rating

### Sample Videos:
- 60-second intro videos for each tutor
- Different subjects and teaching styles
- View counts and like counts
- Featured content in the feed

## 🔧 Configuration

### To use real data instead of sample data:

1. **Set up Supabase:**
   - Create a Supabase project
   - Update `lib/config/supabase_config.dart` with your credentials
   - Set `_useSampleData = false` in `lib/services/feed_service.dart`

2. **Configure Stripe:**
   - Get your Stripe keys
   - Update `lib/config/stripe_config.dart`

3. **Set up Agora:**
   - Get your Agora App ID
   - Update `lib/config/agora_config.dart`

## 🎨 Design System

### Colors:
- **Primary:** Purple (#6C5CE7)
- **Secondary:** Cyan (#00D2FF)
- **Background:** Black (#000000)
- **Surface:** Dark Gray (#1A1A1A)
- **Accent:** Pink (#FF6B9D)

### Typography:
- **Headlines:** Poppins Bold
- **Body:** Inter Regular
- **UI Elements:** System fonts

## 🚧 Next Steps

1. **Live Streaming:** Integrate Agora for real-time tutoring
2. **Payment Processing:** Complete Stripe integration
3. **Tutor Profiles:** Build detailed profile screens
4. **Session Management:** Add Google Meet and whiteboard
5. **Push Notifications:** Implement Firebase messaging
6. **Analytics:** Add user behavior tracking

## 📝 Notes

- The app is currently using sample data for demonstration
- All API calls are mocked with realistic delays
- The booking flow shows a confirmation dialog (no real payment processing)
- Video URLs point to sample videos from Google's test bucket
- The app is optimized for mobile devices (iOS/Android)

## 🐛 Known Issues

- Some deprecation warnings for file_picker (non-critical)
- Google Sign-In not fully implemented (UI ready)
- Live streaming not yet integrated
- Real payment processing not implemented

## 📞 Support

For questions or issues, refer to the README.md file or check the Flutter documentation.
