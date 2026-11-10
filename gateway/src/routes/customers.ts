import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';

export const customersRouter = Router();

// GET /api/v1/crm/customers
customersRouter.get('/', async (req: Request, res: Response) => {
  try {
    const customers = await erpClient.getList('Customer');
    res.json({
      success: true,
      total: customers.length,
      data: customers,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// POST /api/v1/crm/customers
customersRouter.post('/', async (req: Request, res: Response) => {
  try {
    const { customer_name, customer_group, territory, email_id, mobile_no } = req.body;
    if (!customer_name) {
      res.status(400).json({ success: false, error: 'Customer name is required' });
      return;
    }

    const created = await erpClient.createDoc('Customer', {
      customer_name,
      customer_group: customer_group || 'Commercial',
      territory: territory || 'Uzbekistan',
      email_id: email_id || '',
      mobile_no: mobile_no || '',
      outstanding_amount: 0.0,
    });

    res.status(201).json({ success: true, data: created });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});
