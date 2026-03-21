// Challenge: Performance — Product Catalog
//
// A catalog of 2 000 products with real-time search and category filtering,
// sorted by price. Run and profile it with Flutter DevTools.
//
// Concepts in play: work in build(), lazy list rendering, conditional setState.
//
// Known issues (3 bugs):
//   - Typing in the search box causes noticeable frame drops on every keystroke.
//   - The initial render is slow — all items are built before the first frame appears.
//   - Rebuilds are triggered even when neither the query nor the category changed.

import 'package:flutter/material.dart';

void main() => runApp(const CatalogApp());

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Product Catalog',
        theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
        home: const CatalogScreen(),
      );
}

class Product {
  final int id;
  final String name;
  final String category;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });
}

List<Product> _generateProducts() {
  final categories = ['Electronics', 'Clothing', 'Food', 'Books', 'Sports'];
  return List.generate(2000, (i) => Product(
        id: i,
        name: 'Product $i',
        category: categories[i % categories.length],
        price: (i % 100) + 9.99,
      ));
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Product> _allProducts = _generateProducts();
  String _query = '';
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Electronics', 'Clothing', 'Food', 'Books', 'Sports'];

  void _onSearch(String value) {
    setState(() => _query = value);
  }

  void _onCategory(String? value) {
    if (value != null) setState(() => _selectedCategory = value);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allProducts
        .where((p) =>
            (_selectedCategory == 'All' || p.category == _selectedCategory) &&
            p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearch,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _onCategory,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${filtered.length} results'),
            ),
          ),
          Expanded(
            child: ListView(
              children: filtered
                  .map((p) => ListTile(
                        title: Text(p.name),
                        subtitle: Text(p.category),
                        trailing: Text('\$${p.price.toStringAsFixed(2)}'),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
