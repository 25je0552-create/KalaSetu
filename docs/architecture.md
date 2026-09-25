# KalaSetu — System Architecture Document

## Overview
KalaSetu connects rural Indian artisans directly with retail patrons, B2B wholesale buyers, and government handicraft exhibitions.

### Tracks
1. **Artisan Track**:
   - Hindi-first, high tactile accessibility (touch targets >= 56px and 72px).
   - Voice-first interactions for cataloging, product descriptions, and profile onboarding.
   - Camera-first listing flow (live camera capture -> background-removal preview -> voice describe -> AI review -> pricing breakdown).
   - Direct phone assistance integration (Toll-free 1800-200-8899).
   - Craft fairs tracking with government subsidy eligibility and stall reservations.
2. **Customer / Marketplace Track**:
   - Craft cluster discovery (Gorakhpur Terracotta, Maheshwar Handloom, Moradabad Brass, Kashmir Pashmina).
   - Transparent artisan storytelling and GI verification tags.
   - Direct cart & checkout, order tracking, and B2B wholesale quotation requests.

---

## Monorepo Layout
```
KalaSetu/
├── frontend/                          # Flutter client application
│   ├── lib/
│   │   ├── core/                      # Theme, router, localization, shared services & widgets
│   │   ├── features/                  # Feature-first modules (data, domain, presentation)
│   │   └── mock_data/                 # Runtime JSON asset loader
│   ├── assets/
│   │   ├── images/                    # KalaSetu emblem logo & references
│   │   └── mock/                      # Realistic mock fixtures
│   └── pubspec.yaml
├── backend/                           # Node.js + Express API
│   ├── src/
│   │   ├── config/                    # DB & environment config
│   │   ├── routes/                    # REST routes (products, orders, fairs, artisans, users)
│   │   ├── models/                    # Mongoose schemas
│   │   ├── middleware/                # Auth, errors, request logger
│   │   └── services/                  # Business logic (pricing calculator)
│   └── server.js
├── docs/                              # System documentation
└── README.md
```

---

## State Management & Layering
- **Riverpod (`flutter_riverpod`)**:
  - `AsyncNotifierProvider` and `FutureProvider` for remote/mock data loading with loading, data, and error handling.
  - `StateNotifier` for the multi-step `AddItemWizard` to guarantee zero state loss when backgrounding.
  - Layered pattern:
    - **Data**: Repository interface + Mock/HTTP implementation.
    - **Domain**: Pure Dart models with JSON serialization.
    - **Presentation**: Screen, widgets, and Riverpod controllers.

---

## Visual Design Tokens
- Base canvas: `#FFF8F2` (Wet Clay Beige).
- Primary accent: `#9D3E14` (Kiln Terracotta).
- Secondary accent: `#805600` / `#FEBA4A` (Turmeric Ochre).
- Dark contrast: `#201B0F` (Mineral Charcoal) / `#56423B`.
- Headings: `Literata` humanist serif.
- Body/Labels: `Be Vietnam Pro` sans.
