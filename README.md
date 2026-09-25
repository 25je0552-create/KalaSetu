# KalaSetu (कलासेतु)

A handloom and handicraft marketplace bridging rural artisans with conscious customers, bulk buyers, and government craft fairs.

## Repository Structure
- `frontend/` — Flutter cross-platform mobile application (Artisan & Customer tracks).
- `backend/` — Node.js + Express API ready for MongoDB integration.
- `docs/` — Architecture design specifications and API contracts.

---

## Running the Backend

### Prerequisites
- Node.js v18+ (tested on v24)
- npm v9+

### Commands
```bash
cd backend
npm install
npm start
```
The server will boot on `http://localhost:3000`. Test the health check:
```bash
curl http://localhost:3000/health
```

---

## Running the Frontend

### Prerequisites
- Flutter SDK (v3.19+)
- Android Studio / Xcode for device simulation

### Commands
```bash
cd frontend
flutter pub get
flutter run
```

### Environment Configuration
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Fill in your Supabase URL and Anon key when ready:
```
API_BASE_URL=http://localhost:3000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Google Sign-In Setup Notes
1. Add your Android SHA-1 fingerprint in the Google Cloud Console / Firebase console.
2. Place `google-services.json` inside `frontend/android/app/`.
3. For iOS, configure the URL Scheme in `Info.plist` and place `GoogleService-Info.plist` inside `frontend/ios/Runner/`.
