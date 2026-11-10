import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DashboardView extends StatefulWidget {
  final ApiService api;
  final VoidCallback onNavigateToSales;
  final VoidCallback onNavigateToCatalog;

  const DashboardView({
    super.key,
    required this.api,
    required this.onNavigateToSales,
    required this.onNavigateToCatalog,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  DashboardStats? _stats;
  List<SalesOrder> _recentOrders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await widget.api.getDashboard();
    final orders = await widget.api.getSalesOrders();
    if (mounted) {
      setState(() {
        _stats = stats;
        _recentOrders = orders.take(5).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ERP Boshqaruv Paneli',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Headless ERPNext Core + Maxsus Xususiy Ekotizim',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Yangilash'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Cards Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiCard(
                context,
                title: 'Jami Daromad',
                value: currency.format(_stats?.totalRevenue ?? 0),
                icon: Icons.account_balance_wallet,
                color: Colors.teal,
              ),
              _buildKpiCard(
                context,
                title: 'Buyurtmalar Soni',
                value: '${_stats?.ordersCount ?? 0}',
                icon: Icons.shopping_cart_checkout,
                color: Colors.indigo,
              ),
              _buildKpiCard(
                context,
                title: 'Katalog Mahsulotlari',
                value: '${_stats?.itemsCount ?? 0}',
                icon: Icons.inventory_2,
                color: Colors.blueAccent,
              ),
              _buildKpiCard(
                context,
                title: 'Mijozlar Bazasi',
                value: '${_stats?.customersCount ?? 0}',
                icon: Icons.people_alt,
                color: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick actions
          Text(
            'Tezkor Harakatlar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  color: Colors.indigo.withValues(alpha: 0.08),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.add_shopping_cart),
                    ),
                    title: const Text('Yangi Sotuv / POS', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Buyurtma yaratish va qabul qilish'),
                    onTap: widget.onNavigateToSales,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 0,
                  color: Colors.teal.withValues(alpha: 0.08),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.add_box),
                    ),
                    title: const Text('Omborga Tovar Qo\'shish', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Yangi mahsulot kartasini ochish'),
                    onTap: widget.onNavigateToCatalog,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Orders Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oxirgi Sotuv Buyurtmalari',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: widget.onNavigateToSales,
                child: const Text('Barchasini ko\'rish ->'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentOrders.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final o = _recentOrders[idx];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.receipt_long),
                  ),
                  title: Text(
                    '${o.name} • ${o.customerName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Sana: ${o.transactionDate} • ${o.items.length} ta pozitsiya'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency.format(o.grandTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(
                          o.status,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: o.status == 'Completed'
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.blue.withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
