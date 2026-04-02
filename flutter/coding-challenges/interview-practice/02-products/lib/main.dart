import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ❌ Everything in one file. No separation.

void main() => runApp(const MaterialApp(home: ProductsScreen()));

class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final String category;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.category,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'],
      category: json['category'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

class ProductResponse {
  final List<Product> products;
  final int total;

  ProductResponse({required this.products, required this.total});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['products'] as List).map((e) => Product.fromJson(e)).toList(),
      total: json['total'],
    );
  }
}

// ❌ Algorithm stub — implement greedy knapsack
int maxProductsInBudget(List<Product> products, double budget) {
  return 0;
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // ❌ Network logic inside the widget
  Future<void> _fetch() async {
    setState(() { isLoading = true; error = null; });
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products?limit=30'),
      );
      if (response.statusCode == 200) {
        final parsed = ProductResponse.fromJson(jsonDecode(response.body));
        setState(() { products = parsed.products; isLoading = false; });
      } else {
        setState(() { error = 'Status ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              final count = maxProductsInBudget(products, 100.0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Max products for \$100: $count')),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(p.thumbnail, fit: BoxFit.cover, width: double.infinity),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('\$${p.price.toStringAsFixed(2)}'),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    Text(' ${p.rating}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
