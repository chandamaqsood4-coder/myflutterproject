# DukanOS API contract

Base URL: `https://app.dukanos.live/api/v1`

All requests send `Accept: application/json`. Authenticated endpoints require
`Authorization: Bearer <token>`.

## POST /auth/login

Request body:

```json
{ "email": "admin@dukanos.com", "password": "secret" }
```

Success `200`:

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin",
      "email": "admin@dukanos.com",
      "phone": null,
      "status": "active",
      "last_login_at": "2026-10-20T10:11:15+00:00",
      "role": { "id": 1, "name": "Super Admin", "slug": "super_admin" },
      "tenant": null,
      "permissions": ["products.view", "customers.manage"],
      "created_at": "2026-10-14T10:09:41+00:00"
    },
    "token": "17|8SS0Mm0QubwBoIRPHrku1frqNR03DXk0rYSgWZoib0111210",
    "token_type": "Bearer"
  }
}
```

Validation / credential failure `422`:

```json
{
  "success": false,
  "message": "The given data was invalid.",
  "errors": { "email": ["The provided credentials are incorrect."] }
}
```

Other observed behaviour:

- `GET /auth/login` -> `405` `{"message":"The GET method is not supported for route api/v1/auth/login. Supported methods: POST."}`
- Unknown route -> `404` `{"message":"The route api/v1/<path> could not be found."}`

## Notes for the client

- Error envelope: `success: false`, a top-level `message`, and per-field
  `errors` keyed by field name (values are arrays of strings).
- The bearer token is persisted with `flutter_secure_storage`; it is never
  logged.
- Empty `{}` body also returns `422` with `email` and `password` required
  messages, so the form can rely on server-side validation too.

## Verified: Products
- `GET /products?per_page=<n>` (authenticated) — list products. In the web app it's loaded with `per_page=10000` and searched client-side by name/SKU/barcode.
- Response envelope: `{ "success": true, "data": [...] }` or paginated `{ "data": { "data": [...] , "meta": {...} } }`. The client uses `parsePagedList`.
- Product shape (common): `id`, `name`, `sku`, `barcode`, `unit`, `selling_price` (number/string), `purchase_cost`/`purchase_price`, `status` (`active`/`inactive`/`paused`/`deleted`), `category` or `category_name`, `brand` or `brand_name`, `inventory` with `quantity` (stock on hand), `min_quantity_threshold`, `image`/`image_url`/`gallery`, `description`.
- `POST /products` create, `PUT /products/:id` update. When stock changes on edit the web app calls `POST /inventory/:product_id/adjust` with `{ "delta": <diff>, "note": "..." }`.
- `DELETE /products/:id` delete.
- `POST /products/upload-image` multipart upload (returns image URL).

## Verified: Categories / Brands / Units
- `GET /categories`, `GET /brands` (authenticated). Web app paginates with `per_page=10000` conceptually and maps responses.
- `POST /categories`, `POST /brands` create with `{ name, slug, status }`.
- `PUT /categories/:id`, `PUT /brands/:id` update.
- `DELETE /categories/:id`, `DELETE /brands/:id` delete.
- `GET /units` exists on the server; the web app manages units in some flows but this desktop client currently treats units as text on the product and shows a notice if someone tries to manage units separately.

## Verified: Product detail, create, update, stock adjust
- `GET /products/:id` — fetch a single product (authenticated).
- `POST /products` — create product (fields include `name`, `sku`, `barcode`, `category_id`, `brand_id`, `unit`, `selling_price`, `purchase_cost`, `status`, `opening_quantity`, `min_quantity_threshold`, `description`, `image`).
- `PUT /products/:id` — update product.
- `POST /inventory/:product_id/adjust` — adjust stock with `{ "delta": <int>, "note": "..." }` (used for opening stock and edits).
