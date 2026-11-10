class DashboardStats {
  final double totalRevenue;
  final int ordersCount;
  final int itemsCount;
  final int customersCount;
  final int lowStockCount;

  DashboardStats({
    required this.totalRevenue,
    required this.ordersCount,
    required this.itemsCount,
    required this.customersCount,
    required this.lowStockCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      ordersCount: json['ordersCount'] ?? 0,
      itemsCount: json['itemsCount'] ?? 0,
      customersCount: json['customersCount'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
    );
  }
}

class Item {
  final String name;
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String stockUom;
  final double standardRate;
  final double actualQty;
  final String description;

  Item({
    required this.name,
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.stockUom,
    required this.standardRate,
    required this.actualQty,
    this.description = '',
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] ?? '',
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      itemGroup: json['item_group'] ?? 'General',
      stockUom: json['stock_uom'] ?? 'Nos',
      standardRate: (json['standard_rate'] as num?)?.toDouble() ?? 0.0,
      actualQty: (json['actual_qty'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'item_name': itemName,
    'item_group': itemGroup,
    'stock_uom': stockUom,
    'standard_rate': standardRate,
    'actual_qty': actualQty,
    'description': description,
  };
}

class Customer {
  final String name;
  final String customerName;
  final String customerGroup;
  final String territory;
  final String emailId;
  final String mobileNo;
  final double outstandingAmount;

  Customer({
    required this.name,
    required this.customerName,
    required this.customerGroup,
    required this.territory,
    required this.emailId,
    required this.mobileNo,
    required this.outstandingAmount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerGroup: json['customer_group'] ?? 'Commercial',
      territory: json['territory'] ?? 'Uzbekistan',
      emailId: json['email_id'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesOrder {
  final String name;
  final String customer;
  final String customerName;
  final String transactionDate;
  final String deliveryDate;
  final double grandTotal;
  final String status;
  final List<SalesOrderItem> items;

  SalesOrder({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.transactionDate,
    required this.deliveryDate,
    required this.grandTotal,
    required this.status,
    required this.items,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      name: json['name'] ?? '',
      customer: json['customer'] ?? '',
      customerName: json['customer_name'] ?? (json['customer'] ?? ''),
      transactionDate: json['transaction_date'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Draft',
      items: (json['items'] as List<dynamic>?)
              ?.map((it) => SalesOrderItem.fromJson(it))
              .toList() ??
          [],
    );
  }
}

class SalesOrderItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final double rate;
  final double amount;

  SalesOrderItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? (json['item_code'] ?? ''),
      qty: (json['qty'] as num?)?.toDouble() ?? 1.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'item_name': itemName,
    'qty': qty,
    'rate': rate,
  };
}
