import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ❌ Everything in one file. No separation.

void main() => runApp(const MaterialApp(home: RecipesScreen()));

class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficulty;
  final String cuisine;
  final String image;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.cuisine,
    required this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      prepTimeMinutes: json['prepTimeMinutes'],
      cookTimeMinutes: json['cookTimeMinutes'],
      difficulty: json['difficulty'],
      cuisine: json['cuisine'],
      image: json['image'],
    );
  }
}

// ❌ Algorithm stub — implement this
Map<String, double> avgPrepByDifficulty(List<Recipe> recipes) {
  return {};
}

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<Recipe> recipes = [];
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
        Uri.parse('https://dummyjson.com/recipes?limit=20'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['recipes'] as List).map((e) => Recipe.fromJson(e)).toList();
        setState(() { recipes = list; isLoading = false; });
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
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              final stats = avgPrepByDifficulty(recipes);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Avg Prep Time by Difficulty'),
                  content: Text(stats.isEmpty
                      ? 'Not implemented yet'
                      : stats.entries.map((e) => '${e.key}: ${e.value.toStringAsFixed(1)} min').join('\n')),
                ),
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
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final r = recipes[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(r.image, width: 56, height: 56, fit: BoxFit.cover),
                      ),
                      title: Text(r.name),
                      subtitle: Text('${r.cuisine} · ${r.difficulty} · ${r.prepTimeMinutes + r.cookTimeMinutes} min'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // ❌ Detail screen inline — should be a separate widget
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: Text(r.name)),
                            body: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(r.image, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Prep: ${r.prepTimeMinutes} min · Cook: ${r.cookTimeMinutes} min'),
                                  const SizedBox(height: 8),
                                  Text('Difficulty: ${r.difficulty}'),
                                  const SizedBox(height: 16),
                                  const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...r.ingredients.map((i) => Text('• $i')),
                                ],
                              ),
                            ),
                          ),
                        ));
                      },
                    );
                  },
                ),
    );
  }
}
