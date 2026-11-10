import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';

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
    const { customer, customer_name, items } = req.body;
    if (!customer || !items || !items.length) {
      res.status(400).json({ success: false, error: 'Customer and items are required' });
      return;
    }

    const grand_total = items.reduce(
      (sum: number, it: any) => sum + (it.qty || 1) * (it.rate || 0),
      0
    );

    const orderData = {
      customer,
      customer_name: customer_name || customer,
      transaction_date: new Date().toISOString().split('T')[0],
      delivery_date: new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0],
      grand_total,
      status: 'Submitted',
      items: items.map((it: any) => ({
        item_code: it.item_code,
        item_name: it.item_name || it.item_code,
        qty: it.qty,
        rate: it.rate,
        amount: (it.qty || 1) * (it.rate || 0),
      })),
    };

    const created = await erpClient.createDoc('Sales Order', orderData);
    res.status(201).json({ success: true, data: created });
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
