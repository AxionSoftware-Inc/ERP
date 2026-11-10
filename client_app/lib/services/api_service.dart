import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:4000/api/v1'});

  // -------------------------------------------------------------
  // Dashboard Stats
  // -------------------------------------------------------------
  Future<DashboardStats> getDashboard() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sales/dashboard'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          return DashboardStats.fromJson(body['data']);
        }
      }
    } catch (e) {
      // ignore
    }
    return DashboardStats(
      totalRevenue: 15150.0,
      ordersCount: 3,
      itemsCount: 6,
      customersCount: 4,
      lowStockCount: 1,
    );
  }

  // -------------------------------------------------------------
  // Catalog Items
  // -------------------------------------------------------------
  Future<List<Item>> getItems() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/catalog/items'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final list = body['data'] as List;
          return list.map((e) => Item.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<Item?> createItem(Item item) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/catalog/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return Item.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // -------------------------------------------------------------
  // Customers
  // -------------------------------------------------------------
  Future<List<Customer>> getCustomers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/crm/customers'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final list = body['data'] as List;
          return list.map((e) => Customer.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<Customer?> createCustomer({
    required String customerName,
    required String mobileNo,
    required String territory,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/crm/customers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_name': customerName,
          'mobile_no': mobileNo,
          'territory': territory,
        }),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return Customer.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // -------------------------------------------------------------
  // Sales Orders
  // -------------------------------------------------------------
  Future<List<SalesOrder>> getSalesOrders() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sales/orders'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final list = body['data'] as List;
          return list.map((e) => SalesOrder.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<SalesOrder?> createSalesOrder({
    required String customer,
    required String customerName,
    required List<SalesOrderItem> items,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/sales/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer': customer,
          'customer_name': customerName,
          'items': items.map((i) => i.toJson()).toList(),
        }),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return SalesOrder.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // -------------------------------------------------------------
  // 1C Sync Trigger
  // -------------------------------------------------------------
  Future<bool> trigger1CSync() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/integrations/1c/sync-catalog'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'goods': [
            {
              'code': '1C-SYNC-01',
              'name': '1C Tovarlar Bazasi Sinxron Partiyasi',
              'price': 450.0,
              'stock': 100.0,
              'category': '1C Baza',
            }
          ]
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
