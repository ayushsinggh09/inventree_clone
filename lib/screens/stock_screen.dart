import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<dynamic> _stockItems = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  Future<void> _loadStock() async {
    setState(() => _loading = true);
    final stock = await ApiService.getStockItems();
    setState(() {
      _stockItems = stock;
      _filtered = stock;
      _loading = false;
    });
  }

  void _search(String query) {
    setState(() {
      _filtered = _stockItems.where((item) {
        final part = item['part_detail']?['name']?.toString().toLowerCase() ?? '';
        final location = item['location_detail']?['name']?.toString().toLowerCase() ?? '';
        return part.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase());
      }).toList();
    });
  }

  Color _getStockColor(dynamic quantity) {
    final qty = (quantity ?? 0).toDouble();
    if (qty <= 0) return Colors.red;
    if (qty <= 5) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStockStatus(dynamic quantity) {
    final qty = (quantity ?? 0).toDouble();
    if (qty <= 0) return 'Out of Stock';
    if (qty <= 5) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
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
                'Stock Items',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Search bar
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  onChanged: _search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search stock...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _loadStock,
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
              : _filtered.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_outlined,
                    size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'No stock items found',
                  style:
                  TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_filtered.length} stock items found',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('PART',
                            style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('LOCATION',
                            style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Expanded(
                        child: Text('QUANTITY',
                            style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Expanded(
                        child: Text('STATUS',
                            style: TextStyle(
                                color: Color(0xFF06B6D4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Stock list
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      final quantity = item['quantity'] ?? 0;
                      final partName =
                          item['part_detail']?['name'] ?? 'Unknown Part';
                      final locationName =
                          item['location_detail']?['name'] ?? 'No Location';
                      final stockColor = _getStockColor(quantity);
                      final stockStatus = _getStockStatus(quantity);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            // Part name
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF06B6D4)
                                          .withOpacity(0.2),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.inventory_rounded,
                                        color: Color(0xFF06B6D4),
                                        size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      partName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Location
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      color: Colors.white38, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      locationName,
                                      style: const TextStyle(
                                          color: Colors.white54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity
                            Expanded(
                              child: Text(
                                '$quantity',
                                style: TextStyle(
                                  color: stockColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // Status badge
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                  stockColor.withOpacity(0.2),
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                                child: Text(
                                  stockStatus,
                                  style: TextStyle(
                                    color: stockColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}