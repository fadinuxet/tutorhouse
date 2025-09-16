# 🔒 Security Guide

## ⚠️ IMPORTANT: API Keys and Credentials

**NEVER commit real API keys or credentials to version control!**

### 🚨 What Was Fixed

The following sensitive data was previously exposed and has been secured:

1. **Supabase Credentials** - Replaced with placeholder values
2. **Google API Keys** - Replaced with placeholder values  
3. **Google Client IDs** - Replaced with placeholder values
4. **Project IDs** - Replaced with placeholder values

### 🛠️ How to Set Up Your Environment

1. **Copy the environment template:**
   ```bash
   cp env.example .env
   ```

2. **Fill in your actual credentials in `.env`:**
   ```bash
   # Supabase Configuration
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key_here
   
   # Google Configuration  
   GOOGLE_API_KEY=your_actual_google_api_key
   GOOGLE_CLIENT_ID=your_actual_client_id
   GOOGLE_WEB_CLIENT_ID=your_actual_web_client_id
   ```

3. **Update config files with your values:**
   - `lib/config/supabase_config.dart`
   - `lib/config/google_config.dart`
   - `android/app/google-services.json`

### 🔐 Security Best Practices

1. **Environment Variables**: Use `.env` files for sensitive data
2. **Git Ignore**: Never commit `.env` files
3. **Placeholder Values**: Use placeholder values in config files
4. **Separate Environments**: Use different keys for dev/staging/production
5. **Key Rotation**: Regularly rotate your API keys
6. **Access Control**: Limit API key permissions to minimum required

### 🚫 What NOT to Do

- ❌ Never commit real API keys
- ❌ Never share credentials in chat/email
- ❌ Never use production keys in development
- ❌ Never hardcode secrets in source code

### ✅ What TO Do

- ✅ Use environment variables
- ✅ Use placeholder values in configs
- ✅ Keep `.env` files in `.gitignore`
- ✅ Use different keys per environment
- ✅ Document security setup process

### 🔍 How to Check for Exposed Keys

Run this command to scan for potential secrets:
```bash
grep -r "api[_-]key\|secret\|password\|token" --include="*.dart" --include="*.json" lib/
```

### 📞 If Keys Are Compromised

1. **Immediately rotate** the compromised keys
2. **Check usage logs** for unauthorized access
3. **Update all environments** with new keys
4. **Review access permissions**

---

**Remember: Security is everyone's responsibility! 🔒**
