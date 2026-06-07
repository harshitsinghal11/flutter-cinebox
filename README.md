# Cinebox

> A Flutter movie-tracking app that uses phone OTP login, TMDB movie discovery, and Firestore-backed personal watch data.

---

## What is Cinebox?

Cinebox is a movie companion application built with Flutter. It lets a signed-in user browse movie categories from TMDB, search for titles, open a movie detail page, and save movies to a personal watched list or queue with a simple 1-5 rating.

Based on the current repository and project docs, the app was created to combine movie discovery and personal tracking in one place. Instead of separating browsing from watchlist management, Cinebox keeps both flows inside the same authenticated experience and stores each user's saved movie state in Firebase.

The current authentication flow is built around phone-number login and automatically prefixes `+91`, so the present implementation is tailored to Indian phone numbers.

### Built For

* Movie viewers who want a personal queue of titles to watch
* Users who want to keep track of what they have already watched
* People who prefer phone-number-based sign-in for a lightweight personal tracker

---

## Features

### Discovery

* Browse four TMDB-powered movie sections: Trending Now, Now Playing, Upcoming Releases, and Top Rated
* Open any movie card to view a dedicated detail screen
* Search TMDB movies by title from a separate search screen

### Personal Tracking

* Sign in with phone OTP using Firebase Authentication
* Save movies to a personal Firestore list tied to the signed-in user
* Mark movies as watched
* Add movies to a queue
* Rate watched movies on a 1-5 scale
* View watched and queued titles separately on the profile screen

### Data Behavior

* Store movie status under `users/{uid}/my_list/{movieId}` in Cloud Firestore
* Reflect saved movie state in real time on the detail screen through Firestore streams
* Keep queue and watched states mutually exclusive when the user updates a movie
* Allow ratings only after a movie has been marked as watched

### UI & UX

* Route users automatically at startup based on Firebase auth state
* Show loading and empty states across the auth, home, search, and profile flows
* Use responsive layouts for auth screens and the movie detail screen
* Reuse shared UI pieces such as the background wrapper, branded app bar, and action buttons

---

## Installation

### Prerequisites

* Flutter SDK with a Dart version compatible with `sdk: ^3.10.7`
* A Flutter-supported device or simulator
* Firebase services enabled for the project if you want phone auth and Firestore to work

### Setup

1. Clone the repository.
2. Install dependencies:

```bash
flutter pub get
```

3. Review service configuration before running:
   The repository already includes `lib/firebase_options.dart`, `firebase.json`, and `android/app/google-services.json`.
   The TMDB API key is currently read from `lib/data/services/movie_service.dart`.
   If you want to use your own Firebase or TMDB setup, replace those values first.

4. Run the app:

```bash
flutter run
```

### Platform Notes

* Flutter platform folders are present for Android, iOS, Linux, macOS, web, and Windows.
* Firebase options are configured in `lib/firebase_options.dart` for Android, iOS, macOS, web, and Windows.
* Linux is not configured in `lib/firebase_options.dart` and will need FlutterFire setup before use.

---

## How It Works

```text
App Launch
|
v
Firebase Initializes
|
v
Auth Guard Checks `authStateChanges()`
|
v
Signed Out: Phone Number -> OTP Verification -> Sign In
|
v
Signed In: Home Screen Loads TMDB Categories
|
v
User Searches or Opens a Movie
|
v
Detail Screen Reads/Writes Queue, Watched State, and Rating in Firestore
|
v
Profile Screen Groups Saved Movies into Watched and Queue Tabs
```

In simple terms, the app starts by checking whether the user is already logged in. After login, Cinebox loads movie discovery sections from TMDB. When a user opens a movie, they can save it to their queue, mark it as watched, and rate it. That personal data is stored in Firestore under the current user account and then shown again in the profile screen.

---

## Tech Stack

| Layer | Technology | Purpose |
| ----- | ---------- | ------- |
| App UI | Flutter + Material | Builds the cross-platform interface, navigation, and screen layouts |
| Typography | Google Fonts | Applies the Poppins and Bebas Neue text styles used in the app |
| Authentication | Firebase Authentication | Handles phone OTP sign-in and auth-state persistence |
| Database | Cloud Firestore | Stores each user's queue, watched state, ratings, and saved movie metadata |
| External Data | TMDB REST API | Supplies trending, now playing, upcoming, top rated, and search movie data |
| Networking | `http` | Sends REST requests to TMDB and parses JSON responses |
| Assets | Local image assets | Provides the shared full-screen background image |

---

## Project Structure

```text
cinebox/
|-- assets/
|   `-- images/
|-- docs/
|-- lib/
|   |-- core/
|   |-- data/
|   |   |-- models/
|   |   `-- services/
|   |-- presentation/
|   |   |-- screens/
|   |   |   |-- auth/
|   |   |   |-- details/
|   |   |   |-- home/
|   |   |   |-- profile/
|   |   |   `-- search/
|   |   `-- widgets/
|   |-- firebase_options.dart
|   `-- main.dart
|-- android/
|-- ios/
|-- linux/
|-- macos/
|-- web/
|-- windows/
|-- firebase.json
|-- pubspec.yaml
`-- README.md
```

* `lib/main.dart` initializes Firebase, builds the app shell, and sends users to login or home based on auth state.
* `lib/data/models/` contains the `Movie` model and TMDB JSON mapping logic.
* `lib/data/services/` contains the Firebase auth wrapper, Firestore persistence layer, and TMDB API service.
* `lib/presentation/screens/` contains the app's user-facing flows: login, OTP verification, home, search, movie details, and profile.
* `lib/presentation/widgets/` contains reusable UI pieces such as the background wrapper, app bar, and custom buttons.
* `assets/images/` stores the background image used across multiple screens.
* `docs/` contains additional project analysis and a backlog of follow-up work.
* The platform directories (`android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`) contain the generated Flutter runner and platform configuration files.

---

## Challenges Solved

* The app keeps movie discovery and personal tracking in one flow while separating external movie reads from user-specific Firestore writes.
* It uses Firebase auth-state listening at startup so returning users do not have to manually restore a session.
* It stores movie data per user under `users/{uid}/my_list/{movieId}`, which keeps watch data scoped to the authenticated account.
* It prevents inconsistent tracking states by making queue and watched mutually exclusive in the detail screen.
* It gates ratings behind the watched state so users cannot rate a movie before marking it as watched.
* It converts TMDB genre IDs into readable labels and provides fallbacks for missing posters, backdrops, and descriptions.

---

## Future Improvements

* Move the TMDB API key out of client source code and into a safer configuration or proxy layer.
* Add automated unit and widget tests; the repository currently has no `test/` directory.
* Replace the hardcoded `+91` login prefix with a country-code selector and proper E.164 formatting.
* Consolidate repeated styling into the existing `lib/core/` structure for theme and constants management.
* Introduce a more explicit state-management approach if the number of screens and interactions continues to grow.

---

## Author

Harshit Singhal  
GitHub: [harshitsinghal11](https://github.com/harshitsinghal11)

---

## License

No license file is currently present in this repository.
