import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '4000', 10),
  erpnextUrl: process.env.ERPNEXT_URL || 'http://localhost:8000',
  apiKey: process.env.ERPNEXT_API_KEY || 'dev_key',
  apiSecret: process.env.ERPNEXT_API_SECRET || 'dev_secret',
  devMockMode: process.env.DEV_MOCK_MODE !== 'false', // Default true for instant offline dev
};
