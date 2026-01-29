import { createClient } from "@supabase/supabase-js";

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  {
    global: {
      fetch: (url, options = {}) => {
        // Add timeout to all Supabase requests
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 30000); // 30 second timeout
        
        // Merge signals if caller provided one
        const signal = options.signal
          ? (() => {
              // Listen to both signals
              const originalSignal = options.signal as AbortSignal;
              originalSignal.addEventListener('abort', () => controller.abort());
              return controller.signal;
            })()
          : controller.signal;
        
        return fetch(url, {
          ...options,
          signal,
        }).finally(() => clearTimeout(timeoutId));
      },
    },
  }
);
