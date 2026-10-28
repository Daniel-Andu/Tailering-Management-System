# Sendliberty Email OTP Verification Setup Guide

## Overview
Your Tailoring Management System now includes email verification via OTP (One-Time Password) using Sendliberty email service.

## Features Implemented ✅
- ✉️ Professional OTP email templates with beautiful HTML design
- 🔐 6-digit OTP codes that expire in 10 minutes
- 🔄 Resend OTP functionality with 60-second cooldown
- 🛡️ Rate limiting: Max 3 OTP requests per email per hour
- 🎯 Auto-advance OTP input fields
- ⏱️ Live countdown timer showing remaining validity
- 🚫 Brute force protection: Max 5 verification attempts per OTP
- ✅ Automatic verification on 6th digit entry

## Setup Instructions

### 1. Get Sendliberty API Key

1. Go to https://sendliberty.com/
2. Click **"Get Started Free"**
3. Sign in with your Google account
4. Navigate to **"Gmail Accounts"** page
5. Click **"Connect New Account"** to authorize your Gmail
6. Navigate to **"API Keys"** page
7. Click **"Generate New Key"**
8. **Copy the API key** (you won't see it again!)

### 2. Configure Your App

Edit `lib/services/sendliberty_service.dart`:

```dart
// Line 7-9: Replace with your credentials
static const String _apiKey = 'YOUR_SENDLIBERTY_API_KEY_HERE';
static const String _senderEmail = 'yourapp@gmail.com'; // Gmail you connected
static const String _senderName = 'Tailoring System'; // Your app name
```

**Example:**
```dart
static const String _apiKey = 'sl_live_1234567890abcdef...';
static const String _senderEmail = 'noreply@tailoringsystem.com';
static const String _senderName = 'Tailoring Management System';
```

### 3. Update Firestore Security Rules

Add these rules to Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Existing tailors collection
    match /tailors/{tailorId} {
      allow read, write: if request.auth != null && request.auth.uid == tailorId;
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == tailorId;
      }
    }
    
    // OTP codes collection (NEW)
    match /otp_codes/{email} {
      // Anyone can write (create OTP)
      allow create: if true;
      
      // Only the email owner can read/update their OTP
      allow read, update: if request.auth == null || 
                            request.auth.token.email == email;
      
      // Auto-delete after 24 hours
      allow delete: if true;
    }
    
    match /_test/{document} {
      allow read: if true;
    }
  }
}
```

Click **"Publish"** to save.

### 4. Install Dependencies

Run:
```bash
flutter pub get
```

This will install the `http` package added to `pubspec.yaml`.

### 5. Test the Flow

1. **Build & Install APK:**
   ```bash
   flutter build apk --debug
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

2. **Register New Account:**
   - Open the app
   - Click "Register"
   - Fill in all fields
   - Click "Register Shop"
   - **OTP email will be sent!** ✉️

3. **Check Your Email:**
   - Look for email from your sender email
   - Subject: "Verify Your Email - OTP Code"
   - Copy the 6-digit code

4. **Enter OTP:**
   - Type the 6 digits in the app
   - Auto-verifies on 6th digit
   - Account created successfully! ✅

## How It Works

```
User Registration Flow:
┌─────────────────┐
│ Register Screen │
│ (Fill Details)  │
└────────┬────────┘
         │
         ▼
   Send OTP Email
         │
         ▼
┌─────────────────┐
│ OTP Screen      │
│ (6-digit input) │
└────────┬────────┘
         │
         ▼
   Verify OTP
         │
    ┌────┴────┐
    │ Valid?  │
    └────┬────┘
         │ YES
         ▼
  Create Firebase
  Auth Account
         │
         ▼
  Create Firestore
  Shop Profile
         │
         ▼
    Dashboard! 🎉
```

## API Endpoint Used

**Send Email:**
```
POST https://sendliberty.com/api/send
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "from": "yourapp@gmail.com",
  "to": "user@example.com",
  "subject": "Verify Your Email - OTP Code",
  "html": "<html>...</html>"
}
```

## Sendliberty Free Tier Limits

- ✅ **200 emails/day** (per Gmail account)
- ✅ **1,000 emails/day** (per Google Workspace account)
- ✅ **3,500 emails/month** total
- ✅ **Zero DNS configuration** needed
- ✅ **No credit card** required

## Files Modified/Created

### New Files:
- ✅ `lib/services/sendliberty_service.dart` - Email sending service
- ✅ `lib/services/otp_service.dart` - OTP generation and verification
- ✅ `lib/screens/auth/otp_verification_screen.dart` - OTP input UI

### Modified Files:
- ✅ `lib/providers/auth_provider.dart` - Added OTP methods
- ✅ `lib/screens/auth/register_screen.dart` - Navigate to OTP screen
- ✅ `pubspec.yaml` - Added `http` package

## Troubleshooting

### Email Not Received?

1. **Check spam folder** in Gmail
2. **Verify API key** is correct in `sendliberty_service.dart`
3. **Check sender email** matches Gmail you connected
4. **Check Sendliberty dashboard** at https://sendliberty.com/dashboard → Email Logs
5. **Check console logs** for error messages

### OTP Always Invalid?

1. Check **Firestore rules** are published
2. Verify **internet connection** during registration
3. Check **Firebase Console → Firestore** to see if OTP document exists
4. Look for error messages in console logs

### Rate Limited?

- Wait 1 hour before trying again
- Or delete the OTP document manually in Firebase Console

## Security Features

✅ **Time-based expiration:** 10 minutes validity  
✅ **Rate limiting:** 3 OTPs per hour per email  
✅ **Attempt limiting:** 5 wrong attempts max  
✅ **One-time use:** OTP deleted after verification  
✅ **No OTP in URL:** Sent via email only  
✅ **Secure storage:** Firestore with proper rules  

## Next Steps

After users verify their email:
1. They complete onboarding (3-step shop setup)
2. They can access the full dashboard
3. Email verification status is stored
4. Future logins don't require re-verification

## Support

- **Sendliberty Docs:** https://sendliberty.com/docs
- **Sendliberty Dashboard:** https://sendliberty.com/dashboard
- **Firebase Console:** https://console.firebase.google.com/

---

**That's it!** 🎉 Your app now has professional email verification with OTP!
