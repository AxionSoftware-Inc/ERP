import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';
import {
  adjustItemStock,
  adjustCustomerBalance,
  mockSalesOrders,
  mockSalesInvoices,
} from '../services/mock-data.js';

export const salesRouter = Router();

// GET /api/v1/sales/orders
salesRouter.get('/orders', async (req: Request, res: Response) => {
  try {
    const orders = await erpClient.getList('Sales Order');
    res.json({
      success: true,
      total: orders.length,
      data: orders,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// POST /api/v1/sales/orders
salesRouter.post('/orders', async (req: Request, res: Response) => {
  try {
    const { customer, customer_name, items, payment_method, currency } = req.body;
    if (!customer || !items || !items.length) {
      res.status(400).json({ success: false, error: 'Customer and items are required' });
      return;
    }

    const grand_total = items.reduce(
      (sum: number, it: any) => sum + (it.qty || 1) * (it.rate || 0),
      0
    );

    const orderData = {
      name: `SO-${new Date().getFullYear()}-${Date.now().toString().slice(-4)}`,
      customer,
      customer_name: customer_name || customer,
      transaction_date: new Date().toISOString().split('T')[0],
      delivery_date: new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0],
      grand_total,
      currency: currency || 'USD',
      payment_method: payment_method || 'Naqd',
      status: 'Submitted',
      items: items.map((it: any) => ({
        item_code: it.item_code,
        item_name: it.item_name || it.item_code,
        qty: it.qty,
        rate: it.rate,
        amount: (it.qty || 1) * (it.rate || 0),
      })),
    };

    mockSalesOrders.unshift(orderData as any);
    res.status(201).json({ success: true, data: orderData });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// POST /api/v1/sales/pos-checkout (Tezkor Kassa / POS Sotuv)
salesRouter.post('/pos-checkout', async (req: Request, res: Response) => {
  try {
    const {
      customer,
      customer_name,
      items,
      payment_method, // 'Naqd' | 'Karta' | 'Nasiya (Qarz)' | 'Payme' | 'Click'
      currency,       // 'USD' | 'UZS'
      paid_amount,
    } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      res.status(400).json({ success: false, error: 'Savatchada kamida bitta tovar bo\'lishi shart' });
      return;
    }

    const grand_total = items.reduce(
      (sum: number, it: any) => sum + (it.qty || 1) * (it.rate || 0),
      0
    );

    const actualPaid = typeof paid_amount === 'number' ? paid_amount : (payment_method === 'Nasiya (Qarz)' ? 0 : grand_total);
    const debtAmount = Math.max(0, grand_total - actualPaid);

    // 1. Reduce stock for each item sold
    for (const it of items) {
      adjustItemStock(it.item_code, -(it.qty || 1));
    }

    // 2. If debt / nasiya, increase customer debt
    const custId = customer || 'CUST-0001';
    if (debtAmount > 0) {
      adjustCustomerBalance(custId, debtAmount);
    }

    // 3. Create Sales Order
    const orderId = `POS-${Date.now().toString().slice(-6)}`;
    const newOrder = {
      name: orderId,
      customer: custId,
      customer_name: customer_name || 'Tezkor Xaridor',
      transaction_date: new Date().toISOString().split('T')[0],
      delivery_date: new Date().toISOString().split('T')[0],
      grand_total,
      currency: currency || 'USD',
      payment_method: payment_method || 'Naqd',
      status: 'Completed',
      items,
    };
    mockSalesOrders.unshift(newOrder as any);

    // 4. Create Sales Invoice
    const invoiceId = `SINV-${Date.now().toString().slice(-6)}`;
    const newInvoice = {
      name: invoiceId,
      customer: custId,
      customer_name: customer_name || 'Tezkor Xaridor',
      posting_date: new Date().toISOString().split('T')[0],
      due_date: new Date(Date.now() + 14 * 86400000).toISOString().split('T')[0],
      grand_total,
      outstanding_amount: debtAmount,
      status: debtAmount === 0 ? 'Paid' : 'Unpaid',
    };
    mockSalesInvoices.unshift(newInvoice as any);

    res.status(201).json({
      success: true,
      message: 'Savdo muvaffaqiyatli yakunlandi. Chek chiqarishga tayyor!',
      data: {
        order: newOrder,
        invoice: newInvoice,
        receipt: {
          receipt_no: orderId,
          timestamp: new Date().toISOString(),
          customer_name: customer_name || 'Tezkor Xaridor',
          items,
          grand_total,
          paid_amount: actualPaid,
          debt_amount: debtAmount,
          currency: currency || 'USD',
          payment_method: payment_method || 'Naqd',
        },
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// GET /api/v1/sales/dashboard
salesRouter.get('/dashboard', async (req: Request, res: Response) => {
  try {
    const orders = await erpClient.getList('Sales Order');
    const items = await erpClient.getList('Item');
    const customers = await erpClient.getList('Customer');

    const totalRevenue = orders.reduce((sum, o: any) => sum + (o.grand_total || 0), 0);
    const lowStockItems = items.filter((it: any) => (it.actual_qty || 0) < 15);

    res.json({
      success: true,
      data: {
        totalRevenue,
        ordersCount: orders.length,
        itemsCount: items.length,
        customersCount: customers.length,
        lowStockCount: lowStockItems.length,
        recentOrders: orders.slice(0, 5),
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});
