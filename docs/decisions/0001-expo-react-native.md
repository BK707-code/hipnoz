# 0001 — Expo / React Native for the mobile app

- **Status:** Accepted
- **Date:** 2026-10-14

## Context
The first (and main) user owns an iPhone and a Windows laptop — **no Mac**. Native iOS development (Swift/Xcode) requires macOS. The app should eventually be publishable to the App Store.

Options considered:

| Option | Pros | Cons |
|---|---|---|
| Native Swift | Best iOS integration | Impossible without a Mac |
| PWA (web app) | Simplest, works on laptop too | Not on App Store, limited iOS notifications |
| Flutter | Strong framework | New language (Dart); iOS builds still need cloud/Mac |
| **Expo / React Native** | Develop on Windows, test instantly with Expo Go, cloud builds (EAS) for App Store | JavaScript/TypeScript ecosystem to learn |

## Decision
Use **Expo / React Native** with TypeScript.

## Consequences
- Development and on-device testing work from Windows via **Expo Go** over Wi-Fi.
- App Store builds go through **EAS Build** (cloud), no Mac needed.
- Local notifications are available through `expo-notifications`.
