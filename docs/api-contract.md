# KalaSetu — API Contract

All endpoints follow standard JSON REST specifications. Base URL is configurable via `frontend/.env` (`API_BASE_URL`).

## Endpoints

### 1. Health & Status
- **`GET /health`**
  - Response: `{ "status": "ok", "service": "KalaSetu Backend API", "uptime": number, "version": "1.0.0" }`

### 2. Products
- **`GET /api/products`**
  - Query: `?category=&cluster=&artisanId=`
  - Response: `[{ "id": string, "name": string, "descriptionHi": string, "descriptionEn": string, "price": number, "category": string, "images": [string], "artisanId": string }]`
- **`POST /api/products`**
  - Body: `{ "name": string, "descriptionHi": string, "descriptionEn": string, "price": number, "category": string, "images": [string], "materials": [string] }`

### 3. Orders
- **`GET /api/orders`**
  - Headers: `Authorization: Bearer <supabase_jwt>`
  - Response: `[{ "orderNumber": string, "status": string, "totalAmount": number, "items": [] }]`
- **`POST /api/orders`**
  - Body: `{ "items": [{ "productId": string, "quantity": number }], "shippingAddress": object }`

### 4. Craft Fairs
- **`GET /api/fairs`**
  - Response: `[{ "id": string, "titleHi": string, "titleEn": string, "venue": string, "city": string, "startDate": string, "endDate": string, "subsidyPercent": number }]`
- **`POST /api/fairs/:id/apply`**
  - Body: `{ "artisanCardNumber": string, "stallType": string }`
