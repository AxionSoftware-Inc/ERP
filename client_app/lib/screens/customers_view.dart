import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CustomersView extends StatefulWidget {
  final ApiService api;

  const CustomersView({super.key, required this.api});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  List<Customer> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final customers = await widget.api.getCustomers();
    if (mounted) {
      setState(() {
        _customers = customers;
        _loading = false;
      });
    }
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+998 ');
    final territoryCtrl = TextEditingController(text: 'Toshkent');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yangi Mijoz Kiritish'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Kompaniya / Mijoz Nomi', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Telefon Raqam', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: territoryCtrl,
                  decoration: const InputDecoration(labelText: 'Hudud / Manzil', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                Navigator.pop(context);
                await widget.api.createCustomer(
                  customerName: nameCtrl.text,
                  mobileNo: phoneCtrl.text,
                  territory: territoryCtrl.text,
                );
                _load();
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mijozlar & Kontragentlar',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: _showAddCustomerDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Yangi Mijoz'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        itemCount: _customers.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final c = _customers[idx];
                          final hasDebt = c.outstandingAmount > 0;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                              foregroundColor: Colors.deepPurple,
                              child: const Icon(Icons.business_center_outlined),
                            ),
                            title: Text(
                              c.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Tel: ${c.mobileNo} • Hudud: ${c.territory}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  hasDebt ? 'Qarzdorlik: ${currency.format(c.outstandingAmount)}' : 'Balans: 0.00 \$',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: hasDebt ? Colors.red[700] : Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.customerGroup,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
