# cpc_clean_user

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Security and Release Notes

- `android/app/google-services.json` now contains a placeholder API key and should be injected securely at build time.
- Keep real Firebase credentials out of version control.
- `.gitignore` is configured to ignore Firebase service files for Android/iOS.

### Inject Firebase API key (local example)

```bash
export FIREBASE_API_KEY="<real_api_key>"
sed -i "s/__INJECT_FIREBASE_API_KEY_AT_BUILD_TIME__/$FIREBASE_API_KEY/g" android/app/google-services.json
```

### Universal APK build

```bash
flutter build apk --release
```

The Android Gradle config enables ABI splits with a universal APK output to support `armeabi-v7a`, `arm64-v8a`, and `x86_64`.
