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
4. **Money is `double` everywhere.** Stored as float (e.g. `12.50` = ₹12.50). Never integer subunits. Format at display layer only via `formatAmount()`.
5. **JWT audience is `astrobless.customer`.** Never call `/v1/astrologer/*` or `/v1/admin/*`.
6. **All API calls through the `ApiClient` singleton** (Dio instance).
7. **Riverpod only for state.** No `setState` in non-trivial widgets.
8. **Feature-first folder structure.** `lib/features/<featureName>/`.
9. **Generated files not edited manually.** Run `build_runner`.
10. **Every catch block that swallows errors** must report to telemetry.
11. **No hardcoded base URL, API keys, or config.** Use `AppConfig`.
12. **No hardcoded route strings.** Every navigation path must use a constant from `lib/core/router/app_routes.dart`. Never write `context.go('/some/path')` inline.
13. **GetX for overlays only.** `Get.showSnackbar(GetSnackBar(...))` is allowed for context-free error toasts. Never use GetX for state or routing.

---

## 3a. Strict no-hardcode policy

These rules apply to **every file in this project**. A PR review fails if any of these are violated.

### 3a.1 No hardcoded text

**Every user-visible string** must come from the ARB localization file. No exceptions for "short" labels.

```dart
// ✗ Wrong
Text('Send Reset Code'),
ElevatedButton(child: Text('Continue')),

// ✓ Right
Text(AppLocalizations.of(context).sendResetCode),
ElevatedButton(child: Text(l10n.continueButton)),
```

**Adding a new string:**
1. Add the key to `lib/l10n/app_en.arb` (and other locale files)
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Use `AppLocalizations.of(context).yourKey` in widgets

**Exception:** Internal debug strings (in `debugPrint` / logging) do not need localization.

### 3a.2 No hardcoded text styles

**Every `TextStyle` must reference a token** from `Theme.of(context).textTheme` or `AppTextStyles`. Never write raw `TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF...))` inline.

```dart
// ✗ Wrong
Text('Title', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFECEFF1))),

// ✓ Right
Text('Title', style: tt.headlineMedium?.copyWith(color: AppColors.textPrimary)),
Text('Title', style: AppTextStyles.headingLarge),
```

Define any new reusable style in `lib/core/theme/app_text_styles.dart`.

### 3a.3 No hardcoded colors

**Every color must come from `AppColors`** (`lib/core/theme/app_colors.dart`). Never use `Color(0xFFABCDEF)` or `Colors.blue` inline.

```dart
// ✗ Wrong
Container(color: Color(0xFF0D0B1E)),
Icon(Icons.check, color: Colors.green),

// ✓ Right
Container(color: AppColors.bgDark),
Icon(Icons.check, color: AppColors.success),
```

Theme-controlled colors (primary, secondary, surface) must use the backend-fetched theme — see §3b.

### 3a.4 No hardcoded API routes

**Every endpoint path must be a constant** in `lib/core/network/endpoints.dart`. Never write a path string inline anywhere.

```dart
// ✗ Wrong
await _client.post('/customer/auth/email/forgot-password', data: body);

// ✓ Right
await _client.post(Endpoints.auth.forgotPassword, data: body);
```

### 3a.5 No hardcoded navigation paths

Every navigation call uses `AppRoutes` constants:

```dart
// ✗ Wrong
context.go('/auth/phone');

// ✓ Right
context.go(AppRoutes.authPhone);
```

---

## 3b. Backend-controlled theme system

The admin panel controls the app's colors in real-time. The customer app must fetch and apply the active theme from the backend on every launch.

### How it works

**Backend endpoint:**
```
GET /v1/public/app-theme?audience=customer
→ { primaryColor, secondaryColor, accentColor, bgDark, bgLight, textPrimary, textSecondary, success, warning, error }
```

All values are hex strings (e.g. `"#5C6BC0"`). If a value is not overridden in admin, the backend returns the default.

**App integration:**
- `appThemeColorsProvider` (in `lib/core/theme/app_theme_provider.dart`) fetches this on startup
- `AppTheme.dark(colors)` and `AppTheme.light(colors)` consume a `ThemeColors` object built from the response
- `app.dart` watches `appThemeColorsProvider` and rebuilds `MaterialApp.router` when colors change
- Last fetched theme is cached in `SharedPreferences` as a fallback

**Adding a new theme token:**
1. Add the field to `ThemeColors` class
2. Add `appSettings` key in backend (`theme.newToken`)
3. Add it to the `/v1/public/app-theme` endpoint
4. Use it in `AppTheme` builders
5. Reference it as `AppColors.yourToken` (derived from theme colors, not hardcoded)

**Fallback behavior:** If the API call fails, use the default `ThemeColors` with hardcoded values. The app must never crash or show a blank screen due to a failed theme fetch. Cached values take priority over defaults when fresh fetch is unavailable.

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

Tokens are stored in `flutter_secure_storage` under the keys `customer_access_token` and `customer_refresh_token`. See `lib/core/auth/token_storage.dart`.

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
- [ ] Home screen: banners (from `Banner` model), feature grid, trending astrologers, stories, videos, AI chat card
- [ ] AI chat screen (streamed, astrology-only, flutter_gen_ai_chat_ui)
- [ ] Browse + search astrologers (filter by specialty, language, price, rating)
- [ ] Follow / unfollow astrologer (`AstrologerFollower`)
- [ ] Block astrologer (`AstrologerBlock`)
- [ ] Chat consultation (Socket.IO, per-minute billing)
- [ ] Voice call consultation (Agora)
- [ ] Wallet: view balance, top up via recharge packs (`RechargePack`) with optional coupon (`Coupon`)
- [ ] Multiple Kundli profiles per user (saved in DB)
- [ ] Kundli report (cached in DB, not re-fetched each time)
- [ ] Kundli matching (user selects two kundlis → `KundliMatch`)
- [ ] Saved delivery addresses (`CustomerAddress`)
- [ ] Daily / weekly / monthly horoscopes
- [ ] Referral program (`ReferralReward`)
- [ ] Support tickets (`SupportTicket` + `SupportTicketMessage`)
- [ ] Notification center
- [ ] Consultation history
- [ ] Profile management
- [ ] Bottom nav: Home | Chat | Call | History

### v1.1
- [ ] Video calls (Agora)
- [ ] AstroMall (browse + order products)
- [ ] Puja booking (`PujaTemplate`, `PujaSlot`, `PujaBooking`)
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
│   │   │   ├── format_utils.dart        # formatAmount, formatDate, formatDateTime
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
│       ├── profile/
│       │   ├── data/profile_repository.dart
│       │   └── presentation/
│       │       ├── profile_screen.dart
│       │       └── edit_profile_screen.dart
│       │
│       ├── addresses/
│       │   └── presentation/
│       │       ├── address_list_screen.dart
│       │       └── add_address_screen.dart
│       │
│       ├── support/
│       │   └── presentation/
│       │       ├── support_tickets_screen.dart
│       │       ├── ticket_detail_screen.dart
│       │       └── new_ticket_screen.dart
│       │
│       └── puja/                          # v1.1
│           ├── data/puja_repository.dart
│           └── presentation/
│               ├── puja_list_screen.dart
│               ├── puja_detail_screen.dart
│               └── puja_booking_screen.dart
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

### 10.3 Kundli matching (Ashtakoot compatibility)

Entry point: heart icon in the `KundliListScreen` AppBar → navigates to `AppRoutes.kundliMatch`.

**Screen:** `kundli_match_screen.dart` contains two widgets:
- `KundliMatchScreen` — profile picker (two dropdowns) + previous match history list
- `KundliMatchResultScreen` — circular score dial (out of 36), score label badge, Manglik status, per-koota bar chart breakdown

**Models:** `KundliMatch`, `KundliMatchBreakdown`, `KootaScore` in `kundli_models.dart`.

**Provider:** `kundliMatchesProvider` (FutureProvider) fetches match history.

**API flow:**
```
POST /v1/customer/kundli/match { profileAId, profileBId } → KundliMatch (computed + cached)
GET  /v1/customer/kundli/matches → list of previous results (with profileA/profileB nested)
```

The backend fetches from vedicastroapi.com and persists to `kundliMatches` table — results are not recomputed on re-fetch.

**Score labels:** Excellent (≥28), Good (≥21), Average (≥18), Poor (<18) — out of 36 total points.

**Warning color:** `AppThemeColors` has no `warning` field. Use `const Color(0xFFFF9800)` (amber) inline for "Average" score states.

### 10.4 Location picker (Google Maps)

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
POST /astrologers/:id/follow
DELETE /astrologers/:id/follow
GET  /astrologers/following               → list of followed astrologers
POST /astrologers/:id/block
DELETE /astrologers/:id/block

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
POST /wallet/topup { amount, providerKey, idempotencyKey, couponCode? }
GET  /wallet/providers
GET  /wallet/recharge-packs               → active RechargePack list

# Coupons
POST /coupons/validate { code, amount }  → { valid, discountAmount }

# Kundli
POST /kundli/profiles { name, dateOfBirth, timeOfBirth?, placeOfBirth, lat, lng }
GET  /kundli/profiles
GET  /kundli/profiles/:id
DELETE /kundli/profiles/:id
GET  /kundli/profiles/:id/report  → cached kundli data
POST /kundli/match { profileAId, profileBId } → KundliMatch (cached result)
GET  /kundli/matches              → list of previous match results

# Addresses
GET  /addresses
POST /addresses { label, line1, line2?, city, state, pincode, country }
PATCH /addresses/:id
DELETE /addresses/:id
PATCH /addresses/:id/set-default

# Support tickets
POST /support/tickets { category, subject, description, attachmentUrls? }
GET  /support/tickets
GET  /support/tickets/:id
POST /support/tickets/:id/messages { body }
POST /support/tickets/:id/close

# Puja (v1.1)
GET  /puja/templates ?category=&occasion=
GET  /puja/templates/:slug
GET  /puja/templates/:id/slots ?from=&to=
POST /puja/bookings { pujaTemplateId, pujaPackageTierId, scheduledAt, devoteeName, gotra?, specialRequests?, deliveryAddress?, paymentMethod }
GET  /puja/bookings
GET  /puja/bookings/:id
POST /puja/bookings/:id/cancel { reason }

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

Same design system as partner app. Colors are defined in `lib/core/theme/app_colors.dart`. Key values:
- Primary (deep indigo): `#5C6BC0`
- Accent (warm gold): `#FFB300`
- Dark mode backgrounds: `#0D0B1E` (bg), `#1E1B3A` (card), `#231F54` (surface), `#2D2A5E` (border)
- Status: success `#4CAF50`, error `#F44336`
- Text (dark mode): primary `#ECEFF1`, secondary `#B0BEC5`, disabled `#546E7A`

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

`AppConfig` in `lib/core/config/app_config.dart` reads all values via `String.fromEnvironment` / `bool.fromEnvironment` at compile time. Values: `apiBaseUrl` (default `http://localhost:3000/v1/customer`), `publicApiBaseUrl` (default `http://localhost:3000/v1/public`), `wsBaseUrl` (default `ws://localhost:3000`), `agoraAppId`, `googleMapsKey`, `sentryDsn`, `isDev`.

---

## 17. Build order for new features

1. Backend endpoint (check it exists; create if not)
2. Domain models (Dart classes)
3. Repository (API calls)
4. Riverpod provider/controller
5. Screen widget (handle loading/error/data)
6. Route in `app_router.dart`

---

## 18. Decisions recorded (2026-04-25)

### Wallet transactions response shape (locked)

`GET /wallet/transactions` returns `{ ok, data: { items: [...], total: N }, traceId }` — a paginated envelope, **not** a flat array. `ApiClient.fetchWalletTransactions()` extracts `data['items']` when the response data is a Map. Do not cast `data['data']` as `List<dynamic>` directly.

### FCM push notifications — what the app receives

When wallet events occur, the backend pushes FCM notifications. The app should handle these in the FCM foreground/background handler. Data payloads:
- `{ type: 'walletUpdated' }` — customer wallet topped up or debited
- `{ type: 'earningsUpdate', consultationId }` — astrologer earned from a consultation

### Banner imageUrl is nullable

`HomeBanner.imageUrl` is `String?`. The backend stores `imageKey` and resolves to a URL — if no image is uploaded, `imageUrl` is null. Always null-check before passing to `CachedNetworkImage`.

### AppThemeColors — available colors

`AppThemeColors` has: `primary`, `accent`, `success`, `error`, `textPrimary`, `textSecondary`, `bg`, `card`, `surface`, `border`. There is **no** `warning` field. For warning/amber states use `const Color(0xFFFF9800)` inline.

_Last updated: 2026-04-25. Keep this file alive._
