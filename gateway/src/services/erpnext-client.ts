import { config } from '../config.js';
import {
  mockItems,
  mockCustomers,
  mockSalesOrders,
  mockSalesInvoices,
  ERPItem,
  ERPCustomer,
  ERPSalesOrder,
  ERPSalesInvoice,
} from './mock-data.js';

export class ERPNextClient {
  private baseUrl: string;
  private authHeader: string;

  constructor() {
    this.baseUrl = config.erpnextUrl.replace(/\/$/, '');
    this.authHeader = `token ${config.apiKey}:${config.apiSecret}`;
  }

  // -----------------------------------------------------------
  // Generic DocType Handlers
  // -----------------------------------------------------------

  async getList<T = any>(doctype: string, filters?: any): Promise<T[]> {
    if (config.devMockMode) {
      return this.getMockList(doctype) as T[];
    }

    try {
      const url = new URL(`${this.baseUrl}/api/resource/${encodeURIComponent(doctype)}`);
      url.searchParams.set('limit_page_length', '100');
      if (filters) {
        url.searchParams.set('filters', JSON.stringify(filters));
      }

      const res = await fetch(url.toString(), {
        headers: {
          Authorization: this.authHeader,
          Accept: 'application/json',
        },
      });

      if (!res.ok) throw new Error(`ERPNext error: ${res.status} ${res.statusText}`);
      const json = (await res.json()) as any;
      return json.data || [];
    } catch (err) {
      console.warn(`[ERPNextClient] Fallback to mock for ${doctype}:`, (err as Error).message);
      return this.getMockList(doctype) as T[];
    }
  }

  async getDoc<T = any>(doctype: string, name: string): Promise<T | null> {
    if (config.devMockMode) {
      return this.getMockDoc(doctype, name) as T | null;
    }

    try {
      const url = `${this.baseUrl}/api/resource/${encodeURIComponent(doctype)}/${encodeURIComponent(name)}`;
      const res = await fetch(url, {
        headers: {
          Authorization: this.authHeader,
          Accept: 'application/json',
        },
      });

      if (!res.ok) throw new Error(`ERPNext error: ${res.status} ${res.statusText}`);
      const json = (await res.json()) as any;
      return json.data || null;
    } catch (err) {
      console.warn(`[ERPNextClient] Fallback to mock for ${doctype}/${name}:`, (err as Error).message);
      return this.getMockDoc(doctype, name) as T | null;
    }
  }

  async createDoc<T = any>(doctype: string, data: any): Promise<T> {
    if (config.devMockMode) {
      return this.createMockDoc(doctype, data) as T;
    }

    try {
      const url = `${this.baseUrl}/api/resource/${encodeURIComponent(doctype)}`;
      const res = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: this.authHeader,
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
        body: JSON.stringify(data),
      });

      if (!res.ok) throw new Error(`ERPNext error: ${res.status} ${res.statusText}`);
      const json = (await res.json()) as any;
      return json.data;
    } catch (err) {
      console.warn(`[ERPNextClient] Fallback mock create for ${doctype}:`, (err as Error).message);
      return this.createMockDoc(doctype, data) as T;
    }
  }

  // -----------------------------------------------------------
  // Mock Data Resolvers
  // -----------------------------------------------------------

  private getMockList(doctype: string): any[] {
    switch (doctype) {
      case 'Item':
        return mockItems;
      case 'Customer':
        return mockCustomers;
      case 'Sales Order':
        return mockSalesOrders;
      case 'Sales Invoice':
        return mockSalesInvoices;
      default:
        return [];
    }
  }

  private getMockDoc(doctype: string, name: string): any | null {
    const list = this.getMockList(doctype);
    return list.find((item) => item.name === name || item.item_code === name) || null;
  }

  private createMockDoc(doctype: string, data: any): any {
    const id = `${doctype.replace(/\s+/g, '-').toUpperCase()}-${Date.now().toString().slice(-4)}`;
    const created = {
      name: id,
      ...data,
      creation: new Date().toISOString(),
    };

    if (doctype === 'Item') mockItems.unshift(created as ERPItem);
    if (doctype === 'Customer') mockCustomers.unshift(created as ERPCustomer);
    if (doctype === 'Sales Order') mockSalesOrders.unshift(created as ERPSalesOrder);
    if (doctype === 'Sales Invoice') mockSalesInvoices.unshift(created as ERPSalesInvoice);

    return created;
  }
}

export const erpClient = new ERPNextClient();
