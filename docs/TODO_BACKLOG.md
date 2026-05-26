# Cinebox TODO Backlog (Repo Scan)

Scan date: `2026-03-24`

## How This Scan Was Done

1. Read all source files under `lib/` and key config files (`pubspec.yaml`, Android manifests/Gradle, Firebase config).
2. Ran static checks:
  - `flutter analyze` -> 6 issues (all info-level lint findings)
3. Ran build check:
  - `flutter build apk --debug` -> success
4. Ran tests:
  - `flutter test` -> failed because no `test/` directory exists

## Priority Order

## P0 - Critical / Release Blocking

- [ ] **P0-1: Remove TMDB API key from client source code**
  - Problem: TMDB key is hardcoded in app code.
  - Evidence: `lib/data/services/movie_service.dart:7`
  - Risk: Key can be extracted from APK/web bundle and abused.
  - Fix direction: Move key handling behind a backend/proxy or secure runtime config strategy.

- [ ] **P0-2: Add internet permission to release Android manifest**
  - Problem: Main manifest has no `<uses-permission android:name="android.permission.INTERNET"/>`.
  - Evidence: `android/app/src/main/AndroidManifest.xml` (permission not present), while only debug/profile manifests include it.
  - Risk: Release build may not access network APIs reliably.
  - Fix direction: Add internet permission in main manifest.

- [ ] **P0-3: Replace template release config values**
  - Problem: Android still uses template app id and debug signing for release.
  - Evidence:
    - `android/app/build.gradle.kts:27` (`applicationId = "com.example.cinebox"`)
    - `android/app/build.gradle.kts:40` (`signingConfig = signingConfigs.getByName("debug")`)
  - Risk: Not suitable for Play Store production release.
  - Fix direction: Set real application ID and proper release keystore signing.

## P1 - High Impact

- [ ] **P1-1: Add automated tests (currently zero tests)**
  - Problem: No `test/` folder exists.
  - Evidence: `flutter test` output -> `Test directory "test" not found.`
  - Risk: Regressions are likely as features grow.
  - Fix direction: Add unit tests for services/models and widget tests for core flows.

- [ ] **P1-2: Dispose controllers in auth screens**
  - Problem: Controllers are created but never disposed in login/OTP screens.
  - Evidence:
    - `lib/presentation/screens/auth/login_screen.dart:15`
    - `lib/presentation/screens/auth/otp_screen.dart:16`
  - Risk: Memory/resource leaks on repeated navigation.
  - Fix direction: Implement `dispose()` in both screens.

- [ ] **P1-3: Remove OTP flow duplication**
  - Problem: `AuthService.verifyOTP` exists but OTP screen signs in directly with `FirebaseAuth`.
  - Evidence:
    - `lib/data/services/auth_service.dart:42`
    - `lib/presentation/screens/auth/otp_screen.dart:32`
  - Risk: Business logic divergence and harder maintenance.
  - Fix direction: Route OTP verification through `AuthService` or remove unused method.

- [ ] **P1-4: Remove India-only hardcoded phone prefix**
  - Problem: Login flow always prepends `+91`.
  - Evidence: `lib/presentation/screens/auth/login_screen.dart:31`
  - Risk: Blocks users outside India.
  - Fix direction: Add country code picker and normalized E.164 formatting.

## P2 - Code Quality / Maintainability

- [ ] **P2-1: Fix current analyzer issues (6 infos)**
  - Problem: Lint issues from analyzer remain unresolved.
  - Evidence:
    - `lib/data/services/firestore_service.dart:30`
    - `lib/data/services/firestore_service.dart:31`
    - `lib/data/services/firestore_service.dart:32`
    - `lib/presentation/screens/auth/login_screen.dart:68`
    - `lib/presentation/screens/auth/login_screen.dart:72`
    - `lib/presentation/screens/auth/login_screen.dart:139`
  - Fix direction:
    - Use null-aware map entries in Firestore payload.
    - Replace deprecated `withOpacity()` with `withValues(alpha: ...)`.

- [ ] **P2-2: Remove or use unused dependencies**
  - Problem: Some packages in `pubspec.yaml` are not used in `lib/`.
  - Evidence:
    - `pubspec.yaml:25` (`provider`)
    - `pubspec.yaml:28` (`cached_network_image`)
    - `pubspec.yaml:29` (`fluttertoast`)
  - Risk: Extra package surface and maintenance overhead.
  - Fix direction: Remove unused deps or wire them into architecture intentionally.

- [ ] **P2-3: Resolve empty core files**
  - Problem: Placeholder core files are empty.
  - Evidence:
    - `lib/core/constants.dart` (0 bytes)
    - `lib/core/theme.dart` (0 bytes)
  - Risk: Confusing architecture signals and dead structure.
  - Fix direction: Either implement centralized constants/theme or remove files.

- [ ] **P2-4: Replace template project metadata**
  - Problem: Default project description values still present.
  - Evidence:
    - `pubspec.yaml:3`
    - `web/index.html:21`
  - Risk: Unprofessional release metadata.
  - Fix direction: Update description/title/meta with real product copy.

## P3 - Product/Architecture Improvements

- [ ] **P3-1: Introduce explicit state management strategy**
  - Problem: `provider` is included but not used; state is mostly widget-local.
  - Impact: Scaling features may get harder.
  - Fix direction: Adopt Provider/Riverpod/BLoC consistently.

- [ ] **P3-2: Add CI checks**
  - Problem: No visible CI enforcement for analyze/test/build.
  - Impact: Quality checks depend on manual local runs.
  - Fix direction: Add pipeline to run `flutter analyze`, `flutter test`, and one build target on PRs.

## Recommended Fix Sequence (One by One)

1. P0-1 (API key handling)
2. P0-2 (release internet permission)
3. P0-3 (release app id + signing)
4. P1-2 (dispose controllers)
5. P2-1 (analyzer cleanup)
6. P1-1 (test baseline)
7. Remaining tasks
