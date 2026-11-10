import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PosTerminalView extends StatefulWidget {
  final ApiService api;

  const PosTerminalView({super.key, required this.api});

  @override
  State<PosTerminalView> createState() => _PosTerminalViewState();
}

class _PosTerminalViewState extends State<PosTerminalView> {
  List<Item> _items = [];
  List<Customer> _customers = [];
  final Map<String, int> _cart = {}; // itemCode -> qty
  bool _loading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Barchasi';
  String _currency = 'USD'; // 'USD' or 'UZS'
  double _exchangeRate = 12850.0;

  Customer? _selectedCustomer;
  String _paymentMethod = 'Naqd'; // 'Naqd', 'Karta', 'Nasiya (Qarz)', 'Payme', 'Click'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await widget.api.getItems();
    final customers = await widget.api.getCustomers();
    final rate = await widget.api.getExchangeRate();
    if (mounted) {
      setState(() {
        _items = items;
        _customers = customers;
        _exchangeRate = rate;
        if (customers.isNotEmpty) {
          _selectedCustomer = customers.first;
        }
        _loading = false;
      });
    }
  }

  double _convertPrice(double usdPrice) {
    if (_currency == 'UZS') {
      return usdPrice * _exchangeRate;
    }
    return usdPrice;
  }

  String _formatPrice(double usdPrice) {
    final converted = _convertPrice(usdPrice);
    if (_currency == 'UZS') {
      final f = NumberFormat('#,###', 'uz_UZ');
      return '${f.format(converted)} so\'m';
    } else {
      final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
      return f.format(converted);
    }
  }

  double get _cartTotalUsd {
    double sum = 0;
    for (final entry in _cart.entries) {
      final item = _items.firstWhere((it) => it.itemCode == entry.key);
      sum += item.standardRate * entry.value;
    }
    return sum;
  }

  void _addToCart(Item item) {
    if (item.actualQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Ushbu tovar omborda tugagan!')),
      );
      return;
    }
    setState(() {
      final current = _cart[item.itemCode] ?? 0;
      if (current < item.actualQty) {
        _cart[item.itemCode] = current + 1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Ombor qoldig\'idan ortiq qo\'shib bo\'lmaydi!')),
        );
      }
    });
  }

  void _removeFromCart(String itemCode) {
    setState(() {
      final current = _cart[itemCode] ?? 0;
      if (current > 1) {
        _cart[itemCode] = current - 1;
      } else {
        _cart.remove(itemCode);
      }
    });
  }

  Future<void> _processCheckout() async {
    if (_cart.isEmpty) return;

    final cartItems = _cart.entries.map((entry) {
      final item = _items.firstWhere((it) => it.itemCode == entry.key);
      return SalesOrderItem(
        itemCode: item.itemCode,
        itemName: item.itemName,
        qty: entry.value.toDouble(),
        rate: item.standardRate,
        amount: item.standardRate * entry.value,
      );
    }).toList();

    final result = await widget.api.posCheckout(
      customer: _selectedCustomer?.name ?? 'CUST-0001',
      customerName: _selectedCustomer?.customerName ?? 'Tezkor Xaridor',
      items: cartItems,
      paymentMethod: _paymentMethod,
      currency: _currency,
    );

    if (result != null && mounted) {
      setState(() {
        _cart.clear();
      });

      _showReceiptDialog(result['receipt']);
      _load(); // Refresh stock
    }
  }

  void _showReceiptDialog(Map<String, dynamic> receipt) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Savdo Muvaffaqiyatli!'),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'ELEKTRON CHEK #${receipt['receipt_no']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                const Divider(height: 24),
                Text('Mijoz: ${receipt['customer_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('To\'lov turi: ${receipt['payment_method']}'),
                Text('Sana: ${receipt['timestamp'].toString().substring(0, 16).replaceAll('T', ' ')}'),
                const Divider(height: 24),
                const Text('Xarid qilingan tovarlar:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...((receipt['items'] as List).map((it) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${it['item_name']} (x${(it['qty'] as num).toInt()})')),
                        Text(_formatPrice((it['amount'] as num).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                })),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('JAMI SUMMA:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      _formatPrice((receipt['grand_total'] as num).toDouble()),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                    ),
                  ],
                ),
                if ((receipt['debt_amount'] as num) > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nasiya / Qarz:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text(
                        _formatPrice((receipt['debt_amount'] as num).toDouble()),
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.print),
              label: const Text('Chop etish / Yopish'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = ['Barchasi', ..._items.map((e) => e.itemGroup).toSet()];
    final filteredItems = _items.where((it) {
      final matchesSearch = it.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          it.itemCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'Barchasi' || it.itemGroup == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kassa & Tezkor Savdo Terminali', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Currency Switcher
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('USD (\$)'),
                  selected: _currency == 'USD',
                  onSelected: (val) => setState(() => _currency = 'USD'),
                ),
                ChoiceChip(
                  label: const Text('UZS (so\'m)'),
                  selected: _currency == 'UZS',
                  onSelected: (val) => setState(() => _currency = 'UZS'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: _buildCatalogSection(filteredItems, categories)),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _buildCartSection()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildCatalogSection(filteredItems, categories)),
                const Divider(height: 1),
                SizedBox(height: 320, child: _buildCartSection()),
              ],
            ),
    );
  }

  Widget _buildCatalogSection(List<Item> items, List<String> categories) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Tovar nomi yoki shtrix-kod orqali qidirish...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Items Grid
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Tovarlar topilmadi'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      final inCart = _cart[item.itemCode] ?? 0;
                      final isOutOfStock = item.actualQty <= 0;

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: inCart > 0 ? Colors.indigo : Colors.grey.withValues(alpha: 0.2),
                            width: inCart > 0 ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: isOutOfStock ? null : () => _addToCart(item),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                                      child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.indigo),
                                    ),
                                    if (inCart > 0)
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.indigo,
                                        child: Text('$inCart', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  item.itemName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qoldiq: ${item.actualQty.toInt()} ${item.stockUom}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isOutOfStock ? Colors.red : (item.actualQty < 15 ? Colors.orange[800] : Colors.green[800]),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatPrice(item.standardRate),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Xarid Savatchasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (_cart.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _cart.clear()),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Tozalash'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer selection
          DropdownButtonFormField<Customer>(
            initialValue: _selectedCustomer,
            items: _customers.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text('${c.customerName} (${c.territory})', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedCustomer = val),
            decoration: const InputDecoration(
              labelText: 'Mijoz',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),

          // Cart Items List
          Expanded(
            child: _cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Savatcha bo\'sh. Katalogdan tovar tanlang.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView(
                    children: _cart.entries.map((entry) {
                      final item = _items.firstWhere((it) => it.itemCode == entry.key);
                      final total = item.standardRate * entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(_formatPrice(item.standardRate), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => _removeFromCart(item.itemCode),
                            ),
                            Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => _addToCart(item),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                _formatPrice(total),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const Divider(height: 24),

          // Payment method picker
          Wrap(
            spacing: 8,
            children: ['Naqd', 'Karta', 'Nasiya (Qarz)', 'Payme', 'Click'].map((method) {
              final isSelected = _paymentMethod == method;
              return ChoiceChip(
                label: Text(method),
                selected: isSelected,
                selectedColor: Colors.indigo.withValues(alpha: 0.2),
                onSelected: (val) {
                  if (val) setState(() => _paymentMethod = method);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Total & Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jami to\'lov:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                _formatPrice(_cartTotalUsd),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _cart.isEmpty ? null : _processCheckout,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                'To\'lovni Qabul Qilish (${_formatPrice(_cartTotalUsd)})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
