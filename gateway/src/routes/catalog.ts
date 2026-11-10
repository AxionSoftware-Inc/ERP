import { Router, Request, Response } from 'express';
import { erpClient } from '../services/erpnext-client.js';

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
