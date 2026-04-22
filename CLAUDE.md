# CLAUDE.md — Astrobless User App (Customer)

> Master context file for AI assistants working on this Flutter codebase.
> Keep this file authoritative. If reality drifts from this doc, update the doc.
> Read the root `/CLAUDE.md` first — this file extends it, not replaces it.

---

## 1. What this app is

**App name:** Astrobless  
**Persona:** Customer (user who seeks astrological guidance)  
**Platform:** Flutter 3.x — iOS + Android  
**Backend:** Connects to the Node.js/Fastify backend under `/v1/customer/*` and `/v1/public/*`

This is the **customer-facing app**. Customers use it to:
- Browse and connect with astrologers (chat, voice, video)
- Get AI astrologer answers (24/7, streamed, low-cost)
- View daily/weekly horoscopes and astrological content
- Manage their wallet and top up via Razorpay/PhonePe/GPay/Apple Pay
- Generate and save multiple Kundli profiles (birth charts) per account
- View cached Kundli reports without re-fetching from VedicAstro API
- Book and track Puja services (AstroMall)
- Track consultation history

**Architectural principle:** The customer persona is fully separated from astrologer/admin. Separate DB tables, separate JWT audience (`astrobless.customer`), separate route namespace, separate app binary. See root `CLAUDE.md §5`.

---

## 2. Tech stack (locked)

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x (Dart 3) |
| State management | Riverpod 2.x (`flutter_riverpod`) |
| Routing | go_router 14.x |
| Networking | dio 5.x |
| Real-time | socket_io_client 3.x |
| Local storage | flutter_secure_storage (tokens) + shared_preferences (cache) |
| Push notifications | firebase_messaging + flutter_local_notifications |
| Voice/video calls | agora_rtc_engine 6.x |
| Location | geolocator + geocoding (for kundli birth place) |
| Maps | google_maps_flutter (location picker) |
| AI chat UI | flutter_gen_ai_chat_ui |
| Animations | flutter_animate |
| Image | cached_network_image + image_picker |
| Payments | razorpay_flutter (or webview for other providers) |
| Connectivity | connectivity_plus |
| Auth helpers | google_sign_in, sign_in_with_apple |
| UI | Custom design system, Material 3, dark-first |

---

## 3. Non-negotiable rules

1. **Follow root `CLAUDE.md` exactly.**
2. **`camelCase` for Dart code, `snake_case` for file names.**
3. **No token in insecure storage.** Tokens in `flutter_secure_storage` only.
4. **Money is `int` (paise) everywhere.** Never `double`. Format at display layer only.
5. **JWT audience is `astrobless.customer`.** Never call `/v1/astrologer/*` or `/v1/admin/*`.
6. **All API calls through the `ApiClient` singleton** (Dio instance).
7. **Riverpod only for state.** No `setState` in non-trivial widgets.
8. **Feature-first folder structure.** `lib/features/<featureName>/`.
9. **Generated files not edited manually.** Run `build_runner`.
10. **Every catch block that swallows errors** must report to telemetry.
11. **No hardcoded base URL, API keys, or config.** Use `AppConfig`.

---

## 4. Auth system

### 4.1 Supported methods

| Method | Supported |
|---|---|
| Phone OTP (SMS via MSG91) | ✅ primary |
| Email + password | ✅ with email OTP verification |
| Google OAuth | ✅ |
| Apple Sign-In | ✅ iOS only |
| TOTP 2FA | Optional |

### 4.2 Token storage

```dart
// lib/core/auth/token_storage.dart
static const _accessKey  = 'customer_access_token';
static const _refreshKey = 'customer_refresh_token';
```

### 4.3 Auth endpoints (customer)

```
POST /v1/customer/auth/phone/send-otp       { phone }
POST /v1/customer/auth/phone/verify-otp     { phone, otp }
POST /v1/customer/auth/email/signup         { email, password, name }
POST /v1/customer/auth/email/verify-otp     { email, otp }
POST /v1/customer/auth/email/login          { email, password }
POST /v1/customer/auth/email/forgot-password { email }
POST /v1/customer/auth/email/reset-password { token, newPassword }
POST /v1/customer/auth/google               { idToken }
POST /v1/customer/auth/apple                { identityToken, nonce }
POST /v1/customer/auth/refresh              { refreshToken }
DELETE /v1/customer/auth/logout             { refreshToken }
```

### 4.4 Token refresh

Silent refresh via Dio interceptor on 401. On double-401 → clear tokens → navigate to `/auth/phone`.

---

## 5. Feature scope

### MVP
- [ ] Phone OTP + email+password + Google + Apple auth
- [ ] Home screen: banners, feature grid, trending astrologers, stories, videos, AI chat card
- [ ] AI chat screen (streamed, astrology-only, flutter_gen_ai_chat_ui)
- [ ] Browse + search astrologers (filter by specialty, language, price, rating)
- [ ] Chat consultation (Socket.IO, per-minute billing)
- [ ] Voice call consultation (Agora)
- [ ] Wallet: view balance, top up (Razorpay, PhonePe, GPay, Apple Pay)
- [ ] Multiple Kundli profiles per user (saved in DB)
- [ ] Kundli report (cached in DB, not re-fetched each time)
- [ ] Kundli matching (user selects two kundlis)
- [ ] Daily / weekly / monthly horoscopes
- [ ] Notification center
- [ ] Consultation history
- [ ] Profile management
- [ ] Bottom nav: Home | Chat | Call | History

### v1.1
- [ ] Video calls (Agora)
- [ ] AstroMall (browse + order products)
- [ ] Puja booking
- [ ] Referral system
- [ ] Daily panchang
- [ ] Tarot / numerology tools
- [ ] Live streaming

---

## 6. Project structure (feature-first)

```
user_app/
├── lib/
│   ├── main.dart                        # Entry point
│   ├── app.dart                         # MaterialApp.router + theme
│   │
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart          # Env config (base URL, Agora ID, Maps key)
│   │   ├── network/
│   │   │   ├── api_client.dart          # Dio singleton
│   │   │   ├── auth_interceptor.dart    # Token inject + refresh
│   │   │   └── dio_provider.dart        # Riverpod provider
│   │   ├── auth/
│   │   │   ├── token_storage.dart       # flutter_secure_storage wrapper
│   │   │   └── auth_notifier.dart       # AuthState Riverpod notifier
│   │   ├── router/
│   │   │   └── app_router.dart          # go_router + guards
│   │   ├── theme/
│   │   │   ├── app_theme.dart           # ThemeData light + dark
│   │   │   └── app_colors.dart          # Color constants
│   │   ├── cache/
│   │   │   └── cache_service.dart       # SharedPreferences-backed cache with TTL
│   │   ├── utils/
│   │   │   ├── format_utils.dart        # formatPaise, formatDate, formatDateTime
│   │   │   └── validators.dart          # Phone, email, password validators
│   │   └── widgets/                     # Shared widgets
│   │       ├── app_button.dart
│   │       ├── shimmer_loader.dart
│   │       └── offline_banner.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/auth_repository.dart
│       │   ├── domain/auth_models.dart
│       │   └── presentation/
│       │       ├── auth_controller.dart
│       │       ├── splash_screen.dart
│       │       ├── phone_auth_screen.dart
│       │       ├── otp_screen.dart
│       │       └── email_auth_screen.dart
│       │
│       ├── home/
│       │   ├── data/home_repository.dart
│       │   ├── domain/home_models.dart
│       │   └── presentation/
│       │       ├── home_controller.dart
│       │       ├── home_screen.dart         # Full dashboard content
│       │       └── home_shell.dart          # Bottom nav shell
│       │
│       ├── ai_chat/
│       │   ├── data/ai_chat_repository.dart
│       │   └── presentation/
│       │       ├── ai_chat_controller.dart
│       │       └── ai_chat_screen.dart      # flutter_gen_ai_chat_ui
│       │
│       ├── astrologers/
│       │   ├── data/astrologers_repository.dart
│       │   ├── domain/astrologer_models.dart
│       │   └── presentation/
│       │       ├── astrologers_controller.dart
│       │       ├── astrologer_list_screen.dart
│       │       └── astrologer_profile_screen.dart
│       │
│       ├── consultations/
│       │   ├── data/consultations_repository.dart
│       │   ├── domain/consultation_models.dart
│       │   └── presentation/
│       │       ├── chat_screen.dart
│       │       ├── call_screen.dart
│       │       └── consultation_controller.dart
│       │
│       ├── kundli/
│       │   ├── data/kundli_repository.dart
│       │   ├── domain/kundli_models.dart
│       │   └── presentation/
│       │       ├── kundli_controller.dart
│       │       ├── kundli_list_screen.dart
│       │       ├── add_kundli_screen.dart
│       │       ├── kundli_report_screen.dart
│       │       └── location_picker_screen.dart
│       │
│       ├── horoscope/
│       │   ├── data/horoscope_repository.dart
│       │   └── presentation/
│       │       ├── horoscope_screen.dart
│       │       └── horoscope_controller.dart
│       │
│       ├── wallet/
│       │   ├── data/wallet_repository.dart
│       │   ├── domain/wallet_models.dart
│       │   └── presentation/
│       │       ├── wallet_screen.dart
│       │       └── wallet_controller.dart
│       │
│       ├── history/
│       │   └── presentation/
│       │       └── history_screen.dart
│       │
│       ├── notifications/
│       │   └── presentation/
│       │       └── notifications_screen.dart
│       │
│       └── profile/
│           ├── data/profile_repository.dart
│           └── presentation/
│               ├── profile_screen.dart
│               └── edit_profile_screen.dart
│
├── test/
├── integration_test/
├── android/
├── ios/
└── pubspec.yaml
```

---

## 7. Bottom navigation tabs

| Tab | Icon | Route | Content |
|---|---|---|---|
| Home | `home_outlined` | `/home` | Dashboard (banners, grid, astrologers, stories, videos, AI card) |
| Chat | `chat_bubble_outline` | `/chat` | Active chat consultations + list |
| Call | `phone_outlined` | `/call` | Agora voice/video consultation |
| History | `history` | `/history` | Consultation history + kundli reports + wallet |

---

## 8. Home screen layout (top to bottom)

```
AppBar: [Astrobless logo] ........... [Notification icon] [Profile icon]

1. Banner carousel (full-width, auto-scroll, from /v1/public/banners?placement=home)

2. Feature grid (2×N grid of cards):
   - Horoscope (zodiac wheel icon)
   - Kundli (birth chart icon)
   - Kundli Matching (two rings icon)
   - Talk to Astrologer (person icon)
   - Panchang (calendar icon)
   - Tarot (cards icon)
   - Numerology (numbers icon)
   - Vastu (house icon)

3. "Trending Astrologers" section:
   - Section header + "See all" button
   - Horizontal scroll list of AstrologerCard widgets
   - Each card: photo, name, specialties, rating, price/min, online indicator, "Chat" button

4. "Stories" row:
   - Circular story bubbles (Instagram-style)
   - From /v1/public/stories?limit=10
   - Tap → full-screen story viewer

5. "Learn Astrology" section:
   - Horizontal scroll of video cards
   - Thumbnail, title, duration
   - From /v1/public/learning-videos?limit=8

6. AI Chat card:
   - Gradient card with sparkle icon
   - "Ask AI Astrologer" heading
   - "Get instant answers about your horoscope, kundli, and life questions"
   - "Chat Now" button → navigates to /ai-chat
```

---

## 9. AI Chat screen

Uses `flutter_gen_ai_chat_ui` package (https://pub.dev/packages/flutter_gen_ai_chat_ui).

- Model: `AI Astrologer`
- Streamed responses from `POST /v1/customer/ai/chat/stream` (OpenAI SSE)
- System: astrology-only context, user's birth chart injected if available
- Hardcoded disclaimer: "Powered by AI — for entertainment purposes. Consult a human astrologer for serious matters."
- Message history stored locally (SharedPreferences, last 50 messages)
- "Talk to Human Astrologer" button in AppBar

Backend endpoint: `POST /v1/customer/ai/chat/stream` — returns `text/event-stream` (SSE).

---

## 10. Kundli system

### 10.1 Kundli profiles (multiple per user)

Each user can add multiple kundli profiles (self, spouse, children, parents).

```
POST /v1/customer/kundli/profiles          { name, dateOfBirth, timeOfBirth, placeOfBirth, lat, lng }
GET  /v1/customer/kundli/profiles          → list
GET  /v1/customer/kundli/profiles/:id
DELETE /v1/customer/kundli/profiles/:id
```

### 10.2 Kundli reports (cached in DB)

Reports are fetched from VedicAstro API once and cached in our DB.
Second request returns cached data — no second API call.

```
GET /v1/customer/kundli/profiles/:id/report
    → if cached in DB → return immediately
    → if not → fetch from VedicAstro API → cache → return
```

Report contains: planetary positions, houses, dashas, kundli image data.

### 10.3 Location picker (Google Maps)

`LocationPickerScreen` uses `google_maps_flutter` + `geolocator`:
1. Shows map centered on user's current location (requested via geolocator)
2. User moves pin to birth place
3. `geocoding` package reverse-geocodes lat/lng → place name
4. Returns `{ placeOfBirth: string, lat: double, lng: double }` to parent

---

## 11. Backend endpoints reference (customer app)

All under `AppConfig.apiBaseUrl` = `http://localhost:3000/v1/customer` (local) or `https://api.astrobless.app/v1/customer` (prod).

```
# Auth
POST /auth/phone/send-otp
POST /auth/phone/verify-otp → { accessToken, refreshToken, customer }
POST /auth/email/signup
POST /auth/email/verify-otp → { accessToken, refreshToken, customer }
POST /auth/email/login → { accessToken, refreshToken, customer }
POST /auth/email/forgot-password
POST /auth/email/reset-password { token, newPassword }
POST /auth/google { idToken }
POST /auth/apple { identityToken, nonce }
POST /auth/refresh { refreshToken }
DELETE /auth/logout { refreshToken }

# Profile
GET  /profile
PATCH /profile { name?, dob?, gender?, profileImageUrl? }

# Astrologers
GET  /astrologers ?search=&specialty=&language=&minRating=&maxPrice=&isOnline=&sort=&page=&limit=
GET  /astrologers/:id
GET  /astrologers/:id/reviews

# Consultations
POST /consultations/request { astrologerId, type: 'chat'|'voice'|'video' }
GET  /consultations ?status=&type=&from=&to=
GET  /consultations/:id
POST /consultations/:id/end { reason }
GET  /consultations/:id/messages ?afterId=&limit=

# AI chat (streamed)
POST /ai/chat/stream { messages, kundliProfileId? } → SSE stream

# Wallet
GET  /wallet
GET  /wallet/transactions
POST /wallet/topup { amountPaise, providerKey, idempotencyKey }
GET  /wallet/providers

# Kundli
POST /kundli/profiles { name, dateOfBirth, timeOfBirth?, placeOfBirth, lat, lng }
GET  /kundli/profiles
GET  /kundli/profiles/:id
DELETE /kundli/profiles/:id
GET  /kundli/profiles/:id/report  → cached kundli data

# Horoscope
GET  /horoscopes/today/:zodiacSign
GET  /horoscopes/weekly/:zodiacSign

# Notifications
GET  /notifications
POST /notifications/fcm-token { token, platform }
PATCH /notifications/:id/read

# Public (no auth needed)
GET  /v1/public/banners ?placement=home
GET  /v1/public/astrologers/trending ?limit=10
GET  /v1/public/stories ?limit=10
GET  /v1/public/learning-videos ?limit=8
GET  /v1/public/horoscopes/today/:sign
```

---

## 12. UI design language

Same design system as partner app:

```dart
// Dark-first palette
class AppColors {
  static const primary      = Color(0xFF5C6BC0);  // deep indigo
  static const accent       = Color(0xFFFFB300);  // warm gold
  static const bgDark       = Color(0xFF0D0B1E);  // near-black navy
  static const cardDark     = Color(0xFF1E1B3A);  // slightly lighter navy
  static const surfaceDark  = Color(0xFF231F54);  // card surface
  static const borderDark   = Color(0xFF2D2A5E);  // subtle border
  static const success      = Color(0xFF4CAF50);
  static const error        = Color(0xFFF44336);
  static const textPrimary  = Color(0xFFECEFF1);
  static const textSecondary= Color(0xFFB0BEC5);
  static const textDisabled = Color(0xFF546E7A);
}
```

- Font: Inter via google_fonts
- Dark mode is default; honors `ThemeMode.system`
- Skeleton shimmer for loading states
- `flutter_animate` for subtle entrance animations
- Bottom nav: dark navy background with gold active indicator

---

## 13. Cache architecture

Same cache-first pattern as partner app:
- `CacheService` (SharedPreferences + TTL) initialized in `main.dart` before `runApp`
- TTL: home data 5min, astrologers 2min, horoscopes 30min, kundli profiles forever (user-managed)
- Show cached data immediately → fetch fresh in background → update silently

---

## 14. Connectivity

`ConnectivityService` (StreamProvider<bool>) + `OfflineBannerWrapper` shown inside `HomeShell`.

---

## 15. Code conventions

Same as partner_app CLAUDE.md §20. Key points:
- `snake_case.dart` file names
- `PascalCase` class names
- `const` widgets where possible; `build()` < 50 lines
- Feature folder: `data/` + `domain/` + `presentation/`
- No `print()` — use `debugPrint()` or error reporter

---

## 16. Environment config

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://localhost:3000/v1/customer',
  );
  static const publicApiBaseUrl = String.fromEnvironment(
    'PUBLIC_API_BASE_URL', defaultValue: 'http://localhost:3000/v1/public',
  );
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL', defaultValue: 'ws://localhost:3000',
  );
  static const agoraAppId     = String.fromEnvironment('AGORA_APP_ID');
  static const googleMapsKey  = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const sentryDsn      = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const isDev          = bool.fromEnvironment('IS_DEV', defaultValue: true);
}
```

---

## 17. Build order for new features

1. Backend endpoint (check it exists; create if not)
2. Domain models (Dart classes)
3. Repository (API calls)
4. Riverpod provider/controller
5. Screen widget (handle loading/error/data)
6. Route in `app_router.dart`

---

_Last updated: 2026-04-22. Keep this file alive._
