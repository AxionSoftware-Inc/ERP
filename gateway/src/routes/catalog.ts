import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';
import { mockStockEntries, adjustItemStock, mockItems } from '../services/mock-data.js';

export const catalogRouter = Router();

// GET /api/v1/catalog/items
catalogRouter.get('/items', async (req: Request, res: Response) => {
  try {
    const items = await erpClient.getList('Item');
    res.json({
      success: true,
      total: items.length,
      data: items,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// GET /api/v1/catalog/items/:id
catalogRouter.get('/items/:id', async (req: Request, res: Response) => {
  try {
    const item = await erpClient.getDoc('Item', req.params.id);
    if (!item) {
      res.status(404).json({ success: false, error: 'Item not found' });
      return;
    }
    res.json({ success: true, data: item });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// POST /api/v1/catalog/items
catalogRouter.post('/items', async (req: Request, res: Response) => {
  try {
    const created = await erpClient.createDoc('Item', req.body);
    res.status(201).json({ success: true, data: created });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// POST /api/v1/catalog/stock-entry (Ombor Kirim / Chiqim)
catalogRouter.post('/stock-entry', async (req: Request, res: Response) => {
  try {
    const { stock_entry_type, items, purpose } = req.body;
    if (!stock_entry_type || !Array.isArray(items) || items.length === 0) {
      res.status(400).json({ success: false, error: 'stock_entry_type and items are required' });
      return;
    }

    // Is it Receipt (Kirim) or Issue (Chiqim)?
    const isReceipt = stock_entry_type === 'Material Receipt';
    const multiplier = isReceipt ? 1 : -1;

    for (const it of items) {
      adjustItemStock(it.item_code, (it.qty || 1) * multiplier);
    }

    const entry = {
      name: `STE-${Date.now().toString().slice(-6)}`,
      stock_entry_type,
      purpose: purpose || (isReceipt ? 'Omborga tovar kirimi' : 'Ombordan chiqim'),
      posting_date: new Date().toISOString().split('T')[0],
      items,
    };

    mockStockEntries.unshift(entry);

    res.status(201).json({
      success: true,
      message: `${isReceipt ? 'Kirim' : 'Chiqim'} hujjati muvaffaqiyatli saqlandi`,
      data: entry,
    });
  } catch (err) {
    res.status(500).json({ success: false, error: (err as Error).message });
  }
});

// GET /api/v1/catalog/stock-entries
catalogRouter.get('/stock-entries', async (req: Request, res: Response) => {
  res.json({
    success: true,
    total: mockStockEntries.length,
    data: mockStockEntries,
  });
});
