# 🎓 Tutorhouse Shoppertainment App
**"TikTok for Tutor Discovery"** - A vertical video feed platform where students discover tutors through short videos and book trial sessions.

[![Flutter](https://img.shields.io/badge/Flutter-3.32.1-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![Agora](https://img.shields.io/badge/Agora-Live%20Streaming-orange.svg)](https://agora.io/)
[![Stripe](https://img.shields.io/badge/Stripe-Payments-purple.svg)](https://stripe.com/)

## 🚀 Live Demo
The app is currently running and can be tested by running:
```bash
flutter run -d chrome
```

## 📱 Features

### ✅ **Fully Implemented**
- **🎬 TikTok-Style Video Feed** - Vertical scrolling with swipe gestures
- **🔐 Authentication System** - Sign up/sign in with persistent login
- **👨‍🏫 Tutor Profiles** - 7 sample tutors with realistic data
- **📅 Booking System** - Calendar integration with time slot selection
- **🎥 Live Streaming** - Agora integration with raise hand feature
- **💳 Payment Integration** - Stripe demo mode for trials
- **📧 Email Notifications** - Booking confirmations with Google Meet links
- **🌐 Web Platform** - Full Chrome browser support
- **📱 Responsive Design** - Mobile-first dark theme UI
- **💾 Data Persistence** - SharedPreferences + localStorage
- **🔄 State Management** - Riverpod for authentication and tutor data

### ⚠️ **Partially Implemented**
- **📱 Mobile Platform** - Not yet tested on iOS/Android
- **🎥 Live Streaming** - Agora compilation errors (core app works)
- **🖼️ Image Loading** - Some thumbnails have decoding issues

### ❌ **Not Implemented**
- **📹 Video Upload** - Recording and upload functionality
- **💬 In-App Messaging** - Student-tutor communication
- **📊 Analytics** - User and video analytics
- **🏢 Admin Dashboard** - Content moderation and user management
- **🌍 Internationalization** - Multi-language support

## 🛠️ Tech Stack

### **Frontend**
- **Flutter 3.32.1** - Cross-platform UI framework
- **Riverpod** - State management
- **Google Fonts (Poppins)** - Typography
- **TableCalendar** - Booking calendar widget

### **Backend**
- **Supabase** - PostgreSQL database, authentication, storage
- **Agora.io** - Live streaming and video calls
- **Stripe** - Payment processing
- **Google Meet** - Session video calls

### **Platforms**
- **Web** ✅ - Chrome browser support
- **Mobile** ⚠️ - iOS/Android (not tested)
- **Desktop** ❌ - Not implemented

## 🏗️ Project Structure

```
lib/
├── config/           # Configuration files
├── constants/        # App constants and themes
├── models/           # Data models (User, Tutor, Video, etc.)
├── providers/        # Riverpod state management
├── screens/          # UI screens
│   ├── auth/         # Authentication screens
│   ├── booking/      # Booking flow screens
│   ├── feed/         # Video feed screen
│   ├── live/         # Live streaming screens
│   └── tutor/        # Tutor onboarding screens
├── services/         # Business logic services
└── widgets/          # Reusable UI components
```

## 🚀 Getting Started

### **Prerequisites**
- Flutter 3.32.1 or higher
- Dart 3.8.1 or higher
- Chrome browser (for web testing)

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/fadinuxet/tutorhouse.git
   cd tutorhouse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Update `lib/config/supabase_config.dart` with your Supabase credentials
   - Update `lib/config/agora_config.dart` with your Agora credentials
   - Update `lib/config/stripe_config.dart` with your Stripe keys

4. **Run the app**
   ```bash
   flutter run -d chrome
   ```

### **Database Setup**

Run the SQL schema in your Supabase dashboard:
```sql
-- See database_schema.sql for complete schema
```

## 📊 Current Status

### **Completion: ~75%**

| Feature | Status | Priority |
|---------|--------|----------|
| Video Feed | ✅ Complete | High |
| Authentication | ✅ Complete | High |
| Booking System | ✅ Complete | High |
| Tutor Profiles | ✅ Complete | High |
| Live Streaming | ⚠️ Partial | Medium |
| Mobile Support | ⚠️ Untested | Medium |
| Video Upload | ❌ Missing | High |
| Messaging | ❌ Missing | Medium |
| Analytics | ❌ Missing | Low |

## 🎯 Sample Data

The app includes 7 sample tutors:
- **Sarah Johnson** - GCSE/A-Level Maths (4.8★)
- **Dr. Michael Chen** - A-Level Physics (4.9★)
- **Emma Williams** - GCSE/A-Level Chemistry (4.7★)
- **James Thompson** - A-Level English (4.6★)
- **Dr. Lisa Patel** - A-Level Biology (4.8★)
- **Ahmed Al-Rashid** - GCSE Maths (Dubai) (4.7★)
- **Priya Sharma** - A-Level Physics (Singapore) (4.9★)

## 🔧 Development

### **Running Tests**
```bash
flutter test
```

### **Code Analysis**
```bash
flutter analyze
```

### **Building for Web**
```bash
flutter build web
```

## 📝 Key Features Explained

### **1. TikTok-Style Video Feed**
- Vertical scrolling with `PageView.builder`
- Swipe gestures for navigation
- Mixed content (videos + live sessions)
- Auto-play functionality

### **2. Authentication System**
- JWT token-based authentication
- Persistent login with SharedPreferences
- Guest browsing capability
- Form validation with custom error messages

### **3. Booking System**
- Calendar integration with availability highlighting
- Time slot selection with visual feedback
- One trial per tutor limit
- Google Meet link generation

### **4. State Management**
- `AuthProvider` for authentication state
- `TutorProvider` for tutor booking state
- Riverpod for reactive state management
- Cache management for performance

## 🐛 Known Issues

1. **Agora Compilation Errors** - Live streaming features have undefined classes
2. **Image Loading** - Some video thumbnails fail to decode
3. **Mobile Testing** - Not yet tested on iOS/Android devices

## 🚀 Next Steps

### **Priority 1: Fix Critical Issues**
- [ ] Fix Agora compilation errors
- [ ] Test mobile platform
- [ ] Implement video upload system

### **Priority 2: Core Features**
- [ ] Add in-app messaging
- [ ] Implement push notifications
- [ ] Add video recording functionality

### **Priority 3: Polish**
- [ ] Add analytics and monitoring
- [ ] Implement admin dashboard
- [ ] Add internationalization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email support@tutorhouse.co.uk or create an issue in this repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Agora.io for live streaming capabilities
- Stripe for payment processing
- All the open-source contributors

---

**Built with ❤️ for the future of education**