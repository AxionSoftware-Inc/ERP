import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';

export const accountingRouter = Router();

// GET /api/v1/accounting/invoices
accountingRouter.get('/invoices', async (req: Request, res: Response) => {
  try {
    const invoices = await erpClient.getList('Sales Invoice');
    res.json({
      success: true,
      total: invoices.length,
      data: invoices,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// POST /api/v1/accounting/payments
accountingRouter.post('/payments', async (req: Request, res: Response) => {
  try {
    const { party, paid_amount, payment_type, mode_of_payment } = req.body;
    if (!party || !paid_amount) {
      res.status(400).json({ success: false, error: 'Party and paid_amount are required' });
      return;
    }

    const paymentEntry = {
      payment_type: payment_type || 'Receive',
      party_type: 'Customer',
      party,
      paid_amount: parseFloat(paid_amount),
      received_amount: parseFloat(paid_amount),
      mode_of_payment: mode_of_payment || 'Bank',
      posting_date: new Date().toISOString().split('T')[0],
      reference_no: `PAY-${Date.now().toString().slice(-6)}`,
    };

    const created = await erpClient.createDoc('Payment Entry', paymentEntry);
    res.status(201).json({ success: true, data: created });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});
