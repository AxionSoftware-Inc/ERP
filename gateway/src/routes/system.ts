import { Router, Request, Response } from 'express';

export const systemRouter = Router();

// GET /api/v1/system/exchange-rate
systemRouter.get('/exchange-rate', (req: Request, res: Response) => {
  res.json({
    success: true,
    data: {
      base_currency: 'USD',
      target_currency: 'UZS',
      rate: 12850.0,
      timestamp: new Date().toISOString(),
    },
  });
});
