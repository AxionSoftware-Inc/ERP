export interface ERPItem {
  name: string;
  item_code: string;
  item_name: string;
  item_group: string;
  stock_uom: string;
  standard_rate: number;
  actual_qty: number;
  image?: string;
  description?: string;
}

export interface ERPCustomer {
  name: string;
  customer_name: string;
  customer_group: string;
  territory: string;
  email_id: string;
  mobile_no: string;
  outstanding_amount: number;
}

export interface ERPSalesOrder {
  name: string;
  customer: string;
  customer_name: string;
  transaction_date: string;
  delivery_date: string;
  grand_total: number;
  status: 'Draft' | 'Submitted' | 'To Deliver and Bill' | 'Completed' | 'Cancelled';
  items: {
    item_code: string;
    item_name: string;
    qty: number;
    rate: number;
    amount: number;
  }[];
}

export interface ERPSalesInvoice {
  name: string;
  customer: string;
  customer_name: string;
  posting_date: string;
  due_date: string;
  grand_total: number;
  outstanding_amount: number;
  status: 'Draft' | 'Unpaid' | 'Overdue' | 'Paid' | 'Cancelled';
}

export const mockItems: ERPItem[] = [
  {
    name: 'ITEM-001',
    item_code: 'LAP-THINKPAD-X1',
    item_name: 'Lenovo ThinkPad X1 Carbon Gen 11',
    item_group: 'Computers & Laptops',
    stock_uom: 'Nos',
    standard_rate: 1499.00,
    actual_qty: 24,
    description: '14" WUXGA, Core i7, 32GB RAM, 1TB SSD',
  },
  {
    name: 'ITEM-002',
    item_code: 'LAP-MBP-16',
    item_name: 'Apple MacBook Pro 16" M3 Max',
    item_group: 'Computers & Laptops',
    stock_uom: 'Nos',
    standard_rate: 2499.00,
    actual_qty: 12,
    description: 'Apple M3 Max, 36GB RAM, 1TB SSD, Space Black',
  },
  {
    name: 'ITEM-003',
    item_code: 'MON-DELL-32',
    item_name: 'Dell UltraSharp U3223QE 4K Monitor',
    item_group: 'Displays & Monitors',
    stock_uom: 'Nos',
    standard_rate: 789.00,
    actual_qty: 38,
    description: '32-inch 4K IPS Black, USB-C Hub, 90W PD',
  },
  {
    name: 'ITEM-004',
    item_code: 'CHR-AERON-PRO',
    item_name: 'Herman Miller Aeron Ergonomic Chair',
    item_group: 'Office Furniture',
    stock_uom: 'Nos',
    standard_rate: 1250.00,
    actual_qty: 15,
    description: 'PostureFit SL lumbar support, fully adjustable arms',
  },
  {
    name: 'ITEM-005',
    item_code: 'DSK-STAND-PRO',
    item_name: 'FlexiSpot Dual-Motor Electric Standing Desk',
    item_group: 'Office Furniture',
    stock_uom: 'Nos',
    standard_rate: 499.00,
    actual_qty: 19,
    description: 'Solid walnut top 60x30", 4 memory presets',
  },
  {
    name: 'ITEM-006',
    item_code: 'ACC-MX-MASTER',
    item_name: 'Logitech MX Master 3S Wireless Mouse',
    item_group: 'Accessories',
    stock_uom: 'Nos',
    standard_rate: 99.00,
    actual_qty: 85,
    description: 'Ergonomic performance mouse, 8K DPI sensor',
  },
];

export const mockCustomers: ERPCustomer[] = [
  {
    name: 'CUST-0001',
    customer_name: 'Acme Global Technologies Inc',
    customer_group: 'Commercial',
    territory: 'Tashkent, Uzbekistan',
    email_id: 'procurement@acmeglobal.com',
    mobile_no: '+998 90 123 45 67',
    outstanding_amount: 4500.00,
  },
  {
    name: 'CUST-0002',
    customer_name: 'Silk Road Trading House',
    customer_group: 'Commercial',
    territory: 'Samarkand, Uzbekistan',
    email_id: 'supply@silkroad.uz',
    mobile_no: '+998 93 987 65 43',
    outstanding_amount: 0.00,
  },
  {
    name: 'CUST-0003',
    customer_name: 'NextGen Cloud Solutions',
    customer_group: 'Enterprise',
    territory: 'Tashkent, Uzbekistan',
    email_id: 'finance@nextgencloud.io',
    mobile_no: '+998 97 555 44 33',
    outstanding_amount: 3600.00,
  },
  {
    name: 'CUST-0004',
    customer_name: 'Apex Logistic Express',
    customer_group: 'Logistics',
    territory: 'Fergana, Uzbekistan',
    email_id: 'ops@apexexpress.uz',
    mobile_no: '+998 91 222 33 44',
    outstanding_amount: 1200.00,
  },
];

export const mockSalesOrders: ERPSalesOrder[] = [
  {
    name: 'SO-2026-0001',
    customer: 'CUST-0001',
    customer_name: 'Acme Global Technologies Inc',
    transaction_date: '2026-02-10',
    delivery_date: '2026-02-18',
    grand_total: 4497.00,
    status: 'Submitted',
    items: [
      {
        item_code: 'LAP-THINKPAD-X1',
        item_name: 'Lenovo ThinkPad X1 Carbon Gen 11',
        qty: 3,
        rate: 1499.00,
        amount: 4497.00,
      },
    ],
  },
  {
    name: 'SO-2026-0002',
    customer: 'CUST-0002',
    customer_name: 'Silk Road Trading House',
    transaction_date: '2026-02-11',
    delivery_date: '2026-02-20',
    grand_total: 7497.00,
    status: 'To Deliver and Bill',
    items: [
      {
        item_code: 'LAP-MBP-16',
        item_name: 'Apple MacBook Pro 16" M3 Max',
        qty: 3,
        rate: 2499.00,
        amount: 7497.00,
      },
    ],
  },
  {
    name: 'SO-2026-0003',
    customer: 'CUST-0003',
    customer_name: 'NextGen Cloud Solutions',
    transaction_date: '2026-02-05',
    delivery_date: '2026-02-10',
    grand_total: 3156.00,
    status: 'Completed',
    items: [
      {
        item_code: 'MON-DELL-32',
        item_name: 'Dell UltraSharp U3223QE 4K Monitor',
        qty: 4,
        rate: 789.00,
        amount: 3156.00,
      },
    ],
  },
];

export const mockSalesInvoices: ERPSalesInvoice[] = [
  {
    name: 'SINV-2026-0001',
    customer: 'CUST-0001',
    customer_name: 'Acme Global Technologies Inc',
    posting_date: '2026-02-10',
    due_date: '2026-02-25',
    grand_total: 4497.00,
    outstanding_amount: 4497.00,
    status: 'Unpaid',
  },
  {
    name: 'SINV-2026-0002',
    customer: 'CUST-0003',
    customer_name: 'NextGen Cloud Solutions',
    posting_date: '2026-02-05',
    due_date: '2026-02-20',
    grand_total: 3156.00,
    outstanding_amount: 0.00,
    status: 'Paid',
  },
];
