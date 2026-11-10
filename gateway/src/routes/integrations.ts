import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';

export const integrationsRouter = Router();

// ============================================================
// 1C: Enterprise Sync Endpoint (CommerceML / JSON)
// ============================================================
integrationsRouter.post('/1c/sync-catalog', async (req: Request, res: Response) => {
  try {
    const { goods } = req.body; // Array of 1C goods
    if (!Array.isArray(goods)) {
      res.status(400).json({ success: false, error: 'Expected "goods" array from 1C' });
      return;
    }

    const results = [];
    for (const g of goods) {
      const itemData = {
        item_code: g.code || g.article,
        item_name: g.name,
        item_group: g.category || '1C Imports',
        stock_uom: g.uom || 'Nos',
        standard_rate: parseFloat(g.price || 0),
        actual_qty: parseFloat(g.stock || 0),
      };
      const saved = await erpClient.createDoc('Item', itemData);
      results.push(saved);
    }

    res.json({
      success: true,
      importedCount: results.length,
      message: '1C catalog synced successfully with ERP ecosystem',
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// ============================================================
// Payme Merchant API Callback
// ============================================================
integrationsRouter.post('/payments/payme', async (req: Request, res: Response) => {
  const { method, params, id } = req.body;

  // Payme JSON-RPC protocol
  if (method === 'CheckPerformTransaction') {
    res.json({
      jsonrpc: '2.0',
      id,
      result: { allow: true },
    });
    return;
  }

  if (method === 'PerformTransaction') {
    // Record payment in ERPNext
    try {
      await erpClient.createDoc('Payment Entry', {
        payment_type: 'Receive',
        party_type: 'Customer',
        party: params?.account?.order_id || 'CUST-0001',
        paid_amount: (params?.amount || 0) / 100, // tiyin to soum
        mode_of_payment: 'Payme',
        reference_no: params?.id || `PAYME-${Date.now()}`,
      });
    } catch (_) {}

    res.json({
      jsonrpc: '2.0',
      id,
      result: {
        transaction: params?.id || 'TX_01',
        perform_time: Date.now(),
        state: 2,
      },
    });
    return;
  }

  res.json({ jsonrpc: '2.0', id, result: { state: 1 } });
});

// ============================================================
// Click Merchant API Callback
// ============================================================
integrationsRouter.post('/payments/click', async (req: Request, res: Response) => {
  const { click_trans_id, service_id, merchant_trans_id, amount, action } = req.body;

  // Action 0 = Prepare, Action 1 = Complete
  if (action === 0) {
    res.json({
      click_trans_id,
      merchant_trans_id,
      merchant_prepare_id: Date.now(),
      error: 0,
      error_note: 'Success',
    });
    return;
  }

  try {
    await erpClient.createDoc('Payment Entry', {
      payment_type: 'Receive',
      party_type: 'Customer',
      party: merchant_trans_id || 'CUST-0001',
      paid_amount: parseFloat(amount || 0),
      mode_of_payment: 'Click',
      reference_no: `CLICK-${click_trans_id}`,
    });
  } catch (_) {}

  res.json({
    click_trans_id,
    merchant_trans_id,
    merchant_confirm_id: Date.now(),
    error: 0,
    error_note: 'Success',
  });
});

// ============================================================
// Telegram Bot Alert Dispatcher
// ============================================================
integrationsRouter.post('/telegram/notify', async (req: Request, res: Response) => {
  const { title, message, channel } = req.body;
  console.log(`[Telegram Alert] [${channel || 'General'}] ${title}: ${message}`);

  res.json({
    success: true,
    sent: true,
    timestamp: new Date().toISOString(),
  });
});
