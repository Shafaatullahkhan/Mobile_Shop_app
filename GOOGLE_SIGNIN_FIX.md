# Google Sign-In Fix Guide

## Issue
The app is showing `ApiException: 10` when trying to sign in with Google. This error occurs when the SHA-1 fingerprint of your app is not configured in the Firebase console.

## Solution

### Step 1: Get Your SHA-1 Fingerprint
Your app's SHA-1 fingerprint is:
```
25:62:92:A0:B6:BC:7E:07:B8:E5:CD:9C:73:E2:D9:4D:DE:38:12:9F
```

### Step 2: Add SHA-1 to Firebase Console

1. **Open Firebase Console**: Go to https://console.firebase.google.com
2. **Select Your Project**: Choose your Mobile Shop App project
3. **Go to Project Settings**: Click the gear icon ⚙️ in the left sidebar, then "Project settings"
4. **Select Your App**: Under "Your apps" section, click on your Android app
5. **Add SHA Certificate**: Scroll down to the "SHA certificate fingerprints" section
6. **Click "Add certificate"**
7. **Enter the SHA-1**: Paste this fingerprint: `25:62:92:A0:B6:BC:7E:07:B8:E5:CD:9C:73:E2:D9:4D:DE:38:12:9F`
8. **Save**: Click "Save"

### Step 3: Rebuild the App

After adding the SHA-1 fingerprint to Firebase:

1. **Stop the current app**: Press `q` in the terminal where the app is running
2. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Step 4: Test Google Sign-In

1. Open the app
2. Go to the login screen
3. Click the Google Sign-In button
4. It should now work properly!

## What We've Already Fixed

✅ Added internet permission to AndroidManifest.xml
✅ Improved error handling in AuthProvider
✅ Added debug logging for troubleshooting
✅ Enhanced user experience with better error messages

## Troubleshooting

If it still doesn't work after adding the SHA-1:

1. **Wait a few minutes**: Firebase changes can take a few minutes to propagate
2. **Double-check the SHA-1**: Make sure you copied it exactly
3. **Check package name**: Ensure your app's package name matches what's in Firebase
4. **Enable Google Sign-In**: In Firebase Console → Authentication → Sign-in method, make sure Google is enabled

## Current App Package Name
```
com.mobile_app.mobile_app
```

Make sure this matches exactly in your Firebase project settings.
