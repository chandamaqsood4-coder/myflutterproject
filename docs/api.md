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
