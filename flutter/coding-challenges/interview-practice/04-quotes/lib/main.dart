import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ❌ Everything in one file. No separation.

void main() => runApp(MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const QuotesScreen(),
    ));

class Quote {
  final int id;
  final String quote;
  final String author;

  Quote({required this.id, required this.quote, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      quote: json['quote'],
      author: json['author'],
    );
  }
}

// ❌ Algorithm stub — implement longest increasing subsequence of quote lengths
int longestIncreasingSubsequence(List<Quote> quotes) {
  return 0;
}

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  List<Quote> quotes = [];
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
        Uri.parse('https://dummyjson.com/quotes?limit=30'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['quotes'] as List).map((e) => Quote.fromJson(e)).toList();
        setState(() { quotes = list; isLoading = false; });
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
        title: const Text('Quotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              final lis = longestIncreasingSubsequence(quotes);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('LIS of quote lengths: $lis')),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final q = quotes[index];
                    // ❌ Card UI inline — should be a separate QuoteCard widget
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${q.quote}"',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '— ${q.author}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
