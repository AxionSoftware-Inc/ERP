import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class SalesView extends StatefulWidget {
  final ApiService api;

  const SalesView({super.key, required this.api});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  List<SalesOrder> _orders = [];
  List<Customer> _customers = [];
  List<Item> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final orders = await widget.api.getSalesOrders();
    final customers = await widget.api.getCustomers();
    final items = await widget.api.getItems();
    if (mounted) {
      setState(() {
        _orders = orders;
        _customers = customers;
        _items = items;
        _loading = false;
      });
    }
  }

  void _showCreateOrderDialog() {
    if (_customers.isEmpty || _items.isEmpty) return;

    Customer selectedCustomer = _customers.first;
    Item selectedItem = _items.first;
    double qty = 1;
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (builderCtx, setDialogState) {
            final total = qty * selectedItem.standardRate;

            return AlertDialog(
              title: const Text('Yangi Sotuv Buyurtmasi Yaratish'),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mijozni tanlang:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Customer>(
                      initialValue: selectedCustomer,
                      items: _customers.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text('${c.customerName} (${c.territory})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCustomer = val);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Mahsulotni tanlang:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Item>(
                      initialValue: selectedItem,
                      items: _items.map((it) {
                        return DropdownMenuItem(
                          value: it,
                          child: Text('${it.itemName} • ${currency.format(it.standardRate)} (Qoldiq: ${it.actualQty.toInt()})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedItem = val);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Miqdor (dona):', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          onPressed: qty > 1 ? () => setDialogState(() => qty--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${qty.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setDialogState(() => qty++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jami summa:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(currency.format(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Bekor qilish'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    final created = await widget.api.createSalesOrder(
                      customer: selectedCustomer.name,
                      customerName: selectedCustomer.customerName,
                      items: [
                        SalesOrderItem(
                          itemCode: selectedItem.itemCode,
                          itemName: selectedItem.itemName,
                          qty: qty,
                          rate: selectedItem.standardRate,
                          amount: total,
                        ),
                      ],
                    );
                    if (created != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Buyurtma saqlandi: ${created.name}')),
                      );
                      _load();
                    }
                  },
                  child: const Text('Tasdiqlash va Saqlash'),
                ),
              ],
            );
          },
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
                        'Sotuvlar & Buyurtmalar',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: _showCreateOrderDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Yangi Buyurtma (POS)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        itemCount: _orders.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final o = _orders[idx];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                              foregroundColor: Colors.indigo,
                              child: const Icon(Icons.shopping_bag_outlined),
                            ),
                            title: Text(
                              '${o.name} • ${o.customerName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Sana: ${o.transactionDate} | Tovarlar: ${o.items.map((i) => '${i.itemName} (x${i.qty.toInt()})').join(', ')}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currency.format(o.grandTotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(
                                    o.status,
                                    style: const TextStyle(fontSize: 11),
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
                  ),
                ],
              ),
            ),
    );
  }
}
