import 'package:flutter/material.dart';
import '../services/api_service.dart';

class IntegrationsView extends StatefulWidget {
  final ApiService api;

  const IntegrationsView({super.key, required this.api});

  @override
  State<IntegrationsView> createState() => _IntegrationsViewState();
}

class _IntegrationsViewState extends State<IntegrationsView> {
  bool _syncing = false;
  String _syncResult = '';

  Future<void> _handle1CSync() async {
    setState(() {
      _syncing = true;
      _syncResult = '1C Enterprise bilan ma\'lumotlar almashinmoqda...';
    });

    final success = await widget.api.trigger1CSync();

    if (mounted) {
      setState(() {
        _syncing = false;
        _syncResult = success
            ? '✅ 1C tovarlar bazasi muvaffaqiyatli sinxronlandi va ERPNext omboriga kiritildi!'
            : '❌ Sinxronlashda xatolik yuz berdi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Tashqi Dasturlar Integratsiya Qatlami',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'ERPNext Core (Headless) + Integratsiya Gateway (Proprietary Layer)',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // ERPNext Core Card
          _buildIntegrationTile(
            title: 'ERPNext Core Backend (Headless Engine)',
            subtitle: 'Buxgalteriya, ikki tomonlama yozuv va ombor qoldig\'i hisobi',
            statusText: 'Faol (REST API)',
            statusColor: Colors.green,
            icon: Icons.dns_outlined,
          ),
          const SizedBox(height: 12),

          // 1C Card with Sync Action
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.amber.withValues(alpha: 0.15),
                        foregroundColor: Colors.amber[900],
                        child: const Icon(Icons.sync_alt),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('1C: Predpriyatiye (8.3 / Enterprise)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Tovarlar katalogi, qoldiqlar va schyot-fakturalar almashinuvi', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _syncing ? null : _handle1CSync,
                        icon: _syncing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh),
                        label: const Text('1C Sinxronlash'),
                      ),
                    ],
                  ),
                  if (_syncResult.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      _syncResult,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _syncResult.startsWith('✅') ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Payme & Click
          _buildIntegrationTile(
            title: 'Payme Merchant API Gateway',
            subtitle: 'Onlayn to\'lovlar avtomatik ERPNext "Payment Entry"ga konvertatsiya qilinadi',
            statusText: 'Faol (Webhook ulangan)',
            statusColor: Colors.teal,
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 12),

          _buildIntegrationTile(
            title: 'Click Merchant API Gateway',
            subtitle: 'Barcha Click to\'lovlari real-time rejimda tekshiriladi va tasdiqlanadi',
            statusText: 'Faol (Webhook ulangan)',
            statusColor: Colors.blue,
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 12),

          // Telegram
          _buildIntegrationTile(
            title: 'Telegram Bot Xabarnomalar',
            subtitle: 'Katta sotuvlar, past ombor qoldiqlari va hisobotlar Telegram guruhga yuboriladi',
            statusText: 'Tayyor',
            statusColor: Colors.lightBlue,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 24),

          // Architecture Summary Alert Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.indigo, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Litsenziya Xavfsizligi Kafolatlangan (License Isolation)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ushbu Flutter ilovasi va Node.js Gateway faqat tashqi HTTP REST API orqali bog\'langan. '
                        'GPL-3.0 litsenziyasi sizning dasturingizga o\'tmaydi. Butun ekotizim to\'liq sizning xususiy (proprietary) intellektual mulkingiz hisoblanadi.',
                        style: TextStyle(fontSize: 13, color: Colors.indigo[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationTile({
    required String title,
    required String subtitle,
    required String statusText,
    required Color statusColor,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          foregroundColor: statusColor,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
