import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/dashboard_view.dart';
import 'screens/pos_terminal_view.dart';
import 'screens/sales_view.dart';
import 'screens/catalog_view.dart';
import 'screens/customers_view.dart';
import 'screens/integrations_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ERPEcosystemApp());
}

class ERPEcosystemApp extends StatelessWidget {
  const ERPEcosystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Enterprise Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Corporate Royal Navy
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final pages = [
      DashboardView(
        api: _api,
        onNavigateToSales: () => setState(() => _selectedIndex = 1),
        onNavigateToCatalog: () => setState(() => _selectedIndex = 3),
      ),
      PosTerminalView(api: _api), // Tab 1: POS Terminal
      SalesView(api: _api),       // Tab 2: Sales Orders
      CatalogView(api: _api),     // Tab 3: Catalog & Stock
      CustomersView(api: _api),   // Tab 4: Customers & CRM
      IntegrationsView(api: _api),// Tab 5: Integrations
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              extended: MediaQuery.of(context).size.width >= 1100,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.hub_outlined),
                    ),
                    if (MediaQuery.of(context).size.width >= 1100) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'AXION ERP',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Boshqaruv'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale),
                  label: Text('POS Kassa'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('Buyurtmalar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Ombor'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Mijozlar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.extension_outlined),
                  selectedIcon: Icon(Icons.extension),
                  label: Text('Integratsiyalar'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Boshqaruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'POS',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Sotuvlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Ombor',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Mijozlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension),
            label: 'Integratsiya',
          ),
        ],
      ),
    );
  }
}
