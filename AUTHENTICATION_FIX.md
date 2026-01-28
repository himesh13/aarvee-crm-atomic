# Authentication Fix - Testing Guide

## What Was Fixed

The authentication between the frontend and Spring Boot API had two issues:
1. The frontend was trying to retrieve the Supabase JWT token from the wrong location
2. The implementation included redundant caching that duplicated Supabase's built-in session management

Both have been fixed to follow best practices.

## Changes Summary

### 1. Initial Fix (`customServiceDataProvider.ts`)
- ✅ Fixed to correctly retrieve JWT token from Supabase session using `supabase.auth.getSession()`
- ✅ Added error handling for graceful degradation

### 2. Best Practices Update (`customServiceDataProvider.ts`)
- ✅ Removed redundant module-level caching (`cachedToken`, `tokenExpiresAt`, `tokenRefreshPromise`)
- ✅ Simplified to rely on Supabase's built-in session management
- ✅ Fixed logout bug - tokens now cleared immediately when user logs out
- ✅ Improved cross-tab synchronization - handled by Supabase

### 3. Why This Is Better

**Supabase Already Handles:**
- Token caching (localStorage + memory)
- Automatic token refresh
- Token expiry checking
- Cross-tab synchronization
- Clearing tokens on logout

**Benefits:**
- Simpler, more maintainable code (25 lines vs 60 lines)
- No logout bugs - tokens properly cleared
- Works with framework's session management
- Better cross-tab behavior
- Follows best practices - don't duplicate framework functionality

### 4. Backend Support (`pom.xml`)
- ✅ Added `spring-dotenv` dependency to load `.env` files automatically

### 5. Documentation Updates
- ✅ Main README now explains the authentication flow
- ✅ Spring Boot README has detailed troubleshooting steps

## How to Test

### Step 1: Start Services

```bash
# Start Supabase (PostgreSQL + Auth)
make start-supabase

# Start Spring Boot service (in a new terminal)
cd crm-custom-service-spring
cp .env.example .env  # Only needed first time
mvn spring-boot:run

# Start frontend (in a new terminal)
npm run dev
```

### Step 2: Test Authentication

1. Open http://localhost:5173 in your browser
2. Login or create a new account
3. Navigate to "Leads" in the sidebar
4. Click "Create Lead" button
5. Fill out the form:
   - Customer Name: "Test Customer"
   - Contact Number: "1234567890"
   - Product: Select any option
6. Click "Save"

### Expected Result

✅ The lead should be created successfully without any 403 errors
✅ You should see the new lead in the list

### If You Still Get Errors

1. **Check services are running:**
   ```bash
   # Supabase should be on port 54321
   curl http://127.0.0.1:54321
   
   # Spring Boot should be on port 3001
   curl http://localhost:3001/health
   ```

2. **Check JWT secret matches:**
   - Open `crm-custom-service-spring/.env`
   - Verify `SUPABASE_JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long`
   - This should match the local Supabase default

3. **Check browser console:**
   - Open browser DevTools (F12)
   - Look for any error messages
   - Check if Authorization header is present in network requests

4. **Check Spring Boot logs:**
   - Look for JWT validation errors
   - Verify the token is being received and validated

## Architecture Overview

```
┌─────────────┐
│   Browser   │
│  (Supabase  │
│    Auth)    │
└──────┬──────┘
       │ 1. Login
       │ 2. Get JWT Token
       ▼
┌─────────────────┐
│   Frontend      │
│   (React +      │
│   Supabase)     │
└────────┬────────┘
         │ 3. API Request with
         │    Authorization: Bearer <token>
         ▼
┌─────────────────┐
│  Spring Boot    │
│  API            │
│  (JWT           │
│   Validation)   │
└────────┬────────┘
         │ 4. Validate token
         │    using JWT secret
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   (Supabase)    │
└─────────────────┘
```

## Key Files Changed

1. `src/components/atomic-crm/providers/custom-service/customServiceDataProvider.ts`
2. `crm-custom-service-spring/pom.xml`
3. `README.md`
4. `crm-custom-service-spring/README.md`

## For Production Deployment

When deploying to production:

1. Get your Supabase JWT secret from: https://app.supabase.com/project/YOUR_PROJECT/settings/api
2. Update `crm-custom-service-spring/.env`:
   ```
   SUPABASE_JWT_SECRET=<your-actual-jwt-secret>
   ```
3. Ensure the Spring Boot service URL is correctly configured in frontend:
   ```
   VITE_CUSTOM_SERVICE_URL=https://your-api-domain.com/api
   ```

## Support

If you encounter any issues:
1. Check the troubleshooting section in `crm-custom-service-spring/README.md`
2. Verify all services are running
3. Check that JWT secrets match between Supabase and Spring Boot
4. Review browser console and Spring Boot logs for specific error messages
