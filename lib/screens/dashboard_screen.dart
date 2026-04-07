import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import 'parts_screen.dart';
import 'stock_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats = await ApiService.getDashboardStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: const Color(0xFF16213E),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Row(
                    children: [
                      Icon(Icons.inventory_2_rounded,
                          color: Color(0xFF7C3AED), size: 32),
                      SizedBox(width: 12),
                      Text(
                        'InvenTree',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                // Nav items
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavItem(
                  icon: Icons.category_rounded,
                  label: 'Parts',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _NavItem(
                  icon: Icons.inventory_rounded,
                  label: 'Stock',
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const Spacer(),
                const Divider(color: Colors.white12),
                // Logout
                _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  selected: false,
                  onTap: _logout,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const PartsScreen();
      case 2:
        return const StockScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          color: const Color(0xFF16213E),
          child: Row(
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _loading
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Stats grid
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Total Parts',
                      value: '${_stats['total_parts'] ?? 0}',
                      icon: Icons.category_rounded,
                      color: const Color(0xFF7C3AED),
                    ),
                    StatCard(
                      title: 'Stock Items',
                      value: '${_stats['total_stock'] ?? 0}',
                      icon: Icons.inventory_rounded,
                      color: const Color(0xFF06B6D4),
                    ),
                    StatCard(
                      title: 'Locations',
                      value: '${_stats['total_locations'] ?? 0}',
                      icon: Icons.location_on_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    StatCard(
                      title: 'Categories',
                      value: '${_stats['total_categories'] ?? 0}',
                      icon: Icons.folder_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Quick actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _QuickAction(
                      icon: Icons.category_rounded,
                      label: 'View Parts',
                      color: const Color(0xFF7C3AED),
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                    const SizedBox(width: 16),
                    _QuickAction(
                      icon: Icons.inventory_rounded,
                      label: 'View Stock',
                      color: const Color(0xFF06B6D4),
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C3AED).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? const Color(0xFF7C3AED) : Colors.white54,
                size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}