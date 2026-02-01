# 403 Error Fix - JWT ES256 Support

## Problem

The Lead form was returning 403 Forbidden errors when loading and saving because of a JWT algorithm mismatch:

- **Frontend (Supabase)**: Generates JWT tokens using **ES256** (Elliptic Curve) algorithm
- **Backend (Spring Boot)**: Was configured to validate using **HS256** (HMAC-SHA256) with a secret key

## Solution

Updated the Spring Boot authentication to support ES256 tokens by:

1. **Fetching public keys from JWKS endpoint**: Created `JwksKeyProvider` class that fetches and caches public keys from Supabase's `/.well-known/jwks.json` endpoint
2. **Supporting both RSA and EC keys**: The provider can handle both key types
3. **Caching keys for performance**: Keys are cached for 1 hour to avoid repeated HTTP requests

## Changes Made

### 1. Updated `JwtAuthenticationFilter.java`
- Removed HMAC-SHA256 secret key validation
- Added dependency on `JwksKeyProvider` for key lookup
- Now uses `keyLocator()` instead of `verifyWith()` for token parsing

### 2. Created `JwksKeyProvider.java`
- Implements `Locator<Key>` from JJWT library
- Fetches JWKS from `${supabase.auth.url}/.well-known/jwks.json`
- Parses both RSA and EC (Elliptic Curve) public keys
- Caches keys for 1 hour
- Supports P-256, P-384, and P-521 curves

### 3. Updated Configuration Files
- **`.env` and `.env.example`**: Replaced `SUPABASE_JWT_SECRET` with `SUPABASE_AUTH_URL`
- **`application.yml`**: Changed from `supabase.jwt.secret` to `supabase.auth.url`

## Configuration

### Local Development

```env
# .env file
SUPABASE_AUTH_URL=http://127.0.0.1:54321/auth/v1
```

### Production

```env
# .env file for production
SUPABASE_AUTH_URL=https://<your-project>.supabase.co/auth/v1
```

## Testing

1. **Start Supabase**:
   ```bash
   make start-supabase
   ```

2. **Start Spring Boot service**:
   ```bash
   cd crm-custom-service-spring
   mvn spring-boot:run
   ```

3. **Start frontend**:
   ```bash
   npm run dev
   ```

4. **Test the Lead form**:
   - Navigate to http://localhost:5173
   - Login with your credentials
   - Go to "Leads" page
   - Click "Create Lead"
   - Fill out the form and save
   - Should work without 403 errors

## How It Works

1. User logs in via Supabase → receives JWT token signed with ES256
2. Frontend sends API request to Spring Boot with `Authorization: Bearer <token>`
3. `JwtAuthenticationFilter` extracts the token
4. `JwksKeyProvider` looks up the key ID (`kid`) from token header
5. If key not in cache, fetches JWKS from Supabase
6. Parses the EC public key from JWKS
7. Validates token signature using the public key
8. If valid, sets authentication in Spring Security context

## Benefits

- ✅ **More Secure**: ES256 (Elliptic Curve) is more secure than HS256
- ✅ **Standard Approach**: Uses industry-standard JWKS for key distribution
- ✅ **No Secret Sharing**: Public keys are used for validation (no need to share secrets)
- ✅ **Automatic Key Rotation**: When Supabase rotates keys, the service automatically fetches new ones
- ✅ **Production Ready**: Works with both local Supabase and production

## Dependencies

The existing JJWT library (v0.12.3) already supports ES256:

```xml
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
```

No additional dependencies needed!

## Troubleshooting

### 403 errors persist

1. **Check Supabase is running**:
   ```bash
   curl http://127.0.0.1:54321/auth/v1/.well-known/jwks.json
   ```
   Should return a JSON with public keys.

2. **Check Spring Boot logs**:
   Look for "Fetching JWKS from..." and "Cached public key with kid..." messages.

3. **Verify SUPABASE_AUTH_URL**:
   Make sure it points to the correct Supabase instance.

### "No 'kid' (Key ID) found in JWT header"

This means the JWT token doesn't have a Key ID. Check that:
- You're using the latest version of Supabase (2.74.5+)
- The token is actually from Supabase (not a test token)

### "Unsupported key type" or "Unsupported curve"

The JWKS contains a key type we don't support yet. Current supported types:
- RSA keys (kty: "RSA")
- EC keys with curves: P-256, P-384, P-521 (kty: "EC")

## Migration from HS256

If you have an existing deployment using HS256:

1. Deploy the updated code
2. Update `SUPABASE_AUTH_URL` in your `.env` file
3. Remove `SUPABASE_JWT_SECRET` (no longer needed)
4. Restart the Spring Boot service
5. Existing JWT tokens will still work (they'll be validated against the public key)

## References

- [Supabase JWT Documentation](https://supabase.com/docs/guides/auth/jwts)
- [RFC 7517 - JSON Web Key (JWK)](https://tools.ietf.org/html/rfc7517)
- [RFC 7519 - JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519)
- [JJWT Documentation](https://github.com/jwtk/jjwt#jwt-signing-key-resolver)
