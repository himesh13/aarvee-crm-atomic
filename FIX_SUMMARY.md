# 403 Error Fix - Summary

## Problem Statement
The lead form was returning **403 Forbidden errors** when:
1. Loading the lead list
2. Creating/saving a new lead

## Root Cause
**JWT Algorithm Mismatch:**
- Frontend (Supabase 2.74.5+): Uses **ES256** (Elliptic Curve Digital Signature Algorithm)
- Backend (Spring Boot): Was configured for **HS256** (HMAC-SHA256)

The token header showed:
```json
{
  "alg": "ES256",
  "kid": "b81269f1-21d8-4f2e-b719-c2240a840d90",
  "typ": "JWT"
}
```

But the backend was trying to validate with HMAC secret key, causing authentication failures.

## Solution Overview

Updated the Spring Boot backend to support **ES256** tokens by implementing **JWKS (JSON Web Key Set)** based authentication:

1. **Fetch public keys** from Supabase's JWKS endpoint
2. **Validate tokens** using public key cryptography
3. **Cache keys** for performance (1-hour TTL)
4. **Support key rotation** automatically

## Files Changed

### Java Files
1. **`JwtAuthenticationFilter.java`** - Modified
   - Removed HMAC secret key validation
   - Added dependency injection for `JwksKeyProvider`
   - Changed token parsing to use `keyLocator()` instead of `verifyWith()`

2. **`JwksKeyProvider.java`** - New File
   - Implements `Locator<Key>` from JJWT library
   - Fetches JWKS from `${supabase.auth.url}/.well-known/jwks.json`
   - Parses RSA and EC (Elliptic Curve) public keys
   - Caches keys with 1-hour TTL
   - Supports P-256, P-384, and P-521 curves

### Configuration Files
3. **`application.yml`** - Modified
   - Changed from `supabase.jwt.secret` to `supabase.auth.url`
   
4. **`.env.example`** - Modified
   - Replaced `SUPABASE_JWT_SECRET` with `SUPABASE_AUTH_URL`
   - Added documentation for local vs production URLs

5. **`.env`** - Created (not committed)
   - Local configuration file
   - Properly ignored in `.gitignore`

### Documentation
6. **`JWT_ES256_FIX.md`** - New File
   - Comprehensive guide explaining the fix
   - Configuration examples
   - Troubleshooting steps
   - Architecture diagrams

7. **`crm-custom-service-spring/README.md`** - Modified
   - Updated authentication flow section
   - Changed environment variable documentation
   - Added reference to JWT_ES256_FIX.md

8. **`test-403-fix.sh`** - New File
   - Automated verification script
   - Checks all required services
   - Provides manual testing steps

## Technical Details

### Before (HS256)
```java
SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
Claims claims = Jwts.parser()
    .verifyWith(key)
    .build()
    .parseSignedClaims(token)
    .getPayload();
```

### After (ES256 with JWKS)
```java
Claims claims = Jwts.parser()
    .keyLocator(jwksKeyProvider)
    .build()
    .parseSignedClaims(token)
    .getPayload();
```

The `JwksKeyProvider`:
1. Extracts `kid` (Key ID) from JWT header
2. Checks cache for the key
3. If not cached or expired, fetches JWKS from Supabase
4. Parses the EC public key from JWKS JSON
5. Returns the key for token validation

### EC Key Parsing
```java
// Extract coordinates from JWKS
BigInteger xCoord = new BigInteger(1, Base64.decode(x));
BigInteger yCoord = new BigInteger(1, Base64.decode(y));

// Create EC point and spec
ECPoint point = new ECPoint(xCoord, yCoord);
ECPublicKeySpec spec = new ECPublicKeySpec(point, getECParameterSpec(curveName));

// Generate public key
KeyFactory factory = KeyFactory.getInstance("EC");
return factory.generatePublic(spec);
```

## Configuration Changes

### Local Development
```env
# OLD (no longer works)
SUPABASE_JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long

# NEW
SUPABASE_AUTH_URL=http://127.0.0.1:54321/auth/v1
```

### Production
```env
# OLD (no longer works)
SUPABASE_JWT_SECRET=<your-jwt-secret-from-dashboard>

# NEW
SUPABASE_AUTH_URL=https://<your-project>.supabase.co/auth/v1
```

## Security Benefits

1. **More Secure Algorithm**: ES256 is more secure than HS256
2. **No Secret Sharing**: Public keys are used (no need to share secrets)
3. **Key Rotation Support**: Automatic support for Supabase key rotation
4. **Industry Standard**: Uses standard JWKS for key distribution
5. **No Security Vulnerabilities**: CodeQL analysis found 0 alerts

## Testing Instructions

### Prerequisites
```bash
# Start Supabase
make start-supabase

# Start Spring Boot (in new terminal)
cd crm-custom-service-spring
cp .env.example .env  # Only needed first time
mvn spring-boot:run

# Start Frontend (in new terminal)
npm run dev
```

### Automated Check
```bash
./test-403-fix.sh
```

### Manual Testing
1. Open http://localhost:5173
2. Login with credentials
3. Navigate to "Leads" page
4. Click "Create Lead" button
5. Fill form:
   - Customer Name: Test Customer
   - Contact Number: 1234567890
   - Product: Select any option
6. Click "Save"

**Expected**: ✅ Lead created successfully (no 403 errors)

**Previous**: ❌ 403 Forbidden error

### Verify in Logs

**Spring Boot Console:**
```
Fetching JWKS from: http://127.0.0.1:54321/auth/v1/.well-known/jwks.json
Cached public key with kid: b81269f1-21d8-4f2e-b719-c2240a840d90 (type: EC)
```

**Browser Console:**
```
customServiceDataProvider.ts:37 token eyJhbGciOiJFUzI1NiIs...
```
No 403 errors!

## Rollback Plan

If issues occur:
1. The old code is in git history
2. Configuration can be reverted to use `SUPABASE_JWT_SECRET`
3. However, this won't work with Supabase 2.74.5+ which uses ES256

## Dependencies

No new dependencies added! The existing JJWT library (v0.12.3) already supports:
- ES256 algorithm
- JWKS parsing
- Public key validation

## Code Quality

- ✅ **Code Review**: All review comments addressed
- ✅ **Security Scan**: CodeQL found 0 vulnerabilities
- ✅ **Documentation**: Comprehensive docs added
- ✅ **Best Practices**: Follows Spring Security and JWT best practices

## Related Issues

This fix resolves:
- 403 Forbidden on GET /api/leads
- 403 Forbidden on POST /api/leads
- Authentication failures with Supabase 2.74.5+

## Next Steps

For production deployment:
1. Update `.env` with production `SUPABASE_AUTH_URL`
2. Deploy the updated code
3. Restart the Spring Boot service
4. Verify JWKS endpoint is accessible from backend
5. Test lead form functionality

## Support

For issues or questions:
1. Check [JWT_ES256_FIX.md](JWT_ES256_FIX.md) for detailed documentation
2. Review Spring Boot logs for JWT validation messages
3. Verify SUPABASE_AUTH_URL is correct
4. Ensure Supabase JWKS endpoint is accessible

---

**Status**: ✅ Complete and Ready for Testing

**Estimated Testing Time**: 5 minutes

**Risk Level**: Low (no breaking changes for existing users)
