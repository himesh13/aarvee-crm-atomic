# Troubleshooting Guide

## Common Issues and Solutions

### 504 Error: "Outdated Optimize Dep"

**Symptom:**
```
net::ERR_ABORTED 504 (Outdated Optimize Dep)
```

This error appears in the browser console when Vite's dependency optimization cache becomes outdated or corrupted.

**Solution:**

1. **Quick Fix - Clear Vite Cache (Cross-Platform):**
   ```bash
   npm run dev:clean
   ```
   This works on all platforms (Windows, Mac, Linux) and clears the `.vite` cache directory before restarting.

2. **Alternative - Manual Cache Clear:**
   
   **On Linux/Mac:**
   ```bash
   rm -rf node_modules/.vite
   npm run dev
   ```
   
   **On Windows (PowerShell):**
   ```powershell
   Remove-Item -Recurse -Force node_modules\.vite -ErrorAction SilentlyContinue
   npm run dev
   ```
   
   **On Windows (Command Prompt):**
   ```cmd
   rmdir /s /q node_modules\.vite
   npm run dev
   ```

3. **Full Clean (if above doesn't work):**
   
   **On Linux/Mac:**
   ```bash
   rm -rf node_modules node_modules/.vite
   npm install
   npm run dev
   ```
   
   **On Windows (PowerShell):**
   ```powershell
   Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue
   npm install
   npm run dev
   ```

4. **Clear Browser Cache:**
   - Open browser DevTools (F12)
   - Right-click the refresh button
   - Select "Empty Cache and Hard Reload"

**Why This Happens:**
- Vite pre-bundles dependencies for faster loading
- When dependencies change or become outdated, the cache can become stale
- The dev server already uses `--force` flag to rebuild on start, but sometimes manual clearing is needed

**Prevention:**
- Use `npm run dev:clean` when you notice dependency issues
- The `vite.config.ts` now includes optimized settings to reduce this issue

---

### Infinite Spinner / Request Timeouts

**Symptom:**
- The application shows a loading spinner indefinitely
- API requests timeout or fail
- 504 Gateway Timeout errors in network tab

**Solution:**

This has been fixed in the latest version with:
- 30-second timeout on all API requests (Supabase and custom services)
- Smart retry logic with exponential backoff
- Better error messages when services are unavailable

**What to Check:**

1. **Verify Services are Running:**
   ```bash
   # Check if Supabase is running
   npx supabase status
   
   # Check if custom service is running (if using Docker)
   docker compose ps
   ```

2. **Start Required Services:**
   ```bash
   # Start Supabase
   npx supabase start
   
   # Start with Docker (includes custom service)
   make docker-start
   ```

3. **Check Network Tab in DevTools:**
   - Look for requests that timeout after 30 seconds
   - Check the error messages for specific issues

4. **Check Console for Error Logs:**
   - Query errors will be logged with query keys
   - Mutation errors will be logged with mutation keys
   - Look for timeout or network error messages

**Configuration:**
- Timeout is set to 30 seconds in `src/components/atomic-crm/providers/supabase/supabase.ts`
- Retry logic is configured in `src/components/atomic-crm/root/CRM.tsx`
- Custom service timeout is in `src/components/atomic-crm/providers/custom-service/customServiceDataProvider.ts`

---

### Build Failures

**Symptom:**
```
npm run build
```
fails with errors

**Solution:**

1. **TypeScript Errors:**
   ```bash
   npm run typecheck
   ```
   Fix any TypeScript errors before building.

2. **Linting Errors:**
   ```bash
   npm run lint
   ```
   Fix linting errors or use `npm run lint:apply` to auto-fix.

3. **Clean Build:**
   
   **On Linux/Mac:**
   ```bash
   rm -rf dist node_modules/.vite
   npm run build
   ```
   
   **On Windows (PowerShell):**
   ```powershell
   Remove-Item -Recurse -Force dist, node_modules\.vite -ErrorAction SilentlyContinue
   npm run build
   ```

---

### Port Already in Use

**Symptom:**
```
Port 5173 is already in use
```

**Solution:**

1. **Find and Kill the Process:**
   ```bash
   # On Linux/Mac
   lsof -ti:5173 | xargs kill -9
   
   # On Windows
   netstat -ano | findstr :5173
   taskkill /PID <PID> /F
   ```

2. **Use Different Port:**
   ```bash
   vite --port 5174
   ```

---

### Supabase Connection Issues

**Symptom:**
- Cannot connect to Supabase
- Auth errors
- Database query failures

**Solution:**

1. **Check Supabase Status:**
   ```bash
   npx supabase status
   ```

2. **Restart Supabase:**
   ```bash
   npx supabase stop
   npx supabase start
   ```

3. **Verify Environment Variables:**
   Check `.env.development` has correct values:
   ```
   VITE_SUPABASE_URL=http://127.0.0.1:54321
   VITE_SUPABASE_ANON_KEY=<your-key>
   ```

4. **Reset Database (CAUTION: Deletes all data):**
   ```bash
   npx supabase db reset
   ```

---

## Getting Help

If you're still experiencing issues:

1. Check the [GitHub Issues](https://github.com/himesh13/aarvee-crm-atomic/issues)
2. Enable debug logging by opening DevTools Console
3. Check the network tab for failed requests
4. Review the full error stack trace

## Development Tips

- Always use `npm run dev` (not `vite` directly) to ensure proper flags
- Use `npm run dev:clean` if you notice stale dependency issues
- Keep DevTools open to catch errors early
- Check the console for query/mutation error logs
