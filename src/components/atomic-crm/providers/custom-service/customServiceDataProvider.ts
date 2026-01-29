import type { DataProvider } from 'ra-core';
import { supabase } from '../supabase/supabase';
import { fetchWithTimeout } from '../../misc/fetchWithTimeout';

const API_BASE_URL = import.meta.env.VITE_CUSTOM_SERVICE_URL || 'http://localhost:3001/api';
const REQUEST_TIMEOUT = 30000; // 30 seconds timeout for API requests

/**
 * Retrieves the authentication token from Supabase session.
 * 
 * Note: We rely on Supabase's built-in session management which already handles:
 * - Token caching (localStorage + memory)
 * - Automatic token refresh
 * - Token expiry checking
 * - Cross-tab synchronization
 * - Clearing tokens on logout
 * 
 * getSession() is fast (reads from cache, not network) so no additional caching is needed.
 */
const getAuthToken = async () => {
  try {
    const { data: { session }, error } = await supabase.auth.getSession();
    
    if (error || !session?.access_token) {
      return null;
    }
    
    return session.access_token;
  } catch (error) {
    console.error('Failed to retrieve auth token:', error);
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

  try {
    const response = await fetchWithTimeout(url, { 
      ...options, 
      headers,
      timeout: REQUEST_TIMEOUT 
    });
    
    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: response.statusText }));
      throw new Error(error.error || `HTTP error! status: ${response.status}`);
    }
    
    return response.json();
  } catch (error) {
    // Handle timeout and network errors
    if (error instanceof Error) {
      if (error.name === 'AbortError') {
        throw new Error(`Request timeout: The custom service at ${API_BASE_URL} did not respond within ${REQUEST_TIMEOUT / 1000} seconds. Please check if the service is running.`);
      }
      throw new Error(`Network error: ${error.message}`);
    }
    throw error;
  }
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
