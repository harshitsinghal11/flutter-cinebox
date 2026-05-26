# Cinebox

Cinebox is a Flutter + Firebase movie tracking app where users sign in with phone OTP, browse TMDB movies, and maintain a personal watched/queue list with ratings.

## Project Docs

- Project analysis and architecture: `docs/PROJECT_DOCUMENTATION.md`
- Full scanned issue backlog and TODO list: `docs/TODO_BACKLOG.md`

## Current Feature Set

- Phone OTP authentication using Firebase Auth
- Home feed sections:
  - Trending
  - Now Playing
  - Upcoming
  - Top Rated
- Movie search via TMDB
- Movie detail page with:
  - Watched toggle
  - Queue toggle
  - Personal rating (1-5)
- Profile page with watched/queue tabs and sign out
- Firestore persistence per user (`users/{uid}/my_list`)

## Quick Start

1. Install Flutter SDK (the project was built with Flutter 3.38.7, Dart 3.10.7).
2. Install Android Studio (or another Flutter-supported toolchain).
3. Run:

```bash
flutter pub get
flutter run
```

## Verification Commands

```bash
flutter analyze
flutter build apk --debug
flutter test
```

Note: `flutter test` currently reports that there is no `test/` directory yet.
