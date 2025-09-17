# 🔒 Security Guidelines

## Environment Variables

**CRITICAL**: Never commit sensitive credentials to the repository!

### Required Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Optional: Other services
GOOGLE_API_KEY=your_google_api_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
AGORA_APP_ID=your_agora_app_id_here
AGORA_APP_CERTIFICATE=your_agora_app_certificate_here
```

### Building the App

Use the secure build scripts:

```bash
# For development
./run_dev_secure.sh

# For production build
./run_secure.sh
```

### Manual Build with Environment Variables

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL="your_url" \
  --dart-define=SUPABASE_ANON_KEY="your_key" \
  --target=lib/main.dart
```

## Security Checklist

- [ ] `.env` file is in `.gitignore`
- [ ] No hardcoded credentials in source code
- [ ] Environment variables are loaded at build time
- [ ] Production builds use secure credential injection
- [ ] Development uses local `.env` file

## What's Protected

- ✅ Supabase URL and API keys
- ✅ Google API keys
- ✅ Stripe keys
- ✅ Agora credentials
- ✅ Any other sensitive configuration

## What's NOT Protected

- ❌ Client-side code (always visible)
- ❌ Public API endpoints
- ❌ UI/UX configurations