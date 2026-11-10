# Axion Enterprise ERP Ecosystem

A modern, proprietary Enterprise Resource Planning (ERP) ecosystem built with a **Headless ERP + API Gateway + Multi-Platform Client** architecture.

Designed for high performance, modularity, and complete intellectual property (IP) protection.

---

## 🏛️ Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                   PROPRIETARY CLIENT & INTEGRATIONS                   │
│                                                                        │
│   [ Flutter Multi-Platform Client ]        [ External Systems ]        │
│   (Web, Mobile, Desktop UI)                (1C, Payme, Click, Telegram)│
│                 │                                      │               │
│                 └───────────────┐      ┌───────────────┘               │
│                                 ▼      ▼                               │
│                   [ Axion Integration Gateway ]                       │
│                   (Node.js / TypeScript REST & Webhooks)               │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │  Isolated Network API Boundary
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   HEADLESS ERP CORE (ERPNext Engine)                  │
│   - Double-entry Accounting, General Ledger, Stock & Inventory         │
│   - Isolated behind REST API (Zero GPL copyleft taint)                 │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Project Structure

```text
erp_ecosystem/
├── gateway/          # TypeScript / Node.js Integration Gateway
│   ├── src/
│   │   ├── routes/   # Sales, Catalog, CRM, Accounting, Integrations
│   │   ├── services/ # ERPNext REST client & Offline Dev Mock engine
│   │   ├── config.ts # Environment configuration
│   │   └── server.ts # Express server setup
│   ├── package.json
│   └── tsconfig.json
│
├── client_app/       # Flutter 3 Client Application (Material 3)
│   ├── lib/
│   │   ├── models/   # Items, Sales Orders, Customers, Stats
│   │   ├── services/ # Gateway API HTTP service
│   │   ├── screens/  # Dashboard, Sales (POS), Catalog, Customers, Integrations
│   │   └── main.dart # Responsive navigation shell
│   └── pubspec.yaml
│
└── README.md
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Node.js**: v18+ (v22 recommended)
- **Flutter**: v3.22+

### 2. Start the Integration Gateway
```bash
cd gateway
npm install
npm run dev
# Gateway runs on http://localhost:4000
```

### 3. Run the Flutter Client
```bash
cd client_app
flutter pub get
flutter run -d chrome
# Or target macOS, iOS, or Android
```

---

## 🔌 Built-in Integration Adapters

- **1C: Enterprise (8.3)**: `POST /api/v1/integrations/1c/sync-catalog` to synchronize products, stock balances, and prices.
- **Payme Merchant API**: `POST /api/v1/integrations/payments/payme` for JSON-RPC merchant transactions and auto-generating ERP payment entries.
- **Click Merchant API**: `POST /api/v1/integrations/payments/click` for Click prepare/complete verification and accounting entries.
- **Telegram Bot**: `POST /api/v1/integrations/telegram/notify` for automated alerts (large sales, low stock warnings).

---

## 🛡️ License & IP Isolation
All client application code and integration gateway logic in this repository are **100% proprietary**. The backend ERP engine is interfaced exclusively through standard network HTTP/REST protocols, ensuring strict license boundary isolation under open-source compliance standards.
