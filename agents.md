# Zeitgut Connect iOS Agent Guide

This document is the iOS-side working agreement for Zeitgut Connect. It captures the current app architecture, the verified auth flow, the Azure/MSAL configuration that must stay aligned, and the debugging lessons already paid for.

## 1. Product Context

Zeitgut Connect is a whitelabel multi-tenant system for local neighborhood assistance associations.

Design priorities:
- Simple for non-technical and elderly users.
- Strong privacy and trust.
- Low cost through serverless backend infrastructure.
- Clear tenant isolation.
- Easy onboarding through Microsoft sign-in.

The iOS app should behave like the Android app at the auth-contract level even if the implementation is platform-native.

## 2. iOS Stack

- Native iOS app
- SwiftUI
- Microsoft Authentication Library (MSAL) for iOS
- Backend session bootstrap through Azure Functions

Current Xcode project:
- Project: `zeitgut-connect-ios/Zeitgut Connect.xcodeproj`
- Target: `Zeitgut Connect`
- Bundle identifier: `com.github.jonasclick.zeitgutconnect`

## 3. App Structure

The existing app shell and tab UI already existed before auth was added.

Important files:
- `Zeitgut Connect/App/Zeitgut_ConnectApp.swift`
- `Zeitgut Connect/App/Root/MainContainerView.swift`
- `Zeitgut Connect/Features/Auth/AuthGateView.swift`
- `Zeitgut Connect/Features/Auth/AuthViewModel.swift`
- `Zeitgut Connect/Features/Auth/AuthSession.swift`
- `Zeitgut Connect/Features/Auth/Services/AuthService.swift`
- `Zeitgut Connect/Features/Transactions/Services/TransactionService.swift`
- `Zeitgut Connect/Core/Networking/APIClient.swift`
- `Config/Zeitgut-Connect-Info.plist`
- `Config/Entitlements/ZeitgutConnect.entitlements`

The auth layer sits in front of `MainContainerView` rather than being mixed into the tab views.

## 4. Backend / Tenant Architecture

The backend is shared with Android and uses:
- Azure Functions
- Azure Cosmos DB NoSQL
- single-container multi-tenancy
- partition key `/tenantId`

Relevant backend endpoints:
- `GET /api/me`
- `POST /api/me/join`
- `GET /api/auth-debug`

Important backend auth rule:
- the backend derives identity from EasyAuth / `x-ms-client-principal`
- clients must send `Authorization: Bearer <access_token>`
- clients must not invent or trust tenant ids locally

## 5. iOS Auth Architecture

### Current Target Flow

1. App starts.
2. MSAL initializes a public client application.
3. App attempts silent token acquisition from the MSAL keychain cache.
4. If silent sign-in succeeds, app calls `/api/me`.
5. If no cached account is available or silent sign-in fails, user sees a simple `Sign in with Microsoft` button.
6. Interactive Microsoft sign-in runs through MSAL.
7. App calls `/api/me`.
8. If `isAssigned == true`, app enters the main app.
9. If `isAssigned == false`, app shows a minimal invitation code screen.
10. Invitation code submission calls `POST /api/me/join`.
11. On `201`, app enters the main app.

### Source of Truth

Preserve these rules:
- MSAL / bearer tokens are the source of authentication state.
- `/api/me` is the source of truth for backend session bootstrap.
- Local app session state is a convenience layer, not the security authority.
- Do not reintroduce WebView/cookie-based auth.

## 6. Current Verified iOS State

What already works in the repo:
- MSAL is added to the Xcode project through Swift Package Manager.
- The app has a SwiftUI auth gate in front of the existing app shell.
- The app is wired for silent sign-in, interactive sign-in, `/api/me`, and `/api/me/join`.
- The app builds successfully for iOS Simulator from the command line.
- A real iOS MSAL initialization issue was debugged and fixed.

What was fixed during onboarding:
- `CFBundleURLTypes` includes the custom redirect scheme.
- `LSApplicationQueriesSchemes` includes `msauthv2` and `msauthv3`, which MSAL requires.
- Keychain entitlements were added for the MSAL cache group.
- MSAL verbose logging hooks were added to speed up future debugging.

What this means:
- The repo now contains the architectural prerequisites for native Microsoft sign-in on iOS.
- If auth breaks again, check project/plist drift before suspecting backend issues.

## 7. Azure / MSAL Configuration That Must Stay Aligned

### iOS App Registration

- Client id: `1ef99cf2-66c2-4f68-986b-81fb2b1e6a9f`
- Redirect URI: `msauth.com.github.jonasclick.zeitgutconnect://auth`

### Backend API Scope

The app requests the backend delegated scope:

```text
api://5363c539-7d42-4566-b2eb-83f636111c20/user_impersonation
```

### Account Audience

The app should support the same audience as Android:
- Microsoft personal accounts
- Entra/Azure AD accounts

Authority used in iOS:
- `https://login.microsoftonline.com/common`

### Required Local App Configuration

These values must remain aligned:
- bundle identifier: `com.github.jonasclick.zeitgutconnect`
- redirect URI: `msauth.com.github.jonasclick.zeitgutconnect://auth`
- Info.plist URL scheme: `msauth.com.github.jonasclick.zeitgutconnect`
- `LSApplicationQueriesSchemes`: `msauthv2`, `msauthv3`
- entitlement keychain access group: `$(AppIdentifierPrefix)com.microsoft.adalcache`

If any of those drift apart, MSAL may fail before sign-in even starts.

## 8. Auth State Storage on iOS

Keep this distinction clear:

- MSAL token/account cache:
  - stored by MSAL in the iOS Keychain
  - used for silent sign-in on app relaunch

- App-level `AuthSession`:
  - currently in memory only
  - rebuilt from MSAL + `/api/me`
  - should be treated as prototype-level state, not durable identity proof

Best practice for now:
- rely on MSAL keychain persistence
- re-bootstrap through `/api/me` on launch
- avoid inventing a parallel persistent auth store unless there is a clear product need

## 9. Current UI / UX Constraints

Keep the auth UI intentionally simple for now:
- one obvious Microsoft sign-in button
- one simple invitation code field
- no auth styling polish work unless explicitly requested

Current intent:
- match Android behavior first
- add design polish later

## 10. Logging and Debugging Conventions

Use the `ZeitgutAuth` logger output in Xcode console for auth debugging.

Useful checkpoints:
- `MSAL_STEP_1 auth gate started`
- `MSAL_STEP_1 initializing MSAL ...`
- `MSAL_STEP_1 cached account count=...`
- `MSAL_STEP_1 no cached account found`
- `MSAL_STEP_1 attempting silent token acquisition`
- `MSAL_STEP_1 silent success ...`
- `MSAL_STEP_1 interactive sign-in requested`
- `MSAL_STEP_1 presenting interactive sign-in`
- `MSAL_STEP_1 redirect received ...`
- `MSAL_STEP_1 interactive completion error=...`
- `MSAL_STEP_2 calling /api/me ...`
- `MSAL_STEP_2 /api/me success body=...`
- `MSAL_STEP_3 calling /api/me/join ...`
- `MSAL_STEP_3 /api/me/join success body=...`
- `MSAL_INTERNAL ...`

### Important Debugging Lesson Already Learned

If MSAL fails during initialization with:
- `MSALErrorDomain code=-50000`
- and mentions missing `msauthv2` / `msauthv3`

then the problem is:
- local iOS `Info.plist` configuration
- not backend auth
- not `/api/me`
- not redirect callback handling

That issue was already fixed by adding:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>msauthv2</string>
  <string>msauthv3</string>
</array>
```

## 11. Current Integration Gaps

What is still incomplete or prototype-level:
- The main app content is still placeholder/demo-level and not truly domain-bootstrapped.
- The iOS app has not yet been documented as end-to-end device-verified in the same depth as Android.
- Auth logging is intentionally verbose and should later be reduced once the app is stable.
- Session persistence beyond the MSAL cache remains minimal.

## 12. Recommended Next Steps

1. Verify the full iOS auth flow on a real device as well as simulator.
2. Confirm:
   - interactive Microsoft sign-in opens
   - redirect returns to the app
   - `/api/me` succeeds
   - onboarding through `/api/me/join` succeeds
3. After auth is stable, attach real member/profile bootstrap to the app shell.
4. Reduce overly verbose auth logs once iOS auth is considered stable.
5. Keep `auth-debug` on the backend until both Android and iOS are confidently stable.

## 13. Guardrails

- Do not replace MSAL with a custom browser auth flow.
- Do not store tenant identity as a client-side source of truth.
- Do not treat in-memory app session as authoritative auth state.
- Do not remove the `msauthv2` / `msauthv3` query schemes.
- Do not remove the MSAL keychain entitlement without understanding the silent sign-in impact.
- Keep `/api/me` and `/api/me/join` contract-aligned with Android.
