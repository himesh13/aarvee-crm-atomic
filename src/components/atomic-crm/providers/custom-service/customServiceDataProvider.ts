import { DataProvider } from 'ra-core';
import { supabase } from '../supabase/supabase';

const API_BASE_URL = import.meta.env.VITE_CUSTOM_SERVICE_URL || 'http://localhost:3001/api';

// Token cache to avoid fetching from Supabase on every request
let cachedToken: string | null = null;
let tokenExpiresAt: number | null = null;
let tokenRefreshPromise: Promise<string | null> | null = null;

const getAuthToken = async () => {
  try {
    // Check if we have a cached token that hasn't expired
    const now = Date.now() / 1000; // Convert to seconds
    if (cachedToken && tokenExpiresAt && now < tokenExpiresAt - 60) {
      // Return cached token if it's still valid (with 60s buffer)
      return cachedToken;
    }

    // If a token refresh is already in progress, wait for it
    if (tokenRefreshPromise) {
      return await tokenRefreshPromise;
    }

    // Start a new token refresh
    tokenRefreshPromise = (async () => {
      try {
        // Fetch fresh token from Supabase
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error || !session?.access_token) {
          // Clear cache on error
          cachedToken = null;
          tokenExpiresAt = null;
          return null;
        }

        // Cache the token and its expiration time
        cachedToken = session.access_token;
        tokenExpiresAt = session.expires_at || null;
        
        return cachedToken;
      } finally {
        // Clear the promise once complete
        tokenRefreshPromise = null;
      }
    })();

    return await tokenRefreshPromise;
  } catch (error) {
    // Handle unexpected errors gracefully
    console.error('Failed to retrieve auth token:', error);
    cachedToken = null;
    tokenExpiresAt = null;
    tokenRefreshPromise = null;
    return null;
  }
};

const fetchJson = async (url: string, options: RequestInit = {}) => {
  const token = await getAuthToken();
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(options.headers as HeadersInit),
  };

  const response = await fetch(url, { ...options, headers });
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: response.statusText }));
    throw new Error(error.error || `HTTP error! status: ${response.status}`);
  }
  
  return response.json();
};

export const customServiceDataProvider: DataProvider = {
  getList: async (resource, params) => {
    const { page, perPage } = params.pagination;
    const { field, order } = params.sort;
    
    const query = new URLSearchParams({
      page: String(page),
      perPage: String(perPage),
      sortField: field,
      sortOrder: order.toLowerCase(),
      filter: JSON.stringify(params.filter),
    });
    
    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);
    
    return {
      data: json.data,
      total: json.total,
    };
  },
  
  getOne: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    const data = await fetchJson(url);
    return { data };
  },
  
  create: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}`;
    const data = await fetchJson(url, {
      method: 'POST',
      body: JSON.stringify(params.data),
    });
    return { data };
  },
  
  update: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    const data = await fetchJson(url, {
      method: 'PUT',
      body: JSON.stringify(params.data),
    });
    return { data };
  },
  
  updateMany: async (resource, params) => {
    const results = await Promise.all(
      params.ids.map(id =>
        fetchJson(`${API_BASE_URL}/${resource}/${id}`, {
          method: 'PUT',
          body: JSON.stringify(params.data),
        })
      )
    );
    return { data: results.map((_, index) => params.ids[index]) };
  },
  
  delete: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    await fetchJson(url, { method: 'DELETE' });
    return { data: params.previousData as any };
  },
  
  deleteMany: async (resource, params) => {
    await Promise.all(
      params.ids.map(id =>
        fetchJson(`${API_BASE_URL}/${resource}/${id}`, { method: 'DELETE' })
      )
    );
    return { data: params.ids };
  },
  
  getMany: async (resource, params) => {
    const results = await Promise.all(
      params.ids.map(id => fetchJson(`${API_BASE_URL}/${resource}/${id}`))
    );
    return { data: results };
  },
  
  getManyReference: async (resource, params) => {
    const { page, perPage } = params.pagination;
    const { field, order } = params.sort;
    
    const query = new URLSearchParams({
      page: String(page),
      perPage: String(perPage),
      sortField: field,
      sortOrder: order.toLowerCase(),
      filter: JSON.stringify({ ...params.filter, [params.target]: params.id }),
    });
    
    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);
    
    return {
      data: json.data,
      total: json.total,
    };
  },
};
