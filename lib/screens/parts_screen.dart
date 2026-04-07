import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  List<dynamic> _parts = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  Future<void> _loadParts() async {
    setState(() => _loading = true);
    final parts = await ApiService.getParts();
    setState(() {
      _parts = parts;
      _filtered = parts;
      _loading = false;
    });
  }

  void _search(String query) {
    setState(() {
      _filtered = _parts.where((part) {
        final name = part['name']?.toString().toLowerCase() ?? '';
        final desc = part['description']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            desc.contains(query.toLowerCase());
      }).toList();
    });
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
                'Parts',
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
                    hintText: 'Search parts...',
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
                onPressed: _loadParts,
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
                Icon(Icons.category_outlined,
                    size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'No parts found',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
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
                  '${_filtered.length} parts found',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text('NAME',
                              style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      Expanded(
                          flex: 3,
                          child: Text('DESCRIPTION',
                              style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      Expanded(
                          child: Text('STOCK',
                              style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      Expanded(
                          child: Text('ACTIVE',
                              style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Parts list
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final part = _filtered[index];
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
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C3AED)
                                          .withOpacity(0.2),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.category_rounded,
                                        color: Color(0xFF7C3AED),
                                        size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      part['name'] ?? 'N/A',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                part['description'] ?? '-',
                                style: const TextStyle(
                                    color: Colors.white54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${part['total_in_stock'] ?? 0}',
                                style: TextStyle(
                                  color: (part['total_in_stock'] ?? 0) > 0
                                      ? const Color(0xFF10B981)
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (part['active'] == true)
                                      ? const Color(0xFF10B981)
                                      .withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (part['active'] == true)
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    color: (part['active'] == true)
                                        ? const Color(0xFF10B981)
                                        : Colors.red,
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