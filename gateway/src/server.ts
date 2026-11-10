import express from 'express';
import cors from 'cors';
import { config } from './config.js';
import { catalogRouter } from './routes/catalog.js';
import { salesRouter } from './routes/sales.js';
import { customersRouter } from './routes/customers.js';
import { accountingRouter } from './routes/accounting.js';
import { integrationsRouter } from './routes/integrations.js';
import { systemRouter } from './routes/system.js';

const app = express();

app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[Gateway] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health & Info Endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'ERP Enterprise Gateway',
    version: '1.1.0',
    erpnextTarget: config.erpnextUrl,
    mode: config.devMockMode ? 'Dev Mock Mode (Offline ready)' : 'Live ERPNext Connection',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/v1/catalog', catalogRouter);
app.use('/api/v1/sales', salesRouter);
app.use('/api/v1/crm/customers', customersRouter);
app.use('/api/v1/accounting', accountingRouter);
app.use('/api/v1/integrations', integrationsRouter);
app.use('/api/v1/system', systemRouter);

// Start server
app.listen(config.port, () => {
  console.log(`🚀 ERP Gateway running at http://localhost:${config.port}`);
  console.log(`📡 ERPNext Backend Target: ${config.erpnextUrl}`);
  console.log(`🛡️  Dev Mock Mode: ${config.devMockMode}`);
});
