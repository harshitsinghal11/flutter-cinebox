# Cinebox Project Documentation

## 1. Product Goal

Cinebox is a personal movie companion app focused on three main jobs:

1. Help users discover movies (trending, now playing, upcoming, top rated).
2. Let users track their personal watch journey (queue, watched, rating).
3. Keep this data tied to the authenticated user account using Firebase.

## 2. What Is Already Built

1. OTP login flow using Firebase Phone Auth.
2. Auth guard on app startup (`FirebaseAuth.instance.authStateChanges()`).
3. Home feed with four TMDB-powered categories.
4. Search screen for TMDB movie lookup.
5. Detail screen with real-time Firestore-backed status (queue/watched/rating).
6. Profile screen with watched/queue tab filtering and logout.
7. Background image-driven visual UI system with reusable custom widgets.

## 3. Tech Stack

1. Frontend: Flutter (Material).
2. Backend services: Firebase Auth + Cloud Firestore.
3. External API: TMDB REST API.
4. Packages in use: `firebase_core`, `firebase_auth`, `cloud_firestore`, `http`, `google_fonts`.

## 4. Current Code Architecture

### Entry & App Shell

- `lib/main.dart`
  - Initializes Firebase.
  - Creates `MaterialApp`.
  - Applies dark theme with Google Fonts.
  - Routes users by auth state:
    - Logged in -> `HomeScreen`
    - Logged out -> `LoginScreen`

### Data Layer

- `lib/data/models/movie_model.dart`
  - Defines `Movie` entity.
  - Converts TMDB JSON to app model.
  - Maps TMDB genre IDs to readable genre labels.

- `lib/data/services/movie_service.dart`
  - Calls TMDB endpoints for:
    - Trending
    - Now playing
    - Upcoming
    - Top rated
    - Search
  - Converts API responses into `Movie` objects.

- `lib/data/services/auth_service.dart`
  - Wraps phone verification and sign-in helpers.

- `lib/data/services/firestore_service.dart`
  - Handles user-scoped movie data in Firestore:
    - Save/merge movie status
    - Stream a single movie doc
    - Stream full list and filtered lists

### Presentation Layer

- Auth:
  - `lib/presentation/screens/auth/login_screen.dart`
  - `lib/presentation/screens/auth/otp_screen.dart`
- Discovery:
  - `lib/presentation/screens/home/home_screen.dart`
  - `lib/presentation/screens/search/search_screen.dart`
- Tracking:
  - `lib/presentation/screens/details/movie_detail_screen.dart`
  - `lib/presentation/screens/profile/profile_screen.dart`
- Shared widgets:
  - `lib/presentation/widgets/bg_wrapper.dart`
  - `lib/presentation/widgets/cinebox_app_bar.dart`
  - `lib/presentation/widgets/custom_buttons.dart`

## 5. Firestore Data Shape (Inferred)

Collection path:

- `users/{uid}/my_list/{movieId}`

Stored fields:

- `id`
- `title`
- `posterPath`
- `year` (currently sourced from release date string)
- `overview`
- `genres`
- `inQueue` (optional bool)
- `isWatched` (optional bool)
- `rating` (optional int)
- `lastUpdated` (server timestamp)

## 6. User Flow (Current)

1. User opens app.
2. App checks auth state.
3. If unauthenticated: login with Indian phone number format (`+91`).
4. If authenticated: land on home feed.
5. User opens movie details and can:
  - Add/remove queue
  - Mark watched/unwatched
  - Rate only when watched
6. Data syncs into Firestore and appears in profile tabs.

## 7. Build & Verification Status

Scan date: `2026-03-24`

1. `flutter analyze` completed with 6 lint/info issues and no compile-time blocking errors.
2. `flutter build apk --debug` succeeded and produced APK.
3. `flutter test` failed because no `test/` directory exists yet.

## 8. Gaps vs Production-Ready App

1. Secrets and configuration hygiene still needs hardening.
2. Release configuration still contains template placeholders.
3. Automated tests are not set up yet.
4. A few lifecycle and maintainability issues remain in UI/service code.

For the complete actionable list, use `docs/TODO_BACKLOG.md`.
