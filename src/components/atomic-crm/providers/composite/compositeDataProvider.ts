import type { DataProvider } from 'ra-core';
import { dataProvider as supabaseDataProvider } from '../supabase/dataProvider';
import { customServiceDataProvider } from '../custom-service/customServiceDataProvider';

// Resources handled by the custom service
const CUSTOM_RESOURCES = [
  'leads',
  'lead_extensions',
  'business_details',
  'property_details',
  'reminders',
];

const isCustomResource = (resource: string): boolean => {
  return CUSTOM_RESOURCES.includes(resource);
};

export const compositeDataProvider: DataProvider = {
  getList: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getList(resource, params);
  },
  
  getOne: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getOne(resource, params);
  },
  
  create: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.create(resource, params);
  },
  
  update: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.update(resource, params);
  },
  
  updateMany: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.updateMany(resource, params);
  },
  
  delete: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.delete(resource, params);
  },
  
  deleteMany: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.deleteMany(resource, params);
  },
  
  getMany: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getMany(resource, params);
  },
  
  getManyReference: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getManyReference(resource, params);
  },
};
