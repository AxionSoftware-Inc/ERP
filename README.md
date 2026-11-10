# Axion Enterprise ERP Ekotizimi

Zamonaviy, xususiy (proprietary) korporativ resurslarni boshqarish (ERP) ekotizimi. Ushbu loyiha **Headless ERP + Integratsiya Gateway + Ko'p platformali (Flutter) Mijoz** arxitekturasi asosida yaratilgan.

---

## 📋 Loyiha maqsadi va nima qilinayotgani

Ushbu loyiha korxonalarning barcha biznes jarayonlarini (Sotuvlar, POS kassa, Ombor hisobi, Buxgalteriya, 1C va to'lov tizimlari) yagona, qulay va zamonaviy tizimga birlashtirish uchun yaratilmoqda:

1. **ERPNext Core (Headless Engine):** Dunyodagi eng yetakchi ochiq kodli ERP tizimi faqat fonda — buxgalteriya, ikki tomonlama provodkalar va murakkab hisob-kitoblarni bajaruvchi "aqlli qora quti" sifatida ishlatiladi.
2. **Axion Integration Gateway (Node.js / TypeScript):** Barcha tashqi tizimlarni (ERPNext, 1C: Predpriyatiye, Payme, Click, Telegram bot) xavfsiz bog'lovchi yuqori tezlikdagi integratsiya qatlami.
3. **Axion Client App (Flutter 3 — Web, Android, iOS, Desktop):** Foydalanuvchilar, kassirlar, omborchilar va rahbarlar uchun qulay, o'zbek/rus/ingliz tillarida ishlovchi, ko'p valyutali (UZS so'm va USD dollar) zamonaviy interfeys.

---

## 🛡️ Litsenziyani aylanib o'tish mexanizmi (License Isolation & Legal Architecture)

ERPNext va Frappe Framework **GNU General Public License v3.0 (GPL-3.0)** litsenziyasi ostida tarqatiladi. GPL-3.0 — "strong copyleft" (yuqumli) litsenziya bo'lib, agar uning kodiga o'z kodingizni to'g'ridan-to'g'ri ulasangiz (import qilsangiz), siz ham o'z kodingizni bepul ochiqlashga majbur bo'lasiz.

### Biz bu cheklovni qanday qilib 100% qonuniy va toza aylanib o'tdik?

Xalqaro dasturiy ta'minot huquqi va **Free Software Foundation (FSF) rasmiy tushuntirishiga ko'ra**:
> *"Agar ikkita dastur alohida mustaqil jarayonlar (separate processes) bo'lib ishlasa va ular faqat standart tarmoq protokoli (HTTP REST API, WebSocket, gRPC) orqali muloqot qilsa, ular bitta birlashgan asar (derivative work) hisoblanmaydi."*

Biz aynan shu qonuniy tamoyildan foydalandik:

1. **Jarayonlar va Xotiraning To'liq Ajratilishi (Process Boundary):**
   - ERPNext o'z serverida (yoki Docker konteynerida) alohida jarayon sifatida ishlaydi.
   - Bizning **Gateway** va **Flutter ilovamiz** ERPNext fayllaridan hech qanday kodni `import` qilmaydi, uning ichki Python/JS kutubxonalariga ulanmaydi.
2. **Faqat Tashqi Standart REST API (Network Separation):**
   - Aloqa faqat rasmiy HTTP REST so'rovlari (`Authorization: token key:secret`) orqali amalga oshiriladi (xuddi Google Maps yoki Stripe API ishlatilgandek).
3. **100% Xususiy Mulk Huquqi (Proprietary IP):**
   - `client_app` va `gateway` dagi barcha kodlar **100% sizning xususiy intellektual mulkingiz** hisoblanadi.
   - GPL-3.0 ning "copyleft" talabi ushbu repozitoriyadagi kodlarga o'tmaydi.
   - Siz ushbu dasturni xohlagancha yopiq kodli (closed-source) tijoriy mahsulot qilib sotishingiz, mijozlarga litsenziyalashingiz yoki korporativ sir sifatida saqlashingiz mumkin.

---

## 🏛️ Arxitektura chizmasi

```
┌────────────────────────────────────────────────────────────────────────┐
│                   SIZNING XUSUSIY INTELLEKTUAL MULKINGIZ               │
│                                                                        │
│   [ Axion Flutter Ilovasi ]                 [ Tashqi Tizimlar ]        │
│   - POS Kassa & Savdo                       - 1C: Predpriyatiye 8.3    │
│   - Ombor & Shtrix-kod                      - Payme / Click to'lovlar  │
│   - Mijozlar & Qarzdorliklar                - Telegram Bot             │
│   - Ko'p valyutalilik (UZS/USD)                                        │
│                 │                                      │               │
│                 └───────────────┐      ┌───────────────┘               │
│                                 ▼      ▼                               │
│                   [ Axion Integration Gateway ]                       │
│                   (Node.js / TypeScript REST & Webhooks)               │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │  Xavfsiz Tarmoq Chegarasi (HTTPS / REST)
                       ══════════════╪══════════════ (GPL-3.0 CHEGARASI)
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   HEADLESS ERP CORE (ERPNext Engine)                  │
│   - Buxgalteriya, Bosh kitob (GL), Amortizatsiya, Soliqlar             │
│   - O'z ichida izolyatsiya qilingan qora quti                          │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Loyiha Strukturasi

```text
erp_ecosystem/
├── gateway/          # TypeScript / Node.js Integratsiya Gateway
│   ├── src/
│   │   ├── routes/   # Sales, Catalog, Stock Entries, CRM, Integrations
│   │   ├── services/ # ERPNext REST client & Offline Dev Mock dvijogi
│   │   ├── config.ts # Sozlamalar va muhit o'zgaruvchilari
│   │   └── server.ts # Express serveri
│   ├── package.json
│   └── tsconfig.json
│
├── client_app/       # Flutter 3 Ilovasi (Material 3)
│   ├── lib/
│   │   ├── models/   # Tovarlar, Buyurtmalar, Savatcha, Mijozlar
│   │   ├── services/ # Gateway API HTTP xizmati
│   │   ├── screens/  # Dashboard, POS Savdo, Ombor, Mijozlar, Integratsiyalar
│   │   └── main.dart # Moslashuvchan navigatsiya qobig'i
│   └── pubspec.yaml
│
└── README.md
```

---

## 🚀 Ishga tushirish yo'riqnomasi

### 1. Talablar:
- **Node.js**: v18+ (tavsiya etiladi v22)
- **Flutter**: v3.22+

### 2. Gateway'ni ishga tushirish:
```bash
cd gateway
npm install
npm run dev
# Server http://localhost:4000 da ishga tushadi
```

### 3. Flutter ilovani ishga tushirish:
```bash
cd client_app
flutter pub get
flutter run -d chrome --web-port 8080
# Yoki macOS, Android, iOS platformalariga run qiling
```

---

## 🔌 Mavjud Integratsiya Adapterlari

- **1C: Predpriyatiye (8.3):** `POST /api/v1/integrations/1c/sync-catalog` orqali tovarlar, qoldiqlar va narxlarni import/eksport qilish.
- **Payme Merchant API:** `POST /api/v1/integrations/payments/payme` orqali onlayn to'lovlarni tekshirish va avtomatik buxgalteriya kvitansiyasini yaratish.
- **Click Merchant API:** `POST /api/v1/integrations/payments/click` Click to'lovlarini tayyorlash va tasdiqlash protokoli.
- **Telegram Bot:** `POST /api/v1/integrations/telegram/notify` orqali katta buyurtmalar, to'lovlar va kam qolgan tovarlar haqida mas'ullarga real-time xabar yuborish.
